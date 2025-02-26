extends Node


func handleGameLost(chain: ModLoaderHookChain,backendData:Dictionary = {}):
	chain.execute_next([backendData])
	Audio.gameover.emit()
