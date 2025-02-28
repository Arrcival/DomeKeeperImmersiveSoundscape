extends "res://content/sounds/monster/ambience/BattleAmbience.gd"

func _ready():
	for c in get_children():
		c.queue_free()
	queue_free()
	return

func propertyChanged(property:String, oldValue, newValue):
	return

func _process(delta):
	return
