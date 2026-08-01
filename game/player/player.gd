extends CharacterBody3D

@onready var movement_component := $Scripts/MovementComponent

var move_direction := Vector2.ZERO
var sprint_held := false
var jump_held := false

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	$OwnerSync.set_multiplayer_authority(name.to_int())

func is_owner() -> bool:
	return name.to_int() == multiplayer.get_unique_id()

func _ready() -> void:
	if not is_owner():
		return
	$CameraPivot/SpringArm3D/Camera3D.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if is_owner():
		var direction := Input.get_vector("left", "right", "up", "down")
		var sprinting := Input.is_action_pressed("sprint")
		var jumping := Input.is_action_pressed("ui_accept")
		if multiplayer.is_server():
			apply_input(direction, sprinting, jumping)
		else:
			push_input.rpc_id(1, direction, sprinting, jumping)

	if not multiplayer.is_server():
		return

	movement_component.physics_update(delta)

	move_and_slide()

func apply_input(direction: Vector2, sprinting: bool, jumping: bool) -> void:
	move_direction = direction
	sprint_held = sprinting
	jump_held = jumping

@rpc("any_peer", "call_remote", "unreliable_ordered")
func push_input(direction: Vector2, sprinting: bool, jumping: bool) -> void:
	if multiplayer.get_remote_sender_id() == name.to_int():
		apply_input(direction, sprinting, jumping)
