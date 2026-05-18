extends RigidBody2D
class_name Enemy

@export var SPEED : float = 150
@export var MAX_HEALTH := 100.0
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var health : float
var alive := true
var movement := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
	
func take_damage(damage : float):
	health -= damage
	
	movement = false
	if alive == true and health < 0:
		death()

func death():
	linear_velocity = Vector2.ZERO
	movement = false
	alive = false
	get_parent().enemy_dead += 1
	if randf() > 0.5:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		get_parent().room.call_deferred("add_child", canister)
		call_deferred("set_canister_pos", canister)
		
func set_canister_pos(canister : Node2D):
	canister.global_position = global_position
		
