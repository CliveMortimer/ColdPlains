extends CanvasLayer

@export var name1 : Label
@export var name2 : Label
@export var name3 : Label
@export var name4 : Label

@export var time1 : Label
@export var time2 : Label
@export var time3 : Label
@export var time4 : Label

@export var panel1 : PanelContainer
@export var panel2 : PanelContainer
@export var panel3 : PanelContainer
@export var panel4 : PanelContainer

@export var win_label : Label
@export var restart_button : Button


var time = 0
var name_array
var time_array
var panel_array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_array = [name1, name2, name3 ,name4]
	time_array = [time1, time2, time3, time4]
	panel_array = [panel1, panel2, panel3, panel4]
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Lobby.players.has("1"):
		if $Timer.time_left == 0:
			var names : Dictionary
			for id in Lobby.players:
				names.get_or_add(Lobby.players[id]["life_length"], Lobby.players[id]["name"])
			names.sort()
			for i in names.size():
				var keys = names.keys()
				panel_array[i].visible = true
				name_array[i].text = names[keys[i]]
				var value = keys[i]
				if value < 0:
					value = time + Lobby.players[multiplayer.get_unique_id()]["life_length"]
				time_array[i].text = str(round(value * 100) / 100)
			
			if Lobby.gameover == true:
				visible = true
				if Lobby.players[multiplayer.get_unique_id()]["life_length"] < 0:
					win_label.visible = true
				if multiplayer.get_unique_id() == 1:
					restart_button.visible = true
		else:
			$Timer.start()
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if Lobby.players.has(multiplayer.get_unique_id()):
		if Lobby.players[multiplayer.get_unique_id()]["life_length"] > 0:
			time += delta
		else:
			time = 0
	else:
		time = 0


func show_lose_screen():
	visible = true


func _on_restart_button_pressed() -> void:
	get_parent().reset_and_start()
