extends "res://content/keeper/keeper2/Keeper2.gd"

@onready var Audio = get_node("/root/Audio")

enum MUSIC_TYPE { NONE = 0, MONSTERS_APPROACHING = 1, GOOD_LOOT = 2 }
var current_song : MUSIC_TYPE = MUSIC_TYPE.NONE
var time_between_waves = GameWorld.getTimeBetweenWaves()
var time = 0

var assessor_reverb : AudioEffectReverb
var timer: Timer

var CONST = load("res://mods-unpacked/TeamSquidley-ImmersiveSoundscape/Consts.gd").new()

func init():
	super.init()

	assessor_reverb = AudioEffectReverb.new()
	assessor_reverb.room_size = 0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Keeper"), assessor_reverb)

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1	
	timer.timeout.connect(one_second_clock)
	timer.start()

func one_second_clock():
	CONST.update_keeper_bus_reverb(global_position.length(), assessor_reverb)

func _process(delta):
	time = Data.of("monsters.wavecooldown")
	# TEST: If size is greater or equal than 2 play the song
	# Fade music anyway before-brebattle music
	
	_process_carriable()
	CONST.process_sounds(global_position.length())
	CONST.update_keeper_bus_reverb(global_position.length(), assessor_reverb)

func _process_carriable() -> void:
	# We do not process any loot music if there's approaching monsters
	# Unless the loot become ambient, but then should probably be moved
	# to an another player
	#print(Audio.checkPreBattleMusic())
	if current_song == MUSIC_TYPE.MONSTERS_APPROACHING:
		return
	#if carriedCarryables.size() >= 1:
		#var carriedvalue = 0
		#for item in carriedCarryables:
			#if not is_instance_of(item,Drop):
				#return
			#if item.type == CONST.PACK:
				#for drop in item.dropData:
					#carriedvalue += getMaterialValue(drop[0])
			#else:
				#if getMaterialValue(item.type) == null:
					#return
				#carriedvalue += getMaterialValue(item.type)
		## if a song is playing, do not interrupt
		#if not Audio.isMusicPlaying() and carriedvalue >= 9 and current_song not in [MUSIC_TYPE.GOOD_LOOT, MUSIC_TYPE.MONSTERS_APPROACHING] and not Audio.checkPreBattleMusic():
			#current_song = MUSIC_TYPE.GOOD_LOOT
			##play the song
			#Audio.startMusic(1, 3.0)
		#elif Audio.checkPreBattleMusic():
			#Audio.stopMusic(0.0, 3.0)
		#elif carriedvalue < 9 and current_song == MUSIC_TYPE.GOOD_LOOT:
			#carriedvalue = 0
			#Audio.stopMusic(0.0, 3.0)
			#current_song = MUSIC_TYPE.NONE
	#elif current_song == MUSIC_TYPE.GOOD_LOOT:
		##if you drop to 1 or 0 materials, the song fades away
		#Audio.stopMusic(0.0,3.0)
		#current_song = MUSIC_TYPE.NONE


#func getMaterialValue(material:String):
	#match material:
		#CONST.POWERCORE:
			#return 18
		#CONST.GADGET:
			#return 18
		#CONST.RELIC:
			#return 20
		#CONST.EGG:
			#return 0
		#CONST.IRON:
			#return 1
		#CONST.WATER:
			#return 2
		#CONST.SAND:
			## warning : doesn't consider cobalts or revives
			#if (consts.getTotalHp() * 100) / Data.of("dome.maxhealth") <= 25:
				#return 6
			#return 3
		#CONST.PACK:
			#return 99
