extends CanvasLayer

# Owner only, player.gd frees it otherwise

@export var health_bar: ProgressBar
@export var health_label: Label
@export var stats_component: Node

func _ready() -> void:
	# Replicated health fires this on clients
	stats_component.health_changed.connect(update_health)
	update_health(stats_component.current_health, stats_component.max_health)

func update_health(current_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = "%d / %d" % [roundi(current_health), roundi(max_health)]
