extends "res://systems/audio/Audio.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

var additionalMineAmbience: AudioStreamPlayer

var battleMusicStartingSound: AudioStreamPlayer # based on wave number

var battleMusicDefault: AudioStreamPlayer
var battleMusicMonstersWeight: AudioStreamPlayer # monster amount
var battleMusicMonstersWeight2: AudioStreamPlayer # monster amount


# amount of life + cobalt * heal < threshold -> plays music ?
var battleMusicTotalHp: AudioStreamPlayer # % of life AND considering cobalt
var battleMusicStrongestEnemy: AudioStreamPlayer # strongest enemy

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

# Arbitrary number
const WEIGHT_CAP1 := 5
const WEIGHT_CAP2 := 8
const HP_CAP := 300

var allBattleMusicsPlayers: Array[AudioStreamPlayer]

const BUS_CAVE_EFFECTS_NAME := "CaveEffects"
const BUS_CAVE_EFFECTS_ID := 1

signal monsters_total_change(value: int, kill: bool)
signal monsters_big_monster_spawn(activate: bool)
signal hp_change(value: int, hp_loss: bool)

var MusicTween: Tween

func _ready():
	super._ready()
	#region Creating and registering audio players
	battleMusicStartingSound = generateMusicPlayer()
	battleMusicDefault = generateMusicPlayer(true)
	battleMusicDefault.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 1.mp3")
	battleMusicMonstersWeight = generateMusicPlayer(true)
	battleMusicMonstersWeight.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 2.mp3")
	battleMusicMonstersWeight2 = generateMusicPlayer(true)
	battleMusicTotalHp = generateMusicPlayer(true)
	battleMusicTotalHp.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 3.mp3")
	battleMusicStrongestEnemy = generateMusicPlayer(true)
	#battleMusicStrongestEnemy.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/content/music/Layer 3.mp3")
	add_child(battleMusicStartingSound)
	add_child(battleMusicDefault)
	add_child(battleMusicMonstersWeight)
	add_child(battleMusicMonstersWeight2)
	add_child(battleMusicTotalHp)
	add_child(battleMusicStrongestEnemy)
	
	allBattleMusicsPlayers = [
		battleMusicStartingSound,
		battleMusicDefault,
		battleMusicMonstersWeight,
		battleMusicMonstersWeight2,
		battleMusicTotalHp,
		battleMusicStrongestEnemy
	]
	#endregion
	
	AudioServer.add_bus(BUS_CAVE_EFFECTS_ID)
	AudioServer.set_bus_name(BUS_CAVE_EFFECTS_ID, BUS_CAVE_EFFECTS_NAME)
	# add effects to that bus
	
	MusicTween = create_tween()
	monsters_total_change.connect(set_music_based_on_monster_total_weight)
	monsters_big_monster_spawn.connect(set_music_based_on_strongest_monster)
	hp_change.connect(set_music_based_on_hp)

func generateMusicPlayer(autoplay: bool = false) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.autoplay = autoplay
	player.bus = &"Music"
	player.volume_db = -60
	player.stop()
	return player
	
func generateCaveEffectPlayer() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.autoplay = false
	player.bus = BUS_CAVE_EFFECTS_NAME
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

func startBattleMusic():
	super.startBattleMusic()
	# they all should start playing, even if they are muted
	battleMusicDefault.volume_db = 0 # by default on

	# initialize music layers with default values
	set_music_based_on_monster_total_weight(0, false)
	set_music_based_on_strongest_monster(false)
	set_music_based_on_hp(CONSTMOD.getTotalHp(), false)
	# manage volume/pitch there based on conditions
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		player.play(0.0)

func stopBattleMusic():
	super.stopBattleMusic()
	# stop every players, but should fade off to be less abrupt
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		stop_music(player, 0.0, 2.0)

#region Ambience
func playAmbienceMine():
	super.playAmbienceMine()
	# add/activate droplets/mine sound effects

func stopAmbienceMine():
	super.stopAmbienceMine()
	# stop new sounds here
#endregion

# Should be called on monster spawn AND kill
func set_music_based_on_monster_total_weight(monster_weight: int, monster_killed: bool):
	if monster_killed:
		if monster_weight < WEIGHT_CAP1:
			stop_music(battleMusicMonstersWeight)
		elif monster_weight < WEIGHT_CAP2:
			stop_music(battleMusicMonstersWeight2)
	else:
		battleMusicMonstersWeight.volume_db = 0 if monster_weight > WEIGHT_CAP1 else -60
		battleMusicMonstersWeight2.volume_db = 0 if monster_weight > WEIGHT_CAP2 else -60

# Should be called on monster spawn AND kill
func set_music_based_on_strongest_monster(activate: bool):
	battleMusicStrongestEnemy.volume_db = 0 if activate else -60

# Should be called on any hp changes
func set_music_based_on_hp(hp: int, hp_loss: bool):
	if hp_loss and hp < HP_CAP:
		start_music(battleMusicTotalHp)
	else:
		battleMusicTotalHp.volume_db = 0 if hp < HP_CAP else -60

func stop_music(audioPlayer: AudioStreamPlayer, delay:=0.0, fade:=6.0):
	if audioPlayer == null:
		return
	var tween = create_tween()
	tween.tween_property(audioPlayer, "volume_db", -60, fade).set_trans(Tween.TRANS_LINEAR).set_delay(delay)
	tween.tween_callback(audioPlayer.stop).set_delay(fade+delay)

func start_music(audioPlayer: AudioStreamPlayer, delay:=0.0, fade:=6.0):
	if audioPlayer == null:
		return
	var tween = create_tween()
	tween.tween_property(audioPlayer, "volume_db", 0, fade).set_trans(Tween.TRANS_LINEAR).set_delay(delay)
	tween.tween_callback(audioPlayer.play)
