extends CharacterBody2D
class_name Player

@export var SPEED = 150.0
@export var CAMERA_SPEED_MULTIPLIER = 3
var CAMERA_SPEED = SPEED*CAMERA_SPEED_MULTIPLIER
@onready var sprite_2d: Sprite2D = $Sprite2D
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
@onready var dash_progress_bar: TextureProgressBar = $DashProgressBar
@onready var reload_bar: TextureProgressBar = $ReloadBar
@onready var camera_2d: Camera2D = $CameraBody/Camera2D
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
	
	if horizontal or vertical:
		last_dir = Vector2(horizontal, vertical)
		
	
	if is_dashing:
		dash_timer -= delta
		
		afterimage_cooldown -= delta
		if afterimage_cooldown <= 0.0:
			spawn_afterimage()
			afterimage_cooldown = afterimage_interval
		
		velocity = last_dir*dash_speed
		if dash_timer <= 0.0:
			is_dashing = false
			set_collision_layer_value(2, true)
	
	if (Input.is_action_just_pressed("dash") and not is_dashing and cooldown_timer <= 0):
		dash()
	
func dash():
	is_dashing = true
	dash_timer = dash_duration
	cooldown_timer = dash_cooldown
	set_collision_layer_value(2, false)

func spawn_afterimage():
	var ghost : Sprite2D = afterimage_scene.instantiate()
	
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_2d.texture
	
	var frame_width = sprite_2d.texture.get_width() / sprite_2d.hframes
	var frame_height = sprite_2d.texture.get_height() / sprite_2d.vframes
	var col = sprite_2d.frame % sprite_2d.hframes
	var row = sprite_2d.frame / sprite_2d.hframes
	atlas.region = Rect2(col * frame_width, row * frame_height, frame_width, frame_height)
	
	ghost.texture = atlas
	ghost.global_position = sprite_2d.global_position
	ghost.global_rotation = global_rotation
	ghost.flip_h = sprite_2d.flip_h
	ghost.offset = sprite_2d.offset

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

func handle_zoom():
	if Input.is_action_just_pressed("scroll_down"):
		camera_2d.zoom -= Vector2(.1,.1)
	if Input.is_action_just_pressed("scroll_up"):
		camera_2d.zoom += Vector2(.1,.1)

func take_damage(damage : float):
	health -= damage

func _physics_process(_delta: float) -> void:
	# gets movement input
	dash_progress_bar.value = (dash_cooldown-cooldown_timer)/dash_cooldown*dash_progress_bar.max_value
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
	
	handle_zoom()
	
	move_and_slide()
