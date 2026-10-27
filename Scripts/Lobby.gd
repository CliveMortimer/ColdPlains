extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 9999
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"name": "Player",
	"life_length": -1,
	"id": -1
}

var players_loaded = 0
var timer = 0.5
var gameover = false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	if player_info["name"] == "Player":
		player_info["name"] += "1"
	player_info["id"] = 1
	
	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_node_path):
	if multiplayer.is_server():
		#get_node(game_node_path).add_player(1)
		for id in players:
			get_node(game_node_path).add_player(id, players[id]["id"])


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			players_loaded = 0
			$/root/World.start_game()


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	if multiplayer.get_unique_id() == 1:
		#update_player_info.rpc(new_player_id, "id", multiplayer.get_peers().size() + 1)
		players[new_player_id]["id"] = multiplayer.get_peers().size() + 1
		if players[new_player_id]["name"] == "Player":
			change_name.rpc_id(new_player_id, players[new_player_id]["name"] + str(multiplayer.get_peers().size() + 1))
			print(multiplayer.get_peers())
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	#if player_info["name"] == "Player":
		#player_info["name"] += str(multiplayer.get_network_connected_peers().size())
		#print(multiplayer.get_network_connected_peers())
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


@rpc("any_peer", "reliable")
func change_name(new_name):
	if !new_name == "":
		player_info["name"] = new_name
		players[multiplayer.get_unique_id()] = player_info
		update_player_name.rpc(multiplayer.get_unique_id(), new_name)


@rpc("any_peer", "reliable")
func update_player_name(player_id, new_name):
	players[player_id]["name"] = new_name


func lifetime_update(lifetime):
	update_player_info.rpc(multiplayer.get_unique_id(), "life_length", lifetime)


@rpc("any_peer", "reliable", "call_local")
func update_player_info(player_id, key, info):
	#players.get_or_add(player_id)
	players[player_id][key] = info


func send_update():
	var counter = 0
	for i in players:
		if players[i] is Dictionary:
			if players[i]["life_length"] < 0:
				counter += 1
	if counter == 1 and players.size() > 1:
		gameover = true
	else:
		gameover = false
	
	recieve_update.rpc(players)


@rpc("any_peer", "reliable", "call_local")
func recieve_update(data):
	players = data



#@rpc("any_peer", "reliable", "call_local")
#func assign_id(player_id, key, info):
	#players[player_id][key] = info


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()


func _process(delta: float) -> void:
	player_connected.emit(1, player_info)
	#print(players)
	timer -= delta
	if timer < 0:
		timer = 0.5
		if multiplayer.get_unique_id() == 1:
			send_update()
