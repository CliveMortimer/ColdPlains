extends Node3D
class_name ItemSpawner

@export var item_scene: PackedScene
@export var spawn_points: Array[Vector3] = []
@export var num_items_to_spawn: int = 5
@export var random_offset: float = 1.0
 
var spawned_items: Array[Item] = []

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	if item_scene == null:
		print("Error: item_scene not set in ItemSpawner!")
		return
	
	# If no spawn points defined, create random ones
	if spawn_points.is_empty():
		print("Warning: No spawn points defined. Using random positions.")
		_generate_random_spawn_points()
	
	_spawn_items()

func _spawn_items() -> void:
	var spawn_count = min(num_items_to_spawn, spawn_points.size())
	
	# Shuffle spawn points
	spawn_points.shuffle()
	
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
		new_item.item_id = "item_" + str(i)
		new_item.item_name = "Item " + str(i)
		
		add_child(new_item)
		spawned_items.append(new_item)
		
		print("Spawned item at: ", spawn_pos)

func _generate_random_spawn_points() -> void:
	# Generate 10 random spawn points around the origin
	for i in range(10):
		var random_pos = Vector3(
			randf_range(-20, 20),
			0.5,
			randf_range(-20, 20)
		)
		spawn_points.append(random_pos)

func get_spawned_items() -> Array[Item]:
	return spawned_items

func reset_all_items() -> void:
	for item in spawned_items:
		if item:
			item.reset()
