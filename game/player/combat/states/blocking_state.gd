extends CombatState

# Held while the block button is down

@export var player_input: Node
@export var animation_handler: Node
@export var animation_name: StringName = &"Block"

func enter() -> void:
	# Non looping, holds on its last frame
	animation_handler.play(animation_name, animation_priority)

func exit() -> void:
	# Hands the animation back to movement
	animation_handler.release()

func physics_update(_delta: float) -> void:
	# You can punch straight out of a block
	if state_machine.consume_punch():
		state_machine.transition_to(&"PunchingState")
	elif not player_input.block_held:
		state_machine.transition_to(&"IdleState")
