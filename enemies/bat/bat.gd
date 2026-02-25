extends CharacterBody2D

@export var player : CharacterBody2D
enum{
	ATTACK,
	SURROUND,
	HIT,
	SLEEP
}

var state = SLEEP

@export var speed : float = 150
@export var dmg_att1 : float = 5
@export var dmg_att2 : float = 5
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var animation_playing = false
var animation_looping = false
func _ready() -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		_on_visible_on_screen_notifier_2d_screen_entered()


func _physics_process(_delta: float) -> void:
	if state == SLEEP:
		return
	if state == SURROUND:
		move(player,_delta)
		if not animation_player.is_playing():
			animation_player.play("bat/idle_fly")
			
	
	

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if not state == SLEEP:
		return
	state = SURROUND
	animated_sprite_2d.play("bat_wakeup")

func move(target : CharacterBody2D, delta):
	var dir = (target.global_position - global_position).normalized()
	var desired_velocity = dir * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	
	move_and_slide()
