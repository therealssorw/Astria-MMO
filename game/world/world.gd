extends Node3D

const PLAYER := preload("res://game/player/player.tscn")

@onready var players: Node3D = $Players

func _ready() -> void:
	if not multiplayer.has_multiplayer_peer() or not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(spawn)
	multiplayer.peer_disconnected.connect(despawn)
	if DisplayServer.get_name() != "headless":
		spawn(1)

func spawn(id: int) -> void:
	var p := PLAYER.instantiate()
	p.name = str(id)
	p.position = Vector3(players.get_child_count() * 2.0, 1.5, 0)
	players.add_child(p, true)

func despawn(id: int) -> void:
	var p := players.get_node_or_null(str(id))
	if p:
		p.queue_free()
