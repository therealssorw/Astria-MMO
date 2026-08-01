extends Node

#USE THIS IN PRODUCTION const SERVER_ADDRESS := "3.137.184.94"
const SERVER_ADDRESS := "127.0.0.1"
const SERVER_PORT := 27032

func has_launch_flag(flag: String) -> bool:
	return OS.get_cmdline_user_args().has(flag) or OS.get_cmdline_args().has(flag)

func launch_value(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if argument.begins_with(prefix):
			return argument.substr(prefix.length())
	return ""

func should_host() -> bool:
	return OS.has_feature("server") or OS.has_feature("dedicated_server") or has_launch_flag("--server")

func _ready() -> void:
	if has_launch_flag("--offline"):
		return
	if should_host():
		host()
	else:
		join()

func host() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(SERVER_PORT)
	if error != OK:
		push_error("create_server on %d failed: %s" % [SERVER_PORT, error_string(error)])
		return
	multiplayer.multiplayer_peer = peer
	print("hosting on ", SERVER_PORT)

func join() -> void:
	var address := launch_value("--ip=")
	if address == "":
		address = SERVER_ADDRESS
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, SERVER_PORT)
	if error != OK:
		push_error("create_client to %s:%d failed: %s" % [address, SERVER_PORT, error_string(error)])
		return
	multiplayer.connected_to_server.connect(func(): print("CONNECTED to ", address))
	multiplayer.connection_failed.connect(func(): print("FAILED to reach ", address))
	multiplayer.multiplayer_peer = peer
	print("connecting to %s:%d" % [address, SERVER_PORT])
