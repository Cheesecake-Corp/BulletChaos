extends Node2D

var path = "res://World/Generation/Maptest.tscn/Node2D/Boss"
@onready var room = get_node(path)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(path)
	print(room.room.exits[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
