extends Node
class_name CombatState

# Base class, every combat state extends this

# Whether damage taken here gets reduced
@export var blocks_damage := false
# Beats movement animations, which use zero
@export var animation_priority: int = 10

# Assigned by the state machine on ready
var state_machine: Node

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
