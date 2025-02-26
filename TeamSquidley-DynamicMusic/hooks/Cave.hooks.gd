extends Node


func tileRevealed(chain: ModLoaderHookChain,tileCoord:Vector2):
	Audio.playDiscovery()
	chain.execute_next([tileCoord])
