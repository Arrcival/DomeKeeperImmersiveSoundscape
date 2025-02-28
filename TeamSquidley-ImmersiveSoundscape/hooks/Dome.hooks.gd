extends Node

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-ImmersiveSoundscape/Consts.gd")


func requestProjectileDamage(chain: ModLoaderHookChain, rawDamage:int, pos:Vector2, requester):
	chain.execute_next([rawDamage, pos, requester])
	Audio.set_music_based_on_hp()
	
func requestMeleeDamage(chain: ModLoaderHookChain, rawDamage:int, pos:Vector2, requester):
	chain.execute_next([rawDamage, pos, requester])
	Audio.set_music_based_on_hp()
