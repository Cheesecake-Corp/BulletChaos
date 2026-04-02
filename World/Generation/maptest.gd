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
var min_rooms: = {}
var scenes : Dictionary 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start(maxcount: int):
	GAME.change_seed("Schokolate")
	var spawn: Room = Spawn_scene[GAME.RANDOM_GENERATION.randi_range(0,Spawn_scene.size()-1)].instantiate()
	add_child(spawn)
	#get_tree().current_scene.call_deferred("add_child", spawn)
	spawn.global_position = Vector2i(0,0)
	write(spawn, spawn.global_position, null, null)
	min_rooms["Challenge"] = 5
	min_rooms["Checkpoint"] = 2
	min_rooms["Other"] = 5
	scenes = {
		"Challenge": Challenge_scene.duplicate(),
		"Checkpoint": Checkpoint_scene.duplicate(),
		"Other": Other_scene.duplicate()
	}
	while maxcount > 0:
		gen()
		maxcount -= 1
	
	

func gen():
	var exit_entry : Exit = null
	var exit_exit : Exit = null
	while exit_entry == null:
		var result = get_room()
		exit_entry = result[0]
		exit_exit = result[1]
	write(exit_entry.room,exit_entry.global_position-exit_entry.location,exit_entry,exit_exit)
	get_tree().current_scene.call_deferred("add_child",exit_entry.room)
	exit_entry.room.global_position = (exit_entry.global_position-exit_entry.location)*16
	

func get_room() -> Array[Exit]:
	var exit_entry = null
	var e : Exit = exits[GAME.RANDOM_GENERATION.randi_range(0,exits.size()-1)]
	var types = roomtypes.duplicate()
	while types:
		var type = types[GAME.RANDOM_GENERATION.randi_range(0,types.size()-1)]
		if(min_rooms[type] <= 0 and types.size() != 1): 
			continue
		var load_type_scenes : Array[PackedScene] = scenes[type]
		var type_scenes : Array[PackedScene] = load_type_scenes.duplicate()
		while type_scenes:
			var scene = type_scenes[GAME.RANDOM_GENERATION.randi_range(0,type_scenes.size()-1)]
			var room = scene.instantiate()
			exit_entry = tryplace(e, room)
			type_scenes.erase(scene)
			if(exit_entry != null):
				
				break
		types.erase(type)
		if(exit_entry != null):
				break
	if exit_entry == null:
		exits.erase(e)
	return [exit_entry,e]

func tryplace(e: Exit, room: Room) -> Exit:
	var d
	var coordinates_coeficient : Vector2i
	match e.direction:
		Room.direction.RIGHT:
			d = Room.direction.LEFT
			coordinates_coeficient = Vector2i(1, 0)

		Room.direction.LEFT:
			d = Room.direction.RIGHT
			coordinates_coeficient = Vector2i(-1, 0)

		Room.direction.TOP:
			d = Room.direction.DOWN
			coordinates_coeficient = Vector2i(0, -1)

		Room.direction.DOWN:
			d = Room.direction.TOP
			coordinates_coeficient = Vector2i(0, 1)

	
	
	var ex = []
	for x in room.exits:
		if x.direction == d:
			ex.append(x)
	while ex:
		var exi : Exit = ex[GAME.RANDOM_GENERATION.randi_range(0,ex.size()-1)]
		var possible = true
		var coordinates = e.global_position-exi.location + coordinates_coeficient
		exi.global_position = e.global_position + coordinates_coeficient
		for n in room.size:
			var pos = room.size[n]["position"]
			var height = room.size[n]["size"].y
			var width = room.size[n]["size"].x
			var m = 0
			while m <= width and possible:
				var check1 := Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y)
				if walls.get(check1,0) != 0: #Top wall
					ex.erase(exi)
					possible = false
					
				var check2:=Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y + height)
				if walls.get(check2,0) != 0: #Bottom wall
					ex.erase(exi)
					possible = false
				m+=1
			m = 0
			while m <= height and possible:
				if walls.get(Vector2i(pos.x + coordinates.x, pos.y + m + coordinates.y),0) != 0: #Left wall
					ex.erase(exi)
					possible = false
				if walls.get(Vector2i(pos.x + coordinates.x + width, pos.y + m + coordinates.y),0) != 0: #Right wall
					ex.erase(exi)
					possible = false
				m+=1
		if possible == true:
			return exi
	return null

	
func write(room: Room, coordinates: Vector2i, exit_entry: Exit, exit_exit: Exit): #Exit_exit delete, Exit_entry dont add
	for n in room.size:
		var pos = room.size[n]["position"]
		var height = room.size[n]["size"].y
		var width = room.size[n]["size"].x
		var m = 0
		while m <= width:
			walls[Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y)] = 1 #Top wall
			walls[Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y + height)] = 1 #Bottom wall
			m+=1
		m = 0
		while m <= height:
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
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("generate")):
		start(50)
