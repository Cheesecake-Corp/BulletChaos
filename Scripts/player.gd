extends CharacterBody2D


const SPEED = 100.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_dir = "down"
func _physics_process(delta: float) -> void:
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")
	velocity.y = vertical * SPEED
	velocity.x = horizontal * SPEED
	if horizontal:
		
		animated_sprite.play("run_left" if horizontal < 0 else "run_right")
		last_dir = "right" if horizontal > 0 else "left"
	elif vertical:
		
		animated_sprite.play("run_up" if vertical < 0 else "run_down")
		last_dir = "down" if vertical > 0 else "up"
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle_" + last_dir)
	
	
		
		
		
	move_and_slide()
