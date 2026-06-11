extends Room


func _init() -> void:
	has_stuff = false
	size = {}
	navsq = Vector2(7,15)
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(7,15)
	
	exits.append(Exit.new().set_location(Vector2i(1,15)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(1,0)).set_direction(direction.TOP).set_room(self))
