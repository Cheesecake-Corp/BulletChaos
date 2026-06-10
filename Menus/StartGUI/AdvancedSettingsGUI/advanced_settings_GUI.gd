extends Control

@onready var player_base_stats: Control = $ScrollContainer/Control/Player_base_stats
@onready var player_upgrades: Control = $ScrollContainer/Control/Player_upgrades
@onready var weapon_base_stats: Control = $ScrollContainer/Control/Weapon_base_stats
@onready var weapon_upgrades: Control = $ScrollContainer/Control/Weapon_upgrades
@onready var starting_currency: Control = $ScrollContainer/Control/Starting_currency
@onready var currency_multiplier: Control = $ScrollContainer/Control/Currency_multiplier
@onready var upgrade_chance: Control = $ScrollContainer/Control/Upgrade_chance
@onready var heal_chance: Control = $ScrollContainer/Control/Heal_chance
@onready var enemy_damage_multiplier: Control = $ScrollContainer/Control/Enemy_damage_multiplier
@onready var enemy_health_multiplier: Control = $ScrollContainer/Control/Enemy_health_multiplier

@onready var reset_label: Label = $Reset_label
@onready var apply_label: Label = $Apply_label
@onready var back_label: Label = $Back_label


var starting_currency_reset : String
var currency_multiplier_reset : String
var upgrade_chance_reset : String
var heal_chance_reset : String
var enemy_damage_multiplier_reset : String
var enemy_health_multiplier_reset : String

var player_base_stats_array : Array
var player_upgrades_array : Array
var weapon_base_stats_array : Array
var weapon_upgrades_array : Array
var starting_currency_value : int
var currency_multiplier_value : float
var upgrade_chance_value : float
var heal_chance_value : float
var enemy_damage_multiplier_value : float
var enemy_health_multiplier_value : float

var in_effect = false

func _ready() -> void:
	starting_currency_reset = starting_currency.get_child(1).text
	currency_multiplier_reset = currency_multiplier.get_child(1).text
	upgrade_chance_reset = upgrade_chance.get_child(1).text
	heal_chance_reset = heal_chance.get_child(1).text
	enemy_damage_multiplier_reset = enemy_damage_multiplier.get_child(1).text
	enemy_health_multiplier_reset = enemy_health_multiplier.get_child(1).text


func reset_values():
	player_base_stats.reset_values()
	player_upgrades.reset_values()
	weapon_base_stats.reset_values()
	weapon_upgrades.reset_values()
	starting_currency.get_child(1).text = starting_currency_reset
	currency_multiplier.get_child(1).text = currency_multiplier_reset
	upgrade_chance.get_child(1).text = upgrade_chance_reset
	heal_chance.get_child(1).text = heal_chance_reset
	enemy_damage_multiplier.get_child(1).text = enemy_damage_multiplier_reset
	enemy_health_multiplier.get_child(1).text = enemy_health_multiplier_reset


func hide_buttons_and_lines(vis : bool):
	player_base_stats.button.visible = !vis
	player_upgrades.button.visible = !vis
	weapon_base_stats.button.visible = !vis
	weapon_upgrades.button.visible = !vis
	starting_currency.get_child(1).visible = !vis
	currency_multiplier.get_child(1).visible = !vis
	upgrade_chance.get_child(1).visible = !vis
	heal_chance.get_child(1).visible = !vis
	enemy_damage_multiplier.get_child(1).visible = !vis
	enemy_health_multiplier.get_child(1).visible = !vis


func apply(): #Loads all values into this node
	for n in player_base_stats.player_stats_set:
		player_base_stats_array.append(n)
	for n in player_upgrades.pl_upgrades:
		player_upgrades_array.append(n)
	for n in weapon_base_stats.weapon_stats_set:
		weapon_base_stats_array.append(n)
	for n in weapon_upgrades.weap_upgrades:
		weapon_upgrades_array.append(n)
	starting_currency_value = int(starting_currency.get_child(1).text)
	currency_multiplier_value = int(currency_multiplier.get_child(1).text)
	upgrade_chance_value = float(upgrade_chance.get_child(1).text)
	heal_chance_value = float(heal_chance.get_child(1).text)
	enemy_damage_multiplier_value = float(enemy_damage_multiplier.get_child(1).text)
	enemy_health_multiplier_value = float(enemy_health_multiplier.get_child(1).text)


func _on_reset_pressed() -> void:
	in_effect = false
	reset_values()


func _on_apply_pressed() -> void:
	in_effect = true
	visible = false


func _on_back_pressed() -> void:
	visible = false


func _on_reset_mouse_entered() -> void:
	reset_label.visible = true


func _on_reset_mouse_exited() -> void:
	reset_label.visible = false


func _on_apply_mouse_entered() -> void:
	apply_label.visible = true


func _on_apply_mouse_exited() -> void:
	apply_label.visible = false


func _on_back_mouse_entered() -> void:
	back_label.visible = true


func _on_back_mouse_exited() -> void:
	back_label.visible = false
