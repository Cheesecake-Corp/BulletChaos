extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(17,8)
	 
	exits.append(Exit.new().set_location(Vector2i(0,2)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(5,8)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(4,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(11,0)).set_direction(direction.TOP).set_room(self))
