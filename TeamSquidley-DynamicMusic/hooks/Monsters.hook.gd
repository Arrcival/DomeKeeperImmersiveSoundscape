extends Node

var hasBigMonsterSpawned: bool = false

var heavyMonstersNames : Array[String] = ["hornet"]

func spawnWave(chain: ModLoaderHookChain):
	chain.execute_next()
	hasBigMonsterSpawned = false

func spawnMonster(chain: ModLoaderHookChain, breed:String, variant:String, groupSize := 1):
	chain.execute_next([breed, variant, groupSize])
	var main_node : Node = chain.reference_object
	
	if heavyMonstersNames.has(breed) and not hasBigMonsterSpawned:
		# play audio
		hasBigMonsterSpawned = true
		Audio.monsters_big_monster_spawn.emit(true)
	
	Audio.monsters_total_change.emit(main_node.remainingMonsters, true)

func monsterDied(chain: ModLoaderHookChain, m):
	chain.execute_next([m])
	var main_node : Node = chain.reference_object
	Audio.monsters_total_change.emit(main_node.remainingMonsters, false)
