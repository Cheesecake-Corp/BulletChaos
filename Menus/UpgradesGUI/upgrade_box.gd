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
		energy.text = str(upgrade.energy)
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
	else: return t

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
func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		if GAME.player.temp_energy + instance.level + upgrade.energy > GAME.player.energy_max:
			set_pressed_no_signal(false)
			return
		
		changed_enabled = true
		GAME.player.recalculate()
	else:
		changed_enabled = false
		GAME.player.recalculate()
