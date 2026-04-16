extends Node

@export var bot : PackedScene
@export var enemy_count = 3
signal room_complete
var enemies : Array[Enemy] = []
@onready var challange_room: Node2D = $".."
var enemy_dead := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemy_dead == enemy_count:
		room_complete.emit()


func _on_timer_timeout() -> void:
	var n = 0
	var parent = get_parent()
	while n < enemy_count:
		enemies.append(bot.instantiate())
		add_child(enemies[n])
		enemies[n].global_position = parent.global_position + parent.navsq*8 + Vector2(GAME.RANDOM_GENERATION.randf_range(-5,5),GAME.RANDOM_GENERATION.randf_range(-5,5))*16
		enemies[n].visible = true
		enemies[n].nav.target_position = enemies[n].global_position
		n += 1
