class_name Exit

var location = Vector2i()
var direction
var id := 0
var global_position = Vector2i()

func set_location(l: Vector2i) -> Exit:
	location = l
	return self
	
func set_direction(d) -> Exit:
	direction = d
	return self
	
func set_id(i: int) -> Exit:
	id = i
	return self
	
func set_global_position(g: Vector2i) -> Exit:
	global_position = g
	return self
