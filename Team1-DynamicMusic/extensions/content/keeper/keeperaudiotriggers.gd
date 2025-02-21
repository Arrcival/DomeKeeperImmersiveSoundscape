extends "res://content/keeper/keeper1/Keeper1.gd"
@onready var Audio = get_node("/root/Audio") 
func _process(delta):
	# TEST: If size is greater or equal than 2 play the song
	if carriedCarryables.size() >= 2:
		# if a song is playing, do not interrupt
		if not Audio.isMusicPlaying():
			#play the song
			Audio.startMusic(1)
	else:
		#if you drop to 1 or 0 materials, the song fades away
		Audio.stopMusic(0.0,3.0)
