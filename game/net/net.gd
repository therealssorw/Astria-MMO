extends Node

#USE THIS IN PRODUCTION const SERVER_IP := "3.137.184.94"
const SERVER_IP := "127.0.0.1"
const PORT := 27032

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--offline"):
		return
	if args.has("--server"):
		host()
	else:
		join()

func host() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT)
	if err != OK:
		push_error("create_server on %d failed: %s" % [PORT, error_string(err)])
		return
	multiplayer.multiplayer_peer = peer
	print("hosting on ", PORT)

func join() -> void:
	var ip := SERVER_IP
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ip="):
			ip = a.split("=")[1]
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		push_error("create_client to %s:%d failed: %s" % [ip, PORT, error_string(err)])
		return
	multiplayer.connected_to_server.connect(func(): print("CONNECTED to ", ip))
	multiplayer.connection_failed.connect(func(): print("FAILED to reach ", ip))
	multiplayer.multiplayer_peer = peer
	print("connecting to %s:%d" % [ip, PORT])
