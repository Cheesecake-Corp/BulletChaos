extends Enemy

@export var DAMAGE : float = 20

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D

var alive := true
var attack_cooldown : float = 0.0
var ATTACK_COOLDOWN_MAX : float = 0.5
var timer : float = 0.0
var TIMER_MAX : float= 0.3
var movement := true
var sprite_name := ""

func _on_ready() -> void:
	attack_cooldown = ATTACK_COOLDOWN_MAX


func _physics_process(delta: float) -> void:
	attack_cooldown = move_toward(attack_cooldown, 0.0, delta)
	timer = move_toward(timer, 0.0, delta)
	if alive == true:
		var player_distance = GAME.player.global_position - global_position
		if attack_cooldown == 0 and area.overlaps_body(GAME.player) == true and player_distance.length() < 5:
			attack_cooldown = 1000 #Disables it
			movement = false
			var dir = (GAME.player.global_position - global_position).normalized()
			flip_sprite(dir)
			sprite.play("charge")
			sprite_name = "charge"
		if movement == true:
			move(delta)
			if sprite.is_playing() == false:
				sprite.play("move")


func move(delta: float):
	if timer == 0:
		var player_distance = GAME.player.global_position - global_position
		if attack_cooldown == 0 or player_distance.length() > 200:
			nav.target_position = GAME.player.global_position
		else:
			nav.target_position = global_position + Vector2(randf_range(-100,100),randf_range(-100,100))
		timer = TIMER_MAX
	var dir = (nav.get_next_path_position() - global_position).normalized()
	global_position += dir * SPEED * delta
	flip_sprite(dir)
	
func attack():
	if area.overlaps_body(GAME.player) == true:
		GAME.player.take_damage(DAMAGE)
	attack_cooldown = ATTACK_COOLDOWN_MAX
	movement = true


func take_damage(damage : float):
	health -= damage
	if alive == true:
		sprite.play("damaged")
		sprite_name = "damaged"
	movement = false
	if alive == true and health < 0:
		death()


func death():
	sprite.play("death")
	sprite_name = "death"
	movement = false
	alive = false
	get_parent().enemy_dead += 1
	if randf() > 0.5:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		get_parent().room.add_child(canister)
		canister.global_position = global_position


func flip_sprite(dir: Vector2):
	var sprite_previous = sprite.flip_h
	if dir.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	if sprite.flip_h != sprite_previous:
		area_shape.position *= -1


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_name == "charge":
		sprite.play("attack1")
		sprite_name = "attack1"
	elif sprite_name == "attack1":
		attack()
	elif sprite_name == "damaged":
		movement = true
	else:
		queue_free()
