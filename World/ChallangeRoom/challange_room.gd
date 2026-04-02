extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(21,14)
	 
	exits.append(Exit.new().set_location(Vector2i(9,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,7)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(8,14)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(21,8)).set_direction(direction.RIGHT).set_room(self))
