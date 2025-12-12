extends RefCounted

const DROPLET_THRESHOLD: int = 500
const GRAVEL_THRESHOLD: int = 600
const ABSTRACT_THRESHOLD: int = 800
const KEEPER_THRESHOLD: int = 500
const DROPLET_THRESHOLD_MAX_RANGE_REVERB: int = 2000
const GRAVEL_THRESHOLD_MAX_RANGE_REVERB: int = 2000
const KEEPER_THRESHOLD_MAX_RANGE_REVERB: int = 2000

const DROPLET_CHANCE_PER_FRAME: float = 0.03
const GRAVEL_CHANCE_PER_FRAME: float = 0.00025
const ABSTRACT_CHANCE_PER_FRAME: float = 0.000125

const LOWER_MUSIC_VOLUME_THRESHOLD: int = 150

const REVERB_MINE_POWER: float = 1.5


static func process_sounds(keeper_distance_to_dome: float):
	_process_droplets(keeper_distance_to_dome)
	_process_gravel(keeper_distance_to_dome)
	_process_fade_out_music(keeper_distance_to_dome)

static func update_keeper_bus_reverb(keeper_distance_to_dome: float, reverb_effect: AudioEffectReverb):
	if not ModLoaderConfig.get_current_config(MOD_ID).data[CONFIG_ID_REVERB_IN_MINE]:
		return
	var value = clamp(0, (keeper_distance_to_dome - KEEPER_THRESHOLD) / (KEEPER_THRESHOLD_MAX_RANGE_REVERB - KEEPER_THRESHOLD), 1) * REVERB_MINE_POWER
	reverb_effect.room_size = value

static func _process_droplets(keeper_distance_to_dome: float) -> void:
	if keeper_distance_to_dome >= DROPLET_THRESHOLD and GameWorld.paused == false:
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

static func _process_fade_out_music(keeper_distance_to_dome: float) -> void:
	Audio.handle_music_volume(keeper_distance_to_dome >= LOWER_MUSIC_VOLUME_THRESHOLD)

static func process_keeper_buff(property: String, duration: float) -> void:
	if property == "keeper.highbuff":
		Audio.mushroomIncreasePitch(duration)

static func getTotalHp() -> int:
	var domeHealth = Data.of("dome.health")
	var cobalts = Data.of("inventory.sand") * 5000
	# Arbitrary number so the music isn't played if you have cobalt left
	return domeHealth + cobalts

static func get_or_create_reverb() -> AudioEffectReverb:
	var bus_index = AudioServer.get_bus_index("Keeper")
	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect = AudioServer.get_bus_effect(bus_index, i)
		if effect is AudioEffectReverb:
			return effect

	var reverb = AudioEffectReverb.new()
	reverb.room_size = 0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Keeper"), reverb)
	return reverb

const CONFIG_ID_PREBATTLE_NOISE : String = "prewave_noise"
const CONFIG_ID_CAVE_DISCOVERY_SOUND : String = "cave_discovery_sound"
const CONFIG_ID_HEARTBEAT_EFFECT : String = "heartbeat_effect"
const CONFIG_ID_REVERB_IN_MINE : String = "reverb_in_mine"

const MOD_ID : String = "TeamSquidley-ImmersiveSoundscape"
