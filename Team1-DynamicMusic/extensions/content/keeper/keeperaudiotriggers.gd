extends "res://content/keeper/keeper1/Keeper1.gd"
@onready var Audio = get_node("/root/Audio") 

func updateCarry():
	var longest = 0
	# TEST: If size is greater or equal than 2 play the song
	if carriedCarryables.size() >= 2:
		# if a song is playing, do not interrupt
		if not Audio.isMusicPlaying():
			#play the song
			Audio.startMusic(1)
	else:
		#if you drop to 1 or 0 materials, the song fades away
		Audio.stopMusic(0.0,3.0)
	for c in carriedCarryables.duplicate():
		if c.independent:
			dropCarry(c)
		else:
			var d = (position - c.position).length()
			if d > longest:
				longest = d
			if d > maxCarryLineLength:
				dropCarry(c)
				$CarryLineBreak.play()

	var breakThreshold = 0.7
	if longest > breakThreshold * maxCarryLineLength:
		if not $CarryLineStretch.playing:
			$CarryLineStretch.play()
		var pitch = (longest - breakThreshold * maxCarryLineLength) / ((1.0-breakThreshold) * maxCarryLineLength)
		$CarryLineStretch.pitch_scale = 1 + ease(pitch, 0.6)
	else:
		$CarryLineStretch.stop()
