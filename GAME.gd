extends Node


@export var SEED : String
var RANDOM_LOOT : RandomNumberGenerator
var RANDOM_GENERATION : RandomNumberGenerator

func _ready() -> void:
	RANDOM_GENERATION = RandomNumberGenerator.new()
	RANDOM_LOOT = RandomNumberGenerator.new()

func change_seed(_seed):
	SEED = str(_seed)
	RANDOM_GENERATION.seed = hash(SEED + "_GEN")
	RANDOM_LOOT.seed = hash(SEED + "_LOOT")

func get_seed() -> String:
	return SEED
