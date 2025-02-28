extends RefCounted

static func getTotalHp() -> int:
	var domeHealth = Data.of("dome.health")
	var cobalts = Data.of("inventory.sand") * 5000
	# Arbitrary number so the music isn't played if you have cobalt left
	return domeHealth + cobalts
