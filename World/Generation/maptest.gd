extends Node2D

@export var spawn_scene: Array[PackedScene]
@export var challenge_scene: Array[PackedScene]
@export var boss_scene: Array[PackedScene]
@export var checkpoint_scene: Array[PackedScene]
@export var other_scene: Array[PackedScene]

var minx = 0
var maxx = 0
var miny = 0
var maxy = 0

var exits: Array[Exit] = [] #Exits
var walls: = {} #All walls
var roomtypes: Array[String] = ["Challenge", "Checkpoint", "Other"] 
var count: = 0 #Total number of rooms
var min_rooms: = {}
var scenes : Dictionary 
var rooms : Array[Room] = []

var left_exit : PackedScene = preload("res://World/ClosedExits/LeftExit.tscn")
var right_exit : PackedScene = preload("res://World/ClosedExits/RightExit.tscn")
var top_exit : PackedScene = preload("res://World/ClosedExits/TopExit.tscn")
var bottom_exit : PackedScene = preload("res://World/ClosedExits/BottomExit.tscn")

func start(maxcount: int):
	reset()
	start_gen(maxcount)
	var br : Array[PackedScene] = boss_scene.duplicate()
	var ex : Exit = null
	var boss_room : Room = null
	var exit_exit : Exit = null
	while ex == null:
		while br:
			if ex != null:
					break
			var b = GAME.RANDOM_GENERATION.randi_range(0,br.size()-1)
			var e = exits.duplicate()
			while e:
				var exi = GAME.RANDOM_GENERATION.randi_range(0,exits.size()-1)
				var s : Room = br[b].instantiate()
				ex = tryplace(e[exi],s)
				if ex == null:
					e.remove_at(exi)
					s.queue_free()
				else:
					boss_room = s
					exit_exit = e[exi]
					break
			if ex == null:
				br.remove_at(b)
		if ex == null:
			reset()
			start_gen(maxcount)
	get_tree().current_scene.call_deferred("add_child",boss_room)
	boss_room.global_position = (ex.global_position-ex.location)*16
	write(boss_room,ex.global_position-ex.location,ex,exit_exit)
	connect_exits()
	finish_exits()
	GAME.boss_room_pos = boss_room.global_position + Vector2(boss_room.size[0]["size"]*8)
	GAME.outline = [Vector2(minx,miny),Vector2(maxx,miny),Vector2(maxx,maxy),Vector2(minx,maxy)]
	var pe : PackedScene = load("res://Player/Pet/Pet.tscn")
	var pet : Pet = pe.instantiate() #Creates pet
	get_parent().add_child(pet)
	pet.global_position = GAME.player.global_position
	

func start_gen(maxcount: int):
	var spawn: Room = spawn_scene[GAME.RANDOM_GENERATION.randi_range(0,spawn_scene.size()-1)].instantiate()
	add_child(spawn)
	#get_tree().current_scene.call_deferred("add_child", spawn)
	spawn.global_position = Vector2i(0,0)
	write(spawn, spawn.global_position, null, null)
	
	var p : PackedScene = load("res://Player/Player/player.tscn")
	var player : Player = p.instantiate() #Creates player
	get_parent().add_child(player)
	player.global_position = Vector2(spawn.size[0]["size"].x,spawn.size[0]["size"].y+2)*8
	maxx = spawn.navsq.x
	maxy = spawn.navsq.y
	
	min_rooms["Challenge"] = 5
	min_rooms["Checkpoint"] = 2
	min_rooms["Other"] = 5
	scenes = {
		"Challenge": challenge_scene.duplicate(),
		"Checkpoint": checkpoint_scene.duplicate(),
		"Other": other_scene.duplicate()
	}
	while maxcount > 0:
		gen()
		maxcount -= 1


func reset():
	exits = [] #Exits
	walls = {} #All walls
	roomtypes = ["Challenge", "Checkpoint", "Other"] 
	count = 0 #Total number of rooms
	min_rooms = {}
	for room in rooms:
		room.queue_free()
	rooms = []

func finish_exits():
	for e in exits:
		spawn_exit(e)
		

func connect_exits():
	var ex = exits.duplicate()
	while ex:
		var e : Exit = ex.pop_front()
		if not exits.has(e):
			continue
		var coordinates_coeficient : Vector2i
		var d
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
		for other in ex:
			if other.global_position == e.global_position + coordinates_coeficient and other.direction == d:
				exits.erase(e)
				exits.erase(other)
				ex.erase(other)
				break
			
func spawn_exit(e : Exit):
	var scene : PackedScene = null
	match e.direction:
		Room.direction.LEFT:
			scene = left_exit
		Room.direction.RIGHT:
			scene = right_exit
		Room.direction.TOP:
			scene = top_exit
		Room.direction.DOWN:
			scene = bottom_exit
	var s = scene.instantiate()
	add_child(s)
	s.global_position = Vector2(e.global_position.x,e.global_position.y)*16

func gen():
	if exits.is_empty():
		return
	var exit_entry : Exit = null
	var exit_exit : Exit = null
	while exit_entry == null:
		var result = get_room()
		exit_entry = result[0]
		exit_exit = result[1]
	write(exit_entry.room,exit_entry.global_position-exit_entry.location,exit_entry,exit_exit)
	connect_exits()
	get_tree().current_scene.call_deferred("add_child",exit_entry.room)
	exit_entry.room.global_position = (exit_entry.global_position-exit_entry.location)*16
	rooms.append(exit_entry.room)
	maxx = max(maxx, exit_entry.room.global_position.x + exit_entry.room.navsq.x*16)
	maxy = max(maxy, exit_entry.room.global_position.y + exit_entry.room.navsq.y*16)
	minx = min(minx, exit_entry.room.global_position.x)
	miny = min(miny, exit_entry.room.global_position.y)
	exit_entry.room.add_to_group("Rooms")
	

func get_room() -> Array[Exit]:
	var exit_entry = null
	var e : Exit = exits[GAME.RANDOM_GENERATION.randi_range(0,exits.size()-1)]
	var types = roomtypes.duplicate()
	while types:
		var type = types[GAME.RANDOM_GENERATION.randi_range(0,types.size()-1)]
		if(min_rooms[type] <= 0 and types.size() != 1): 
			continue
		var type_scenes : Array[PackedScene] = scenes[type].duplicate()
		while type_scenes:
			var scene = type_scenes[GAME.RANDOM_GENERATION.randi_range(0,type_scenes.size()-1)]
			var room = scene.instantiate()
			exit_entry = tryplace(e, room)
			type_scenes.erase(scene)
			if(exit_entry != null):
				break
			room.queue_free()
		types.erase(type)
		if(exit_entry != null):
				break
	if exit_entry == null:
		exits.erase(e)
		
		spawn_exit(e)
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
		if x.direction == d and e.id == x.id:
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
					break
					
				var check2:=Vector2i(pos.x + m + coordinates.x, pos.y + coordinates.y + height)
				if walls.get(check2,0) != 0: #Bottom wall
					ex.erase(exi)
					possible = false
					break
				m+=1
			m = 0
			while m <= height and possible:
				if walls.get(Vector2i(pos.x + coordinates.x, pos.y + m + coordinates.y),0) != 0: #Left wall
					ex.erase(exi)
					possible = false
					break
				if walls.get(Vector2i(pos.x + coordinates.x + width, pos.y + m + coordinates.y),0) != 0: #Right wall
					ex.erase(exi)
					possible = false
					break
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

func _ready() -> void:
	start(20)
