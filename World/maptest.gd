extends Node2D

@export var Spawn_scene: Array[PackedScene]
@export var Challenge_scene: Array[PackedScene]
@export var Boss_scene: Array[PackedScene]
@export var Checkpoint_scene: Array[PackedScene]
@export var Other_scene: Array[PackedScene]

var exits: Array[Exit] = [] #Exits
var walls: = {} #All walls
var roomtypes: Array[String] = ["Challenge", "Checkpoint", "Other"] 
var count: = 0 #Total number of rooms
var maxcount: = 20
var available_rooms = []
var maxroom: = {}
var scenes = {
	"Challenge": Challenge_scene,
	"Checkpoint": Checkpoint_scene,
	"Other": Other_scene
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start():
	var spawn: Room = Spawn_scene[GAME.RANDOM_GENERATION.randi_range(0,Spawn_scene.size()-1)].instantiate()
	get_tree().current_scene.call_deferred("add_child", spawn)
	spawn.global_position = Vector2i(0,0)
	write(spawn, spawn.global_position, null, null)
	maxroom["Challenge"] = 5
	maxroom["Checkpoint"] = 2
	maxroom["Other"] = 13
	for n in roomtypes:
		for m in maxroom[n]:
			available_rooms.append(n)

func gen():
	var exit_entry = null
	var e = exits[GAME.RANDOM_GENERATION.randi_range(0,exits.size()-1)]
	var r = available_rooms[]
	
func tryplace(e: Exit, room: Room) -> Exit:
	var d
	match e.direction:
		e.direction.RIGHT: d = e.direction.LEFT
		e.direction.LEFT: d = e.direction.RIGHT
		e.direction.TOP: d = e.direction.DOWN
		e.direction.DOWN: d = e.direction.TOP
	var ex = []
	for x in room.exits:
		if x.direction == d:
			ex.append(x)
	while ex:
		var exi = ex[GAME.RANDOM_GENERATION.randi_range(0,ex.size()-1)]
		var possible = true
		for n in room.size:
			var pos = n["position"]
			var height = n.size.y
			var width = n.size.x
			var m = 0
			var coordinates = Vector2i(exi.global_position.x - exi.location.x, exi.global_position.y - exi.location.y)
			while pos.x + m < width:
				if walls.get(Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y),0) != 0: #Top wall
					ex.erase(exi)
					possible = false
				if walls.get(Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y + height),0) != 0: #Bottom wall
					ex.erase(exi)
					possible = false
				m+=1
			m = 0
			while pos.y + m < height:
				if walls.get(Vector2i(pos.x + coordinates.x, pos.y + m + coordinates.y),0) != 0: #Left wall
					ex.erase(exi)
					possible = false
				if walls.get(Vector2i(pos.x + coordinates.x + width, pos.y + m + coordinates.y)) != 0: #Right wall
					ex.erase(exi)
					possible = false
				m+=1
		if possible == true:
			return exi
	return null

	
func write(room: Room, coordinates: Vector2i, exit_entry: Exit, exit_exit: Exit): #Exit_exit delete, Exit_entry dont add
	for n in room.size:
		var pos = n["position"]
		var height = n.size.y
		var width = n.size.x
		var m = 0
		while pos.x + m < width:
			walls[Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y)] = 1 #Top wall
			walls[Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y + height)] = 1 #Bottom wall
			m+=1
		m = 0
		while pos.y + m < height:
			walls[Vector2i(pos.x + coordinates.x, pos.y + m + coordinates.y)] = 1 #Left wall
			walls[Vector2i(pos.x + coordinates.x + width, pos.y + m + coordinates.y)] = 1 #Right wall
			m+=1
	if exit_exit != null:
		exits.erase(exit_exit)
	for e in room.exits:
		e.global_position.x = coordinates.x + e.location.x
		e.global_position.y = coordinates.y + e.location.y
		if e == exit_entry: 
			continue
		exits.append(e)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
