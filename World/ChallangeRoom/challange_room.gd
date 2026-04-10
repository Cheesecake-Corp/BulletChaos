extends Room
func _init() -> void:
	navsq = Vector2(33,20)
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(33,20)
	 
	exits.append(Exit.new().set_location(Vector2i(14,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,4)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(14,20)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(33,4)).set_direction(direction.RIGHT).set_room(self))
