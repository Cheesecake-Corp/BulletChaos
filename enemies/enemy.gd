extends RigidBody2D
class_name Enemy

@export var SPEED : float = 150
@export var MAX_HEALTH := 100.0
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var health : float
var alive := true
var movement := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	

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
	get_parent().enemy_dead += 1
	if GAME.RANDOM_LOOT.randf() > 0.5:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		get_parent().room.call_deferred("add_child", canister)
		call_deferred("set_canister_pos", canister)
		
	if GAME.RANDOM_LOOT.randf() > 0.5:
		var dir := DirAccess.open("res://Upgrades/PlayerUpgrades")
		if dir == null: printerr("Could not open folder"); return
		dir.list_dir_begin()
		var files : Array = dir.get_files()
		var file = files[GAME.RANDOM_LOOT.randi_range(0,files.size()-1)] #Chooses file
		var upgrade := load(dir.get_current_dir() + "/" + file) #Loaded resource
		var upgrade_item : Node2D = load("res://Upgrades/Upgrade_item.tscn").instantiate() #Creates instance of upgrade_item
		upgrade_item.upgrade = upgrade #Upgrade item is on ground it is a scene
		get_parent().room.call_deferred("add_child", upgrade_item)
		call_deferred("set_canister_pos", upgrade_item)
		



func set_canister_pos(canister : Node2D):
	canister.global_position = global_position
		
