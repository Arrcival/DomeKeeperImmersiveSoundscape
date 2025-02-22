extends RefCounted

static func getTotalHp() -> int:
	return Data.of("dome.health") + Data.of("inventory.sand") * Data.of("dome.autohealamount")
