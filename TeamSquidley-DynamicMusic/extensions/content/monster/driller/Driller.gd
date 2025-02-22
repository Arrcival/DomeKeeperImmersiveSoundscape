extends "res://content/monster/driller/Driller.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

func subProcess(delta):
	super.subProcess(delta)
	if phase == 5 and damageSum >= damageUnit:
		Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
