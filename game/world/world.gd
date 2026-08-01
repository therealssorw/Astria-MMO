extends Node3D

const PLAYER_SCENE := preload("res://game/player/player.tscn")

@onready var players: Node3D = $Players

func _ready() -> void:
	if not multiplayer.has_multiplayer_peer() or not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(spawn)
	multiplayer.peer_disconnected.connect(despawn)
	if DisplayServer.get_name() != "headless":
		spawn(1)

func spawn(peer_id: int) -> void:
	var player := PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.position = Vector3(players.get_child_count() * 2.0, 1.5, 0)
	players.add_child(player, true)

func despawn(peer_id: int) -> void:
	var player := players.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
