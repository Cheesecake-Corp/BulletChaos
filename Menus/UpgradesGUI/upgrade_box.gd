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

func _process(_delta: float) -> void:
	if is_hovered():
		z_index = 1
		control.visible = true
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
