extends Node

var instanced_particle_systems : Dictionary[int, GPUParticles3D] = {}

func _ready():
	SequenceManager.on_sequence_change.connect(refresh)
	for candle in CandleManager.candle_settings:
		var ps = candle.warp_particles.instantiate() as GPUParticles3D
		ps.emitting = false
		add_child(ps)
		instanced_particle_systems.set(candle.id, ps)
	
func refresh(sequence : Array[int]):
	for key in instanced_particle_systems.keys():
		instanced_particle_systems[key].emitting = false
	
	for id in sequence:
		instanced_particle_systems[id].emitting = true
