extends "res://game/GameWorld.gd"

func handleGameLost(backendData:Dictionary = {}):
	Audio.gameOver()
	super.handleGameLost(backendData)
