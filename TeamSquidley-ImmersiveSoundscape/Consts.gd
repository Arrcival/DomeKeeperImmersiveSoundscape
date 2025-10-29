extends RefCounted

const DROPLET_THRESHOLD: int = 500
const GRAVEL_THRESHOLD: int = 600
const ABSTRACT_THRESHOLD: int = 800
const KEEPER_THRESHOLD: int = 500
const DROPLET_THRESHOLD_MAX_RANGE_REVERB: int = 2000
const GRAVEL_THRESHOLD_MAX_RANGE_REVERB: int = 2000
const KEEPER_THRESHOLD_MAX_RANGE_REVERB: int = 2000

const DROPLET_CHANCE_PER_FRAME: float = 0.03
const DROPLET_CHANCE_LOUD_PER_FRAME: float = 0.001
const GRAVEL_CHANCE_PER_FRAME: float = 0.00025
const ABSTRACT_CHANCE_PER_FRAME: float = 0.000125

static func process_sounds(keeper_distance_to_dome: float):
	_process_droplets(keeper_distance_to_dome)
	_process_gravel(keeper_distance_to_dome)

static func update_keeper_bus_reverb(keeper_distance_to_dome: float, reverb_effect: AudioEffectReverb):
	reverb_effect.room_size = (keeper_distance_to_dome - KEEPER_THRESHOLD) / (KEEPER_THRESHOLD_MAX_RANGE_REVERB - KEEPER_THRESHOLD)

static func _process_droplets(keeper_distance_to_dome: float) -> void:
	if keeper_distance_to_dome >= DROPLET_THRESHOLD and GameWorld.paused == false:
		#var random = randf()
		#if random < DROPLET_CHANCE_LOUD_PER_FRAME:
		#	# Should be between 0-1
		#	var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
		#	Audio.play_droplet_sound(room_scale * 2, true)
		var random = randf()
		if random < DROPLET_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - DROPLET_THRESHOLD) / (DROPLET_THRESHOLD_MAX_RANGE_REVERB - DROPLET_THRESHOLD)
			Audio.play_droplet_sound(room_scale * 2, false)

static func _process_gravel(keeper_distance_to_dome: float) -> void:
	if keeper_distance_to_dome >= GRAVEL_THRESHOLD and GameWorld.paused == false:
		var random = randf()
		if random < GRAVEL_CHANCE_PER_FRAME:
			# Should be between 0-1
			var room_scale : float = (keeper_distance_to_dome - GRAVEL_THRESHOLD) / (GRAVEL_THRESHOLD_MAX_RANGE_REVERB - GRAVEL_THRESHOLD)
			Audio.play_gravel_sound(room_scale * 2)


static func getTotalHp() -> int:
	var domeHealth = Data.of("dome.health")
	var cobalts = Data.of("inventory.sand") * 5000
	# Arbitrary number so the music isn't played if you have cobalt left
	return domeHealth + cobalts


const CONFIG_ID_PREBATTLE_NOISE : String = "prewave_noise"
const CONFIG_ID_CAVE_DISCOVERY_SOUND : String = "cave_discovery_sound"
const CONFIG_ID_HEARTBEAT_EFFECT : String = "heartbeat_effect"

const MOD_ID : String = "TeamSquidley-ImmersiveSoundscape"
