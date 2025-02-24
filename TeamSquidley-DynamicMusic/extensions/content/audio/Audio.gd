extends "res://systems/audio/Audio.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

var additionalMineAmbience: AudioStreamPlayer

var player_battleMusicStartingSound: AudioStreamPlayer # based on wave number ?

var player_battleMusicDefault: AudioStreamPlayer
var player_battleMusicMonstersWeight: AudioStreamPlayer # monster amount
var player_battleMusicMonstersWeight2: AudioStreamPlayer # monster amount

# amount of life + cobalt * heal < threshold -> plays music ?
var player_battleMusicTotalHp: AudioStreamPlayer # % of life AND considering cobalt
var player_battleMusicStrongestEnemy: AudioStreamPlayer # strongest enemy

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

var player_droplet: AudioStreamPlayer

# Arbitrary numbers
const WEIGHT_CAP1 := 5
const WEIGHT_CAP2 := 8
const HP_CAP := 400

var allBattleMusicsPlayers: Array[AudioStreamPlayer]

const BUS_CAVE_EFFECTS_NAME := "CaveEffects"
const BUS_CAVE_EFFECTS_ID := 1

signal monsters_total_change(value: int, kill: bool)
signal monsters_big_monster_spawn(activate: bool)
signal hp_change(value: int, hp_loss: bool)
signal should_droplet_sound(reverb_magnitude: float)

var has_hp_faded_in: bool = false

var MusicTween: Tween

func _ready():
	super._ready()
	
	#region Buscreation
	AudioServer.add_bus(BUS_CAVE_EFFECTS_ID)
	AudioServer.set_bus_name(BUS_CAVE_EFFECTS_ID, BUS_CAVE_EFFECTS_NAME)
	AudioServer.set_bus_volume_db(BUS_CAVE_EFFECTS_ID, 0.0)
	var reverb = AudioEffectReverb.new()
	AudioServer.add_bus_effect(BUS_CAVE_EFFECTS_ID, reverb)
	#endregion
	
	
	#region Creating and registering audio players
	player_battleMusicStartingSound = generateMusicPlayer()
	player_battleMusicDefault = generateMusicPlayer()
	player_battleMusicDefault.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 1.mp3")
	player_battleMusicMonstersWeight = generateMusicPlayer()
	player_battleMusicMonstersWeight.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 2.mp3")
	player_battleMusicMonstersWeight2 = generateMusicPlayer()
	player_battleMusicTotalHp = generateMusicPlayer()
	player_battleMusicTotalHp.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 3.mp3")
	player_battleMusicStrongestEnemy = generateMusicPlayer()
	#battleMusicStrongestEnemy.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 3.mp3")
	add_child(player_battleMusicStartingSound)
	add_child(player_battleMusicDefault)
	add_child(player_battleMusicMonstersWeight)
	add_child(player_battleMusicMonstersWeight2)
	add_child(player_battleMusicTotalHp)
	add_child(player_battleMusicStrongestEnemy)
	
	allBattleMusicsPlayers = [
		player_battleMusicStartingSound,
		player_battleMusicDefault,
		player_battleMusicMonstersWeight,
		player_battleMusicMonstersWeight2,
		player_battleMusicTotalHp,
		player_battleMusicStrongestEnemy
	]
	
	player_droplet = generateCaveEffectPlayer()
	player_droplet.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water.ogg")
	
	#endregion
	
	# add effects to that bus
	
	MusicTween = create_tween()
	monsters_total_change.connect(set_music_based_on_monster_total_weight)
	monsters_big_monster_spawn.connect(set_music_based_on_strongest_monster)
	should_droplet_sound.connect(play_droplet_sound)
	hp_change.connect(set_music_based_on_hp)

func generateMusicPlayer() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.autoplay = false
	player.bus = &"Music"
	player.volume_db = -60
	player.stop()
	return player
	
func generateCaveEffectPlayer() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.autoplay = false
	player.bus = BUS_CAVE_EFFECTS_NAME
	player.volume_db = 0
	return player

func playTrack(track,delay:=0.0):
	$Music.stop()
	if currentTrackList.is_empty():
		Logger.error("track list is empty", "Audio.startMusic")
		return
	$Music.stream = track
	$Music.volume_db = 0
	$MusicTween.stop_all()
	$MusicTween.remove_all()
	$MusicTween.interpolate_callback($Music, delay, "play")
	$MusicTween.start()

#region Battle music
func startBattleMusic():
	super.startBattleMusic()
	# they all should start playing, even if they are muted
	player_battleMusicDefault.volume_db = 0 # by default on
	Audio.set_bus_volume("Music",0)

	# initialize music layers with default values
	set_music_based_on_monster_total_weight(0, false)
	set_music_based_on_strongest_monster(false)
	set_music_based_on_hp(CONSTMOD.getTotalHp(), false)
	
	weight1 = false
	weight2 = false
	heavy_monster_activated = false
	
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		if player == player_battleMusicDefault and Data.of("wavemeter.showcounter") == true:
			pass
		else:
			player.play(0.0)

func stopBattleMusic():
	super.stopBattleMusic()
	# stop every music, but should fade off to be less abrupt
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		fade_out_music(player)
		stop_music(player)
#endregion

#region Ambience
func playAmbienceMine():
	super.playAmbienceMine()
	# add/activate droplets/mine sound effects

func stopAmbienceMine():
	super.stopAmbienceMine()
	# stop new sounds here
#endregion

#region Events
# Should be called on monster spawn AND kill
var weight1 = false
var weight2 = false
func set_music_based_on_monster_total_weight(monsters_amount: int, monster_killed: bool):
	if monster_killed:
		if monsters_amount < WEIGHT_CAP2:
			weight2 = false
			fade_out_music(player_battleMusicMonstersWeight2)
		elif monsters_amount < WEIGHT_CAP1:
			weight1 = false
			fade_out_music(player_battleMusicMonstersWeight)
	else:
		if monsters_amount >= WEIGHT_CAP2 and not weight2:
			weight2 = true
			fade_in_music(player_battleMusicMonstersWeight2)
		elif monsters_amount < WEIGHT_CAP2 and weight2:
			weight2 = false
			fade_out_music(player_battleMusicMonstersWeight2)
		if monsters_amount >= WEIGHT_CAP1 and not weight1:
			weight1 = true
			fade_in_music(player_battleMusicMonstersWeight)
		elif monsters_amount < WEIGHT_CAP1 and weight1:
			weight1 = false
			fade_out_music(player_battleMusicMonstersWeight)

# Should be called on heavy monster spawn
var heavy_monster_activated = false
func set_music_based_on_strongest_monster(activate: bool):
	if activate and not heavy_monster_activated:
		fade_in_music(player_battleMusicStrongestEnemy)
		heavy_monster_activated = true
	if not activate and heavy_monster_activated:
		fade_out_music(player_battleMusicStrongestEnemy)
		heavy_monster_activated = false

# Should be called on any hp changes
func set_music_based_on_hp(hp: int, hp_loss: bool):
	if hp_loss and hp < HP_CAP and not has_hp_faded_in:
		fade_in_music(player_battleMusicTotalHp)
		has_hp_faded_in = true
	else:
		player_battleMusicTotalHp.volume_db = 0 if hp < HP_CAP else -60
	if hp >= HP_CAP:
		has_hp_faded_in = false

func play_droplet_sound(magnitude: float):
	if player_droplet.playing:
		return
	var reverb: AudioEffectReverb = getReverbEffectOrNull(BUS_CAVE_EFFECTS_ID)
	if reverb != null:
		reverb.room_size = magnitude
	player_droplet.play()

func getReverbEffectOrNull(bus_id: int) -> AudioEffectReverb:
	for i in range(AudioServer.get_bus_effect_count(bus_id)):
		var effect = AudioServer.get_bus_effect(bus_id, i)
		if effect is AudioEffectReverb:
			return effect
	return null
#endregion

#region Start & Stops
# those method doesn't stop the players so they are still in sync
func fade_out_music(audioPlayer: AudioStreamPlayer, delay:=0.0, fade:=2.0):
	if audioPlayer == null:
		return
	var tween = create_tween()
	tween.tween_property(audioPlayer, "volume_db", -60, fade).set_trans(Tween.TRANS_LINEAR).set_delay(delay)

func stop_music(audioPlayer: AudioStreamPlayer, delay:=0.0):
	if audioPlayer == null:
		return
	var tween = create_tween()
	tween.tween_callback(audioPlayer.stop).set_delay(delay)

func fade_in_music(audioPlayer: AudioStreamPlayer, delay:=0.0, fade:=2.0):
	if audioPlayer == null:
		return
	var tween = create_tween()
	tween.tween_property(audioPlayer, "volume_db", 0, fade).set_trans(Tween.TRANS_LINEAR).set_delay(delay)
#endregion
