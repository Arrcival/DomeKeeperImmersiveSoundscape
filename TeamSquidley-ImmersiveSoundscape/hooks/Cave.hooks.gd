extends Node

const CONST_AUDIO = preload("res://mods-unpacked/TeamSquidley-ImmersiveSoundscape/Consts.gd")

func tileRevealed(chain: ModLoaderHookChain,tileCoord:Vector2):
	if ModLoaderConfig.get_current_config(CONST_AUDIO.MOD_ID).data[CONST_AUDIO.CONFIG_ID_CAVE_DISCOVERY_SOUND]:
		Audio.playDiscovery()
	chain.execute_next([tileCoord])
