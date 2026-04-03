extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(32,20)
	 
	exits.append(Exit.new().set_location(Vector2i(13,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,4)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(13,20)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(32,4)).set_direction(direction.RIGHT).set_room(self))
