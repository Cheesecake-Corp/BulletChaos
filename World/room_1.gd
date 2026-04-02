extends Node2D
class_name Room
enum direction{LEFT,RIGHT,TOP,DOWN}
var exits = []
var size = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(11,9)
	 
	exits.append(Exit.new().set_location(Vector2i(11,4)).set_direction(direction.RIGHT).set_id(1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
