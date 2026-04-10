extends Node


@export var SEED : String = "Chocolate"
var RANDOM_LOOT : RandomNumberGenerator
var RANDOM_GENERATION : RandomNumberGenerator
var player : Player = null
@export var current_weapon : Weapon 
var boss_room_pos : Vector2
var outline: PackedVector2Array

signal weapon_changed

func register_player(p):
	player = p
	var weap = load("res://Weapons/BasicGuns/revolver.tscn").instantiate()
	change_weapon(weap)

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
