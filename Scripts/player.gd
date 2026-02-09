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

# movement in camera mode
func camera_movement(horizontal, vertical):

	# adds velocity to camera in map_mode (same in every direction)
	if horizontal or vertical:
		camera_body.linear_velocity = Vector2( horizontal, vertical).normalized() * CAMERA_SPEED
	
	# slows down camera when no movements keys pressed
	else:
		camera_body.linear_velocity.y = move_toward(velocity.y, 0, SPEED)
		camera_body.linear_velocity.x = move_toward(velocity.x, 0, SPEED)

# normal character movement
func character_movement(horizontal, vertical):

	# makes camera follow player smoothly
	camera_body.linear_velocity = -camera_body.position*5
	
	# adds velocity to player (same in every direction)
	velocity = Vector2(horizontal, vertical).normalized() * SPEED
	
	# ANIMATION HANDELING
	# horizontal animations
	# prioritizes horizontal animation
	if horizontal:
		animated_sprite.play("run_left" if horizontal < 0 else "run_right")
		last_dir = "right" if horizontal > 0 else "left"

	# vertical animations
	elif vertical:
		animated_sprite.play("run_up" if vertical < 0 else "run_down")
		last_dir = "down" if vertical > 0 else "up"

# toggle map mode
func map_mode_handeling(horizontal, vertical):
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
		character_movement(horizontal, vertical)
	
func _physics_process(_delta: float) -> void:
	
	# gets movement input
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")
	
	# handles switching between map mode
	map_mode_handeling(horizontal, vertical)

	# slows character down even if in map mode
	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# plays idle animation
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle_" + last_dir)
	move_and_slide()

func _process(_delta: float) -> void:
	# enables mouse when esc pressed
	if (Input.is_action_just_pressed("pause")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
