extends Node

@export var animation_player: AnimationPlayer

func play(anim: StringName, blend: float = 0.15) -> void:
	if animation_player.current_animation == anim:
		return
	assert(animation_player.has_animation(anim), "No animation named '%s'" % anim)
	animation_player.play(anim, blend)
