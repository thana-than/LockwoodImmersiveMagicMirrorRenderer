@tool
extends Node3D
class_name ManagedLight

@export_group("Editor Tool")
enum LightType { OMNI, SPOT, DIRECTIONAL }
@export var light_type: LightType
@export var add_light: bool = false:
	set(value):
		if value:
			_create_light()
			add_light = false

@export var light_name_base := "ManagedLight"
@export var keep_parent_transform := true

@export_group("Runtime")
enum FlickerMode { OFF, INDEPENDENT, SYNCHRONIZED }
@export var flicker_mode: FlickerMode = FlickerMode.OFF
@export var flicker_freq_hz: float = 0.15 # How fast the flicker runs
@export var flicker_amp: float = 1.0 # 0..1, multiplies the base_energy for the lights
@export var flicker_seed: int = 666 # stable randomness to guarantee same behavior
@export var preview_in_editor: bool = false

var _flicker_time: float = 0.0
var _noise := FastNoiseLite.new()
var _base_energy_cache: Dictionary = {}

func _ready() -> void:
	_noise.seed = flicker_seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 1.0
	_cache_base_energy()
	
func _process(delta: float) -> void:
	var should_run := flicker_mode != FlickerMode.OFF and (preview_in_editor or not Engine.is_editor_hint())
	if not should_run:
		return
	_flicker_time += delta
	_apply_flicker()

func _cache_base_energy() -> void:
	_base_energy_cache.clear()
	var lights := get_lights()
	for c in lights:
		if not _base_energy_cache.has(c.name):
			_base_energy_cache[c.name] = {}
		
		var rng := RandomNumberGenerator.new()
		rng.seed = int(c.name.hash() ^ flicker_seed)
		
		_base_energy_cache[c.name] = {
			'base_energy': c.light_energy,
			'phase': rng.randf() * 1000.0,
		}

func _restore_cached_values() -> void:
	var lights := get_lights()
	for c in lights:
		if not _base_energy_cache.has(c.name):
			continue
		if not _base_energy_cache[c.name].has("base_energy"):
			continue
		c.light_energy = _base_energy_cache[c.name]["base_energy"]
	return

func _apply_flicker() -> void:
	var t := _flicker_time
	var freq_scale: float = max(0.001, flicker_freq_hz)
	var lights := get_lights()
	
	match flicker_mode:
		FlickerMode.SYNCHRONIZED:
			var v := _noise_value(t * freq_scale, 0.0) # -1..1
			for c in lights:
				if not _base_energy_cache.has(c.name):
					continue
				if not _base_energy_cache[c.name].has('base_energy'):
					continue
				var base := float(_base_energy_cache[c.name]['base_energy'])
				c.light_energy = base * _map_amp(v, flicker_amp)
		FlickerMode.INDEPENDENT:
			for c in lights:
				if not _base_energy_cache.has(c.name):
					continue
				if not _base_energy_cache[c.name].has('base_energy'):
					continue
				var base := float(_base_energy_cache[c.name]['base_energy'])
				var phase := float(_base_energy_cache[c.name]['phase'])
				var v:= _noise_value(t * freq_scale, phase)
				c.light_energy = base * _map_amp(v, flicker_amp)
		_:
			pass

func _noise_value(t, phase) -> float:
	return _noise.get_noise_2d(t, phase)

func _map_amp(n: float, amp: float) -> float:
	var m: float= 1.0 + n * clamp(amp, 0.0, 1.0)
	return max(0.001, m)

func get_lights() -> Array:
	var arr: Array = []
	for c in get_children():
		if c is Light3D:
			arr.append(c)
	return arr

func _make_unique_name() -> String:
	var max_index := 0
	var prefix := light_name_base + "_"
	for c in get_children():
		if c is Light3D and c.name.begins_with(prefix):
			var tail := c.name.substr(prefix.length())
			var i := int(tail) if tail.is_valid_int() else 0
			if i > max_index:
				max_index = i
	return "%s_%03d" % [light_name_base, max_index+1]

func _create_light() -> void:
	if not is_inside_tree():
		return
	
	var xform := Transform3D.IDENTITY
	if keep_parent_transform:
		xform = self.transform
	
	var new_light: Light3D
	match light_type:
		LightType.OMNI: 
			new_light = OmniLight3D.new()
		LightType.SPOT: 
			new_light = SpotLight3D.new()
		LightType.DIRECTIONAL: 
			new_light = DirectionalLight3D.new()
		_: 
			new_light = OmniLight3D.new()
	
	if new_light and is_instance_valid(new_light):
		new_light.name = _make_unique_name()
		add_child(new_light, true)
		if owner != null:
			new_light.owner = owner
		else:
			if Engine.is_editor_hint():
				new_light.owner = get_tree().edited_scene_root
		new_light.transform = xform
	
	property_list_changed.emit()

func _notification(what):
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			_restore_cached_values()
			self.preview_in_editor = false

func get_current_flicker_multiplier(light: Light3D = null) -> float:
	var should_run := flicker_mode != FlickerMode.OFF and (preview_in_editor or not Engine.is_editor_hint())
	if not should_run:
		return 1.0
	
	var freq_scale: float = max(0.001, flicker_freq_hz)
	var t := _flicker_time * freq_scale
	var v: float = 0.0

	match flicker_mode:
		FlickerMode.SYNCHRONIZED:
			v = _noise_value(t, 0.0)
		FlickerMode.INDEPENDENT:
			var phase := 0.0
			if light != null and _base_energy_cache.has(light.name) and _base_energy_cache[light.name].has("phase"):
				phase = float(_base_energy_cache[light.name]["phase"])
			v = _noise_value(t, phase)
		_:
			return 1.0  # safety

	return _map_amp(v, flicker_amp)
