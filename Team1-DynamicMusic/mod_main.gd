extends Node

const MYMODNAME_MOD_DIR = "Team1-DynamicMusic/"
const MYMODNAME_LOG = "Team1-DynamicMusic"

const EXTENSIONS_DIR = "extensions/"

func _init(modLoader = ModLoader):
	ModLoaderLog.info("init starting", MYMODNAME_LOG)
	var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	var ext_dir = dir + EXTENSIONS_DIR
	
	# Add extensions
	loadExtension(ext_dir, "content/keeper/keeperaudiotriggers.gd")
	loadExtension(ext_dir, "content/audio/Audio.gd")
	
	ModLoaderLog.info("init done", MYMODNAME_LOG)

func modInit():
	pass
	
func _ready():
	ModLoaderLog.info("_ready starting", MYMODNAME_LOG)
	add_to_group("mod_init")
	ModLoaderLog.info("_ready done", MYMODNAME_LOG)

func loadExtension(ext_dir, fileName):
	ModLoaderMod.install_script_extension(ext_dir + fileName)

