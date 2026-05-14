extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_activated() -> void:
	var array = get_selected_items()
	if array.size() != 0:
		if get_item_text(int(array[0])) == "Hard":
			GAME.difficulty = 2
		else:
			GAME.difficulty = 1
