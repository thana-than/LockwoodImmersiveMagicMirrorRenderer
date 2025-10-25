@tool
extends Node
class_name FireBall

@export var flame_color := Color.WHITE:
	get:
		return flame_color
	set(value):
		flame_color = value
		_refresh_flame_color(value)
		
@export var light_color := Color.WHITE:
	get:
		return light_color
	set(value):
		light_color = value
		_refresh_light_color(value)

@export var destroy_delay := 2
		
@export_tool_button("Start Emission", "Callable") var start_action = start
@export_tool_button("Stop Emission", "Callable") var stop_action = stop

@onready var sfx_ignite : FmodEventEmitter2D = get_node("Audio/Ignite")

var particle_systems : Array[GPUParticles3D] = []
var lights : Array[Light3D] = []

var instanced_meshes : Dictionary[String, Mesh] = {}

func start():
	for p in particle_systems:
		p.emitting = true
	for l in lights:
		l.visible = true
		
	sfx_ignite.play(false)
	
func stop():
	for p in particle_systems:
		p.emitting = false
	for l in lights:
		l.visible = false
	
	sfx_ignite.stop()
		
func remove():
	stop()
	await get_tree().create_timer(destroy_delay).timeout
	queue_free()
	
func _get_nodes():
	particle_systems.clear()
	lights.clear()
	
	for child in get_node("Particles").get_children():
		if child is GPUParticles3D:
			particle_systems.append(child)
			
	for child in get_node("Lights").get_children():
		if child is Light3D:
			lights.append(child)

func _enter_tree():
	_get_nodes()
	
func _ready():
	if len(particle_systems) < 0 or len(lights) < 0:
		_get_nodes()
		
	_refresh_flame_color(flame_color)
	_refresh_light_color(light_color)
	start()
		
func _refresh_flame_color(value):
	for p in particle_systems:
		_update_particle_color(p, value)
	
func _refresh_light_color(value):	
	for l in lights:
		l.light_color = value
		
func _update_particle_color(particle_system : GPUParticles3D, color : Color):	
	var mesh = instanced_meshes.get(particle_system.name)
	
	if not mesh or mesh != particle_system.draw_pass_1:
		mesh = particle_system.draw_pass_1.duplicate(true)
		mesh.resource_local_to_scene = true
		instanced_meshes.set(particle_system.name, mesh)
		particle_system.draw_pass_1 = mesh

	var mat = mesh.surface_get_material(0)
	mat.set_shader_parameter("Color", color)
