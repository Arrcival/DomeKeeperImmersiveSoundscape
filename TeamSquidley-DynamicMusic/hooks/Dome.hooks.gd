extends Node

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")


func requestProjectileDamage(chain: ModLoaderHookChain, rawDamage:int, pos:Vector2, requester):
	chain.execute_next([rawDamage, pos, requester])
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
	
func requestMeleeDamage(chain: ModLoaderHookChain, rawDamage:int, pos:Vector2, requester):
	chain.execute_next([rawDamage, pos, requester])
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
