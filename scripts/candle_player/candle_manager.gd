extends Node

@export var candle_settings: Array[CandleSetting]
@export var spacing := Vector3(1.0, 0.0, 0.0)

var _candle_dict : Dictionary[int, CandleSetting] = {}
var _instanced_candles : Array[FireBall] = []
var _child_root_transform : Node3D

func _ready():
	for setting in candle_settings:
		_candle_dict.set(setting.id, setting)
	
	setup_root()
	
	if not Engine.is_editor_hint():
		SequenceManager.on_sequence_change.connect(refresh)
	
func setup_root():
	if not _child_root_transform:
		_child_root_transform = Node3D.new()
		_child_root_transform.name = "CandleRoot"
		add_child(_child_root_transform)
	
	_child_root_transform.position = -spacing * (len(candle_settings) - 1) * .5
	

func refresh(sequence : Array[int]):
	for i in range(len(_instanced_candles), len(sequence)):
		var setting = _candle_dict.get(sequence[i]) as CandleSetting
		var instance = setting.prefab.instantiate()
		_child_root_transform.add_child(instance)
		instance.position = spacing * i
		_instanced_candles.append(instance)
	
	for i in range(len(_instanced_candles), len(sequence), -1):
		_instanced_candles.pop_back().remove()
