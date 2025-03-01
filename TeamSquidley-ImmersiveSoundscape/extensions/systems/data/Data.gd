extends "res://systems/data/Data.gd"

func changeDomeHealth(amount:float):
	super.changeDomeHealth(amount)
	Audio.set_music_based_on_hp()
