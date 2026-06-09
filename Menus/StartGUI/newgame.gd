extends Menu_button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/StartGUI/New_game_gui.tscn")
