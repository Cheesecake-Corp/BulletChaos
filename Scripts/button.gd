extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _on_body_entered(body: Node2D) -> void:
	animated_sprite_2d.play("pressing")


func _on_body_exited(body: Node2D) -> void:
	animated_sprite_2d.play("leaving")
