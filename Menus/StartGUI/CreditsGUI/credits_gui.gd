extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("uid://piu0jen1j5xh")
