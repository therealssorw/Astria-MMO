extends Node

signal state_changed(state_name: StringName)

@export var initial_state: Node
@export var player_input: Node

# States are children, named like the transition
var current_state: Node
# Holds a punch until a state accepts it
var punch_buffered := false

func _ready() -> void:
	player_input.punch_requested.connect(buffer_punch)
	for state in get_children():
		state.state_machine = self
	current_state = initial_state
	current_state.enter()

# Driven by player.gd, server side only
func physics_update(delta: float) -> void:
	current_state.physics_update(delta)

func transition_to(state_name: StringName) -> void:
	var next_state := get_node_or_null(NodePath(state_name))
	if next_state == null or next_state == current_state:
		return
	current_state.exit()
	current_state = next_state
	current_state.enter()
	state_changed.emit(state_name)

func buffer_punch() -> void:
	punch_buffered = true

# Reading the buffer also clears it
func consume_punch() -> bool:
	if not punch_buffered:
		return false
	punch_buffered = false
	return true

# Damage rules ask the current state
func is_blocking() -> bool:
	return current_state.blocks_damage
