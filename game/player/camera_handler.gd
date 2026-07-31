extends Node

@export_group("Core")
@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var mouse_sens: float = 0.005
@export var body: CharacterBody3D

@export_group("Sprint")
@export var normal_fov: float = 75.0
@export var sprint_fov: float = 88.0
var target_fov: float

func _ready() -> void:
	target_fov = normal_fov

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		body.rotate_y(-event.relative.x * mouse_sens) # player rotate y
		camera_pivot.rotate_x(-event.relative.y * mouse_sens) # camera pivot rotate x
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -90, 45) # limit camera pivot


func _on_movement_component_is_sprinting() -> void:
	target_fov = sprint_fov


func _on_movement_component_not_sprinting() -> void:
	target_fov = normal_fov


func _process(delta: float) -> void:
	camera.fov = lerpf(camera.fov, target_fov, delta * 4)
