extends ItemList






func _on_texture_button_activated() -> void:
	var array = get_selected_items()
	if array.size() != 0:
		if get_item_text(int(array[0])) == "Hard":
			GAME.difficulty = 2
		else:
			GAME.difficulty = 1
