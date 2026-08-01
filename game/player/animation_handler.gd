extends Node

@export var animation_player: AnimationPlayer

# Tracks who currently owns the animation
var active_animation := &""
var active_priority := 0

# Movement passes 0, combat states pass 10
func play(animation_name: StringName, priority: int = 0, blend_time: float = 0.15) -> void:
	# Walk cannot interrupt an active punch
	if priority < active_priority:
		return
	if animation_name == active_animation:
		return
	assert(animation_player.has_animation(animation_name), "No animation named '%s'" % animation_name)
	active_animation = animation_name
	active_priority = priority
	animation_player.play(animation_name, blend_time)

# Combat states call this when leaving
func release() -> void:
	active_animation = &""
	active_priority = 0
