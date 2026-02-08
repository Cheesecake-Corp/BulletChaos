extends CharacterBody2D


const SPEED = 100.0
const CAMERA_SPEED = SPEED*3
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_dir = "down"
@onready var camera_body: RigidBody2D = $CameraBody
var map_mode = false

func camera_movement(horizontal, vertical):

	if horizontal or vertical:
		camera_body.linear_velocity.y = vertical * CAMERA_SPEED
		camera_body.linear_velocity.x = horizontal * CAMERA_SPEED
	else:
		camera_body.linear_velocity.y = move_toward(velocity.y, 0, SPEED)
		camera_body.linear_velocity.x = move_toward(velocity.x, 0, SPEED)

func character_movement(horizontal, vertical):

	camera_body.linear_velocity = -camera_body.position*5
	velocity.y = vertical * SPEED
	velocity.x = horizontal * SPEED

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
	elif(Input.is_action_just_released("map")):
		map_mode = false

	if(map_mode):
		camera_movement(horizontal,vertical)
	else:
		character_movement(horizontal, vertical)

	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle_" + last_dir)
	move_and_slide()
