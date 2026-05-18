extends ItemList


func _ready() -> void:
	select_mode = ItemList.SELECT_SINGLE


func _on_texture_button_activated() -> void:
	var array = get_selected_items()
	if array.size() != 0:
		GAME.weapon_menu = get_item_text(int(array[0]))
