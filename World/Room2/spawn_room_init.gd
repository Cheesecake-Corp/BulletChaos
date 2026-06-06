extends Room

func _init() -> void:
	navsq = Vector2(33,20)
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,2)
	size[0]["size"] = Vector2i(29,19)
	size[1] = {}
	size[1]["position"] = Vector2i(30,7)
	size[1]["size"] = Vector2i(2,10)
	 
	exits.append(Exit.new().set_location(Vector2i(12,2)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(32,7)).set_direction(direction.RIGHT).set_room(self))
