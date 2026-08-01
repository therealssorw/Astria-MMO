extends CharacterBody3D

@onready var player_input := $Scripts/PlayerInput
@onready var movement_component := $Scripts/MovementComponent
@onready var combat_component := $Scripts/CombatComponent
@onready var combat_state_machine := $Scripts/CombatStateMachine

func _enter_tree() -> void:
	# Server simulates, owner only sends rotation
	set_multiplayer_authority(1)
	$OwnerSync.set_multiplayer_authority(name.to_int())

# Node is named after its peer id
func is_owner() -> bool:
	return name.to_int() == multiplayer.get_unique_id()

func _ready() -> void:
	if not is_owner():
		# Only your own health bar shows
		$CombatHud.queue_free()
		return
	$CameraPivot/SpringArm3D/Camera3D.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if is_owner():
		player_input.send_input()

	# Everything below is server authoritative
	if not multiplayer.is_server():
		return

	# Combat first, it can lock animation
	combat_state_machine.physics_update(delta)
	movement_component.physics_update(delta)

	move_and_slide()

# Entry point used by another player's strike
func receive_damage(amount: float, source_position: Vector3) -> void:
	combat_component.receive_damage(amount, source_position)
