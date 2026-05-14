extends RigidBody2D
class_name Enemy

@export var SPEED : float = 150
@export var MAX_HEALTH := 100.0
var health : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
	
func take_damage(damage : float):
	health -= damage
