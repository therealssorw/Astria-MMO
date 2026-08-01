extends CombatState

# Default state, movement owns the animation

@export var player_input: Node

func physics_update(_delta: float) -> void:
	# Punch wins, blocking is only held
	if state_machine.consume_punch():
		state_machine.transition_to(&"PunchingState")
	elif player_input.block_held:
		state_machine.transition_to(&"BlockingState")
