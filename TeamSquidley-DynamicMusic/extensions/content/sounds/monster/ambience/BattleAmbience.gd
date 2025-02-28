extends "res://content/sounds/monster/ambience/BattleAmbience.gd"

func _ready():
	var loud_buggy_noise = find_child("Walker_3")
	remove_child(loud_buggy_noise)
	loud_buggy_noise.queue_free()
	super._ready()
	for player in ambiences:
		if player is AudioStreamPlayer:
			player.volume_db = -9
