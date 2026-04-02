extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(3,0)
	size[0]["size"] = Vector2i(3,3)
	size[1] = {}
	size[1]["position"] = Vector2i(0,4)
	size[1]["size"] = Vector2i(11,7)
	 
	exits.append(Exit.new().set_location(Vector2i(3,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(9,11)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(11,9)).set_direction(direction.RIGHT).set_room(self))
