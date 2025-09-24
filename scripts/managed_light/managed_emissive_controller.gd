extends MeshInstance3D

@export var managed_light_instance: ManagedLight

var _cached_lights: Array[Light3D] = []
var _cached_emission_strength: float = 1.0
var _mat: ShaderMaterial

func _ready() -> void:
	if not managed_light_instance:
		return
	_cached_lights = _get_children_of_light()
	_mat = self.get_active_material(0) as ShaderMaterial
	if _mat:
		self.set_surface_override_material(0, _mat.duplicate())
		_mat = self.get_active_material(0)
		_cached_emission_strength = _mat.get_shader_parameter("emission_strength")
	
func _get_children_of_light() -> Array[Light3D]:
	var result: Array[Light3D] = []
	for c in managed_light_instance.get_children():
		if c is Node and c.is_class("Light3D"):
			result.append(c)
	return result
	
func _process(_delta: float) -> void:
	if not _mat:
		return
	var mult: float = 1.0
	match managed_light_instance.flicker_mode:
		ManagedLight.FlickerMode.OFF:
			return
		ManagedLight.FlickerMode.SYNCHRONIZED:
			mult = managed_light_instance.get_current_flicker_multiplier()
		ManagedLight.FlickerMode.INDEPENDENT:
			for c in _cached_lights:
				mult = min(managed_light_instance.get_current_flicker_multiplier(c), mult)
	_mat.set_shader_parameter("emission_strength", _cached_emission_strength * mult)
