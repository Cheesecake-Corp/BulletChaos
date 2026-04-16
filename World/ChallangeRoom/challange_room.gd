extends Room

@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer
@onready var enemies: Node = $Enemies


func _init() -> void:
	navsq = Vector2(33,20)
	size = {}
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(33,20)
	 
	exits.append(Exit.new().set_location(Vector2i(14,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,4)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(14,20)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(33,4)).set_direction(direction.RIGHT).set_room(self))


func _on_enemies_room_complete() -> void:
	enemies.queue_free()
	timer.queue_free()
	area_2d.queue_free()
	print("Room complete")
