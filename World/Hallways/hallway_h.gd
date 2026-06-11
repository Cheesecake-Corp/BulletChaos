extends Room


func _init() -> void:
	has_stuff = false
	size = {}
	navsq = Vector2(15,9)
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(15,9)
	
	exits.append(Exit.new().set_location(Vector2i(15,0)).set_direction(direction.RIGHT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,0)).set_direction(direction.LEFT).set_room(self))
