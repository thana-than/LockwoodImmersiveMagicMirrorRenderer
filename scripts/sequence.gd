extends Node
class_name Sequence

signal on_sequence_change(order : Array[int])
signal on_state_change(state : Sequence.STATE)

enum STATE {
	DETECT,
	INCORRECT,
	CORRECT
}

var state := Sequence.STATE.DETECT:
	get:
		return state
	set(value):
		var last_state = state
		state = value
		if last_state != state:
			on_state_change.emit(state)
			
var order : Array[int] = []:
	get:
		return order
	set(value):
		var last_order = order
		order = value
		
		if len(last_order) != len(order):
			on_sequence_change.emit(order)
