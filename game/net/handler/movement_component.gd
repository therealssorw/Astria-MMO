extends Node

# Server only, moves the body from input

@export var normal_speed: float = 5.0
@export var sprint_speed: float = 9.0
var speed: float
@export var jump_velocity = 4.5
@export var body: CharacterBody3D
@export var player_input: Node
@export var animation_handler: Node

signal is_sprinting
signal not_sprinting

func physics_update(delta: float):
	var grounded := body.is_on_floor()

	if not grounded:
		body.velocity += body.get_gravity() * delta

	if player_input.jump_held and grounded:
		body.velocity.y = jump_velocity

	# Input is local, basis makes it world
	var direction := (body.transform.basis * Vector3(player_input.move_direction.x, 0, player_input.move_direction.y)).normalized()

	var sprint_state: bool = player_input.sprint_held

	# Priority zero, combat states override these
	if direction:
		if sprint_state == true:
			speed = sprint_speed
			is_sprinting.emit()
			animation_handler.play("Run" if grounded else "Jump")
		else:
			speed = normal_speed
			not_sprinting.emit()
			animation_handler.play("Walk" if grounded else "Jump")

		body.velocity.x = direction.x * speed
		body.velocity.z = direction.z * speed
	else:
		body.velocity.x = 0
		body.velocity.z = 0
		animation_handler.play("Idle" if grounded else "Jump")
