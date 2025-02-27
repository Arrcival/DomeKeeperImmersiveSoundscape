extends Node
var timer

# Called when the node enters the scene tree for the first time.
func useHit(chain: ModLoaderHookChain,keeper:Keeper):
	chain.execute_next([keeper])
	var pitchEffect = AudioEffectPitchShift
	pitchEffect.pitch_scale = 1.5
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Master"),pitchEffect)
	var timer = Timer.new()
	timer.wait_time = 3 
	timer.connect("timeout", _on_Timer_timeout)
	add_child(timer)
	timer.start()
	
func _on_Timer_timeout():
	for i in range(AudioServer.get_bus_effect_count(AudioServer.get_bus_index(Audio.BUS_MASTER))):
			var effect = AudioServer.get_bus_effect(AudioServer.get_bus_index(Audio.BUS_MASTER), i)
			if effect is AudioEffectPitchShift:
				AudioServer.remove_bus_effect(AudioServer.get_bus_index(Audio.BUS_MASTER),i)
				timer = null
	return null
	
