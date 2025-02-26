extends Node


func handleGameLost(chain: ModLoaderHookChain,backendData:Dictionary = {}):
	Audio.gameover.emit()
