extends Control

@onready var text_edit: TextEdit = $TextEdit

func _on_button_pressed() -> void:
	text_edit.text = str(randi_range(0,65536))
