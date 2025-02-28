extends "res://content/sounds/monster/ambience/BattleAmbience.gd"

func _ready():
	super._ready()
	for player in ambiences:
		if player is AudioStreamPlayer:
			player.volume_db -= 9
