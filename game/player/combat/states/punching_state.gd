extends CombatState

# Windup, then one hit, then recovery

@export var combat_component: Node
@export var animation_handler: Node
@export var left_animation_name: StringName = &"PunchLeft"
@export var right_animation_name: StringName = &"PunchRight"
# Timings must match the animation length
@export var windup_duration: float = 0.16
@export var recovery_duration: float = 0.32

var elapsed_time := 0.0
# Guarantees one strike per punch
var has_struck := false
var uses_left_fist := false

func enter() -> void:
	elapsed_time = 0.0
	has_struck = false
	# Fists alternate on every punch
	uses_left_fist = not uses_left_fist
	animation_handler.play(left_animation_name if uses_left_fist else right_animation_name, animation_priority)

func exit() -> void:
	animation_handler.release()

func physics_update(delta: float) -> void:
	elapsed_time += delta

	# Hit lands at full arm extension
	if not has_struck and elapsed_time >= windup_duration:
		has_struck = true
		combat_component.strike()

	# Recovery doubles as the punch cooldown
	if elapsed_time >= windup_duration + recovery_duration:
		state_machine.transition_to(&"IdleState")
