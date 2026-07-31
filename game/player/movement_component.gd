extends Node

@export var normal_speed: float = 5.0
@export var sprint_speed: float = 9.0
var speed: float
@export var jump_vel = 4.5
@export var body: CharacterBody3D
@export var anim: Node

signal is_sprinting
signal not_sprinting

func physics_update(delta: float):
	var grounded := body.is_on_floor()

	if not grounded:
		body.velocity += body.get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and grounded:
		body.velocity.y = jump_vel

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var sprint_state: bool = Input.is_action_pressed("sprint")

	if direction:
		if sprint_state == true:
			speed = sprint_speed
			is_sprinting.emit()
			anim.play("Run" if grounded else "Jump")
		else:
			speed = normal_speed
			not_sprinting.emit()
			anim.play("Walk" if grounded else "Jump")

		body.velocity.x = direction.x * speed
		body.velocity.z = direction.z * speed
	else:
		body.velocity.x = 0
		body.velocity.z = 0
		anim.play("Idle" if grounded else "Jump")
