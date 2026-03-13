class_name Weapon
extends Node2D

@export var use_rate : float = 100
@export var base_damage : float = 1
@export var base_magazine_capacity : int = 20
@export var bullet_speed : float = .1
@export var base_reload_time : float = 1.5
var reloading_time : float = 0
var final_reload_time : float
var is_reloading : bool = false
var final_magazine_capacity : int
var loaded_ammo : int = 20
var last_use_time : float
var aim_angle : float
@export var player : CharacterBody2D
var can_use : bool = true

var used_bullets: Array[RigidBody2D] = []
var available_bullets: Array[RigidBody2D] = []
@export var bullet_scene: PackedScene
func _ready() -> void:
	loaded_ammo = base_magazine_capacity
	final_magazine_capacity = base_magazine_capacity
	final_reload_time = base_reload_time
	
	for i in range(final_magazine_capacity):
		var b : RigidBody2D = bullet_scene.instantiate()
		b.visible = false
		b.global_position = global_position
		b.freeze = true
		b.contact_monitor = true
		b.max_contacts_reported = 1

		var a2 : Area2D = b.get_node("./Area2D")
		a2.body_entered.connect(_on_body_entered.bind(b))

		available_bullets.append(b)
		get_tree().current_scene.call_deferred("add_child", b)
	
func _process(delta: float) -> void:
	set_aim_direction(-player.global_position + get_global_mouse_position())
	rotation = lerp_angle(rotation, aim_angle, 40 * delta)
	
	if(Input.is_action_just_pressed("reload")):
		is_reloading = true
		
	if(is_reloading):
		reloading_time += delta
	if reloading_time >= final_reload_time:
		loaded_ammo = final_magazine_capacity
		is_reloading = false
		reloading_time = 0
	
func set_aim_direction (aim_dir : Vector2):
	aim_angle = aim_dir.angle()
	var offset = Vector2(30,0).rotated(aim_angle)
	global_position = player.global_position + Vector2(0, -20) + offset
	if get_global_mouse_position().x < player.global_position.x:
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

	_use()
	return true

func _use():
	loaded_ammo -= 1
	var b = available_bullets.pop_back()
	
	b.freeze=false
	b.global_position = global_position

	b.visible = true
	b.global_rotation = aim_angle
	var dir = (get_global_mouse_position() - global_position).normalized()
	b.linear_velocity = dir * bullet_speed * 1500
	used_bullets.append(b)

func _on_body_entered(_body: Node, bullet: RigidBody2D) -> void:
	if not bullet.visible:
		return
	call_deferred("_recycle_bullet", bullet)

func _recycle_bullet(bullet: RigidBody2D) -> void:
	bullet.freeze = true
	bullet.visible = false
	bullet.linear_velocity = Vector2.ZERO
	bullet.angular_velocity = 0
	bullet.global_position = global_position
	used_bullets.erase(bullet)
	available_bullets.append(bullet)
