extends "res://content/monster/diver/Diver.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

func applyDamage():
	super.applyDamage()
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
