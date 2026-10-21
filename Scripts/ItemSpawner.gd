extends Node3D
class_name ItemSpawner

@export var item_scene: PackedScene
@export var spawn_points: Array[Vector3] = []
@export var num_items_to_spawn: int = 5
@export var random_offset: float = 1.0
 
#var spawned_items_data: Array = []
var spawned_items: Array[Item] = []
#var has_spawned: bool = false


func _ready() -> void:
	if not is_multiplayer_authority():
		return

	if item_scene == null:
		print("Error: item_scene not set in ItemSpawner!")
		return

		#if spawn_points.is_empty():
			#print("Warning: No spawn points defined. Using random positions.")
			#generate_random_spawn_points()
	_spawn_items()


func _spawn_items() -> void:
	var spawn_count = min(num_items_to_spawn, spawn_points.size())
	
	for i in range(spawn_count):
		var spawn_pos = spawn_points[i]
		
		# Add random offset
		spawn_pos += Vector3(
			randf_range(-random_offset, random_offset),
			0,
			randf_range(-random_offset, random_offset)
		)
		
		var new_item = item_scene.instantiate()
		new_item.global_position = spawn_pos
		new_item.item_id = "health_pack"
		new_item.item_name = "Health Pack"
		new_item.item_type = "consumable"
		
		add_child(new_item)
		spawned_items.append(new_item)
		
		print("Spawned item at: ", spawn_pos)


func generate_random_spawn_points() -> void:
	# Generate 10 random spawn points around the origin
	for i in range(10):
		var random_pos = Vector3(
			randf_range(-50, 50),
			0.2,
			randf_range(-50, 50)
		)
		spawn_points.append(random_pos)


#func _on_peer_connected(peer_id: int) -> void:
	#if not multiplayer.is_server():
		#return
	## send the entire authoritative state so the joining client can spawn visuals
	#rpc_id(peer_id, "_client_sync_items", spawned_items_data)

func get_spawned_items() -> Array[Item]:
	return spawned_items


func reset_all_items() -> void:
	for item in spawned_items:
		if item:
			item.reset()
