extends Node

signal player_connected(peer_id:int, player_info:Dictionary)
signal player_disconnected(peer_id:int)
signal server_disconnected

const PORT := 7000
const DEFAULT_SERVER_IP := "127.0.0.1"
const MAX_CONNECTIONS := 10

## Dictionary of player id to their information.
var players : Dictionary[int, Dictionary]

var players_loaded : int = 0

var player_info := {
	"name": "Nameless",
	"player_id": -1
}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Every peer will call this when they have loaded the game scene.
#@rpc("any_peer", "call_local", "reliable")
#func player_loaded() -> void:
	#if multiplayer.is_server():
		#players_loaded += 1
		#if players_loaded == players.size():
			#$/root/Game.start_game()
			#players_loaded = 0

#region Game stuff

func get_local_player() -> Player:
	var id : int = player_info[multiplayer.get_unique_id()]["player_id"]
	if id == -1: return null
	return instance_from_id(id)

@rpc("any_peer", "reliable")
func set_local_player(player : Player) -> void:
	player_info[multiplayer.get_remote_sender_id()]["player_id"] = player.get_instance_id()

#endregion

#region Lobby management
func create_game() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(player_info)
	
	Log.connection("Created lobby")
	
	return Error.OK

func join_game(address := "") -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)
	if error: return error
	multiplayer.multiplayer_peer = peer
	
	Log.connection("Joined Lobby " + address + " as peer " + str(multiplayer.get_unique_id()))
	
	return Error.OK

func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = ENetMultiplayerPeer.new()
	players.clear()
#endregion

#region Signal logic
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id:int) -> void:
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info:Dictionary) -> void:
	var new_player_id := multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id:int) -> void:
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail() -> void:
	remove_multiplayer_peer()

func _on_server_disconnected() -> void:
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
#endregion
