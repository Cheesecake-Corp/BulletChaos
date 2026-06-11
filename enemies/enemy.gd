extends RigidBody2D
class_name Enemy

@export var SPEED : float = 150
@export var MAX_HEALTH := 100.0
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var upgrade_resources = preload("res://Upgrades/ALLUPGRADES.tres")
var health : float
var alive := true
var movement := true
var room_manager : EnemySpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH * GAME.enemies_stats_set["health_multiplier"]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func take_damage(damage : float):
	health -= damage
	
	movement = false
	if alive == true and health < 0:
		death()

func death():
	linear_velocity = Vector2.ZERO
	movement = false
	alive = false
	room_manager.enemy_dead += 1
	
	var rand = GAME.RANDOM_LOOT.randf()
	
	if rand > GAME.drop_chance_set["heal"]:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		room_manager.room.call_deferred("add_child", canister)
		call_deferred("set_canister_pos", canister)
		
	elif rand > 1-GAME.drop_chance_set["heal"]-GAME.drop_chance_set["upgrade"]:
		var upgrade = upgrade_resources.upgrades[GAME.RANDOM_LOOT.randi_range(0,upgrade_resources.upgrades.size()-1)]
		var upgrade_item : Node2D
		if not upgrade.name in GAME.player.upgrade_resources:
			upgrade_item = load("res://Upgrades/Upgrade_item.tscn").instantiate() #Creates instance of upgrade_item
			upgrade_item.upgrade = upgrade #Upgrade item is on ground it is a scene
		
			
		else:
			upgrade_item = load("res://Upgrades/processor_item.tscn").instantiate() #Creates instance of upgrade_item
			
			upgrade_item.amount =  GAME.RANDOM_LOOT.randi_range(10,115) * GAME.currency_set["multiplier"]#Upgrade item is on ground it is a scene
		
		room_manager.room.call_deferred("add_child", upgrade_item)
		call_deferred("set_canister_pos", upgrade_item)
		



func set_canister_pos(canister : Node2D):
	canister.global_position = global_position
		
