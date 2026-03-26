extends Node2D

@export var Spawn_scene: Array[PackedScene]
@export var Room1_scene: PackedScene
@export var Room2_scene: PackedScene
@export var Room3_scene: PackedScene
@export var Room4_scene: PackedScene
@export var Room5_scene: PackedScene
@export var Room6_scene: PackedScene
@export var Room7_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawn_node = Spawn_scene[0].instantiate()
	spawn_node.global_position = Vector2(0,0)
	var exits = {
		1: {
			"position" = spawn_node.exits["position"],
			"direction" = spawn_node.exits["direction"],
			"id" = spawn_node.exits["id"]
		}
	}
	var walls: Array[int] = []
	var n = 0
	while n < spawn_node.size.size.x: #top and down walls
		walls.append([spawn_node.size.position.x + n,spawn_node.size.position.y]) #Top wall
		walls.append([spawn_node.size.position.x + n,spawn_node.size.position.y + spawn_node.size.size.y]) #Bottom wall
		n+=1
	n = 0
	while n < spawn_node.size.size.y:
		walls.append([spawn_node.size.position.x,spawn_node.size.position.y + n]) #Left wall
		walls.append([spawn_node.size.position.x + spawn_node.size.size.x,spawn_node.size.position.y + n])#Right wall
		n+=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
