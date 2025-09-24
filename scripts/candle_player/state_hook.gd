extends Node
class_name StateHook

signal on_state_changed(state : Sequence.STATE)
signal on_reset()
signal on_correct()
signal on_incorrect()

func _ready():
	SequenceManager.on_state_change.connect(_state_changed)

func _state_changed(state : Sequence.STATE):
	on_state_changed.emit(state)
	match state:
		Sequence.STATE.DETECT:
			on_reset.emit()
		Sequence.STATE.CORRECT:
			on_correct.emit()
		Sequence.STATE.INCORRECT:
			on_incorrect.emit()
