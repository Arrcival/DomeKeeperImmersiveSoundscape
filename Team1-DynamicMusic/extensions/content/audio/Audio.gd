extends "res://systems/audio/Audio.gd"

### UNTESTED

var additionalMineAmbience: AudioStreamPlayer

var battleMusicStartingSound: AudioStreamPlayer # based on wave number
var battleMusicDefault: AudioStreamPlayer
var battleMusicIntensity1: AudioStreamPlayer # monster amount

# amount of life + cobalt * heal < threshold -> plays music ?
var battleMusicIntensity2: AudioStreamPlayer # % of life AND considering cobalt
var battleMusicIntensity3: AudioStreamPlayer # strongest enemy

# intensity based on wave number ? monsters amount ? damage taken ? strongest enemy ?
# outside dome variations? -> perhaps deafen monsters ?

var allBattleMusicsPlayers: Array[AudioStreamPlayer] = [
	battleMusicStartingSound,
	battleMusicDefault,
	battleMusicIntensity1,
	battleMusicIntensity2,
	battleMusicIntensity3
]

const BUS_CAVE_EFFECTS_NAME := "CaveEffects"
const BUS_CAVE_EFFECTS_ID := 1

func _ready():
	super._ready()
	#region Creating and registering audio players
	battleMusicStartingSound = AudioStreamPlayer.new()
	battleMusicStartingSound.bus = &"Music"
	battleMusicDefault = AudioStreamPlayer.new()
	battleMusicDefault.autoplay = true
	battleMusicDefault.bus = &"Music"
	battleMusicIntensity1 = AudioStreamPlayer.new()
	battleMusicIntensity1.autoplay = true
	battleMusicIntensity1.bus = &"Music"
	battleMusicIntensity2 = AudioStreamPlayer.new()
	battleMusicIntensity2.autoplay = true
	battleMusicIntensity2.bus = &"Music"
	battleMusicIntensity3 = AudioStreamPlayer.new()
	battleMusicIntensity3.autoplay = true
	battleMusicIntensity3.bus = &"Music"
	add_child(battleMusicStartingSound)
	add_child(battleMusicDefault)
	add_child(battleMusicIntensity1)
	add_child(battleMusicIntensity2)
	add_child(battleMusicIntensity3)
	
	allBattleMusicsPlayers = [
		battleMusicStartingSound,
		battleMusicDefault,
		battleMusicIntensity1,
		battleMusicIntensity2,
		battleMusicIntensity3
	]
	#endregion
	
	AudioServer.add_bus(BUS_CAVE_EFFECTS_ID)
	AudioServer.set_bus_name(BUS_CAVE_EFFECTS_ID, BUS_CAVE_EFFECTS_NAME)
	# add effects to that bus

func playAmbienceMine():
	super.playAmbienceMine()
	# add/activate droplets/mine sound effects

func stopAmbienceMine():
	super.stopAmbienceMine()
	# stop new sounds here

func startBattleMusic():
	super.startBattleMusic()
	# they all should start playing, even if they are muted
	
	# manage volume/pitch there based on conditions
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		player.play()

func stopBattleMusic():
	super.stopBattleMusic()
	# stop every players, but should fade off to be less abrupt
	for player: AudioStreamPlayer in allBattleMusicsPlayers:
		player.stop()
