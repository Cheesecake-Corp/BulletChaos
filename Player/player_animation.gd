extends Node

@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: Player = $".."

var last_facing_direction := Vector2(2,-1)

func _physics_process(_delta: float) -> void:
	var idle = !player.velocity
	
	if not idle:
		last_facing_direction = player.velocity.normalized()
	
	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
