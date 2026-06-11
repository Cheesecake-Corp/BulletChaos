extends Room
func _init() -> void:
	navsq = Vector2(33,19)
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(33,19)
	 
	exits.append(Exit.new().set_location(Vector2i(33,5)).set_direction(direction.RIGHT).set_room(self))
