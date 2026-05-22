extends CanvasLayer

@onready var health_label = $HealthLabel
var player


func _ready():
	# Get the parent player node
	player = get_parent()
	
	print("HealthBar _ready() called for player:", player.name)
	print("Is this the local player authority?", player.is_multiplayer_authority())
	
	# Only show UI for the local player
	if not player.is_multiplayer_authority():
		print("This is NOT the local player, hiding HealthBar")
		visible = false
		return
	
	print("This IS the local player, setting up HealthBar")
	
	# Connect to the signal FIRST, before anything else
	player.health_changed.connect(_on_health_changed)
	print("Connected to health_changed signal")
	
	# Set up the ProgressBar
	health_label.min_value = 0
	health_label.max_value = 100
	health_label.value = player.health
	
	print("Initial health bar value set to:", health_label.value)
	print("HealthBar setup complete!")


func _on_health_changed(new_health):
	print("=== _on_health_changed CALLED ===")
	print("new_health:", new_health)
	print("health_label ref:", health_label)
	
	if health_label == null:
		print("ERROR: health_label is null!")
		return
	
	health_label.value = new_health
	print("Health bar value updated to:", health_label.value)
	print("Health bar visible:", health_label.visible)
