extends Control

@onready var control: Control = $Control
@onready var button: Button = $Button
const ALLUPGRADES = preload("uid://1r40jg2w5t6b")
const UPGRADE_BUTTON = preload("uid://blyy0xas2cf13")
@onready var grid_container: GridContainer = $Control/VScrollBar/GridContainer

var active = false
var pl_upgrades : Array = []

func _ready() -> void:
	control.visible = false
	button.visible = true
	active = false
	for i in grid_container.get_children():
		i.queue_free()
	for n in ALLUPGRADES.upgrades:
		if n is PlayerUpgrade:
			var upgr_button = UPGRADE_BUTTON.instantiate()
			upgr_button.get_child(0).text = n.name
			upgr_button.upgrade = n
			grid_container.add_child(upgr_button)


func _on_button_pressed() -> void:
	button.visible = false
	control.visible = true
	active = true
	get_parent().get_parent().get_parent().hide_buttons_and_lines(true)


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("escape"):
			hide_control()
		if Input.is_action_just_pressed("enter"):
			apply()


func reset_values():
	var rectangles = grid_container.get_children()
	for n in rectangles:
		n.get_child(0).button_pressed = false


func hide_control():
	active = false
	control.visible = false
	button.visible = true
	get_parent().get_parent().get_parent().hide_buttons_and_lines(false)


func apply():
	active = false
	control.visible = false
	button.visible = true
	var rectangles = grid_container.get_children()
	for n in rectangles:
		if n.get_child(0).button_pressed:
			pl_upgrades.append(n.upgrade)
	hide_control()


func _on_close_pressed() -> void:
	hide_control()


func _on_apply_pressed() -> void:
	apply()
