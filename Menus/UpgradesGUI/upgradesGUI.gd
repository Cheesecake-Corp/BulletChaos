extends NinePatchRect
class_name Inventory

@export var type: String = "player"
@onready var stat_table: NinePatchRect = $StatTable
@onready var energy_table: NinePatchRect = $EnergyTable
@onready var grid_container: GridContainer = $UpgradesScroll/MarginContainer/GridContainer
@onready var filter: NinePatchRect = $Filter
@onready var sort_1: NinePatchRect = $Sort1
const UPGRADE = preload("uid://b33xc4skqictj")
var energy_used : float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GAME.player_registered.connect(inventory_start.bind())


func inventory_start() -> void:
	if type == "player":
		inv_load(GAME.player.player_stats, GAME.player.energy_max)
	else:
		pass #TODO Add weapon inventory


func inv_load(dict : Dictionary, energy_max: int) -> void:
	var energy_number = energy_table.get_child(1)
	energy_number.text = str(int(energy_max - energy_used)) + "/" + str(energy_max)
	var stat_names = stat_table.get_child(0)
	var stat_names_labels = stat_names.get_children()
	var stat_values = stat_table.get_child(1)
	var stat_values_labels = stat_values.get_children()
	var m = 0
	for n in dict:
		stat_names_labels[m].text = dict[n]["name"]
		stat_values_labels[m].text = str(dict[n]["value"])
		m += 1
	for a in grid_container.get_children(): #Removes all nodes under GridContainer
		a.queue_free()
	for n in GAME.player.upgrades: #Adds upgrades from Array in player
		var upgrade_box = UPGRADE.instantiate()
		upgrade_box.upgrade = n.data
		upgrade_box.level = n.level
		grid_container.call_deferred("add_child",upgrade_box)
