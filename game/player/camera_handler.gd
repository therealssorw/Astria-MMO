extends Node

@export_group("Core")
@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var mouse_sensitivity: float = 0.005
@export var body: CharacterBody3D

@export_group("Sprint")
@export var normal_field_of_view: float = 75.0
@export var sprint_field_of_view: float = 88.0
var target_field_of_view: float

func _ready() -> void:
	target_field_of_view = normal_field_of_view

func _input(event: InputEvent) -> void:
	if not body.is_owner():
		return
	if event is InputEventMouseMotion:
		body.rotate_y(-event.relative.x * mouse_sensitivity) # player rotate y
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity) # camera pivot rotate x
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -90, 45) # limit camera pivot


func _on_movement_component_is_sprinting() -> void:
	target_field_of_view = sprint_field_of_view


func _on_movement_component_not_sprinting() -> void:
	target_field_of_view = normal_field_of_view


func _process(delta: float) -> void:
	camera.fov = lerpf(camera.fov, target_field_of_view, delta * 4)
