extends "res://content/monster/bigtick/BigTick.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

func applyDamage():
	super.applyDamage()
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
