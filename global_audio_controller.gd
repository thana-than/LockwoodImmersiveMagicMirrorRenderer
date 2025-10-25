extends Node

@onready var sfx_fire_ambient : FmodEventEmitter2D = get_node("FireAmbient")
@onready var sfx_fire_out : FmodEventEmitter2D = get_node("FireOut")
@onready var sfx_correct : FmodEventEmitter2D = get_node("Correct")
@onready var sfx_incorrect : FmodEventEmitter2D = get_node("Incorrect")

func _ready():
	SequenceManager.on_sequence_change.connect(on_sequence_change)
	SequenceManager.on_state_change.connect(on_state_change)

func reset():
	sfx_fire_ambient.stop()
	
func on_state_change(state : Sequence.STATE):
	match state:
		Sequence.STATE.INCORRECT:
			sfx_incorrect.play(false)
			sfx_fire_ambient.stop()
		Sequence.STATE.CORRECT:
			sfx_correct.play(false)
		Sequence.STATE.DETECT:
			sfx_incorrect.stop()
			sfx_correct.stop()

func on_sequence_change(order : Array[int]):
	var count = len(order)
	if count == 0:
		sfx_fire_ambient.stop()
		sfx_fire_out.play(false)
	elif SequenceManager.state != Sequence.STATE.INCORRECT:
		sfx_fire_ambient.set_parameter("SequenceSize", count)
		sfx_fire_ambient.play(false)
