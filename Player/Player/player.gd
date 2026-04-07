extends CharacterBody2D
class_name Player

@export var SPEED = 150.0
@export var CAMERA_SPEED_MULTIPLIER = 3
var CAMERA_SPEED = SPEED*CAMERA_SPEED_MULTIPLIER
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last = "down"
var last_dir : Vector2 = Vector2(0,1)
@onready var health = 100
var last_health = health
@onready var max_health = 100
var last_damage = 100
@onready var regen_delay = 20
@onready var natural_regen_per_second = 2
@onready var camera_body: RigidBody2D = $CameraBody
@onready var cursor: Sprite2D = $CameraBody/CameraCollision/Sprite2D
@onready var camera_collision: CollisionShape2D = $CameraBody/CameraCollision
@export var current_weapon : Weapon
@export var dash_speed := 400.0
@export var dash_duration := 0.15
@export var dash_cooldown := 1.5

var dash_timer := 0.0
var cooldown_timer := 0.0
var is_dashing := false

var afterimage_cooldown := 0.0
@export var afterimage_interval := 0.05
@export var afterimage_scene := preload("res://Player/DashAfterImage/AfterImage.tscn")


var map_mode = false
signal health_change(health)

func _ready() -> void:
	GAME.register_player(self)
	change_weapon(GAME.current_weapon)

func change_weapon(weapon : PackedScene):
	var w = weapon.instantiate()
	add_child(w)
	current_weapon = w
# movement in camera mode
func camera_movement(horizontal, vertical):

	# adds velocity to camera in map_mode (same in every direction)
	if horizontal or vertical:
		camera_body.linear_velocity = Vector2(horizontal, vertical).normalized() * CAMERA_SPEED
	
	# slows down camera when no movements keys pressed
	else:
		camera_body.linear_velocity.y = move_toward(velocity.y, 0, SPEED)
		camera_body.linear_velocity.x = move_toward(velocity.x, 0, SPEED)

# normal character movement
func character_movement(horizontal, vertical, delta):

	# makes camera follow player smoothly
	camera_body.linear_velocity = -camera_body.position*5
	
	# adds velocity to player (same in every direction)
	velocity = Vector2(horizontal, vertical).normalized() * SPEED
	
	# ANIMATION HANDELING
	# horizontal animations
	# prioritizes horizontal animation
	if horizontal or vertical:
		last_dir = Vector2(horizontal, vertical)
		if horizontal > 0:
			if vertical > 0:
				last = "rd"
				
			if vertical == 0:
				last = "right"
			if vertical < 0:
				last = "ru"
		elif horizontal < 0:
			if vertical > 0:
				last = "ld"
			if vertical == 0:
				last = "left"
			if vertical < 0:
				last = "lu"
		elif horizontal == 0:
			if vertical > 0:
				last = "down"
			if vertical < 0:
				last = "up"
	
	if is_dashing:
		dash_timer -= delta
		afterimage_cooldown -= delta
		if afterimage_cooldown <= 0.0:
			spawn_afterimage()
			afterimage_cooldown = afterimage_interval
		
		velocity = last_dir*dash_speed

		if dash_timer <= 0.0:
			is_dashing = false
	
	if (Input.is_action_just_pressed("dash") and not is_dashing and cooldown_timer <= 0):
		dash()

func dash():
	is_dashing = true
	dash_timer = dash_duration
	cooldown_timer = dash_cooldown

func spawn_afterimage():
	var ghost : Sprite2D = afterimage_scene.instantiate()
	ghost.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	ghost.global_position = animated_sprite.global_position
	ghost.global_rotation = global_rotation
	ghost.flip_h = animated_sprite.flip_h
	ghost.offset = animated_sprite.offset

	get_tree().current_scene.add_child(ghost)

# toggle map mode
func map_mode_handeling(horizontal, vertical, delta):
	# handles enabling map mode
	if(Input.is_action_just_pressed("map")):
		map_mode = true
		cursor.visible = true
		camera_collision.disabled = false
	# handles disabling map mode
	elif(Input.is_action_just_released("map")):
		map_mode = false
		cursor.visible = false
		camera_collision.disabled = true
	
	# handles movement depending if map mode is enabled
	if(map_mode):
		camera_movement(horizontal,vertical)
	else:
		character_movement(horizontal, vertical, delta)
	
func _physics_process(_delta: float) -> void:
	# gets movement input
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")

	if(Input.is_action_pressed("attack")):
		current_weapon._try_use()

	if(last_damage == regen_delay):
		health = move_toward(health, max_health, natural_regen_per_second*_delta)
	
	# last damage timer
	last_damage = min(last_damage + 1, regen_delay)
	cooldown_timer = move_toward(cooldown_timer, 0, _delta)
	
	if(health != last_health):
		health_change.emit(health)
		last_health = health
	
	
	# handles switching between map mode
	map_mode_handeling(horizontal, vertical, _delta)

	# slows character down even if in map mode
	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# plays idle animation
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle_" + last)
	else:
		animated_sprite.play("run_" + last)
	
	move_and_slide()
