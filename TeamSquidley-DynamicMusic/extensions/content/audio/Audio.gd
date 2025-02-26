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

var player_heartbeat: AudioStreamPlayer # critical situation
var player_preroundintrosound: AudioStreamPlayer # beofre round starts sound
var player_preroundintrosoundloop: AudioStreamPlayer # beofre round starts loop

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

var player_additional_music: AudioStreamPlayer
var player_droplet: AudioStreamPlayer
var player_discovery: AudioStreamPlayer

var monstersAmount: int = 0

const abstractTrack = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/abstractsounds.wav")
const dropletsounds = [
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water1.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water2.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water3.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water4.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water5.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water6.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water7.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water8.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water9.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water10.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water11.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water12.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water13.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water14.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water15.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble6.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble7.ogg"),

]
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
signal should_abstract_sound(reverb_magnitude: float)
signal gameover()
signal preroundintro()
signal preroundintroloop(play: bool)
signal preroundintroloopvolume(volume)

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
	player_additional_music = generateMusicPlayer()
	
	player_heartbeat = generatePlayer(&"UI", 0, false)
	player_heartbeat.volume_db = 15
	player_heartbeat.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/heartbeat.ogg")
	player_preroundintrosound = generatePlayer(&"Sounds", 0, false)
	player_preroundintrosound.volume_db = 0
	player_preroundintrosound.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching(intro).ogg")
	player_preroundintrosoundloop = generatePlayer(&"Music", 0, false)
	player_preroundintrosoundloop.volume_db = -10
	player_preroundintrosoundloop.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching(loop).ogg")
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
	add_child(player_heartbeat)
	add_child(player_preroundintrosound)
	add_child(player_preroundintrosoundloop)
	
	allBattleMusicsPlayers = [
		player_battleMusicStartingSound,
		player_battleMusicDefault,
		player_battleMusicMonstersWeight,
		player_battleMusicMonstersWeight2,
		player_battleMusicTotalHp,
		player_battleMusicStrongestEnemy
	]
	
	player_droplet = generateCaveEffectPlayer()
	player_droplet.volume_db = -5
	add_child(player_droplet)
	player_discovery = generatePlayer(&"Sounds",0,false)
	player_discovery.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/discovering.mp3")
	add_child(player_discovery)
	#endregion
	
	# add effects to that bus

	MusicTween = create_tween()
	monsters_total_change.connect(set_music_based_on_monster_total_weight)
	monsters_big_monster_spawn.connect(set_music_based_on_strongest_monster)
	should_droplet_sound.connect(play_droplet_sound)
	gameover.connect(gameOver)
	preroundintro.connect(preRoundIntro)
	preroundintroloop.connect(preRoundIntroLoop)
	preroundintroloopvolume.connect(preRoundIntroLoopVolume)
	should_abstract_sound.connect(play_abstract_sound)
	hp_change.connect(set_music_based_on_hp)


var audioMuffled = false
func playDiscovery():
	if not player_discovery.playing:
		player_discovery.play()
func preRoundIntro():
	player_preroundintrosound.play()
func preRoundIntroLoop(play:bool):
	if play:
		player_preroundintrosoundloop.play()
	else:
		fade_out_music(player_preroundintrosoundloop,0,1)
func preRoundIntroLoopVolume(volume):
	player_preroundintrosoundloop.volume_db += volume
		
func gameOver():
	removeMuffle()
func muffleAudio():
	if audioMuffled:
		return
	audioMuffled = true
	var lowpass: AudioEffectLowPassFilter = removeLowPassEffectOrNull(AudioServer.get_bus_index("Master"))
	if lowpass == null:
		lowpass = AudioEffectLowPassFilter.new()
	lowpass.cutoff_hz = 2000
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Monster"),-10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),-10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),-10)
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Monster"),lowpass)
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"),lowpass)
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Sounds"),lowpass)

func removeMuffle():
	if not audioMuffled:
		return
	audioMuffled = false
	removeLowPassEffectOrNull(AudioServer.get_bus_index("Master"))
	removeLowPassEffectOrNull(AudioServer.get_bus_index("Sounds"))
	removeLowPassEffectOrNull(AudioServer.get_bus_index("Monster"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Monster"),0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),0)

func generateMusicPlayer() -> AudioStreamPlayer:
	return generatePlayer(&"Music", -60, false)
	
func generateCaveEffectPlayer() -> AudioStreamPlayer:
	return generatePlayer(BUS_CAVE_EFFECTS_NAME, 0, true)

func generatePlayer(bus_name: String, initial_volume: float, is_playing: bool = false) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.autoplay = false
	player.bus = bus_name
	player.volume_db = initial_volume
	if not is_playing:
		player.stop()
	return player

func playMusicTrack(track, delay:=0.0):
	$Music.stop()
	if currentTrackList.is_empty():
		Logger.error("track list is empty", "Audio.playMusicTrack")
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

	# initialize music layers with default values
	set_music_based_on_monster_total_weight(0, false)
	set_music_based_on_strongest_monster(false)
	set_music_based_on_hp(CONSTMOD.getTotalHp(), false)
	
	weight1 = false
	weight2 = false
	heavy_monster_activated = false
	
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
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
	monstersAmount = monsters_amount
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
	_check_heartbeat()


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
	_check_heartbeat()

var isHeartbeatPlaying = false
func _check_heartbeat() -> void:
	if monstersAmount >= WEIGHT_CAP2 and CONSTMOD.getTotalHp() <= 500 and not isHeartbeatPlaying:
		player_heartbeat.volume_db = -60
		player_heartbeat.play()
		fade_in_music(player_heartbeat, 0.0, 1.0)
		isHeartbeatPlaying = true
		muffleAudio()
	elif monstersAmount < WEIGHT_CAP2 or CONSTMOD.getTotalHp() > 500 or CONSTMOD.getTotalHp() <= 0:
		if isHeartbeatPlaying:
			isHeartbeatPlaying = false
			fade_out_music(player_heartbeat, 0.0, 1.0)
			stop_music(player_heartbeat, 1.0)
			removeMuffle()

	elif monstersAmount < WEIGHT_CAP2 or CONSTMOD.getTotalHp() > 500:
		removeMuffle()
		
func play_droplet_sound(room_scale: float):
	if player_droplet.playing:
		return
	var reverb: AudioEffectReverb = removeReverbEffectOrNull(BUS_CAVE_EFFECTS_ID)
	if reverb != null:
		reverb.room_size = room_scale
	else:
		reverb = AudioEffectReverb.new()
	player_droplet.pitch_scale = randf_range(0.9, 1.1) # Change the pitch of droplets
	player_droplet.volume_db = -(room_scale * 10) # Placeholder
	AudioServer.add_bus_effect(BUS_CAVE_EFFECTS_ID, reverb)
	player_droplet.stream = dropletsounds[randi() % dropletsounds.size()]
	player_droplet.play()

func play_abstract_sound(room_scale: float):
	if player_droplet.playing:
		return
	var reverb: AudioEffectReverb = removeReverbEffectOrNull(BUS_CAVE_EFFECTS_ID)
	if reverb != null:
		reverb.room_size = room_scale
	else:
		reverb = AudioEffectReverb.new()
	player_droplet.pitch_scale = randf_range(0.9, 1.1) # Change the pitch of droplets
	player_droplet.volume_db = -(room_scale * 10) # Placeholder
	AudioServer.add_bus_effect(BUS_CAVE_EFFECTS_ID, reverb)
	player_droplet.stream = abstractTrack
	player_droplet.play(randf_range(0,145))
	fade_in_music(player_droplet,0,1)
	fade_out_music(player_droplet,5,2)

func removeReverbEffectOrNull(bus_id: int) -> AudioEffectReverb:
	for i in range(AudioServer.get_bus_effect_count(bus_id)):
		var effect = AudioServer.get_bus_effect(bus_id, i)
		AudioServer.remove_bus_effect(bus_id,i)
		if effect is AudioEffectReverb:
			return effect
	return null

func removeLowPassEffectOrNull(bus_id: int) -> AudioEffectLowPassFilter:
	for i in range(AudioServer.get_bus_effect_count(bus_id)):
		var effect = AudioServer.get_bus_effect(bus_id, i)
		if effect is AudioEffectLowPassFilter:
			AudioServer.remove_bus_effect(bus_id,i)
	return null

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

#region Additional music
var isFadingOut = false
func fade_out_music_bus(fade :float = 1.0):
	if isFadingOut:
		return
	isFadingOut = true
	var tween = create_tween()
	tween.tween_property($Music, "volume_db", -60, fade)
	tween.tween_property(self, "isFadingOut", false, 0.0).set_delay(fade)

var isFadingIn = false
func fade_in_music_bus(fade :float = 1.0):
	if isFadingIn:
		return
	isFadingIn = true
	var tween = create_tween()
	tween.tween_property($Music, "volume_db", 0, fade)
	tween.tween_property(self, "isFadingIn", false, 0.0).set_delay(fade)

#endregion
