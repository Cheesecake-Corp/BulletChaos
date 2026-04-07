extends Room
func _init() -> void:
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(12,9)
	 
	exits.append(Exit.new().set_location(Vector2i(12,0)).set_direction(direction.RIGHT).set_room(self))
