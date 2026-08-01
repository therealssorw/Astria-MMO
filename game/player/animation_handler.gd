extends Node

@export var animation_player: AnimationPlayer

func play(animation_name: StringName, blend_time: float = 0.15) -> void:
	if animation_player.current_animation == animation_name:
		return
	assert(animation_player.has_animation(animation_name), "No animation named '%s'" % animation_name)
	animation_player.play(animation_name, blend_time)
