extends "res://content/caves/mushroomcave/MushroomCave.gd"

var timer

# Called when the node enters the scene tree for the first time.
func useHit(keeper:Keeper):
	if super.useHit(keeper):
		Audio.mushroomIncreasePitch(GameWorld.getTimeBetweenWaves() * 0.6)
		return true
	return false
