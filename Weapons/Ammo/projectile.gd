class_name Projectile
extends RigidBody2D

signal timeout(bullet : Projectile)
@onready var timer: Timer = $Timer
@onready var bullet: Projectile = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = get_meta("max_time")
	

func start():
	timer.start(get_meta("max_time"))

# Called every frame. 'delta' is the elapsed time since the previous frame.



func on_timeout() -> void:
	timeout.emit(self)
	
