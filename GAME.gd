extends Node


@export var SEED : String = "Chocolate"
var RANDOM_LOOT : RandomNumberGenerator
var RANDOM_GENERATION : RandomNumberGenerator
var player : Player = null
@export var current_weapon : PackedScene = load("res://Weapons/BasicGuns/revolver.tscn")

func register_player(p):
	player = p

func _ready() -> void:
	RANDOM_GENERATION = RandomNumberGenerator.new()
	RANDOM_LOOT = RandomNumberGenerator.new()
	

func change_seed(_seed):
	SEED = str(_seed)
	RANDOM_GENERATION.seed = hash(SEED + "_GEN")
	RANDOM_LOOT.seed = hash(SEED + "_LOOT")

func get_seed() -> String:
	return SEED
