extends "res://content/monster/tick/Tick.gd"


const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

func applyDamage():
	super.applyDamage()
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
