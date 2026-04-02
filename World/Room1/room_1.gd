extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(11,9)
	 
	exits.append(Exit.new().set_location(Vector2i(11,4)).set_direction(direction.RIGHT).set_id(1).set_room(self))
