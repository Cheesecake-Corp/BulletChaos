class_name Weapon
extends Node2D

@export var use_rate : float = 100 # ms
@export var base_damage : float = 12
@export var base_magazine_capacity : int = 20
@export var bullet_speed : float = .1
@export var base_reload_time : float = 1.5 # s
@export var rotation_distance := 30.0
@onready var ray: RayCast2D = $RayCast2D
var final_damage : float
var reloading_time : float = 0
var final_reload_time : float
var is_reloading : bool = false
var final_magazine_capacity : int
var loaded_ammo : int = 20
var last_use_time : float
var aim_angle : float
@export var player : Player
var can_use : bool = true
var player_offset := Vector2(0,0)

var used_bullets: Array[Projectile] = []
var available_bullets: Array[Projectile] = []
@export var bullet_scene: PackedScene

signal change_bullets(bullets : int)

func create_bullets():
	var time = bullet_scene.instantiate().get_meta("max_time")
	for i in range((time-base_reload_time)*1000/use_rate + 1):
		var b : Projectile = bullet_scene.instantiate()
		b.visible = false
		b.global_position = global_position
		b.freeze = true
		b.contact_monitor = true
		b.max_contacts_reported = 1

		var a2 : Area2D = b.get_node("./Area2D")
		a2.body_entered.connect(_on_body_entered.bind(b))
		b.timeout.connect(_on_bullet_timeout)

		available_bullets.append(b)
		get_tree().current_scene.call_deferred("add_child", b)

func _ready() -> void:
	loaded_ammo = base_magazine_capacity
	final_magazine_capacity = base_magazine_capacity
	final_reload_time = base_reload_time
	final_damage = base_damage
	player = GAME.player
	create_bullets()

func reload(delta):
	if Input.is_action_just_pressed("reload") and not is_reloading and not loaded_ammo >= final_magazine_capacity:
		is_reloading = true
		
	if(is_reloading):
		reloading_time += delta
		player.reload_bar.value = reloading_time/final_reload_time*player.reload_bar.max_value
	if reloading_time >= final_reload_time:
		loaded_ammo = final_magazine_capacity
		is_reloading = false
		reloading_time = 0
		change_bullets.emit(loaded_ammo)

func _process(delta: float) -> void:
	set_aim_direction(-(player.global_position + player_offset) + get_global_mouse_position())
	rotation = lerp_angle(rotation, aim_angle, 40 * delta)
	reload(delta)

func set_aim_direction (aim_dir : Vector2):
	aim_angle = aim_dir.angle()
	var dir = aim_dir.normalized()

	var player_mid := player.global_position + player_offset

	# Raycast forward from player
	ray.global_position = player_mid
	ray.target_position = ray.to_local(player_mid + dir * rotation_distance)
	ray.force_raycast_update()

	var distance = rotation_distance

	if ray.is_colliding():
		var hit_point = ray.get_collision_point()
		distance = player_mid.distance_to(hit_point) - 2
		distance = max(distance, 5) # prevent weapon collapsing into player

	var offset = dir * distance
	global_position = player_mid + offset
	if get_global_mouse_position().x < player_mid.x:
		scale.y = -1
	else:
		scale.y = 1

func _try_use() -> bool:
	
	if not can_use:
		return false
	if Time.get_ticks_msec() - last_use_time < use_rate and last_use_time != null:
		return false
	if loaded_ammo == 0:
		return false
	if is_reloading:
		return false
	last_use_time = Time.get_ticks_msec()

	_use(available_bullets.pop_back())
	return true

func _use(b):
	loaded_ammo -= 1
	b.start()
	b.freeze=false
	b.global_position = global_position

	b.visible = true
	b.global_rotation = aim_angle
	var dir = (get_global_mouse_position() - global_position).normalized()
	b.linear_velocity = dir * bullet_speed * 1500
	used_bullets.append(b)
	change_bullets.emit(loaded_ammo)

func _on_body_entered(_body: Node, bullet: Projectile) -> void:
	if not bullet.visible:
		return
	if _body is Enemy:
		_body = _body as Enemy
		_body.take_damage(final_damage)
	call_deferred("_recycle_bullet", bullet)

func _on_bullet_timeout(bullet : Projectile) -> void:
	call_deferred("_recycle_bullet", bullet)

func _recycle_bullet(bullet: Projectile) -> void:
	print("a")
	bullet.freeze = true
	bullet.visible = false
	bullet.linear_velocity = Vector2.ZERO
	bullet.angular_velocity = 0
	bullet.global_position = global_position
	used_bullets.erase(bullet)
	available_bullets.append(bullet)
