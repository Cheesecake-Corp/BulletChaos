extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var plant: Array = [5,5,5,5,5,5,5,5,5,5]
	var start := Vector2i(0,0)
	mapgen(plant, start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func mapgen(plant: Array, start: Vector2i) -> void:
	const BASEWIDTH = 600
	const BASEHEIGHT = 400
	var width = BASEWIDTH + 10 * (plant[0] - 4)
	var height = BASEHEIGHT + 10 * (plant[1] - 4)
	var mapsize := Vector2i(width, height)
	var mapstart := Vector2i(0 - width/2, 0 - height/2)
	#Exit1 - right; Exit2 - down; Exit3 - left; Exit4 - up; Exit5 - 2right; Exit6 - 2down; Exit7 - 2left; Exit8 - 2up
	#Vector4(xcord,ycord,size,priority)
	#Vector2(xsize,ysize)
	var rooms = {
		"Spawn_room_Right": {"Size": Vector2i(20,20), "Exits": [1], "Exit1": Vector4i(20,10,1,1)},
		"Spawn_room_Down": {"Size": Vector2i(20,20), "Exits": [2], "Exit2": Vector4i(10,20,1,1)},
		"Spawn_room_Left": {"Size": Vector2i(20,20), "Exits": [3], "Exit3": Vector4i(1,10,1,1)},
		"Spawn_room_Up": {"Size": Vector2i(20,20), "Exits": [4], "Exit4": Vector4i(10,1,1,1)},
		"Small_room": {"Size": Vector2i(10,10), "Exits": [1,2,3,4], "Exit1": Vector4i(10,5,1,1), "Exit2": Vector4i(5,10,1,1),"Exit3": Vector4i(1,5,1,1),"Exit4": Vector4i(5,10,1,1)},
		"Medium_room": {"Size": Vector2i(20,20), "Exits": [1,2,3,4], "Exit1": Vector4i(20,10,1,1), "Exit2": Vector4i(10,20,1,1),"Exit3": Vector4i(1,10,1,1),"Exit4": Vector4i(10,1,1,1)},
		"Large_room": {"Size": Vector2i(30,30), "Exits": [1,2,3,4], "Exit1": Vector4i(30,15,1,1), "Exit2": Vector4i(15,30,1,1),"Exit3": Vector4i(1,15,1,1),"Exit4": Vector4i(15,1,1,1)},
		"Challenge_room": {"Size": Vector2i(20,20), "Exits": [1,2,3,4], "Exit1": Vector4i(20,10,1,1), "Exit2": Vector4i(10,20,1,1),"Exit3": Vector4i(1,10,1,1),"Exit4": Vector4i(10,1,1,1)},
		"Checkpoint_room": {"Size": Vector2i(20,20), "Exits": [1,2,3,4], "Exit1": Vector4i(20,10,1,1), "Exit2": Vector4i(10,20,1,1),"Exit3": Vector4i(1,10,1,1),"Exit4": Vector4i(10,1,1,1)},
		"Hall_Horizontal_Small":{"Size": Vector2i(1,1),"Exits": [1,3], "Exit1": Vector4i(1,1,1,1), "Exit3": Vector4i(1,1,1,1)},
		"Hall_Horizontal_Medium":{"Size": Vector2i(1,2),"Exits": [1,3], "Exit1": Vector4i(1,1,2,1), "Exit3": Vector4i(1,1,2,1)},
		"Hall_Horizontal_Large":{"Size": Vector2i(1,3),"Exits": [1,3], "Exit1": Vector4i(1,1,3,1), "Exit3": Vector4i(1,1,3,1)},
		"Hall_Vertical_Small":{"Size": Vector2i(1,1),"Exits": [2,4], "Exit2": Vector4i(1,1,1,1), "Exit4": Vector4i(1,1,1,1)},
		"Hall_Vertical_Medium":{"Size": Vector2i(2,1),"Exits": [2,4], "Exit2": Vector4i(1,1,2,1), "Exit4": Vector4i(1,1,2,1)},
		"Hall_Vertical_Large":{"Size": Vector2i(3,1),"Exits": [2,4], "Exit2": Vector4i(1,1,3,1), "Exit4": Vector4i(1,1,3,1)},
	}
	var exits = {
		"name" : [],
		"x" : [], #Exit x coordinate
		"y" : [], #Exit y coordinate
		"bool" : [], #Is exit used? false - used, true - empty
		"size" : [], #Exit size, 1, 2 or 3 tiles
		"value" : [], #Priority of the exit during generation
	}
	var pixel = {
		"X": [], #Tile x coordinate on map
		"Y": [], #Tile y coordinate on map
		"value" : [], #Vector on tileset
	}
	var roomcount = { #For special rooms that have limited amount
		"Checkpoint_room": {"Max": 4, "Current": 0},
		"Challenge_room": {"Max": 4, "Current": 0},
	}
	print("DEBUG: Generating dictionaries complete") #INFO
	
	var spawnmiddle: Vector2i = rooms.Spawn_room_Right.Size/2
	var distx := Vector2i(mapstart.x + mapsize.x - spawnmiddle.x, spawnmiddle.x - mapstart.x) #First coordinate is distance to right, second coordinate is distance to left
	var disty := Vector2i(mapstart.y + mapsize.y - spawnmiddle.y, spawnmiddle.y - mapstart.y) #First coordinate is distance down, second coordinate is distance up
	#print("To right " + str(distx.x) + " To left " + str(distx.y) + " To down " + str(disty.x) + " To up " + str(disty.y))
	if max(distx.x,distx.y)*(float(BASEHEIGHT)/float(BASEWIDTH)) > max(disty.x,disty.y):
		#Before first roomwrites it is necessary to add atleast one exit
		if distx.x > distx.y: #To right is the biggest distance
			Roomwrite(pixel, rooms, exits, start, "Spawn_room_Right")
			#print("Spawn_room_Right")
		else: #To left is the biggest distance
			Roomwrite(pixel, rooms, exits, start, "Spawn_room_Left")
			#print("Spawn_room_Left")
	else:
		if disty.x > disty.y: #To down is the biggest distance
			Roomwrite(pixel, rooms, exits, start, "Spawn_room_Down")
			#print("Spawn_room_Down")
		else: #To up is the biggest distance
			Roomwrite(pixel, rooms, exits, start, "Spawn_room_Up")
			#print("Spawn_room_Up")
	var lastseed = 0
	print("DEBUG: Writing spawn room successful")
	for n in 1:
		lastseed = Roomgen(lastseed, plant, rooms, exits, pixel, roomcount)
		print("Rooms printed: " + str(n))
	
	print("DEBUG: Roomdraw started...")
	Roomdraw(pixel)
	print("DEBUG: Roomdraw ended")


func Roomgen(lastplant: int, plant: Array, rooms: Dictionary, exits: Dictionary, pixel: Dictionary, roomcount: Dictionary) -> int:
	print("DEBUG: Roomgen started...")
	var m := 0
	var maxval = 0
	var j := -1 #Coordinate in array of the highest value exit
	while m < exits.value.size(): #Searches for highest value of exit
		if exits.bool[m] == true:
			maxval = max(maxval, exits.value[m])
		m += 1
	print("M:" + str(m))
	var cont := true
	while cont == true :
		j += 1
		if exits.value[j] == maxval && exits.bool[j] == true:
			cont = false
		
	print("J:" + str(j)) 
	var hallsize := ""
	match exits.size[j]:
		1:
			hallsize = "Small"
		2:
			hallsize = "Medium"
		3:
			hallsize = "Large"
	#print(hallsize)
	var dir := Vector2i(0,0)
	var halldir := ""
	if exits.name[j] == "Exit1" or exits.name[j] == "Exit5": # Right
		dir = Vector2i(1,0)
		halldir = "Horizontal"
	elif exits.name[j] == "Exit2" or exits.name[j] == "Exit6": # Down
		dir = Vector2i(0,1)
		halldir = "Vertical"
	elif exits.name[j] == "Exit3" or exits.name[j] == "Exit7": # Left
		dir = Vector2i(-1,0)
		halldir = "Horizontal"
	else: # Up
		dir = Vector2i(0,-1)
		halldir = "Vertical"
	var hallname := "Hall_" + halldir + "_" + hallsize
	var hallstart := Vector2i(exits.x[j] + dir.x, exits.y[j] + dir.y)
	exits.bool[j] = false
	Roomwrite(pixel,rooms,exits,hallstart,hallname) #Generates hallway
	var possible: Array = ["Small_room","Medium_room","Large_room"]
	if roomcount.Checkpoint_room.Current < roomcount.Checkpoint_room.Max:
		possible.append("Checkpoint_room")
	if roomcount.Checkpoint_room.Current < roomcount.Checkpoint_room.Max:
		possible.append("Challenge_room")
	
	var goodsize: Array = []
	var corrsize = false
	var i = 0
	var k = 1
	var l = 1
	var o = 0
	var a = 0
	var b = 0
	var roomstart := Vector2i(0,0)
	var exitname := str(exits.name[j])
	var roomcordx: Array = []
	var roomcordy: Array = []
	
	for n in possible: #Checks room size to see if they can generate
		roomstart = Vector2i(hallstart.x + dir.x - rooms[possible[o]][exitname].x, hallstart.y + dir.y - rooms[possible[o]][exitname].y) #One tile further from original exit minus vector how to get from roomstart to roomexit
		corrsize = true
		while k <= rooms[possible[o]]["Size"].x: #Gets all coordinates of all tiles in room
			while l <= rooms[possible[o]]["Size"].y:
				roomcordx.append(roomstart.x + k)
				roomcordy.append(roomstart.y + l)
				l += 1
			k += 1
		o += 1
		for p in roomcordx: #Tests for each room coordinate if it is already occupied by something(stored in pixel dictionary)
			for q in pixel.X:
				if pixel.X[b] == roomcordx[a] && pixel.Y[b] == roomcordy[a]:
					corrsize = false
				b += 1
			b = 0
			a += 1
		a = 0
		if corrsize == true: #If tiles are not occupied adds room name to array goodsize
			goodsize.append(possible[i])
		roomcordx.clear()
		roomcordy.clear()
	
	var roomnumb := 0
	roomnumb = (plant[lastplant] + 1) * (goodsize.size() / 10) #Number of room type in goodsize
	while roomnumb > goodsize.size():
		roomnumb /= 2
	Roomwrite(pixel, rooms, exits, roomstart, goodsize[roomnumb]) #Writes the room, selects roomnumb from goodsize
	print("DEBUG: Roomgen ended")
	return plant[lastplant] + 1


func Roomwrite(pixel: Dictionary, rooms: Dictionary, exits: Dictionary, roomstart: Vector2i, roomtype: String):
	print("DEBUG: Roomwrite started...") #INFO
	#var Size := Vector2i(rooms[roomtype]["Size"])
	#var Exits: Array = [rooms.roomtype.Exits]
	var m = 0
	for n in rooms[roomtype]["Exits"]: #Writes each exit of room in exits dictionary in correct arrays
		#while exits["exitsx"][m] != null: #Searches for empty space
		var exname = "Exit" + str(rooms[roomtype]["Exits"][m]) 
		print(exname)
		exits["name"].append(exname) #Adds new information to arrays in exits dictionary
		exits.x.append(rooms[roomtype][exname].x)
		exits.y.append(rooms[roomtype][exname].y)
		exits.bool.append(true)
		exits.size.append(rooms[roomtype][exname].z)
		exits.value.append(rooms[roomtype][exname].w)
		m += 1
	
	var n := 1
	while n < rooms[roomtype]["Size"].x: #Top and bottom wall
		pixel.X.append(roomstart.x + n)
		pixel.Y.append(roomstart.y)
		pixel.value.append(Vector2i(2,0))
		pixel.X.append(roomstart.x + n)
		pixel.Y.append(roomstart.y + rooms[roomtype]["Size"].y)
		pixel.value.append(Vector2i(9,3))
		n += 1
		
	n = 1
	while n < rooms[roomtype]["Size"].y: #Right and left wall
		pixel.X.append(roomstart.x + rooms[roomtype]["Size"].x) #Right wall
		pixel.Y.append(roomstart.y + n)
		pixel.value.append(Vector2i(11,2))
		pixel.X.append(roomstart.x) #Left wall
		pixel.Y.append(roomstart.y + n)
		pixel.value.append(Vector2i(8,1))
		n += 1
	
		pixel.X.append(roomstart.x) #Top left corner
		pixel.Y.append(roomstart.y)
		pixel.value.append(Vector2i(1,0))
		pixel.X.append(roomstart.x + rooms[roomtype]["Size"].x) #Top right corner
		pixel.Y.append(roomstart.y)
		pixel.value.append(Vector2i(3,0))
		pixel.X.append(roomstart.x) #Down left corner
		pixel.Y.append(roomstart.y  + rooms[roomtype]["Size"].y)
		pixel.value.append(Vector2i(1,2))
		pixel.X.append(roomstart.x + rooms[roomtype]["Size"].x) #Down right corner
		pixel.Y.append(roomstart.y  + rooms[roomtype]["Size"].y)
		pixel.value.append(Vector2i(3,2))
	
	n = 1
	var o = 1
	#m = 0
	while n < rooms[roomtype]["Size"].x: #Writes the floor into pixel dictionary and into correct arrays
		#while pixel.X[m] != null: #Search for empty space
		#	m += 1
		#print(n)
		while o < rooms[roomtype]["Size"].y:
			#print("O: " + str(o))
			pixel.X.append(roomstart.x + n)
			pixel.Y.append(roomstart.y + o)
			pixel.value.append(Vector2i(2,1))
			o += 1
		o = 1
		n += 1
	print("DEBUG: Roomwrite ended") #INFO

func Roomdraw(pixel: Dictionary):
	var m = 0
	for n in pixel.X:
		var coor = Vector2i(pixel.X[m],pixel.Y[m])
		set_cell(coor,3,pixel.value[m],0)
		m += 1
