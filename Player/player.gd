extends CharacterBody2D
class_name Player

### BASE VALUES PLAYER #OUTDATED - UNUSED
@export var BASE_SPEED: = 150.0
@export var BASE_MAX_HEALTH: = 100.0
@export var BASE_DASH_SPEED := 4.0
@export var BASE_DASH_COOLDOWN := 1.5
@export var BASE_MAX_SHIELD := 100.0
@export var BASE_SHIELD_DELAY := 1.5
@export var BASE_SHIELD_REGEN := 15.0
@export var BASE_HEAL_BONUS := 0.0

var max_health: float = GAME.player_base_stats["BASE_HEALTH"]
var heal_bonus: float = GAME.player_base_stats["BASE_HEALING_BONUS"]
var max_shield: float = GAME.player_base_stats["BASE_SHIELD"]
var shield_regen: float = GAME.player_base_stats["BASE_SHIELD_REGEN"]
var shield_delay: float = GAME.player_base_stats["BASE_SHIELD_DELAY"]
var speed : float = GAME.player_base_stats["BASE_SPEED"]
var dash_speed: float = GAME.player_base_stats["BASE_DASH_SPEED"]
var dash_cooldown: float = GAME.player_base_stats["BASE_DASH_DELAY"]

var shield: float = GAME.player_base_stats["BASE_SHIELD"]
var health : float = GAME.player_base_stats["BASE_HEALTH"]

###BASE VALUES WEAPON OUTDATED - UNUSED
@export var BASE_DAMAGE := 10
@export var BASE_DAMAGE_MULTIPLIER := 1
@export var BASE_CRITICAL_RATE := 0.2
@export var BASE_CRITICAL_MULTIPLIER := 1
@export var BASE_RELOAD_SPEED := 1
@export var BASE_MAGAZINE_SIZE := 20
@export var BASE_SHOOTING_SPEED := 1
@export var BASE_PUNCTURE := 0

@export var dash_duration := 0.15

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
signal weapon_stats_changed()

var upgrade_resources : Array = []
var weapon_upgrades : Array[WeaponModInstance] = []
var upgrades : Array[PlayerModInstance] = []
var energy_max : int = 20
var weapon_energy_max : int = 20
var player_stats: Dictionary
var weapon_stats: Dictionary
var used_energy := 0
var weapon_used_energy := 0
var used_energy_temp := 0
var weapon_used_energy_temp := 0
var player_stats_temp: Dictionary
var weapon_stats_temp: Dictionary
var processors : int = 0
var energy: Dictionary


func _ready() -> void:
	player_stats = {
		"health": {"name": "Health", "value": max_health, "positive": true},
		"healing_bonus": {"name": "Heal bonus", "value": heal_bonus, "positive": true}, 
		"shield": {"name": "Shield", "value": max_shield, "positive": true}, 
		"shield_regen": {"name": "Shield regen", "value": shield_regen, "positive": true}, 
		"shield_delay": {"name": "Shield delay", "value": shield_delay, "positive": false},
		"speed": {"name": "Speed", "value": speed, "positive": true}, 
		"dash_delay": {"name": "Dash delay", "value": dash_cooldown, "positive": false}, 
		"dash_speed": {"name": "Dash speed", "value": dash_speed, "positive": true},
	}
	weapon_stats = {
		"damage": {"name": "Damage", "value": GAME.weapon_base_stats["BASE_DAMAGE"], "positive": true},
		"damage_multiplier": {"name": "DMG mult", "value": GAME.weapon_base_stats["BASE_DAMAGE_MULTIPLIER"], "positive": true},
		"critical_rate": {"name": "CRIT rate", "value": GAME.weapon_base_stats["BASE_CRITICAL_RATE"], "positive": true}, 
		"critical_multiplier": {"name": "CRIT mult", "value": GAME.weapon_base_stats["BASE_CRITICAL_MULTIPLIER"], "positive": true}, 
		"reload_speed": {"name": "REL speed", "value": GAME.weapon_base_stats["BASE_RELOAD_SPEED"], "positive": true}, 
		"magazine_size": {"name": "Capacity", "value": GAME.weapon_base_stats["BASE_MAGAZINE_SIZE"], "positive": true},
		"shooting_speed": {"name": "SH speed", "value": GAME.weapon_base_stats["BASE_SHOOTING_SPEED"], "positive": true}, 
		"puncture": {"name": "Puncture", "value": GAME.weapon_base_stats["BASE_PUNCTURE"], "positive": true}, 
	}
	energy = {
		"player_energy_max": energy_max,
		"player_energy_used": used_energy,
		"player_energy_used_temp": used_energy_temp,
		"weapon_energy_max": weapon_energy_max,
		"weapon_energy_used": weapon_used_energy,
		"weapon_energy_used_temp": weapon_used_energy_temp,
	}
	for n in GAME.player_upgrades_set:
		upgrade_resources.append(n.name)
		var u = PlayerModInstance.new()
		u.data = n
		upgrades.append(u)
	for n in GAME.weapon_upgrades_set:
		upgrade_resources.append(n.name)
		var u = WeaponModInstance.new()
		u.data = n
		weapon_upgrades.append(u)
	GAME.register_player(self)


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
	cooldown_timer = 1/dash_cooldown
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
		var new_zoom = camera_2d.zoom - Vector2(0.1, 0.1)
		camera_2d.zoom = Vector2(max(new_zoom.x, 0.1), max(new_zoom.y, 0.1))
	if Input.is_action_just_pressed("scroll_up"):
		camera_2d.zoom += Vector2(0.1, 0.1)


func take_damage(damage : float):
	if is_dashing:
		return
	last_damage = 0
	shield -= damage
	if shield < 0:
		health +=  shield
		shield = 0
		
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

func level_completed():
	reparent(get_tree().root)
	GAME.GAME_LEVEL += 1
	
	get_tree().change_scene_to_file("uid://453t4ja41tb4")

func _physics_process(_delta: float) -> void:
	if not is_inside_tree():
		return
	if(Input.is_action_just_pressed("next_level")):
		level_completed()
	if(Input.is_action_just_pressed("restart")):
		
		GAME.GAME_LEVEL = -1
		get_tree().change_scene_to_file("uid://piu0jen1j5xh")
		
		return
	if(Input.is_action_just_pressed("inventory")):
		if upgrade.visible:
			hide_upgrade()
		else:
			show_upgrade()
	if upgrade.visible:
		camera_body.linear_velocity = -camera_body.position*5 #Camera stops when inventory is active
		return
	# gets movement input
	dash_progress_bar.value = (1/dash_cooldown-cooldown_timer)/(1/dash_cooldown)*dash_progress_bar.max_value
	var horizontal := Input.get_axis("go_left","go_right")
	var vertical := Input.get_axis("go_up","go_down")
	
	if(Input.is_action_pressed("attack")):
		current_weapon._try_use()
	
	last_damage = move_toward(last_damage, max(shield_delay,0) , _delta) # Last damage timer
	cooldown_timer = move_toward(cooldown_timer, 0, _delta) # Dash timer
	
	if last_damage == max(shield_delay,0): #Shield regeneration
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
	if upgrade_script.type == "weapon":
		recalculate_weapon_stats()
	else:
		recalculate_player_stats()


func recalculate_player_stats():
	var c_max_health = GAME.player_base_stats["BASE_HEALTH"]
	var c_heal_bonus = GAME.player_base_stats["BASE_HEALING_BONUS"]
	var c_shield =  GAME.player_base_stats["BASE_SHIELD"]
	var c_shield_delay = GAME.player_base_stats["BASE_SHIELD_DELAY"]
	var c_shield_regen = GAME.player_base_stats["BASE_SHIELD_REGEN"]
	var c_speed = GAME.player_base_stats["BASE_SPEED"]
	var c_dash_cooldown = GAME.player_base_stats["BASE_DASH_DELAY"]
	var c_dash_speed = GAME.player_base_stats["BASE_DASH_SPEED"]
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
	energy["player_energy_used_temp"] = c_used_energy
	upgrade_script.change_new_labels(player_stats_temp, player_stats, energy_max, c_used_energy, used_energy)
	

func apply_player_changes(): #Applying changes
	max_health = GAME.player_base_stats["BASE_HEALTH"]
	heal_bonus = GAME.player_base_stats["BASE_HEALING_BONUS"]
	max_shield = GAME.player_base_stats["BASE_SHIELD"]
	shield_delay = GAME.player_base_stats["BASE_SHIELD_DELAY"]
	shield_regen = GAME.player_base_stats["BASE_SHIELD_REGEN"]
	speed = GAME.player_base_stats["BASE_SPEED"]
	dash_cooldown = GAME.player_base_stats["BASE_DASH_DELAY"]
	dash_speed = GAME.player_base_stats["BASE_DASH_SPEED"]
	used_energy = 0
	
	for u in upgrades:
		if !u.enabled: continue
		used_energy += u.data.energy + u.level 
		max_health += u.data.health + u.level * u.data.health_change
		heal_bonus += u.data.healing_bonus + u.level * u.data.healing_bonus_change
		max_shield += u.data.shield + u.level * u.data.shield_change
		shield_delay += u.data.shield_delay + u.level * u.data.shield_delay_change
		shield_regen += u.data.shield_recharge + u.level * u.data.shield_recharge_change
		speed += u.data.speed + u.level * u.data.speed_change
		dash_cooldown += u.data.dash_delay + u.level * u.data.dash_delay_change
		dash_speed += u.data.dash_speed + u.level * u.data.dash_speed_change
	
	energy["player_energy_used"] = used_energy
	player_stats["health"]["value"] = max_health
	player_stats["healing_bonus"]["value"] = heal_bonus
	player_stats["shield"]["value"] = max_shield
	player_stats["shield_regen"]["value"] = shield_regen
	player_stats["shield_delay"]["value"] = shield_delay
	player_stats["speed"]["value"] = speed
	player_stats["dash_delay"]["value"] = dash_cooldown
	player_stats["dash_speed"]["value"] = dash_speed
	
	health_change.emit(health)
	shield_change.emit(shield)


func recalculate_weapon_stats():
	var temp_damage = GAME.weapon_base_stats["BASE_DAMAGE"]
	var temp_damage_multiplier = GAME.weapon_base_stats["BASE_DAMAGE_MULTIPLIER"]
	var temp_critical_rate = GAME.weapon_base_stats["BASE_CRITICAL_RATE"]
	var temp_critical_multiplier = GAME.weapon_base_stats["BASE_CRITICAL_MULTIPLIER"]
	var temp_reload_speed = GAME.weapon_base_stats["BASE_RELOAD_SPEED"]
	var temp_magazine_size = GAME.weapon_base_stats["BASE_MAGAZINE_SIZE"]
	var temp_shooting_speed = GAME.weapon_base_stats["BASE_SHOOTING_SPEED"]
	var temp_puncture = GAME.weapon_base_stats["BASE_PUNCTURE"]
	var temp_weapon_used_energy = 0
	
	for u in upgrade_grid.get_children(): #Upgrade_box
		if !u.changed_enabled: continue
		temp_weapon_used_energy += u.upgrade.energy + u.changed_lvl
		temp_damage += u.upgrade.damage + u.changed_lvl * u.upgrade.damage_change
		temp_damage_multiplier += u.upgrade.damage_multiplier + u.changed_lvl * u.upgrade.damage_multiplier_change
		temp_critical_rate += u.upgrade.critical_rate + u.changed_lvl * u.upgrade.critical_rate_change
		temp_critical_multiplier += u.upgrade.critical_multiplier + u.changed_lvl * u.upgrade.critical_multiplier_change
		temp_reload_speed += u.upgrade.reload_speed + u.changed_lvl * u.upgrade.reload_speed_change
		temp_magazine_size += u.upgrade.magazine_size + u.changed_lvl * u.upgrade.magazine_size_change
		temp_shooting_speed += u.upgrade.shooting_speed + u.changed_lvl * u.upgrade.shooting_speed_change
		temp_puncture += u.upgrade.puncture + u.changed_lvl * u.upgrade.puncture_change
	
	weapon_stats_temp = {
		"damage": {"name": "Damage", "value": temp_damage},
		"damage_multiplier": {"name": "DMG mult", "value": temp_damage_multiplier},
		"critical_rate": {"name": "CRIT rate", "value": temp_critical_rate}, 
		"critical_multiplier": {"name": "CRIT mult", "value": temp_critical_multiplier}, 
		"reload_speed": {"name": "REL speed", "value": temp_reload_speed}, 
		"magazine_size": {"name": "Capacity", "value": temp_magazine_size},
		"shooting_speed": {"name": "SH speed", "value": temp_shooting_speed}, 
		"puncture": {"name": "Puncture", "value": temp_puncture}, 
	}
	weapon_used_energy_temp = temp_weapon_used_energy
	energy["weapon_energy_used_temp"] = temp_weapon_used_energy
	upgrade_script.change_new_labels(weapon_stats_temp, weapon_stats, weapon_energy_max, weapon_used_energy_temp, weapon_used_energy)


func apply_weapon_changes(make_bullets : bool = true):
	var damage = GAME.weapon_base_stats["BASE_DAMAGE"]
	var damage_multiplier = GAME.weapon_base_stats["BASE_DAMAGE_MULTIPLIER"]
	var critical_rate = GAME.weapon_base_stats["BASE_CRITICAL_RATE"]
	var critical_multiplier = GAME.weapon_base_stats["BASE_CRITICAL_MULTIPLIER"]
	var reload_speed = GAME.weapon_base_stats["BASE_RELOAD_SPEED"]
	var magazine_size = GAME.weapon_base_stats["BASE_MAGAZINE_SIZE"]
	var shooting_speed = GAME.weapon_base_stats["BASE_SHOOTING_SPEED"]
	var puncture = GAME.weapon_base_stats["BASE_PUNCTURE"]
	weapon_used_energy = 0
	
	
	for u in weapon_upgrades:
		if !u.enabled: continue
		weapon_used_energy += u.data.energy + u.level
		damage += u.data.damage + u.level * u.data.damage_change
		damage_multiplier += u.data.damage_multiplier + u.level * u.data.damage_multiplier_change
		critical_rate += u.data.critical_rate + u.level * u.data.critical_rate_change
		critical_multiplier += u.data.critical_multiplier + u.level * u.data.critical_multiplier_change
		reload_speed += u.data.reload_speed + u.level * u.data.reload_speed_change
		magazine_size += u.data.magazine_size + u.level * u.data.magazine_size_change
		shooting_speed += u.data.shooting_speed + u.level * u.data.shooting_speed_change
		puncture += u.data.puncture + u.level * u.data.puncture_change
	
	energy["weapon_energy_used"] = weapon_used_energy
	weapon_stats["damage"]["value"] = damage
	weapon_stats["damage_multiplier"]["value"] = damage_multiplier
	weapon_stats["critical_rate"]["value"] = critical_rate
	weapon_stats["critical_multiplier"]["value"] = critical_multiplier
	weapon_stats["reload_speed"]["value"] = reload_speed
	weapon_stats["magazine_size"]["value"] = magazine_size
	weapon_stats["shooting_speed"]["value"] = shooting_speed
	weapon_stats["puncture"]["value"] = puncture

	weapon_stats_changed.emit()
	if make_bullets: GAME.current_weapon.add_bullets()


func death() -> void:
	GAME.GAME_LEVEL = -1
	get_tree().change_scene_to_file("uid://piu0jen1j5xh")
