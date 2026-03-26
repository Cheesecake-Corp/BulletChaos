extends Node2D


var exits = {}
var size = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	size = {"position": [], "size": []}
	size["position"][0] = Vector2i(0,0)
	size["size"][0] = Vector2i(11,9)
	
	exits = {
		1: {
			"position": Vector2i(11,4), 
			"direction": 'R',
			"id": 1}
	}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
