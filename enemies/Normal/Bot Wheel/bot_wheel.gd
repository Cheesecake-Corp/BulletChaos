extends Enemy

@export var bullet_scene : PackedScene
@export var BULLET_SPEED : float = 100
@export var SHOOTING_SPEED : float = 10
@export var DAMAGE_MULT : float = 10
@export var SPEED_MULT : float = 10 #Speed of bullet multiplier

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var bullets: Array[Bot_bullet] = []
var shooting_cooldown : float = 0
var SHOOTING_COOLDOWN_MAX := float(10/SHOOTING_SPEED)
var timer : float = 0 #How often bot sets nav.target
var TIMER_MAX : float = 0.5 #How often bot sets nav.target
var animation_timer : float = 0.75
var ANIMATION_TIMER_MAX : float = 0.75 #Time it takes to play shooting animation
var damage_timer : float = 0
var DAMAGE_TIMER_MAX : float = 0.2
var alive := true
var movement = true


func _ready() -> void:
	MAX_HEALTH = 100.0
	SPEED = 100
	timer = TIMER_MAX
	var parent = get_parent()
	for n in 20:
		bullets.append(bullet_scene.instantiate())
		parent.add_child(bullets[n])
	super()


func _physics_process(delta: float) -> void:
	damage_timer = move_toward(damage_timer, DAMAGE_TIMER_MAX, delta)
	animation_timer = move_toward(animation_timer, ANIMATION_TIMER_MAX, delta)
	if alive == true:
		if movement == true:
			shooting_cooldown = move_toward(shooting_cooldown, SHOOTING_COOLDOWN_MAX, delta)
			move(delta)
			timer = move_toward(timer, TIMER_MAX, delta)
		if animation_timer == ANIMATION_TIMER_MAX:
			animation_timer = ANIMATION_TIMER_MAX + 1 #Disables timer
			shoot()
		if shooting_cooldown == SHOOTING_COOLDOWN_MAX:
			shooting_cooldown = 0
			sprite.play("shoot")
			movement = false
			animation_timer = 0
		if damage_timer == DAMAGE_TIMER_MAX:
			damage_timer = DAMAGE_TIMER_MAX + 1 #Disables timer
			movement = true
	elif alive == false and sprite.is_playing() == false:
		queue_free()


func move(_delta: float) -> void:
	if timer == TIMER_MAX:
		var player_distance = GAME.player.global_position - global_position
		var target := Vector2()
		if player_distance.length() < 100:
			target = global_position + -1 * player_distance.normalized() * 50
		elif player_distance.length() > 200:
			target = global_position + player_distance.normalized() * 50
		else:
			target = global_position + Vector2(randf_range(50,100) * randi_range(-1,1),randf_range(50,100)* randi_range(-1,1))
		nav.target_position = target
		timer = 0
	var nav_next = nav.get_next_path_position()
	var dir = (nav_next - global_position).normalized()
	linear_velocity = dir * SPEED
	if sprite.is_playing() == false:
		sprite.play("move")
	if dir.x < 0:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1

func shoot() -> void:
	var direction = (GAME.player.global_position - global_position).normalized()
	var n = 0
	while bullets[n].active == true:
		if n + 1 >= bullets.size():
			break
		n += 1
	var bullet = bullets[n]
	bullet.bot = self
	bullet.direction = direction
	bullet.global_position = global_position
	bullet.global_rotation = direction.angle()
	bullet.enable()
	movement = true
	

func take_damage(damage: float) -> void:
	sprite.play("damaged")
	movement = false
	damage_timer = 0
	health = health - damage
	if alive == true and health <= 0:
		death()

func death() -> void:
	sprite.play("death")
	alive = false
	get_parent().enemy_dead += 1
	if randf() > 0.5:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		get_parent().room.add_child(canister)
		canister.global_position = global_position
