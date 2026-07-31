extends Node

@export var normal_speed: float = 5.0
@export var sprint_speed: float = 9.0
var speed: float
@export var jump_vel = 4.5
@export var body: CharacterBody3D

signal is_sprinting
signal not_sprinting

func physics_update(delta: float):
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and body.is_on_floor():
		body.velocity.y = jump_vel

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var sprint_state: bool = Input.is_action_pressed("sprint")
	
	if direction:
		if sprint_state == true:
			speed = sprint_speed
			is_sprinting.emit()
		else:
			speed = normal_speed
			not_sprinting.emit()
			
		body.velocity.x = direction.x * speed
		body.velocity.z = direction.z * speed
	else:
		body.velocity.x = 0
		body.velocity.z = 0
