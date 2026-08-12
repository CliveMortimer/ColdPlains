extends Node
class_name PlayerInventory

@export var inventory_size: int = 10

var inventory: Array = []
var player_id: int

func _ready() -> void:
	player_id = get_parent().name.to_int()

func add_item(item: Item) -> bool:
	if inventory.size() >= inventory_size:
		print("Inventory is full!")
		return false
	
	# Add item data to inventory
	var item_data = {
		"id": item.item_id,
		"name": item.item_name,
		"type": item.item_type
	}
	inventory.append(item_data)
	print("Item added to inventory: ", item.item_name)
	return true

func remove_item(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	
	inventory.remove_at(index)
	return true

func get_inventory() -> Array:
	return inventory

func get_inventory_size() -> int:
	return inventory.size()

func clear_inventory() -> void:
	inventory.clear()
