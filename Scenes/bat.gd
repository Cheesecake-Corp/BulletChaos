extends RigidBody2D

var targeting = false
@export var speed : float = 50
@export var dmg_att1 : float = 5
@export var dmg_att2 : float = 5
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var animation_playing = false
var animation_looping = false
func _ready() -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		_on_visible_on_screen_notifier_2d_screen_entered()


func _physics_process(_delta: float) -> void:
	if not targeting:
		return
	if animation_playing == false and animation_looping == false:
		animated_sprite_2d.play("bat_idlefly")
	

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if targeting:
		return
	targeting = true
	animated_sprite_2d.play("bat_wakeup")
	animation_playing = true


func _on_animated_sprite_2d_animation_finished() -> void:
	animation_playing = false


func _on_animated_sprite_2d_animation_looped() -> void:
	animation_looping = true
