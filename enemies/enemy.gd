class_name Enemy

extends CharacterBody2D
@export var speed : float = 150
var health : float = 100.0
@export var max_health := 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if health <= 0:
		visible = false
		
	
func take_damage(damage : float):
	health -= damage
