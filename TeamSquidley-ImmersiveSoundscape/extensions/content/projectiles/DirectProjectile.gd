extends "res://content/shared/projectiles/DirectProjectile.gd"

const CONSTMOD = preload("res://mods-unpacked/TeamSquidley-ImmersiveSoundscape/Consts.gd")

func _physics_process(delta):
	super._physics_process(delta)

	if not flying or GameWorld.paused:
		return
		
	var d = target - position
	rotation = d.angle() + PI * rotation_offset
	position += (d.normalized() * delta * speed).limit_length(d.length())
	if d.length() < 2.0 and get_collision_layer_value(CONST.LAYER_MONSTER_PROJECTILES):
		# means damage are sent to dome
		Audio.hp_change.emit(CONSTMOD.getTotalHp(), true)
