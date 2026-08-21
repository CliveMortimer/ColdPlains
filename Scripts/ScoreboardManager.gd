extends Node

signal scoreboard_updated(stats: Dictionary)

# Key: peer_id (int) -> Value: {name: String, kills: int, deaths: int, score: int}
var player_stats: Dictionary = {}

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	player_stats[peer_id] = {
		"name": "Player " + str(peer_id),
		"kills": 0,
		"deaths": 0,
		"score": 0
	}
	_sync_scoreboard()

func _on_peer_disconnected(peer_id: int) -> void:
	player_stats.erase(peer_id)
	_sync_scoreboard()

func record_kill(attacker_id: int, victim_id: int) -> void:
	if not multiplayer.is_server(): return
	
	if player_stats.has(attacker_id):
		player_stats[attacker_id]["kills"] += 1
		player_stats[attacker_id]["score"] += 100
		
	if player_stats.has(victim_id):
		player_stats[victim_id]["deaths"] += 1
		
	_sync_scoreboard()

func _sync_scoreboard() -> void:
	rpc("receive_scoreboard_data", player_stats)

@rpc("authority", "reliable", "call_local")
func receive_scoreboard_data(data: Dictionary) -> void:
	player_stats = data
	scoreboard_updated.emit(player_stats)
