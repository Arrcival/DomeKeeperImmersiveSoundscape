extends "res://content/keeper/keeper1/Keeper1.gd"

@onready var Audio = get_node("/root/Audio")

enum MUSIC_TYPE { NONE = 0, MONSTERS_APPROACHING = 1, GOOD_LOOT = 2 }
var current_song : MUSIC_TYPE = MUSIC_TYPE.NONE
var time_between_waves = GameWorld.getTimeBetweenWaves()
var time = 0
var timewithoutmusic = 0
var volume = 0
var transitionsongtime = 0
const layer1 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Tracks/Layer-1.ogg")
const layer2 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Tracks/Layer-2.ogg")
const layer3 = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Audio/Tracks/Layer-3.ogg")

var consts = load("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd").new()

const DROPLET_THRESHOLD: int = 400
const ABSTRACT_THRESHOLD: int = 600
const DROPLET_THRESHOLD_MAX_RANGE_REVERB: int = 2000

const DROPLET_CHANCE_PER_FRAME: float = 0.0005
const ABSTRACT_CHANCE_PER_FRAME: float = 0.0000025


func _process(delta):
	# TEST: If size is greater or equal than 2 play the song
	time = Data.of("monsters.wavecooldown")

	# Fade music anyway before-brebattle music
	if time <= 16 && time > 15:
		Audio.fade_out_music_bus()
	if time <= 15 and time > 1:
		_process_approching_music()
	elif time < 1:
		current_song = MUSIC_TYPE.NONE
		Audio.fade_out_music_bus()

	_process_carriable()
	_process_droplets()
	_process_abstract()

func _process_approching_music():
	# Current song is currently correct !
	if current_song == MUSIC_TYPE.MONSTERS_APPROACHING:
		return
	# Do not own bar -> no music
	if not Data.of("wavemeter.showcounter"):
		return
	var keeperDist = global_position.length()
	# The more the further, the quieter the music
	volume = -(keeperDist / 50)
	Audio.fade_in_music_bus()
	current_song = MUSIC_TYPE.MONSTERS_APPROACHING
	#These should be different ones depending on the faraway value
	Audio.playMusicTrack(layer1)

func _process_carriable() -> void:
	# We do not process any loot music if there's approaching monsters
	# Unless the loot become ambient, but then should probably be moved
	# to an another player
	if current_song == MUSIC_TYPE.MONSTERS_APPROACHING:
		return
	
	if carriedCarryables.size() >= 1:
		var carriedvalue = 0
		for item in carriedCarryables:
			print(is_instance_of(item,Drop))
			if not is_instance_of(item,Drop):
				return
			if item.type == CONST.PACK:
				for drop in item.dropData:
					carriedvalue += getMaterialValue(drop[0])
			else:
				carriedvalue += getMaterialValue(item.type)
		# if a song is playing, do not interrupt
		if not Audio.isMusicPlaying() and carriedvalue >= 9 and current_song != MUSIC_TYPE.GOOD_LOOT:
			current_song = MUSIC_TYPE.GOOD_LOOT
			#play the song
			Audio.startMusic(1, 3.0)
		elif carriedvalue < 9 and current_song == MUSIC_TYPE.GOOD_LOOT:
			carriedvalue = 0
			Audio.stopMusic(0.0, 3.0)
			current_song = MUSIC_TYPE.NONE
	elif current_song == MUSIC_TYPE.GOOD_LOOT:
		#if you drop to 1 or 0 materials, the song fades away
		Audio.stopMusic(0.0,3.0)
		current_song = MUSIC_TYPE.NONE

func _process_droplets() -> void:
	var keeper_distance_to_dome = global_position.length()
	if keeper_distance_to_dome >= DROPLET_THRESHOLD and GameWorld.paused == false:
		var random = randf()
		if random < DROPLET_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
			Audio.should_droplet_sound.emit(room_scale * 2)
func _process_abstract() -> void:
	var keeper_distance_to_dome = global_position.length()
	if keeper_distance_to_dome >= ABSTRACT_THRESHOLD and GameWorld.paused == false:
		var random = randf()
		if random < ABSTRACT_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
			print("emiti señal")
			Audio.should_abstract_sound.emit(room_scale * 2)

func getMaterialValue(material:String):
	match material:
		CONST.POWERCORE:
			return 18
		CONST.GADGET:
			return 18
		CONST.RELIC:
			return 20
		CONST.EGG:
			return 0
		CONST.IRON:
			return 1
		CONST.WATER:
			return 2
		CONST.SAND:
			# warning : doesn't consider cobalts or revives
			if (consts.getTotalHp() * 100) / Data.of("dome.maxhealth") <= 25:
				return 6
			return 3
		CONST.PACK:
			return 99
