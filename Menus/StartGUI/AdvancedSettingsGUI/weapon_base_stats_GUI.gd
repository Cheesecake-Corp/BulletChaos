extends Control

@onready var button: Button = $Button
@onready var control: Control = $Control
@onready var v_box_container_2: VBoxContainer = $Control/VBoxContainer2

var active: = false
var weapon_stats_set : Array = []
var weapon_stats_set_reset : Array = []


func _ready() -> void:
	control.visible = false
	button.visible = true
	weapon_stats_set_reset = [10.0, 1.0, 0.2, 1.0, 1.0, 20, 1.0, 0.0]
	weapon_stats_set = weapon_stats_set_reset
	var texts : Array = v_box_container_2.get_children()
	for n in weapon_stats_set.size():
		texts[n].text = str(weapon_stats_set[n])

func _process(_delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("enter"):
			apply()
		if Input.is_action_just_pressed("exit"):
			hide_control()


func reset_values():
	weapon_stats_set = weapon_stats_set_reset
	var texts : Array = v_box_container_2.get_children()
	for n in weapon_stats_set.size():
		texts[n].text = str(weapon_stats_set[n])


func _on_button_pressed() -> void:
	get_parent().get_parent().get_parent().hide_buttons_and_lines(true)
	control.visible = true
	button.visible = false
	var texts : Array = v_box_container_2.get_children()
	for n in weapon_stats_set.size():
		texts[n].text = str(weapon_stats_set[n])


func apply():
	var texts : Array = v_box_container_2.get_children()
	var m = 0
	for n in texts:
		weapon_stats_set[m] = float(n.text)
		m += 1
	hide_control()


func hide_control():
	active = false
	control.visible = false
	button.visible = true
	get_parent().get_parent().get_parent().hide_buttons_and_lines(false)


func _on_apply_pressed() -> void:
	apply()


func _on_close_pressed() -> void:
	hide_control()
