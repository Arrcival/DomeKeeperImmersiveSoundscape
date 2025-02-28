extends "res://content/shared/projectiles/PathProjectile.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-ImmersiveSoundscape/Consts.gd")

func onTravelFinished():
	super.onTravelFinished()
	if get_collision_layer_value(CONST.LAYER_MONSTER_PROJECTILES):
		# means damage are sent to dome
		Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
