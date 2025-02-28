extends "res://content/caves/mushroomcave/MushroomCave.gd"

func useHit(keeper:Keeper):
	return super.useHit(keeper)
	
	
	#if super.useHit(keeper):
	#	Audio.mushroomIncreasePitch(GameWorld.getTimeBetweenWaves() * 0.6)
	#	return true
	#return false
