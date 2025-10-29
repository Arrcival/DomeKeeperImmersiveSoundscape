extends Node

const MYMODNAME_MOD_DIR = "TeamSquidley-ImmersiveSoundscape/"
const MYMODNAME_LOG = "TeamSquidley-ImmersiveSoundscape"

const EXTENSIONS_DIR = "extensions/"
const HOOKS_DIR = "hooks/"


func _init(modLoader = ModLoader):
	ModLoaderLog.info("init starting", MYMODNAME_LOG)
	var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	var ext_dir = dir + EXTENSIONS_DIR
	var hooks_dir = dir + HOOKS_DIR
	
	# Add extensions
	loadExtension(ext_dir, "content/audio/Audio.gd")
	loadExtension(ext_dir, "game/GameWorld.gd")
	loadExtension(ext_dir, "content/caves/mushroomcave/MushroomCave.gd")
	loadExtension(ext_dir, "systems/data/Data.gd")
	loadExtension(ext_dir, "content/hud/wavemeter/WaveMeter.gd")
	loadExtension(ext_dir, "content/gamemode/assignments/Assignments.gd")
	loadExtension(ext_dir, "content/gamemode/relichunt/Relichunt.gd")
	loadExtension(ext_dir, "content/sounds/monster/ambience/BattleAmbience.gd")
	loadExtension(ext_dir, "content/keeper/engineeraudiotriggers.gd")
	loadExtension(ext_dir, "content/keeper/assessoraudiotriggers.gd")
	loadExtension(ext_dir, "content/projectiles/DirectProjectile.gd")
	loadExtension(ext_dir, "content/projectiles/PathProjectile.gd")
	#loadExtension(ext_dir, "content/gadgets/mushroomfarm/MyzelOverlay.gd") # preload dans Tile :/
	
	# Find a way to not have the Monsters hook
	loadHook("res://content/monster/Monsters.gd", hooks_dir, "Monsters.hooks.gd")
	loadHook("res://content/caves/Cave.gd", hooks_dir, "Cave.hooks.gd")
	
	ModLoaderLog.info("init done", MYMODNAME_LOG)

func modInit():
	if OS.has_feature("standalone"):
		var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
		var load_hooks_pack_success := ProjectSettings.load_resource_pack(dir.path_join("Domegd.zip"))
		print("load success?: ", load_hooks_pack_success)

func _ready():
	ModLoaderLog.info("_ready starting", MYMODNAME_LOG)
	add_to_group("mod_init")
	ModLoaderLog.info("_ready done", MYMODNAME_LOG)

func loadExtension(ext_dir, fileName):
	ModLoaderMod.install_script_extension(ext_dir + fileName)

func loadHook(vanilla_class, hooks_dir, fileName):
	ModLoaderMod.install_script_hooks(vanilla_class, hooks_dir + fileName)
