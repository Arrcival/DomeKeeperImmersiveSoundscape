extends "res://content/keeper/keeper1/Keeper1.gd"
@onready var Audio = get_node("/root/Audio") 
var current_song = null
func _process(delta):
	# TEST: If size is greater or equal than 2 play the song
	if Data.of("monsters.wavepresent") == true:
		if not Audio.isMusicPlaying() or current_song != "monsters_aproaching":
			#play the song
			current_song = "monsters_aproaching"
			Audio.startMusic(1)
	elif carriedCarryables.size() >= 1:
		# if a song is playing, do not interrupt
		var carriedvalue = 0
		for item in carriedCarryables:
			carriedvalue += getMaterialValue(item.type)
		if not Audio.isMusicPlaying() and carriedvalue >= 9 and current_song != "good_loot":
			current_song = "good_loot"
			#play the song
			print("playing good loot")
			Audio.startMusic(1,3.0)
		elif carriedvalue < 9:
			carriedvalue = 0
			Audio.stopMusic(0.0,3.0)
			current_song = null
	else:
		#if you drop to 1 or 0 materials, the song fades away
		Audio.stopMusic(0.0,3.0)
		current_song = null
func getMaterialValue(material:String):
	match material:
		CONST.POWERCORE:
			return 10
		CONST.GADGET:
			return 0
		CONST.RELIC:
			return 20
		CONST.EGG:
			return 0
		CONST.IRON:
			return 1
		CONST.WATER:
			return 2
		CONST.SAND:
			return 3
		CONST.PACK:
			return 0
