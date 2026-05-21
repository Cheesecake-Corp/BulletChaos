extends CharacterBody2D
class_name Player

### BASE HODNOTY
@export var BASE_SPEED = 150
@export var BASE_MAX_HEALTH = 100
@export var BASE_DASH_SPEED := 4
@export var BASE_DASH_COOLDOWN := 1.5
@export var BASE_SHIELD := 10
@export var BASE_SHIELD_DELAY := 10
@export var BASE_SHIELD_REGEN := 1
@export var BASE_HEAL_BONUS := 0

var speed = 150
var max_health = 100
var dash_speed := 4
var dash_cooldown := 1.5
var shield := 10
var shield_delay := 10
var shield_regen := 1
var heal_bonus := 0

@export var dash_duration := 0.15
@onready var health = 100
var last = "down"
var last_dir : Vector2 = Vector2(0,1)
var last_health = health
var last_damage = 100

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var camera_body: RigidBody2D = $CameraBody
@onready var camera_collision: CollisionShape2D = $CameraBody/CameraCollision
@onready var dash_progress_bar: TextureProgressBar = $DashProgressBar
@onready var reload_bar: TextureProgressBar = $ReloadBar
@onready var camera_2d: Camera2D = $CameraBody/Camera2D
@export var current_weapon : Weapon
@onready var upgrade: CanvasLayer = $Upgrade
@onready var upgrade_script = $Upgrade/UpgradeGUI/Window
@onready var upgrade_grid = $Upgrade/UpgradeGUI/Window/UpgradesScroll/MarginContainer/GridContainer

var dash_timer := 0.0
var cooldown_timer := 0.0
var is_dashing := false

var afterimage_cooldown := 0.0
@export var afterimage_interval := 0.05
@export var afterimage_scene := preload("res://Player/DashAfterImage/AfterImage.tscn")


var map_mode = false
signal health_change(health)

var upgrade_resources : Array = []
var weapon_upgrades : Array = []
var upgrades : Array[PlayerModInstance] = []
var energy_max : int = 20
var player_stats: Dictionary
var used_energy := 0
var temp_energy := 0

func _ready() -> void:
	GAME.register_player(self)
	player_stats = {
		"health": {"name": "Health", "value": max_health},
		"healing_bonus": {"name": "Heal bonus", "value": heal_bonus}, 
		"shield": {"name": "Shield", "value": shield}, 
		"shield_regen": {"name": "Shield regen", "value": shield_regen}, 
		"shield_delay": {"name": "Shield delay", "value": shield_delay},
		"speed": {"name": "Speed", "value": speed}, 
		"dash_delay": {"name": "Dash delay", "value": dash_cooldown}, 
		"dash_speed": {"name": "Dash speed", "value": dash_speed},
	}


# normal character movement
func character_movement(horizontal, vertical, delta):

	# makes camera follow player smoothly
	camera_body.linear_velocity = -camera_body.position*5
	
	# adds velocity to player (same in every direction)
	velocity = Vector2(horizontal, vertical).normalized() * speed
	
	if horizontal or vertical:
		last_dir = Vector2(horizontal, vertical)
		
	
	if is_dashing:
		dash_timer -= delta

		afterimage_cooldown -= delta
		if afterimage_cooldown <= 0.0:
			spawn_afterimage()
			afterimage_cooldown = afterimage_interval
		
		velocity = last_dir*dash_speed*100
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

	
	

func handle_zoom():
	if Input.is_action_just_pressed("scroll_down"):
		camera_2d.zoom -= Vector2(.1,.1)
	if Input.is_action_just_pressed("scroll_up"):
		camera_2d.zoom += Vector2(.1,.1)

func take_damage(damage : float):
	health -= damage

func hide_upgrade():
	upgrade.visible = !upgrade.visible
	Engine.time_scale = 1
func show_upgrade():
	upgrade.visible = !upgrade.visible
	Engine.time_scale = 0
	upgrade_script.inventory_start()
func _physics_process(_delta: float) -> void:
	if(Input.is_action_just_pressed("inventory")):
		if upgrade.visible:
			hide_upgrade()
		else:
			show_upgrade()
	if upgrade.visible:
		camera_body.linear_velocity = -camera_body.position*5 #Camera stops when inventory is active
		return
	# gets movement input
	dash_progress_bar.value = (dash_cooldown-cooldown_timer)/dash_cooldown*dash_progress_bar.max_value
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")

	if(Input.is_action_pressed("attack")):
		current_weapon._try_use()

	
		

	
	
	# last damage timer
	last_damage = min(last_damage + 1, shield_delay)
	cooldown_timer = move_toward(cooldown_timer, 0, _delta)
	
	if(health != last_health):
		health_change.emit(health)
		last_health = health
	
	
	# handles switching between map mode
	character_movement(horizontal, vertical, _delta)
	
	# slows character down even if in map mode
	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, speed)
		velocity.x = move_toward(velocity.x, 0, speed)
	
	handle_zoom()
	
	move_and_slide()

#@export var health := 0
#@export var healing_bonus := 0
#@export var shield := 0
#@export var shield_recharge := 0
#@export var shield_delay := 0
#@export var speed := 0
#@export var dash_delay := 0
#@export var dash_speed := 0

func recalculate():
	var c_max_health = BASE_MAX_HEALTH
	var c_heal_bonus = BASE_HEAL_BONUS
	var c_shield = BASE_SHIELD
	var c_shield_delay = BASE_SHIELD_DELAY
	var c_shield_regen = BASE_SHIELD_REGEN
	var c_speed = BASE_SPEED
	var c_dash_cooldown = BASE_DASH_COOLDOWN
	var c_dash_speed = BASE_DASH_SPEED
	var c_used_energy = 0
	
	for u in upgrade_grid.get_children():
		if !u.changed_enabled: continue
		c_used_energy += u.upgrade.energy + u.changed_lvl
		c_max_health += u.upgrade.health + u.changed_lvl * u.upgrade.health_change
		c_heal_bonus += u.upgrade.healing_bonus + u.changed_lvl * u.upgrade.healing_bonus_change
		c_shield += u.upgrade.shield + u.changed_lvl * u.upgrade.shield_change
		c_shield_delay += u.upgrade.shield_delay + u.changed_lvl * u.upgrade.shield_delay_change
		c_shield_regen += u.upgrade.shield_recharge + u.changed_lvl * u.upgrade.shield_recharge_change
		c_speed += u.upgrade.speed + u.changed_lvl * u.upgrade.speed_change
		c_dash_cooldown += u.upgrade.dash_delay + u.changed_lvl * u.upgrade.dash_delay_change
		c_dash_speed += u.upgrade.dash_speed + u.changed_lvl * u.upgrade.dash_speed_change
	var calculation = {
		"health": {"name": "Health", "value": c_max_health},
		"healing_bonus": {"name": "Heal bonus", "value": c_heal_bonus}, 
		"shield": {"name": "Shield", "value": c_shield}, 
		"shield_regen": {"name": "Shield regen", "value": c_shield_regen}, 
		"shield_delay": {"name": "Shield delay", "value": c_shield_delay},
		"speed": {"name": "Speed", "value": c_speed}, 
		"dash_delay": {"name": "Dash delay", "value": c_dash_cooldown}, 
		"dash_speed": {"name": "Dash speed", "value": c_dash_speed},
	}
	upgrade_script.change_labels(calculation, energy_max, c_used_energy)
	

func calculate_changes():
	max_health = BASE_MAX_HEALTH
	heal_bonus = BASE_HEAL_BONUS
	shield = BASE_SHIELD
	shield_delay = BASE_SHIELD_DELAY
	shield_regen = BASE_SHIELD_REGEN
	speed = BASE_SPEED
	dash_cooldown = BASE_DASH_COOLDOWN
	dash_speed = BASE_DASH_SPEED
	
	used_energy = 0
	for u in upgrades:
		if !u.enabled: continue
		used_energy += u.data.energy + u.level
		max_health += u.data.health + u.level * u.data.health_change
		heal_bonus += u.data.healing_bonus + u.level * u.data.healing_bonus_change
		shield += u.data.shield + u.level * u.data.shield_change
		shield_delay += u.data.shield_delay + u.level * u.data.shield_delay_change
		shield_regen += u.data.shield_recharge + u.level * u.data.shield_recharge_change
		speed += u.data.speed + u.level * u.data.speed_change
		dash_cooldown += u.data.dash_delay + u.level * u.data.dash_delay_change
		dash_speed += u.data.dash_speed + u.level * u.data.dash_speed_change
	
	player_stats = {
		"health": {"name": "Health", "value": max_health},
		"healing_bonus": {"name": "Heal bonus", "value": heal_bonus}, 
		"shield": {"name": "Shield", "value": shield}, 
		"shield_regen": {"name": "Shield regen", "value": shield_regen}, 
		"shield_delay": {"name": "Shield delay", "value": shield_delay},
		"speed": {"name": "Speed", "value": speed}, 
		"dash_delay": {"name": "Dash delay", "value": dash_cooldown}, 
		"dash_speed": {"name": "Dash speed", "value": dash_speed},
	}
		
