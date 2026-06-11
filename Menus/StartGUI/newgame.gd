extends Menu_button


func _on_pressed() -> void:
	get_parent().add_child(load("uid://bw58q6f1eqm4u").instantiate())
	get_tree().change_scene_to_file("uid://cu6mggfbcajbm")
