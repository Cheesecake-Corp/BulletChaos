extends RigidBody2D
class_name Enemy

@export var speed : float = 150
@export var max_health := 100.0
var health : float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
	
func take_damage(damage : float):
	health -= damage
