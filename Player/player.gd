extends CharacterBody2D
class_name Player

### BASE VALUES
@export var BASE_SPEED = 150
@export var BASE_MAX_HEALTH = 100
@export var BASE_DASH_SPEED := 4
@export var BASE_DASH_COOLDOWN := 1.5
@export var BASE_MAX_SHIELD := 100
@export var BASE_SHIELD_DELAY := 10
@export var BASE_SHIELD_REGEN := 1
@export var BASE_HEAL_BONUS := 0

var speed = BASE_SPEED
var max_health: int = BASE_MAX_HEALTH
var dash_speed := BASE_DASH_SPEED
var dash_cooldown := BASE_DASH_COOLDOWN
var max_shield: int = BASE_MAX_SHIELD 
var shield: float = BASE_MAX_SHIELD
var shield_delay := BASE_SHIELD_DELAY
var shield_regen := BASE_SHIELD_REGEN
var heal_bonus := BASE_HEAL_BONUS

@export var dash_duration := 0.15
var health : float = max_health
var last = "down"
var last_dir : Vector2 = Vector2(0,1)
var last_health: float = 0.0
var last_damage: float = 0.0 #Time in seconds from last damage
var last_shield: float = 0.0

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
signal shield_change(shield)

var upgrade_resources : Array = []
var weapon_upgrades : Array = []
var upgrades : Array[PlayerModInstance] = []
var energy_max : int = 20
var player_stats: Dictionary
var used_energy := 0
var used_energy_temp := 0
var player_stats_temp: Dictionary

func _ready() -> void:
	GAME.register_player(self)
	player_stats = {
		"health": {"name": "Health", "value": max_health},
		"healing_bonus": {"name": "Heal bonus", "value": heal_bonus}, 
		"shield": {"name": "Shield", "value": max_shield}, 
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


func handle_zoom():
	if Input.is_action_just_pressed("scroll_down"):
		camera_2d.zoom -= Vector2(.1,.1)
	if Input.is_action_just_pressed("scroll_up"):
		camera_2d.zoom += Vector2(.1,.1)


func take_damage(damage : float):
	last_damage = 0
	shield -= damage
	if shield < 0:
		shield = 0
		health = health - (damage - shield)
	if health < 0:
		health = 0
		death()


func heal(heal_amount: float):
	health = move_toward(health, max_health, heal_amount + heal_amount * heal_bonus)


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
	
	last_damage = move_toward(last_damage, 1/shield_delay*5 , _delta) # Last damage timer
	cooldown_timer = move_toward(cooldown_timer, 0, _delta) # Dash timer
	
	if last_damage == 1/shield_delay*5: #Shield regeneration
		shield = move_toward(shield, max_shield, _delta * shield_regen)
	
	if(health != last_health): #Changes HUD bars
		health_change.emit(health)
		last_health = health
	
	if(shield != last_shield): #Changes HUD bars
		shield_change.emit(shield)
		last_shield = shield
	
	# handles switching between map mode
	character_movement(horizontal, vertical, _delta)
	
	# slows character down even if in map mode
	if (not (horizontal or vertical)) or map_mode:
		velocity.y = move_toward(velocity.y, 0, speed)
		velocity.x = move_toward(velocity.x, 0, speed)
	
	handle_zoom()
	
	move_and_slide()


func recalculate_stats():
	var c_max_health = BASE_MAX_HEALTH
	var c_heal_bonus = BASE_HEAL_BONUS
	var c_shield = BASE_MAX_SHIELD
	var c_shield_delay = BASE_SHIELD_DELAY
	var c_shield_regen = BASE_SHIELD_REGEN
	var c_speed = BASE_SPEED
	var c_dash_cooldown = BASE_DASH_COOLDOWN
	var c_dash_speed = BASE_DASH_SPEED
	var c_used_energy = 0
	
	for u in upgrade_grid.get_children():
		if !u.changed_enabled: continue
		c_used_energy += u.upgrade.energy + u.changed_lvl - 1
		c_max_health += u.upgrade.health + u.changed_lvl * u.upgrade.health_change
		c_heal_bonus += u.upgrade.healing_bonus + u.changed_lvl * u.upgrade.healing_bonus_change
		c_shield += u.upgrade.shield + u.changed_lvl * u.upgrade.shield_change
		c_shield_delay += u.upgrade.shield_delay + u.changed_lvl * u.upgrade.shield_delay_change
		c_shield_regen += u.upgrade.shield_recharge + u.changed_lvl * u.upgrade.shield_recharge_change
		c_speed += u.upgrade.speed + u.changed_lvl * u.upgrade.speed_change
		c_dash_cooldown += u.upgrade.dash_delay + u.changed_lvl * u.upgrade.dash_delay_change
		c_dash_speed += u.upgrade.dash_speed + u.changed_lvl * u.upgrade.dash_speed_change
	player_stats_temp = {
		"health": {"name": "Health", "value": c_max_health},
		"healing_bonus": {"name": "Heal bonus", "value": c_heal_bonus}, 
		"shield": {"name": "Shield", "value": c_shield}, 
		"shield_regen": {"name": "Shield regen", "value": c_shield_regen}, 
		"shield_delay": {"name": "Shield delay", "value": c_shield_delay},
		"speed": {"name": "Speed", "value": c_speed}, 
		"dash_delay": {"name": "Dash delay", "value": c_dash_cooldown}, 
		"dash_speed": {"name": "Dash speed", "value": c_dash_speed},
	}
	used_energy_temp = c_used_energy
	upgrade_script.change_new_labels(player_stats_temp, player_stats, energy_max, c_used_energy, used_energy)
	

func apply_changes(): #Applying changes
	max_health = BASE_MAX_HEALTH
	heal_bonus = BASE_HEAL_BONUS
	max_shield = BASE_MAX_SHIELD
	shield_delay = BASE_SHIELD_DELAY
	shield_regen = BASE_SHIELD_REGEN
	speed = BASE_SPEED
	dash_cooldown = BASE_DASH_COOLDOWN
	dash_speed = BASE_DASH_SPEED
	
	used_energy = 0
	for u in upgrades:
		
		if !u.enabled: continue
		used_energy += u.data.energy + u.level - 1
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
		"shield": {"name": "Shield", "value": max_shield}, 
		"shield_regen": {"name": "Shield regen", "value": shield_regen}, 
		"shield_delay": {"name": "Shield delay", "value": shield_delay},
		"speed": {"name": "Speed", "value": speed}, 
		"dash_delay": {"name": "Dash delay", "value": dash_cooldown}, 
		"dash_speed": {"name": "Dash speed", "value": dash_speed},
	}
	health_change.emit(health)
	shield_change.emit(shield)


func death() -> void:
	pass
