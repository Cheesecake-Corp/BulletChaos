extends Sprite2D

var PET_SPEED = 50
@onready var player: CharacterBody2D = $"../.."
@onready var camera_2d: Camera2D = $".."

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta: float) -> void:
	global_position = camera_2d.get_screen_center_position() + (player.global_position)/5
	global_position.y -= 12
