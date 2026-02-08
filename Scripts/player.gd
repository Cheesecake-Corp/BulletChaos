extends CharacterBody2D


@export var SPEED = 100.0
@export var CAMERA_SPEED_MULTIPLIER = 3
var CAMERA_SPEED = SPEED*CAMERA_SPEED_MULTIPLIER
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_dir = "down"
@onready var camera_body: RigidBody2D = $CameraBody
@onready var cursor: Sprite2D = $CameraBody/CameraCollision/Sprite2D
@onready var camera_collision: CollisionShape2D = $CameraBody/CameraCollision
var map_mode = false

func camera_movement(horizontal, vertical):

	if horizontal or vertical:
		camera_body.linear_velocity = Vector2( horizontal, vertical).normalized() * (SPEED if Input.is_action_pressed("shift") else CAMERA_SPEED)
	else:
		camera_body.linear_velocity.y = move_toward(velocity.y, 0, SPEED)
		camera_body.linear_velocity.x = move_toward(velocity.x, 0, SPEED)

func character_movement(horizontal, vertical):

	camera_body.linear_velocity = -camera_body.position*5
	
	velocity = Vector2(horizontal, vertical).normalized() * SPEED
	

	if horizontal:
		animated_sprite.play("run_left" if horizontal < 0 else "run_right")
		last_dir = "right" if horizontal > 0 else "left"

	elif vertical:
		animated_sprite.play("run_up" if vertical < 0 else "run_down")
		last_dir = "down" if vertical > 0 else "up"

func _physics_process(_delta: float) -> void:
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")

	if(Input.is_action_just_pressed("map")):
		map_mode = true
		cursor.visible = true
		camera_collision.disabled = false
	elif(Input.is_action_just_released("map")):
		map_mode = false
		cursor.visible = false
		camera_collision.disabled = true

	if(map_mode):
		camera_movement(horizontal,vertical)
	else:
		character_movement(horizontal, vertical)

	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle_" + last_dir)
	move_and_slide()

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
