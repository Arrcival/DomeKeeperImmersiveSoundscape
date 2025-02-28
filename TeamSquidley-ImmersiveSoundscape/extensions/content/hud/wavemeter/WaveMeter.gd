extends "res://content/hud/wavemeter/WaveMeter.gd"

var hasPlayedHorn = false

func _ready():
	super._ready()

func propertyChanged(property:String, oldValue, newValue):
	super.propertyChanged(property, oldValue, newValue)
	
	# called on wave starts and end 
	if property == "monsters.wavepresent":
		hasPlayedHorn = false
	
	if hasPlayedHorn:
		return
	
	if property == "monsters.wavecooldown": 
		if Data.ofOr("wavemeter.warner", false):
			for keeper in Keepers.getAll():
				var keeperDist = keeper.global_position.length()
				if keeperDist > 150:
					var threshold = 1.5 + (6.0 + keeperDist * 0.01) * GameWorld.waveMeterWarningModifier
					if newValue <= threshold:
						hasPlayedHorn = true
						Audio.preBattleMusic(newValue)
