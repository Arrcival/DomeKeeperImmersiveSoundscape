extends "res://systems/audio/Audio.gd"

### UNTESTED

var additionalMineAmbience: AudioStreamPlayer

var battleMusicStartingSound: AudioStreamPlayer # based on wave number

var battleMusicDefault: AudioStreamPlayer
var battleMusicMonstersWeight: AudioStreamPlayer # monster amount
var battleMusicMonstersWeight2: AudioStreamPlayer # monster amount


# amount of life + cobalt * heal < threshold -> plays music ?
var battleMusicTotalHp: AudioStreamPlayer # % of life AND considering cobalt
var battleMusicStrongestEnemy: AudioStreamPlayer # strongest enemy

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

# Arbitrary number
const WEIGHT_CAP1 := 30
const WEIGHT_CAP2 := 60
const BIGGEST_MONSTER_CAP := 10
const HP_CAP := 300

var allBattleMusicsPlayers: Array[AudioStreamPlayer]

const BUS_CAVE_EFFECTS_NAME := "CaveEffects"
const BUS_CAVE_EFFECTS_ID := 1

signal monsters_weight_change(value: int, kill: bool)
signal monsters_spawn(value: int, kill: bool)
signal hp_change(value: int, hp_loss: bool)

func _ready():
	super._ready()
	#region Creating and registering audio players
	battleMusicStartingSound = generateMusicPlayer()
	battleMusicDefault = generateMusicPlayer(true)
	battleMusicMonstersWeight = generateMusicPlayer(true)
	battleMusicMonstersWeight2 = generateMusicPlayer(true)
	battleMusicTotalHp = generateMusicPlayer(true)
	battleMusicStrongestEnemy = generateMusicPlayer(true)
	add_child(battleMusicStartingSound)
	add_child(battleMusicDefault)
	add_child(battleMusicMonstersWeight)
	add_child(battleMusicMonstersWeight2)
	add_child(battleMusicTotalHp)
	add_child(battleMusicStrongestEnemy)
	
	allBattleMusicsPlayers = [
		battleMusicStartingSound,
		battleMusicDefault,
		battleMusicMonstersWeight,
		battleMusicMonstersWeight2,
		battleMusicTotalHp,
		battleMusicStrongestEnemy
	]
	#endregion
	
	AudioServer.add_bus(BUS_CAVE_EFFECTS_ID)
	AudioServer.set_bus_name(BUS_CAVE_EFFECTS_ID, BUS_CAVE_EFFECTS_NAME)
	# add effects to that bus
	
	monsters_weight_change.connect(set_music_based_on_monster_total_weight)
	monsters_spawn.connect(set_music_based_on_strongest_monster)
	hp_change.connect(set_music_based_on_hp)

func generateMusicPlayer(autoplay: bool = false) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.autoplay = autoplay
	player.bus = &"Music"
	return player
	
func generateCaveEffectPlayer() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.autoplay = false
	player.bus = BUS_CAVE_EFFECTS_NAME
	return player

func startBattleMusic():
	super.startBattleMusic()
	# they all should start playing, even if they are muted
	battleMusicDefault.volume_db = 0 # by default on

	# initialize music layers with default values
	set_music_based_on_monster_total_weight(0, false)
	set_music_based_on_strongest_monster(0, false)
	set_music_based_on_hp(Data.of("dome.health") + Data.of("inventory.sand") * Data.of("dome.autohealamount"), false)
	# manage volume/pitch there based on conditions
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		player.play()

func stopBattleMusic():
	super.stopBattleMusic()
	# stop every players, but should fade off to be less abrupt
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		stop_music(player, 0.0, 2.0)

#region Ambience
func playAmbienceMine():
	super.playAmbienceMine()
	# add/activate droplets/mine sound effects

func stopAmbienceMine():
	super.stopAmbienceMine()
	# stop new sounds here
#endregion

# Should be called on monster spawn AND kill
func set_music_based_on_monster_total_weight(monster_weight: int, monster_killed: bool):
	if monster_killed:
		if monster_weight < WEIGHT_CAP1:
			stop_music(battleMusicMonstersWeight)
		elif monster_weight < WEIGHT_CAP2:
			stop_music(battleMusicMonstersWeight2)
	else:
		battleMusicMonstersWeight.volume_db = 0 if monster_weight > WEIGHT_CAP1 else -60
		battleMusicMonstersWeight2.volume_db = 0 if monster_weight > WEIGHT_CAP2 else -60

# Should be called on monster spawn AND kill
func set_music_based_on_strongest_monster(monster_weight: int, monster_killed: bool):
	if monster_killed and monster_weight < BIGGEST_MONSTER_CAP:
		stop_music(battleMusicMonstersWeight)
	else:
		battleMusicStrongestEnemy.volume_db = 0 if monster_weight > BIGGEST_MONSTER_CAP else -60

# Should be called on any hp changes
func set_music_based_on_hp(hp: int, hp_loss: bool):
	if hp_loss and hp < HP_CAP:
		stop_music(battleMusicTotalHp)
	else:
		battleMusicTotalHp.volume_db = 0 if hp < HP_CAP else -60

# Untested, but should be called to fade away a player instead of abrupt end
func stop_music(audioPlayer: AudioStreamPlayer, delay:=0.0, fade:=6.0):
	$MusicTween.interpolate_property(audioPlayer, "volume_db", audioPlayer.volume_db, -60, fade, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	$MusicTween.interpolate_callback(audioPlayer, fade+delay, "stop")
