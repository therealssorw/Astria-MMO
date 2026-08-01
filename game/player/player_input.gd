extends Node

@export var body: CharacterBody3D

# Latest intent, read by server components
var move_direction := Vector2.ZERO
var sprint_held := false
var jump_held := false
var block_held := false

# Punch is an edge, not held
signal punch_requested

# Owner only, called every physics frame
func send_input() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	var sprinting := Input.is_action_pressed("sprint")
	var jumping := Input.is_action_pressed("ui_accept")
	var blocking := Input.is_action_pressed("block")
	# Host applies locally, clients send upstream
	if multiplayer.is_server():
		apply_input(direction, sprinting, jumping, blocking)
	else:
		push_input.rpc_id(1, direction, sprinting, jumping, blocking)

	if not Input.is_action_just_pressed("punch"):
		return
	if multiplayer.is_server():
		punch_requested.emit()
	else:
		push_punch.rpc_id(1)

func apply_input(direction: Vector2, sprinting: bool, jumping: bool, blocking: bool) -> void:
	move_direction = direction
	sprint_held = sprinting
	jump_held = jumping
	block_held = blocking

# Stops peers from driving other players
func is_sender_the_owner() -> bool:
	return multiplayer.get_remote_sender_id() == body.name.to_int()

# Held state, a dropped packet is harmless
@rpc("any_peer", "call_remote", "unreliable_ordered")
func push_input(direction: Vector2, sprinting: bool, jumping: bool, blocking: bool) -> void:
	if is_sender_the_owner():
		apply_input(direction, sprinting, jumping, blocking)

# Reliable, a dropped punch is gone
@rpc("any_peer", "call_remote", "reliable")
func push_punch() -> void:
	if is_sender_the_owner():
		punch_requested.emit()
