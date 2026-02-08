extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var currently_pressed = false
var teleporting = false
var lastCharacter : RigidBody2D

func _process(_delta: float) -> void:
	if currently_pressed && Input.is_action_just_released("map"):
		animated_sprite_2d.play("pressing")
		teleporting = true
		

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $AnimatedSprite2D/Sprite2D

func _on_body_entered(body: Node2D) -> void:
	sprite.modulate = Color.BLACK
	
	animated_sprite_2d.modulate = Color.PINK
	currently_pressed = true
	lastCharacter = body


func _on_body_exited(_body: Node2D) -> void:
	sprite.modulate = Color(0,0,0,0.43)
	animated_sprite_2d.modulate = Color.WHITE
	currently_pressed = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if not teleporting:
		return
	var parent : CharacterBody2D = lastCharacter.get_parent()
	parent.global_position = global_position
	teleporting = false
	animated_sprite_2d.play_backwards("pressing")
