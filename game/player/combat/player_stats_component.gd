extends Node

signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0
# Setter also fires when replication writes it
var current_health: float = 100.0: set = set_current_health

func apply_damage(amount: float) -> void:
	set_current_health(current_health - amount)

func heal(amount: float) -> void:
	set_current_health(current_health + amount)

func set_current_health(value: float) -> void:
	var clamped_health := clampf(value, 0.0, max_health)
	# Skip redundant signals from unchanged writes
	if clamped_health == current_health:
		return
	current_health = clamped_health
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()
