extends Node

# Server only, owns all damage rules

@export var body: CharacterBody3D
@export var stats_component: Node
@export var combat_state_machine: Node
# Empty marker at chest height
@export var strike_origin: Node3D

@export_group("Strike")
@export var damage: float = 12.0
# Metres forward from the strike origin
@export var reach: float = 1.4
@export var strike_radius: float = 0.5
@export var maximum_targets: int = 8

@export_group("Block")
# Blocked hits keep this fraction of damage
@export var block_damage_multiplier: float = 0.2
@export var block_arc_degrees: float = 120.0

# Fired once per punch, at full extension
func strike() -> void:
	var strike_shape := SphereShape3D.new()
	strike_shape.radius = strike_radius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = strike_shape
	# Negative Z is forward in Godot
	query.transform = Transform3D(Basis(), strike_origin.global_position - body.global_basis.z * reach)
	# Never punch yourself
	query.exclude = [body.get_rid()]

	for collision in body.get_world_3d().direct_space_state.intersect_shape(query, maximum_targets):
		var target: Object = collision.collider
		# Walls and props simply ignore this
		if target.has_method("receive_damage"):
			target.receive_damage(damage, body.global_position)

# Runs on the victim, not the attacker
func receive_damage(amount: float, source_position: Vector3) -> void:
	if combat_state_machine.is_blocking() and is_facing(source_position):
		amount *= block_damage_multiplier
	stats_component.apply_damage(amount)

# Blocking never protects your back
func is_facing(source_position: Vector3) -> bool:
	var to_source := source_position - body.global_position
	# Height difference must not skew the angle
	to_source.y = 0.0
	if to_source.is_zero_approx():
		return true
	return rad_to_deg((-body.global_basis.z).angle_to(to_source.normalized())) <= block_arc_degrees * 0.5
