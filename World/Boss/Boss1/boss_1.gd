extends Room
@onready var marker_2d: Marker2D = $Marker2D
@onready var timer: Timer = $Timer
var spawned = false
func _init() -> void:
	size = {}
	navsq = Vector2(48,28)
	size[0] = {}
	size[0]["position"] = Vector2i(0,0)
	size[0]["size"] = Vector2i(48,28)
	 
	exits.append(Exit.new().set_location(Vector2i(14,0)).set_direction(direction.TOP).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(0,4)).set_direction(direction.LEFT).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(29,28)).set_direction(direction.DOWN).set_room(self))
	exits.append(Exit.new().set_location(Vector2i(48,12)).set_direction(direction.RIGHT).set_room(self))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Player: return
	if spawned: return
	spawned = true
	var boss = load("uid://5cc0ei0pmkxl").instantiate()
	GAME.entities_node.call_deferred("add_child",boss)
	boss.global_position = marker_2d.global_position
	boss.room = self
	
	
	


func _on_timer_timeout() -> void:
	GAME.player.level_completed()
