extends Control

var scene = preload("res://Menus/StartGUI/advanced.gd")

func _on_button_pressed() -> void:
	scene.instantiate()
