class_name Projectile
extends RigidBody2D

signal timeout(bullet : Projectile)
@onready var timer: Timer = $Timer
@onready var bullet: Projectile = $"."
var puncture : int = 1
var vel : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = get_meta("max_time")
	

func start():
	timer.start(get_meta("max_time"))
	vel = linear_velocity
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	if visible and not linear_velocity.normalized().is_equal_approx(vel.normalized()):
		timeout.emit(self)

func on_timeout() -> void:
	timeout.emit(self)
	
