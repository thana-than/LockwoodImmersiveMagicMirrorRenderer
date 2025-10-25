extends Node

const _settings_resource = preload("res://resources/candle_settings.tres")
var _candle_dict : Dictionary[int, CandleResource] = {}

var candle_settings: Array[CandleResource]: 
	get:
		return _settings_resource.candle_settings as Array[CandleResource]

func _ready() -> void:
	for setting in candle_settings:
		_candle_dict.set(setting.id, setting)
		
func get_candle_count():
	return len(candle_settings)
		
func get_candle(id : int) -> CandleResource:
	return _candle_dict.get(id) as CandleResource
