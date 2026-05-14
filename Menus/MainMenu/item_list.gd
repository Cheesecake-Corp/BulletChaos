extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SelectMode.SELECT_SINGLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_activated() -> void:
	var array = get_selected_items()
	if array.size() != 0:
		GAME.weapon_menu = get_item_text(int(array[0]))
