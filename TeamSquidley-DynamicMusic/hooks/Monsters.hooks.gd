extends Node

var hasBigMonsterSpawned: bool = false

var enemiesWeight = 0
var heavyMonstersNames : Array[String] = ["hornet"]
var ticklist = []
func spawnWave(chain: ModLoaderHookChain):
	chain.execute_next()
	hasBigMonsterSpawned = false

func _spawnMonster(chain: ModLoaderHookChain, breed:String, variant:String, groupSize := 1):
	chain.execute_next([breed, variant, groupSize])
	var main_node : Node = chain.reference_object
	if breed == "tick_single" or breed == "bigtick_single":
		enemiesWeight += 0.05
	elif breed == "tick" or breed == "big_tick":
		pass
	else:
		enemiesWeight += 1
	if heavyMonstersNames.has(breed) and not hasBigMonsterSpawned:
		# play audio
		hasBigMonsterSpawned = true
		Audio.monsters_big_monster_spawn.emit(true)
	
	Audio.monsters_total_change.emit(enemiesWeight, false)

func monsterDied(chain: ModLoaderHookChain, m):
	chain.execute_next([m])
	print(m.scene_file_path)
	var main_node : Node = chain.reference_object
	if m.scene_file_path == "res://content/monster/tick/Tick.tscn" or m.scene_file_path == "res://content/monster/bigtick/Bigticker.tscn" :
		enemiesWeight -= 0.05
	else:
		enemiesWeight -= 1
	Audio.monsters_total_change.emit(enemiesWeight, true)
