extends Control

func hide_button(button_name: String, vis: bool) -> void:
	if button_name == "Seed":
		var str4 = button_name[0].to_upper() + button_name.substr(1) + "/Button"
		var str5 = button_name[0].to_upper() + button_name.substr(1) + "/TextEdit"
		if vis == true:
			get_node(str4).visible = false
			get_node(str5).visible = false
			return
		else:
			get_node(str4).visible = true
			return
	var str1 = button_name[0].to_upper() + button_name.substr(1) + "/Button"
	var str2 = button_name[0].to_upper() + button_name.substr(1) + "/VBoxContainer"
	var str3 = button_name[0].to_upper() + button_name.substr(1) + "/NinePatchRect"
	
	if vis == true:
		get_node(str1).visible = false
		get_node(str2).visible = false
		get_node(str3).visible = false
	else:
		get_node(str1).visible = true


func _on_start_game_pressed() -> void:
	pass # Replace with function body.
