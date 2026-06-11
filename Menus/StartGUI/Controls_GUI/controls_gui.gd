extends Control

@onready var move_up: Button = $ScrollContainer/Control/Grid/Move_up
@onready var move_down: Button = $ScrollContainer/Control/Grid/Move_down
@onready var move_left: Button = $ScrollContainer/Control/Grid/Move_left
@onready var move_right: Button = $ScrollContainer/Control/Grid/Move_right
@onready var shoot: Button = $ScrollContainer/Control/Grid/Shoot
@onready var reload: Button = $ScrollContainer/Control/Grid/Reload
@onready var dash: Button = $ScrollContainer/Control/Grid/Dash
@onready var inventory: Button = $ScrollContainer/Control/Grid/Inventory
@onready var inventory_switch: Button = $ScrollContainer/Control/Grid/Inventory_switch
@onready var inventory_upgrade: Button = $ScrollContainer/Control/Grid/Inventory_upgrade
@onready var inventory_apply: Button = $ScrollContainer/Control/Grid/Inventory_apply
@onready var inventory_reset: Button = $ScrollContainer/Control/Grid/Inventory_reset
@onready var pet: Button = $ScrollContainer/Control/Grid/Pet
@onready var pause: Button = $ScrollContainer/Control/Grid/Pause
@onready var hide_warning: Button = $ScrollContainer/Control/Grid/Hide_warning
@onready var enter: Button = $ScrollContainer/Control/Grid/Enter
@onready var main_menu: Button = $ScrollContainer/Control/Grid/Main_menu
@onready var next_level: Button = $ScrollContainer/Control/Grid/Next_level


var listen : = false
var event_key : InputEvent
var button_listening : Button
var action_listening : String

var dict : Dictionary = {
	0: {"action_name": "go_up", "letter_keybinds": "W", "mouse_keybinds": "", "is_mouse" : false},
	1: {"action_name": "go_down", "letter_keybinds": "S", "mouse_keybinds": "", "is_mouse" : false},
	2: {"action_name": "go_left", "letter_keybinds": "A", "mouse_keybinds": "", "is_mouse" : false},
	3: {"action_name": "go_right", "letter_keybinds": "D", "mouse_keybinds": "", "is_mouse" : false},
	4: {"action_name": "attack", "letter_keybinds": "RMB", "mouse_keybinds": "1", "is_mouse" : true},
	5: {"action_name": "reload", "letter_keybinds": "R", "mouse_keybinds": "", "is_mouse" : false},
	6: {"action_name": "dash", "letter_keybinds": "Shift", "mouse_keybinds": "", "is_mouse" : false},
	7: {"action_name": "inventory", "letter_keybinds": "X", "mouse_keybinds": "", "is_mouse" : false},
	8: {"action_name": "inventory_change", "letter_keybinds": "Y", "mouse_keybinds": "", "is_mouse" : false},
	9: {"action_name": "upgrade_upgrade", "letter_keybinds": "Q", "mouse_keybinds": "", "is_mouse" : false},
	10: {"action_name": "inventory_apply", "letter_keybinds": "A", "mouse_keybinds": "", "is_mouse" : false},
	11: {"action_name": "inventory_reset", "letter_keybinds": "T", "mouse_keybinds": "", "is_mouse" : false},
	12: {"action_name": "pet", "letter_keybinds": "B", "mouse_keybinds": "", "is_mouse" : false},
	13: {"action_name": "pause", "letter_keybinds": "Escape", "mouse_keybinds": "", "is_mouse" : false},
	14: {"action_name": "reject_warning", "letter_keybinds": "E", "mouse_keybinds": "", "is_mouse" : false},
	15: {"action_name": "enter", "letter_keybinds": "Enter", "mouse_keybinds": "", "is_mouse" : false},
	16: {"action_name": "restart", "letter_keybinds": "L", "mouse_keybinds": "", "is_mouse" : false},
	17: {"action_name": "next_level", "letter_keybinds": "N", "mouse_keybinds": "", "is_mouse" : false},
}


func _ready() -> void:
	reset()
	start()


func reset():
	InputMap.load_from_project_settings()
	move_up.text = dict[0]["letter_keybinds"]
	move_down.text = dict[1]["letter_keybinds"]
	move_left.text = dict[2]["letter_keybinds"]
	move_right.text = dict[3]["letter_keybinds"]
	shoot.text = "LMB"
	reload.text = dict[5]["letter_keybinds"]
	dash.text = dict[6]["letter_keybinds"]
	inventory.text = dict[7]["letter_keybinds"]
	inventory_switch.text = dict[8]["letter_keybinds"]
	inventory_upgrade.text = dict[9]["letter_keybinds"]
	inventory_apply.text = dict[10]["letter_keybinds"]
	inventory_reset.text = dict[11]["letter_keybinds"]
	pet.text = dict[12]["letter_keybinds"]
	pause.text = dict[13]["letter_keybinds"]
	hide_warning.text = dict[14]["letter_keybinds"]
	enter.text = dict[15]["letter_keybinds"]
	main_menu.text = dict[16]["letter_keybinds"]
	next_level.text = dict[17]["letter_keybinds"]


func _input(event: InputEvent) -> void:
	if listen:
		if event is InputEventKey or event is InputEventMouseButton:
			event_key = event
			process_event()


func process_event():
	listen = false
	InputMap.action_erase_events(action_listening)
	InputMap.action_add_event(action_listening, event_key)
	if event_key is InputEventKey:
		button_listening.text = event_key.as_text_keycode()
	if event_key is InputEventMouseButton:
		button_listening.text = mouse_description(event_key)
	print(event_key)


func button_start_listen(b : Button, a : String):
	listen = true
	button_listening = b
	action_listening = a
	button_listening.text = "Press key"


func mouse_description(event : InputEvent) -> String:
	var tx = event.button_index
	match tx:
		1:
			return "LMB"
		2:
			return "RMB"
		3:
			return "MMB"
	return "ERR"


func start():
	for n in dict:
		InputMap.action_erase_events(dict[n]["action_name"])
		if dict[n]["is_mouse"]:
			var a : InputEventMouseButton = InputEventMouseButton.new()
			a.set_button_index(int(dict[n]["mouse_keybinds"]))
			InputMap.action_add_event(dict[n]["action_name"], a)
		else:
			var a : InputEventKey = InputEventKey.new()
			a.keycode = OS.find_keycode_from_string(dict[n]["letter_keybinds"])
			InputMap.action_add_event(dict[n]["action_name"], a)


func _on_move_up_pressed() -> void:
	button_start_listen(move_up, "go_up")


func _on_move_down_pressed() -> void:
	button_start_listen(move_down, "go_down")


func _on_move_left_pressed() -> void:
	button_start_listen(move_left, "go_left")


func _on_move_right_pressed() -> void:
	button_start_listen(move_right, "go_right")


func _on_shoot_pressed() -> void:
	button_start_listen(shoot, "attack")


func _on_reload_pressed() -> void:
	button_start_listen(reload, "reload")


func _on_dash_pressed() -> void:
	button_start_listen(dash, "dash")


func _on_inventory_pressed() -> void:
	button_start_listen(inventory, "inventory")


func _on_inventory_switch_pressed() -> void:
	button_start_listen(inventory_switch, "inventory_change")


func _on_inventory_upgrade_pressed() -> void:
	button_start_listen(inventory_upgrade, "upgrade_upgrade")


func _on_inventory_apply_pressed() -> void:
	button_start_listen(inventory_apply, "inventory_apply")


func _on_inventory_reset_pressed() -> void:
	button_start_listen(inventory_reset, "inventory_reset")


func _on_pet_pressed() -> void:
	button_start_listen(pet, "pet")


func _on_pause_pressed() -> void:
	button_start_listen(pause, "pause")


func _on_hide_warning_pressed() -> void:
	button_start_listen(hide_warning, "reject_warning")


func _on_enter_pressed() -> void:
	button_start_listen(enter, "enter")


func _on_main_menu_pressed() -> void:
	button_start_listen(main_menu, "restart")


func _on_next_level_pressed() -> void:
	button_start_listen(next_level, "next_level")


func _on_reset_pressed() -> void:
	reset()


func _on_apply_pressed() -> void:
	get_tree().change_scene_to_file("uid://piu0jen1j5xh")
