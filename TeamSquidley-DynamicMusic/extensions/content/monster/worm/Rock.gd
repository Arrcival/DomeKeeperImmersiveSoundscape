extends "res://content/monster/worm/Rock.gd"


const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-DynamicMusic/Consts.gd")

func hitDome():
	super.hitDome()
	Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
