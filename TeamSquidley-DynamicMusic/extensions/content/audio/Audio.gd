extends "res://systems/audio/Audio.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")


var additionalMineAmbience: AudioStreamPlayer

var player_battle_default: AudioStreamPlayer
var player_battleMusicMonstersWeight: AudioStreamPlayer # monster amount
var player_battleMusicMonstersWeight2: AudioStreamPlayer # monster amount

var player_battle_mid_intensity: AudioStreamPlayer # monster amount v2
var player_battle_high_intensity: AudioStreamPlayer # monster amount v2

var player_heartbeat: AudioStreamPlayer # critical situation
var player_preroundhorn: AudioStreamPlayer # beofre round starts sound
var player_preroundmusic: AudioStreamPlayer # beofre round starts loop

var player_heavy_skymonster: AudioStreamPlayer
var player_heavy_groundmonster: AudioStreamPlayer
var player_final_wave: AudioStreamPlayer

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

var player_additional_music: AudioStreamPlayer
var player_droplet: AudioStreamPlayer
var player_gravel: AudioStreamPlayer
var player_abstract: AudioStreamPlayer
var cave_effects_reverb: AudioEffectReverb

var heartbeat_lowpass : AudioEffectLowPassFilter

var player_discovery: AudioStreamPlayer

var monstersAmount: int = 0

const prebattle1 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching_loop1_V2.ogg")
const prebattle2 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching_loop2_V2.ogg")
const prebattle3 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching_loop3_V2.ogg")
const prebattle4 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching_loop4_V2.ogg")
var prebattleloop
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
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water1_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water1_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water1_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water1_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water2_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water2_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water2_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water2_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water3_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water3_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water3_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water3_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water4_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water4_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water4_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water4_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water5_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water5_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water5_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/water5_Right2.mp3"),
]
const gravelsounds = [
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble6.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble7.ogg"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble1_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble2_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble3_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble4_Right2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5_Left.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5_Left2.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5_Right.mp3"),
	preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/crumble5_Right2.mp3"),

]
# Arbitrary numbers
const WEIGHT_CAP1 := 6
const WEIGHT_CAP2 := 9
const HP_CAP := 400

var allBattleMusicsPlayers: Array[AudioStreamPlayer]

const BUS_CAVE_EFFECTS_NAME := "CaveEffects"

const USE_RESONANCE = true

var has_hp_faded_in: bool = false
var prebattle = false
var wavenum = 1
var finalwave = false

func _ready():
	super._ready()

	#region Bus creation
	var cave_effect_bus_id = AudioServer.bus_count
	AudioServer.add_bus(AudioServer.bus_count)
	AudioServer.set_bus_name(cave_effect_bus_id, BUS_CAVE_EFFECTS_NAME)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_CAVE_EFFECTS_NAME), 0.0)
	cave_effects_reverb = AudioEffectReverb.new()
	AudioServer.add_bus_effect(cave_effect_bus_id, cave_effects_reverb)
	
	heartbeat_lowpass = AudioEffectLowPassFilter.new()
	heartbeat_lowpass.cutoff_hz = 20000
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Monster"), heartbeat_lowpass)
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), heartbeat_lowpass)
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Sounds"), heartbeat_lowpass)
	#endregion

	#region Creating and registering audio players
	player_additional_music = generateMusicPlayer()
	
	player_heartbeat = generatePlayer(&"UI", 0, false)
	player_heartbeat.volume_db = 15
	player_heartbeat.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/heartbeat.ogg")
	player_preroundhorn = generatePlayer(&"Sounds", 0, false)
	player_preroundhorn.volume_db = 0
	player_preroundhorn.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching(intro).ogg")
	player_preroundmusic = generatePlayer(&"Music", 0, false)
	player_preroundmusic.volume_db = -60
	player_preroundmusic.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching(loop).ogg")
	
	player_battle_default = generateMusicPlayer()
	
	player_battle_mid_intensity = generateMusicPlayer()
	player_battle_high_intensity = generateMusicPlayer()
	
	player_heavy_groundmonster = generateMusicPlayer()
	player_heavy_skymonster = generateMusicPlayer()
	player_final_wave = generateMusicPlayer()

	player_final_wave = generatePlayer(&"Music", 0, false)
	player_final_wave.volume_db = -60
	player_final_wave.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/wave_approaching(loop).ogg") # the epic song goes there 8)
	
	if USE_RESONANCE:
		player_battle_default.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/base_layer_res.mp3")
		player_battle_mid_intensity.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/medium_intensity_res.mp3")
		player_battle_high_intensity.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/high_intensity_res.mp3")
		player_heavy_groundmonster.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/ground_boss_res.mp3")
		player_heavy_skymonster.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/sky_boss_res.mp3")
	else:
		player_battle_default.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/base_layer_no_res.mp3")
		player_battle_mid_intensity.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/medium_intensity_no_res.mp3")
		player_battle_high_intensity.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/high_intensity_no_res.mp3")
		player_heavy_groundmonster.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/ground_boss_no_res.mp3")
		player_heavy_skymonster.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Musics/sky_boss_no_res.mp3")
	
	
	allBattleMusicsPlayers = [
		player_battle_default,
		player_battle_mid_intensity,
		player_battle_high_intensity,
		player_heavy_groundmonster,
		player_heavy_skymonster
	]

	player_droplet = generateCaveEffectPlayer()
	player_droplet.volume_db = -5
	player_gravel = generateCaveEffectPlayer()
	player_gravel.volume_db = -5
	player_abstract = generateCaveEffectPlayer()
	player_abstract.volume_db = -5
	player_discovery = generatePlayer(&"Sounds", 0, false)
	player_discovery.volume_db = -5
	player_discovery.stream = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Sounds/discovering.mp3")
	#endregion

func playDiscovery():
	if not player_discovery.playing:
		player_discovery.play()

func preBattleMusic(time_left: float):
	if wavenum >=1 and wavenum < 5:
		prebattleloop = prebattle1
	elif wavenum >= 5 and wavenum <9:
		prebattleloop = prebattle2
	elif wavenum >= 9 and wavenum < 13:
		prebattleloop = prebattle3
	elif wavenum >= 13:
		prebattleloop = prebattle4
	stopMusic(0.0, 1.0)
	player_preroundhorn.play()
	player_preroundmusic.stream = prebattleloop
	player_preroundmusic.volume_db = -18
	player_preroundmusic.play()
	fade_in_music(player_preroundmusic, 1.5, time_left - 2)
	fade_out_music(player_preroundmusic, time_left, 1)
	prebattle = true

func checkPreBattleMusic():
	return prebattle

func gameOver():
	finalwave = false
	removeMuffle()

var audioMuffled = false
func muffleAudio():
	if audioMuffled:
		return
	audioMuffled = true
	heartbeat_lowpass.cutoff_hz = 2000
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Monster"),-10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),-10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),-10)

func removeMuffle():
	if not audioMuffled:
		return
	audioMuffled = false
	heartbeat_lowpass.cutoff_hz = 20000
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Monster"), 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), 0)

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
	add_child(player)
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
	player_battle_default.volume_db = -60 # by default on

	# initialize music layers with default values
	set_music_based_on_monster_amount(0)
	set_music_based_on_hp()
	
	ground_heavy_monster_activated = false
	sky_heavy_monster_activated = false
	prebattle = false
	cap1 = false
	cap2 = false

	if Data.of("inventory.relic") == 1:
		playFinalWaveMusic()
		finalwave = true
		return
	fade_in_music(player_battle_default)
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		player.play(0.0)

func stopBattleMusic():
	super.stopBattleMusic()
	wavenum += 1
	# stop every music, but should fade off to be less abrupt
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		fade_out_music(player, 0.0, 4.0)
		stop_music(player)
#endregion

#region Ambience
func playAmbienceMine():
	super.playAmbienceMine()
	# add/activate droplets/mine sound effects

func stopAmbienceMine():
	super.stopAmbienceMine()
	# stop new sounds here
func playFinalWaveMusic():
	player_final_wave.play()
	fade_in_music(player_final_wave, 0.0, 3.0)
#endregion

#region Events
# Should be called on monster spawn AND kill
var cap1 = false
var cap2 = false
func set_music_based_on_monster_amount(monsters_amount: int):
	if finalwave == true:
		return
	_check_heartbeat()
	monstersAmount = monsters_amount
	if not cap1 and not cap2:
		if monstersAmount >= WEIGHT_CAP1:
			cap1 = true
			fade_out_music(player_battle_default, 1.0, 3.0)
			fade_in_music(player_battle_mid_intensity)
		if monstersAmount >= WEIGHT_CAP2:
			cap2 = true
			fade_out_music(player_battle_mid_intensity, 1.0, 3.0)
			fade_in_music(player_battle_high_intensity)
			return
	if cap1 and cap2:
		if monstersAmount < WEIGHT_CAP2:
			cap2 = false
			fade_out_music(player_battle_mid_intensity, 1.0, 3.0)
			fade_in_music(player_battle_high_intensity)
	if cap1 and not cap2:
		if monstersAmount < WEIGHT_CAP1:
			cap1 = false
			fade_out_music(player_battle_mid_intensity, 1.0, 3.0)
			fade_in_music(player_battle_default)
		elif monstersAmount >= WEIGHT_CAP2:
			cap2 = true
			fade_out_music(player_battle_mid_intensity, 1.0, 3.0)
			fade_in_music(player_battle_high_intensity)

# Should be called on heavy monster spawn
var ground_heavy_monster_activated = false
var sky_heavy_monster_activated = false
func set_music_based_on_strongest_monster(is_flying: bool):
	if finalwave == true:
		return
	if is_flying and not sky_heavy_monster_activated:
		fade_in_music(player_heavy_skymonster)
		sky_heavy_monster_activated = true
	if not is_flying and not ground_heavy_monster_activated:
		fade_in_music(player_heavy_groundmonster)
		ground_heavy_monster_activated = true

# Should be called on any hp changes
func set_music_based_on_hp():
	_check_heartbeat()

var isHeartbeatPlaying = false
func _check_heartbeat() -> void:
	if CONSTMOD.getTotalHp() <= 500 and not isHeartbeatPlaying:
		player_heartbeat.volume_db = -60
		player_heartbeat.play()
		fade_in_music(player_heartbeat, 0.0, 1.0)
		isHeartbeatPlaying = true
		muffleAudio()
	elif CONSTMOD.getTotalHp() > 500 or CONSTMOD.getTotalHp() <= 0:
		if isHeartbeatPlaying:
			isHeartbeatPlaying = false
			fade_out_music(player_heartbeat, 0.0, 1.0)
			stop_music(player_heartbeat, 1.0)
			removeMuffle()

var isDropletPlaying = false
func play_droplet_sound(room_scale: float):
	if isDropletPlaying:
		return
	isDropletPlaying = true
	cave_effects_reverb.room_size = room_scale
	player_droplet.pitch_scale = randf_range(0.9, 1.1) # Change the pitch of droplets
	player_droplet.volume_db = -(room_scale * 10) # Placeholder
	player_droplet.stream = dropletsounds[randi() % dropletsounds.size()]
	player_droplet.play()
	
	create_tween().tween_property(self, "isDropletPlaying", false, 0.0).set_delay(player_droplet.stream.get_length() * 2)

var isGravelPlaying = false
func play_gravel_sound(room_scale: float):
	if isGravelPlaying:
		return
	isGravelPlaying = true
	player_gravel.pitch_scale = randf_range(0.9, 1.1) # Change the pitch of droplets
	player_gravel.volume_db = -(room_scale * 10) # Placeholder
	player_gravel.stream = gravelsounds[randi() % gravelsounds.size()]
	player_gravel.play()
	create_tween().tween_property(self, "isGravelPlaying", false, 0.0).set_delay(player_gravel.stream.get_length() * 2)

var isAbstractPlaying = false
func play_abstract_sound(room_scale: float):
	if isAbstractPlaying:
		return
	isAbstractPlaying = true
	cave_effects_reverb.room_size = room_scale
	player_abstract.pitch_scale = randf_range(0.9, 1.1) # Change the pitch of droplets
	player_abstract.volume_db = -(room_scale * 10) # Placeholder
	player_abstract.stream = abstractTrack
	player_abstract.play(randf_range(0, 145))
	fade_in_music(player_abstract, 0, 1)
	fade_out_music(player_abstract, 5, 2)
	create_tween().tween_property(self, "isAbstractPlaying", false, 0.0).set_delay(player_abstract.stream.get_length() * 2)

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

func sound(soundName:String):
	#skipping replaced sounds by music/new sounds
	if soundName == "wavestart":
		return
	super.sound(soundName)
