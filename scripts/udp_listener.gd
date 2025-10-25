extends Node
class_name CandleClient

@export var port := 5005
@export var print_log := false

var udp := PacketPeerUDP.new()

func _ready():
	udp.bind(port)
	
func _log_data(data):
	print("Sequence: ", data["sequence"]["order"])
	print("State:    ", data["sequence"]["state"])
	for candle in data["candles"]:
		print("Candle: ", candle)
		
static func parse_state(str_name : String):
	match str_name:
		"DETECT":
			return Sequence.STATE.DETECT
		"INCORRECT":
			return Sequence.STATE.INCORRECT
		"CORRECT":
			return Sequence.STATE.CORRECT
	return Sequence.STATE.DETECT
	
func _process(_delta):
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(packet)
		if data:
			SequenceManager.state = Sequence.STATE[data["sequence"]["state"]]
			
			#Convert order into int array
			var order : Array[int] = []
			for id in data["sequence"]["order"]:
				order.append(int(id))
			SequenceManager.order = order
			# TODO record candle state (detection, bounds) somewhere that can be collected (maybe the order iteself?)
			if print_log:
				_log_data(data)
