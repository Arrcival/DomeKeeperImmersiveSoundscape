extends Node

const MYMODNAME_MOD_DIR = "TeamSquidley-DynamicMusic/"
const MYMODNAME_LOG = "TeamSquidley-DynamicMusic"

const EXTENSIONS_DIR = "extensions/"

func _init(modLoader = ModLoader):
	ModLoaderLog.info("init starting", MYMODNAME_LOG)
	var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	var ext_dir = dir + EXTENSIONS_DIR
	
	# Add extensions
	loadExtension(ext_dir, "content/audio/Audio.gd")
	loadExtension(ext_dir, "content/keeper/keeperaudiotriggers.gd")
	loadExtension(ext_dir, "content/monster/Beast/Beast.gd")
	loadExtension(ext_dir, "content/monster/bigtick/BigTick.gd")
	loadExtension(ext_dir, "content/monster/diver/Diver.gd")
	loadExtension(ext_dir, "content/monster/driller/Driller.gd")
	loadExtension(ext_dir, "content/monster/hornet/Hornet.gd")
	loadExtension(ext_dir, "content/monster/mucker/Mucker.gd")
	loadExtension(ext_dir, "content/monster/phaser/Phaser.gd")
	loadExtension(ext_dir, "content/monster/rockman/Rockman.gd")
	loadExtension(ext_dir, "content/monster/tick/Tick.gd")
	loadExtension(ext_dir, "content/monster/walker/Walker.gd")
	loadExtension(ext_dir, "content/monster/worm/Rock.gd")
	loadExtension(ext_dir, "content/projectiles/DirectProjectile.gd")
	loadExtension(ext_dir, "content/projectiles/PathProjectile.gd")
	
	ModLoaderLog.info("init done", MYMODNAME_LOG)

func modInit():
	pass
	
func _ready():
	ModLoaderLog.info("_ready starting", MYMODNAME_LOG)
	add_to_group("mod_init")
	ModLoaderLog.info("_ready done", MYMODNAME_LOG)

func loadExtension(ext_dir, fileName):
	ModLoaderMod.install_script_extension(ext_dir + fileName)

