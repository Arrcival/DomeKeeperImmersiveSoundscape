extends "res://content/keeper/keeper1/Keeper1.gd"
@onready var Audio = get_node("/root/Audio") 
var current_song = null
var time_between_waves = GameWorld.getTimeBetweenWaves()
var time = 0
func _process(delta):
	# TEST: If size is greater or equal than 2 play the song
	time = Data.of("monsters.wavecooldown")
	if time <= 15 and time > 1:
		var faraway = false
		for keeper in Keepers.getAll():
			var keeperDist = keeper.global_position.length()
			if keeperDist > 500:
				faraway = true
		if not Audio.isMusicPlaying() or current_song != "monsters_aproaching" and faraway and Data.of("wavemeter.showbar") == true:
			#play the song
			current_song = "monsters_aproaching"
			Audio.startMusic(0)
	elif time < 1:
		Audio.stopMusic(0.0,3.0)
		current_song = null
	elif carriedCarryables.size() >= 1:
		# if a song is playing, do not interrupt
		var carriedvalue = 0
		for item in carriedCarryables:
			if getMaterialValue(item.type) == 99:
				for drop in item.dropData:
					carriedvalue += getMaterialValue(drop[0])
			else:
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
			if (Data.of("dome.health")*100) / Data.of("dome.maxhealth") <= 25:
				return 6
			return 3
		CONST.PACK:
			return 99
