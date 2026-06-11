extends Node


@export var SEED : String = "Chocolate"
var RANDOM_LOOT : RandomNumberGenerator
var RANDOM_GENERATION : RandomNumberGenerator
var player : Player = null
@export var current_weapon : Weapon 
var boss_room_pos : Vector2
var outline: PackedVector2Array
var difficulty := 1
var weapon_menu := "Revolver"
var upgrade_menu : Inventory
var starter_money = 0
var entities_node : Node2D

###VALUES FROM NEW_GAME_GUI
var player_base_stats : Dictionary = {} # WORKS
var weapon_base_stats : Dictionary = {} # WORKS
var player_upgrades_set : Array # WORKS
var weapon_upgrades_set : Array # WORKS
var currency_set : Dictionary # {"amount" : 0, "multiplier" : 1}
var drop_chance_set : Dictionary # {"upgrade": 0.5, "heal": 0.5}
var enemies_stats_set : Dictionary # {"damage_multiplier", "health_multiplier"}

signal weapon_changed
signal player_registered

func register_player(p):
	player = p
	player.processors = starter_money
	var weap : Node2D
	if weapon_menu == "Laser":
		weap = load("res://Weapons/Guns/LaserGun/LaserGun.tscn").instantiate()
	else:
		weap = load("res://Weapons/Guns/BasicGuns/revolver.tscn").instantiate()
	change_weapon(weap)
	player.processors = currency_set["amount"]
	player_registered.emit()


func _ready() -> void:
	RANDOM_GENERATION = RandomNumberGenerator.new()
	RANDOM_LOOT = RandomNumberGenerator.new()
	
	
func change_seed(_seed):
	SEED = str(_seed)
	RANDOM_GENERATION.seed = hash(SEED + "_GEN")
	RANDOM_LOOT.seed = hash(SEED + "_LOOT")

func get_seed() -> String:
	return SEED

func change_weapon(weapon : Weapon):
	if current_weapon != null:
		current_weapon.queue_free()
	
	current_weapon = weapon
	player.current_weapon = weapon
	player.add_child(current_weapon)
	weapon_changed.emit()
