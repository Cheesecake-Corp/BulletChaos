extends Button
@onready var control: Control = $Control
@onready var name_: Label = $Name
@onready var energy: Label = $Energy
@onready var lvl: Label = $LVL
@onready var description: Label = $Control/Description
var instance : ModInstance
var upgrade: Upgrade


var changed_enabled : bool = TYPE_NIL
var changed_lvl : int = TYPE_NIL


func _ready() -> void:
	if upgrade:
		name_.text = upgrade.name
		energy.text = str(upgrade.energy + instance.level)
		lvl.text = str(instance.level)
		description.text = use_placeholders(upgrade.description)
		set_pressed_no_signal(instance.enabled)
		changed_lvl = instance.level


func use_placeholders(t : String) -> String:
	if upgrade is PlayerUpgrade:
		return t.replace("{health}" ,str(upgrade.health + instance.level * upgrade.health_change)) \
		.replace("{heal_bonus}", str(upgrade.healing_bonus + instance.level * upgrade.healing_bonus_change)) \
		.replace("{shield}", str(upgrade.shield + instance.level * upgrade.shield_change)) \
		.replace("{shield_delay}", str(upgrade.shield_delay + instance.level * upgrade.shield_delay_change)) \
		.replace("{shield_recharge}", str(upgrade.shield_recharge + instance.level * upgrade.shield_recharge_change)) \
		.replace("{speed}", str(upgrade.speed + instance.level * upgrade.speed_change)) \
		.replace("{dash_delay}", str(upgrade.dash_delay + instance.level * upgrade.dash_delay_change)) \
		.replace("{dash_speed}", str(upgrade.dash_speed + instance.level * upgrade.dash_speed_change))
	else:
		return t \
		.replace("{reload_speed}", str(upgrade.reload_speed + instance.level * upgrade.reload_speed_change)) \
		.replace("{damage}", str(upgrade.damage + instance.level * upgrade.damage_change)) \
		.replace("{damage_mult}", str(upgrade.damage_multiplier + instance.level * upgrade.damage_multiplier_change)) \
		.replace("{crit_rate}", str(upgrade.critical_rate + instance.level * upgrade.critical_rate_change)) \
		.replace("{crit_mult}", str(upgrade.critical_multiplier + instance.level * upgrade.critical_multiplier_change)) \
		.replace("{mag}", str(upgrade.magazine_size + instance.level * upgrade.magazine_size_change)) \
		.replace("{shoot_speed}", str(upgrade.shooting_speed + instance.level * upgrade.shooting_speed_change)) \
		.replace("{puncture}", str(upgrade.puncture + instance.level * upgrade.puncture_change))

func generate_stats() -> Array[Dictionary]:
	if upgrade is PlayerUpgrade:
		var stats : Array[Dictionary] = []
		if upgrade.health != 0 or upgrade.health_change != 0:
			stats.append(
				{
					"name" : "Health",
					"value": upgrade.health + instance.level * upgrade.health_change,
					"change": upgrade.health_change
				}
			)
		if upgrade.healing_bonus != 0 or upgrade.healing_bonus_change != 0:
			stats.append(
				{
					"name" : "Heal bonus",
					"value": upgrade.healing_bonus + instance.level * upgrade.healing_bonus_change,
					"change": upgrade.healing_bonus_change
				}
			)
		if upgrade.shield != 0 or upgrade.shield_change != 0:
			stats.append(
				{
					"name" : "Shield",
					"value": upgrade.shield + instance.level * upgrade.shield_change,
					"change": upgrade.shield_change
				}
			)
		if upgrade.shield_delay != 0 or upgrade.shield_delay_change != 0:
			stats.append(
				{
					"name" : "Shield delay",
					"value": upgrade.shield_delay + instance.level * upgrade.shield_delay_change,
					"change": upgrade.shield_delay_change
				}
			)
		if upgrade.shield_recharge != 0 or upgrade.shield_recharge_change != 0:
			stats.append(
				{
					"name" : "Shield recharge",
					"value": upgrade.shield_recharge + instance.level * upgrade.shield_recharge_change,
					"change": upgrade.shield_recharge_change
				}
			)
		if upgrade.speed != 0 or upgrade.speed_change != 0:
			stats.append(
				{
					"name" : "Speed",
					"value": upgrade.speed + instance.level * upgrade.speed_change,
					"change": upgrade.speed_change
				}
			)
		if upgrade.dash_delay != 0 or upgrade.dash_delay_change != 0:
			stats.append(
				{
					"name" : "Dash delay",
					"value": upgrade.dash_delay + instance.level * upgrade.dash_delay_change,
					"change": upgrade.dash_delay_change
				}
			)
		if upgrade.dash_speed != 0 or upgrade.dash_speed_change != 0:
			stats.append(
				{
					"name" : "Dash speed",
					"value": upgrade.dash_speed + instance.level * upgrade.dash_speed_change,
					"change": upgrade.dash_speed_change
				}
			)
		
		return stats
	else:
			
		var stats : Array[Dictionary] = []

		if upgrade.reload_speed != 0 or upgrade.reload_speed_change != 0:
			stats.append({
				"name": "Reload speed",
				"value": upgrade.reload_speed + instance.level * upgrade.reload_speed_change,
				"change": upgrade.reload_speed_change
			})

		if upgrade.damage != 0 or upgrade.damage_change != 0:
			stats.append({
				"name": "Damage",
				"value": upgrade.damage + instance.level * upgrade.damage_change,
				"change": upgrade.damage_change
			})

		if upgrade.damage_multiplier != 0 or upgrade.damage_multiplier_change != 0:
			stats.append({
				"name": "Damage multiplier",
				"value": upgrade.damage_multiplier + instance.level * upgrade.damage_multiplier_change,
				"change": upgrade.damage_multiplier_change
			})

		if upgrade.critical_rate != 0 or upgrade.critical_rate_change != 0:
			stats.append({
				"name": "Crit rate",
				"value": upgrade.critical_rate + instance.level * upgrade.critical_rate_change,
				"change": upgrade.critical_rate_change
			})

		if upgrade.critical_multiplier != 0 or upgrade.critical_multiplier_change != 0:
			stats.append({
				"name": "Crit multiplier",
				"value": upgrade.critical_multiplier + instance.level * upgrade.critical_multiplier_change,
				"change": upgrade.critical_multiplier_change
			})

		if upgrade.magazine_size != 0 or upgrade.magazine_size_change != 0:
			stats.append({
				"name": "Magazine size",
				"value": upgrade.magazine_size + instance.level * upgrade.magazine_size_change,
				"change": upgrade.magazine_size_change
			})

		if upgrade.shooting_speed != 0 or upgrade.shooting_speed_change != 0:
			stats.append({
				"name": "Shooting speed",
				"value": upgrade.shooting_speed + instance.level * upgrade.shooting_speed_change,
				"change": upgrade.shooting_speed_change
			})

		if upgrade.puncture != 0 or upgrade.puncture_change != 0:
			stats.append({
				"name": "Puncture",
				"value": upgrade.puncture + instance.level * upgrade.puncture_change,
				"change": upgrade.puncture_change
			})
		return stats

func _process(_delta: float) -> void:
	if is_hovered() and GAME.upgrade_menu.upgrade_lvl.visible == false:
		z_index = 1
		control.visible = true
		if Input.is_action_just_pressed("upgrade_upgrade"):
			GAME.upgrade_menu.upgrade_lvl.open_upgrades(
				upgrade.name,upgrade.energy + instance.level, instance.level, generate_stats(), instance
			)
	else:
		control.visible = false
		z_index = 0

func apply():
	instance.level = changed_lvl
	instance.enabled = changed_enabled

func reset_changes():
	changed_lvl = instance.level
	changed_enabled = instance.enabled
	if changed_enabled:
		set_pressed_no_signal(true)
	else:
		set_pressed_no_signal(false)

func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		changed_enabled = true
		GAME.player.recalculate_stats()
	else:
		changed_enabled = false
		GAME.player.recalculate_stats()
