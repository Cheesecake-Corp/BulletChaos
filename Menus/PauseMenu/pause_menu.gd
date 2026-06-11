extends Control


func _on_button_pressed() -> void:
	GAME.GAME_LEVEL = -1
	get_tree().change_scene_to_file("uid://piu0jen1j5xh")
