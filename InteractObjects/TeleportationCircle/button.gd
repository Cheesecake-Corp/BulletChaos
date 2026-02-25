extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var currently_pressed = false
var teleporting = false
var lastCharacter : RigidBody2D

func _process(_delta: float) -> void:
	# triggers teleport when cursor released on collision
	if currently_pressed && Input.is_action_just_released("map"):
		animated_sprite_2d.play("pressing")
		teleporting = true
		

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $AnimatedSprite2D/Sprite2D

func _on_body_entered(body: Node2D) -> void:
	# changes color when hovered
	sprite.modulate = Color.BLACK
	
	# saves that cursor is on button
	currently_pressed = true
	
	# saves last body with hitbox on button
	lastCharacter = body


func _on_body_exited(_body: Node2D) -> void:
	# changes color to gray
	sprite.modulate = Color(0,0,0,0.43)
	
	# saves that button is not on button
	currently_pressed = false


func _on_animated_sprite_2d_animation_finished() -> void:
	# 
	if not teleporting:
		return
	var parent : CharacterBody2D = lastCharacter.get_parent()
	parent.global_position = global_position
	teleporting = false
	animated_sprite_2d.play_backwards("pressing")
