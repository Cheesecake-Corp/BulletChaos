extends Node
class_name EnemySpawner

@export var bot : PackedScene
@export var deer : PackedScene
@export var enemy_count = 4
@export var chance_bot := 0.5 #Value between 0 and 1

@onready var challange_room: Node2D = $".."

signal room_complete(enemies_killed : int)

var enemies : Array[Enemy] = []
var enemy_dead := 0
var room : Node2D

func _ready() -> void:
	room = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if enemy_dead == enemy_count * GAME.difficulty:
		room_complete.emit(enemy_dead)


func _on_timer_timeout() -> void:
	if enemies:
		return
	var n = 0
	var parent = get_parent()
	while n < enemy_count * GAME.difficulty:
		var enemy : Enemy
		if randf() < chance_bot:
			enemy = bot.instantiate()
		else:
			enemy = deer.instantiate()
		enemy.room_manager = self
		enemies.append(enemy)
		GAME.entities_node.add_child(enemy)
		enemy.global_position = parent.global_position + parent.navsq*8 + Vector2(GAME.RANDOM_GENERATION.randf_range(-5,5),GAME.RANDOM_GENERATION.randf_range(-5,5))*16
		enemy.visible = true
		enemy.nav.target_position = enemies[n].global_position
		n += 1
