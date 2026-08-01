extends CharacterBody3D

@onready var move_c := $Scripts/MovementComponent

var move := Vector2.ZERO
var sprint := false
var jump := false

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
		var m := Input.get_vector("left", "right", "up", "down")
		var s := Input.is_action_pressed("sprint")
		var j := Input.is_action_pressed("ui_accept")
		if multiplayer.is_server():
			apply_input(m, s, j)
		else:
			push_input.rpc_id(1, m, s, j)

	if not multiplayer.is_server():
		return

	move_c.physics_update(delta)

	move_and_slide()

func apply_input(m: Vector2, s: bool, j: bool) -> void:
	move = m
	sprint = s
	jump = j

@rpc("any_peer", "call_remote", "unreliable_ordered")
func push_input(m: Vector2, s: bool, j: bool) -> void:
	if multiplayer.get_remote_sender_id() == name.to_int():
		apply_input(m, s, j)
