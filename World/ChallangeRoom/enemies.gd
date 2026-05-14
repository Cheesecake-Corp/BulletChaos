extends Node

@export var bot : PackedScene
@export var deer : PackedScene
@export var enemy_count = 4
@export var chance_bot := 0.5 #Value between 0 and 1
signal room_complete(enemies_killed : int)
var enemies : Array[Enemy] = []
@onready var challange_room: Node2D = $".."
var enemy_dead := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if enemy_dead == enemy_count:
		room_complete.emit(enemy_dead)


func _on_timer_timeout() -> void:
	var n = 0
	var parent = get_parent()
	while n < enemy_count:
		if randf() < chance_bot:
			enemies.append(bot.instantiate())
		else:
			enemies.append(deer.instantiate())
		add_child(enemies[n])
		enemies[n].global_position = parent.global_position + parent.navsq*8 + Vector2(GAME.RANDOM_GENERATION.randf_range(-5,5),GAME.RANDOM_GENERATION.randf_range(-5,5))*16
		enemies[n].visible = true
		enemies[n].nav.target_position = enemies[n].global_position
		n += 1
