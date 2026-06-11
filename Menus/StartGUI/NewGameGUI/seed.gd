extends Control

@onready var text_edit: LineEdit = $TextEdit

var seed : String

func _on_button_pressed() -> void:
	text_edit.text = str(randi_range(0,65536))


func _on_text_edit_text_changed(new_text: String) -> void:
	seed = text_edit.text
