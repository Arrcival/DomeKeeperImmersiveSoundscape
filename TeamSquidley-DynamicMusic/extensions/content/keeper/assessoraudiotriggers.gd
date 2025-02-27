extends "res://content/keeper/keeper2/Keeper2.gd"

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
const GRAVEL_THRESHOLD: int = 600
const ABSTRACT_THRESHOLD: int = 800
const DROPLET_THRESHOLD_MAX_RANGE_REVERB: int = 2000
const GRAVEL_THRESHOLD_MAX_RANGE_REVERB: int = 2000

const DROPLET_CHANCE_PER_FRAME: float = 0.0005
const GRAVEL_CHANCE_PER_FRAME: float = 0.00025
const ABSTRACT_CHANCE_PER_FRAME: float = 0.0000025

func _process(delta):
	time = Data.of("monsters.wavecooldown")
	# TEST: If size is greater or equal than 2 play the song
	# Fade music anyway before-brebattle music
	
	_process_carriable()
	_process_sounds()

func _process_carriable() -> void:
	# We do not process any loot music if there's approaching monsters
	# Unless the loot become ambient, but then should probably be moved
	# to an another player
	if current_song == MUSIC_TYPE.MONSTERS_APPROACHING:
		return
	if carriedCarryables.size() >= 1:
		var carriedvalue = 0
		for item in carriedCarryables:
			if not is_instance_of(item,Drop):
				return
			if item.type == CONST.PACK:
				for drop in item.dropData:
					carriedvalue += getMaterialValue(drop[0])
			else:
				if getMaterialValue(item.type) == null:
					return
				carriedvalue += getMaterialValue(item.type)
		# if a song is playing, do not interrupt
		if not Audio.isMusicPlaying() and carriedvalue >= 9 and current_song not in [MUSIC_TYPE.GOOD_LOOT, MUSIC_TYPE.MONSTERS_APPROACHING] and not Audio.checkPreBattleMusic():
			current_song = MUSIC_TYPE.GOOD_LOOT
			#play the song
			Audio.startMusic(1, 3.0)
		elif Audio.checkPreBattleMusic():
			Audio.stopMusic(0.0, 3.0)
		elif carriedvalue < 9 and current_song == MUSIC_TYPE.GOOD_LOOT:
			carriedvalue = 0
			Audio.stopMusic(0.0, 3.0)
			current_song = MUSIC_TYPE.NONE
	elif current_song == MUSIC_TYPE.GOOD_LOOT:
		#if you drop to 1 or 0 materials, the song fades away
		Audio.stopMusic(0.0,3.0)
		current_song = MUSIC_TYPE.NONE

func _process_sounds():
	_process_droplets()
	_process_gravel()
	_process_abstract()

func _process_droplets() -> void:
	var keeper_distance_to_dome = global_position.length()
	if keeper_distance_to_dome >= DROPLET_THRESHOLD and GameWorld.paused == false:
		var random = randf()
		if random < DROPLET_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
			Audio.play_droplet_sound(room_scale * 2)

func _process_gravel() -> void:
	var keeper_distance_to_dome = global_position.length()
	if keeper_distance_to_dome >= GRAVEL_THRESHOLD and GameWorld.paused == false:
		var random = randf()
		if random < GRAVEL_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - GRAVEL_THRESHOLD) / (GRAVEL_THRESHOLD_MAX_RANGE_REVERB - GRAVEL_THRESHOLD)
			Audio.play_gravel_sound(room_scale * 2)

func _process_abstract() -> void:
	var keeper_distance_to_dome = global_position.length()
	if keeper_distance_to_dome >= ABSTRACT_THRESHOLD and GameWorld.paused == false:
		var mult = 1 + (keeper_distance_to_dome - 400)/1000
		var random = randf()
		if random < (ABSTRACT_CHANCE_PER_FRAME * mult):
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
			Audio.play_abstract_sound(room_scale * 2)

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
