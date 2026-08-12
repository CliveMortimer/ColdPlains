extends CanvasLayer
class_name InventoryUI

@onready var item_list: ItemList = $Control/PanelContainer/VBoxContainer/ItemList
@onready var item_count_label: Label = $Control/PanelContainer/VBoxContainer/ItemCount

var player_inventory: PlayerInventory
var player_id: int

func _ready() -> void:
	# Get reference to player's inventory
	var player = get_parent()
	player_id = player.name.to_int()
	player_inventory = player.get_node_or_null("PlayerInventory")
	
	if not player_inventory:
		print("[InventoryUI] Error: PlayerInventory not found!")
		return
	
	print("[InventoryUI] Connected to player inventory for player: ", player_id)
	
	# Connect inventory changes (if you add a signal later)
	# For now, we'll update it every frame
	update_display()

func _process(_delta: float) -> void:
	# Update inventory display every frame
	update_display()

func update_display() -> void:
	if not player_inventory:
		return
	
	var inventory = player_inventory.get_inventory()
	var inventory_size = player_inventory.inventory_size
	var current_count = inventory.size()
	
	# Update ItemList
	item_list.clear()
	
	for i in range(current_count):
		var item_data = inventory[i]
		var item_text = item_data["name"] + " (" + item_data["type"] + ")"
		item_list.add_item(item_text)
	
	# Update count label
	item_count_label.text = "Items: " + str(current_count) + "/" + str(inventory_size)
