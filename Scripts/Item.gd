extends Node3D
class_name Item

@export var item_id: String = "item_default"
@export var item_name: String = "Item"
@export var item_type: String = "consumable"  # consumable, weapon, ammo, etc.

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

var is_picked_up: bool = false
var original_position: Vector3

func _ready() -> void:
	original_position = global_position
	
@rpc("call_local", "reliable", "any_peer")
func pick_up(player_id: int) -> bool:
	if is_picked_up:
		print("[Item] Already picked up, rejecting pickup")
		return false

	is_picked_up = true
	print("[Item] Picked up by player: ", player_id)

	mesh_instance.visible = false
	collision_shape.disabled = true
	area_3d.monitoring = false
	## Keep the item in the scene but invisible and non-interactable
	## This way it stays synced across the network
	print("[Item] Pickup synced - item hidden for all clients (main)")

	# Sync pickup across network to ALL clients
	# Use rpc() with "call_local" to execute on everyone immediately
	rpc("item_picked_up")
	return true
	
@rpc("call_local", "reliable", "any_peer")
func item_picked_up() -> void:
	if is_picked_up:
		print("[Item] Already picked up, rejecting pickup")
		return 
	
	is_picked_up = true
	#print("[Item] Picked up by player: ", player_id)
	
	mesh_instance.visible = false
	collision_shape.disabled = true
	area_3d.monitoring = false
	## Keep the item in the scene but invisible and non-interactable
	## This way it stays synced across the network
	print("[Item] Pickup synced - item hidden for all clients (rpc)")
	
	# Sync pickup across network to ALL clients
	# Use rpc() with "call_local" to execute on everyone immediately
	#rpc("_on_item_picked_up", player_id)
	return
	
	
#
#func pick_up(player_id: int) -> bool:
	#if is_picked_up:
		#print("[Item] Already picked up, rejecting pickup")
		#return false
	#
	#is_picked_up = true
	#print("[Item] Picked up by player: ", player_id)
	#
	## Sync pickup across network to ALL clients
	## Use rpc() with "call_local" to execute on everyone immediately
	#rpc("_on_item_picked_up", player_id)
	#return true
#
#@rpc("call_local", "reliable", "any_peer")
#func _on_item_picked_up() -> void:
	#mesh_instance.visible = false
	#collision_shape.disabled = true
	#area_3d.monitoring = false
	## Keep the item in the scene but invisible and non-interactable
	## This way it stays synced across the network
	#print("[Item] Pickup synced - item hidden for all clients (main)")
	#rpc("update_item")
	#
#@rpc("call_local", "reliable", "any_peer")
#func upadte_item () -> void:
	#mesh_instance.visible = false
	#collision_shape.disabled = true
	#area_3d.monitoring = false
	## Keep the item in the scene but invisible and non-interactable
	## This way it stays synced across the network
	#print("[Item] Pickup synced - item hidden for all clients (update)")

func reset() -> void:
	if is_multiplayer_authority():
		rpc("_reset_item")

@rpc("call_local")
func _reset_item() -> void:
	is_picked_up = false
	mesh_instance.visible = true
	collision_shape.disabled = false
	area_3d.monitoring = true
