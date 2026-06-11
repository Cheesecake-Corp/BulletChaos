extends Control

@onready var button: Button = $Button
@onready var control: Control = $Control
@onready var v_box_container_2: VBoxContainer = $Control/VBoxContainer2

var active = false
var player_stats_set : Array
var player_stats_set_reset : Array

func _ready() -> void:
	control. visible = false
	player_stats_set_reset = [100.0, 0.0, 100.0, 15.0, 1.5, 150.0, 1.5, 4.0]
	player_stats_set = player_stats_set_reset
	var texts : Array = v_box_container_2.get_children()
	for n in player_stats_set.size():
		texts[n].text = str(player_stats_set[n])


func _on_button_pressed() -> void:
	get_parent().get_parent().get_parent().hide_buttons_and_lines(true)
	button.visible = false
	control.visible = true
	active = true
	var texts : Array = v_box_container_2.get_children()
	for n in player_stats_set.size():
		texts[n].text = str(player_stats_set[n])


func _process(_delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("escape"):
			hide_control()
		if Input.is_action_just_pressed("enter"):
			apply()


func reset_values():
	player_stats_set = player_stats_set_reset
	var texts : Array = v_box_container_2.get_children()
	for n in player_stats_set.size():
		texts[n].text = str(player_stats_set[n])


func hide_control():
	active = false
	button.visible = true
	control.visible = false
	get_parent().get_parent().get_parent().hide_buttons_and_lines(false)


func _on_apply_pressed() -> void:
	apply()


func _on_close_pressed() -> void:
	hide_control()


func apply():
	var texts : Array = v_box_container_2.get_children()
	for n in player_stats_set.size():
		player_stats_set[n] = float(texts[n].text)
	hide_control()
