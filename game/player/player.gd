extends CharacterBody3D

@onready var move_c := $Scripts/MovementComponent

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	move_c.physics_update(delta)

	move_and_slide()
