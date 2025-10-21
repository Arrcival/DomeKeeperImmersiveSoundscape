extends Node

var hasBigMonsterSpawned: bool = false

var enemiesWeight = 0
var heavy_sky_monster_names : Array[String] = ["scarab", "floater", "bloater", "phaser"]
var heavy_ground_monster_names : Array[String] = ["tormentor", "stag", "driller"]

var small_enemy_weight = 0.05

func spawnWave(chain: ModLoaderHookChain):
	chain.execute_next()
	hasBigMonsterSpawned = false

func _spawnMonster(chain: ModLoaderHookChain, breed:String, variant:String, groupSize := 1):
	chain.execute_next([breed, variant, groupSize])
	var main_node : Node = chain.reference_object
	if breed == "tick_single" or breed == "bigtick_single":
		enemiesWeight += small_enemy_weight
	elif breed == "tick" or breed == "big_tick":
		pass
	else:
		enemiesWeight += 1
	if heavy_sky_monster_names.has(breed):
		Audio.set_music_based_on_strongest_monster(true)
	if heavy_ground_monster_names.has(breed):
		Audio.set_music_based_on_strongest_monster(false)
	
	Audio.set_music_based_on_monster_amount(enemiesWeight)

func monsterDied(chain: ModLoaderHookChain, m):
	chain.execute_next([m])
	var main_node : Node = chain.reference_object
	if m.scene_file_path == "res://content/monster/tick/Tick.tscn" or m.scene_file_path == "res://content/monster/bigtick/Bigticker.tscn" :
		enemiesWeight -= small_enemy_weight
	else:
		enemiesWeight -= 1
	Audio.set_music_based_on_monster_amount(enemiesWeight)
