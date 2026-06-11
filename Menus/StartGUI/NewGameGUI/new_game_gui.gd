extends Control

@onready var game_mode: Control = $Game_mode
@onready var difficulty: Control = $Difficulty
@onready var commands: Control = $Commands
@onready var advanced: Control = $Advanced
@onready var advanced_settings: Control = $Advanced_settings

var player_stats_set : Dictionary = {}

var game_mode_value : String
var difficulty_value : String
var commands_value : String
var seed_value : String


func _ready() -> void:
	advanced_settings.visible = false


func hide_button(button_name: String, vis: bool) -> void:
	if button_name == "Seed":
		var str4 = button_name[0].to_upper() + button_name.substr(1) + "/Button"
		var str5 = button_name[0].to_upper() + button_name.substr(1) + "/TextEdit"
		if vis == true:
			get_node(str4).visible = false
			get_node(str5).visible = false
			return
		else:
			get_node(str4).visible = true
			get_node(str5).visible = true
			return
	var str1 = button_name[0].to_upper() + button_name.substr(1) + "/Button"
	var str2 = button_name[0].to_upper() + button_name.substr(1) + "/VBoxContainer"
	var str3 = button_name[0].to_upper() + button_name.substr(1) + "/NinePatchRect"
	
	if vis == true:
		get_node(str1).visible = false
		get_node(str2).visible = false
		get_node(str3).visible = false
	else:
		get_node(str1).visible = true


func apply(): #collects all data in this node (advanced stay stored in advanced settings tree node)
	apply_basic()
	apply_advanced()


func apply_basic():
	match game_mode_value:
		"Survival": #Will be used for enabling story mode, starting cutscene
			pass
		"Endless": #Will be used for engless amount of levels, without ending
			pass
		"Immortal":
			GAME.player_base_stats = {
				"BASE_HEALTH": INF,
				"BASE_SHIELD": INF,
				"BASE_SHIELD_REGEN": INF,
				"BASE_DASH_DELAY": 0,
			}
	
	match difficulty_value:
		"Peaceful":
			GAME.enemies_stats_set = {
				"damage_multiplier": 0.1,
				"health_multiplier": 0.1,
			}
		"Easy":
			GAME.enemies_stats_set = {
				"damage_multiplier": 0.5,
				"health_multiplier": 0.5,
			}
		"Normal":
			GAME.enemies_stats_set = {
				"damage_multiplier": 1,
				"health_multiplier": 1,
			}
		"Hard":
			GAME.enemies_stats_set = {
				"damage_multiplier": 2,
				"health_multiplier": 2,
			}
		"Insane":
			GAME.enemies_stats_set = {
				"damage_multiplier": 4,
				"health_multiplier": 4,
			}
	
	match commands_value:
		"Enabled": #Will be used for enabling commands in game
			pass
		"Disabled": #Will be used for disabling commands in game - default state
			pass
	
	GAME.SEED = seed_value


func apply_advanced():
	advanced_settings.apply() # Necessary otherwise values are not loaded into Advanced_settings node resulting in empty arrays
	GAME.player_base_stats = {
		"BASE_HEALTH": advanced_settings.player_base_stats_array[0],
		"BASE_HEALING_BONUS": advanced_settings.player_base_stats_array[1],
		"BASE_SHIELD": advanced_settings.player_base_stats_array[2],
		"BASE_SHIELD_REGEN": advanced_settings.player_base_stats_array[3],
		"BASE_SHIELD_DELAY": advanced_settings.player_base_stats_array[4],
		"BASE_SPEED": advanced_settings.player_base_stats_array[5],
		"BASE_DASH_DELAY": advanced_settings.player_base_stats_array[6],
		"BASE_DASH_SPEED": advanced_settings.player_base_stats_array[7],
		}
	
	GAME.weapon_base_stats = {
		"BASE_DAMAGE": advanced_settings.weapon_base_stats_array[0],
		"BASE_DAMAGE_MULTIPLIER": advanced_settings.weapon_base_stats_array[1],
		"BASE_CRITICAL_RATE": advanced_settings.weapon_base_stats_array[2],
		"BASE_CRITICAL_MULTIPLIER": advanced_settings.weapon_base_stats_array[3],
		"BASE_RELOAD_SPEED": advanced_settings.weapon_base_stats_array[4],
		"BASE_MAGAZINE_SIZE": advanced_settings.weapon_base_stats_array[5],
		"BASE_SHOOTING_SPEED": advanced_settings.weapon_base_stats_array[6],
		"BASE_PUNCTURE": advanced_settings.weapon_base_stats_array[7],
		}
	
	for n in advanced_settings.player_upgrades_array:
		GAME.player_upgrades_set.append(n)
	for n in advanced_settings.weapon_upgrades_array:
		GAME.weapon_upgrades_set.append(n)
	
	GAME.currency_set = { #DONE
		"amount": advanced_settings.starting_currency_value,
		"multiplier": advanced_settings.currency_multiplier_value,
	}
	
	GAME.drop_chance_set = { # DONE
		"upgrade": advanced_settings.upgrade_chance_value,
		"heal": advanced_settings.heal_chance_value,
	}
	
	GAME.enemies_stats_set = {
		"damage_multiplier": advanced_settings.enemy_damage_multiplier_value,
		"health_multiplier": advanced_settings.enemy_health_multiplier_value,
	}
	
	if advanced_settings.in_effect == false:
		apply_basic()


func _on_start_game_pressed() -> void:
	apply()
	get_tree().change_scene_to_file("res://World/MainWorld.tscn")


func _on_button_pressed() -> void: #Button from advanced
	advanced_settings.visible = true
