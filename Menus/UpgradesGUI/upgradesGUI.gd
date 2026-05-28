extends NinePatchRect
class_name Inventory

@export var type: String = "player"
@onready var grid_container: GridContainer = $UpgradesScroll/MarginContainer/GridContainer
@onready var stat_names: VBoxContainer = $StatTable/StatNames
@onready var stat_values: VBoxContainer = $StatTable/StatValues
@onready var stat_new_values: VBoxContainer = $StatTable/StatNewValues
@onready var energy_val: Label = $EnergyTable/EnergyVal
@onready var energy_new_val: Label = $EnergyTable/EnergyNewVal
@onready var warning_energy: NinePatchRect = $WarningEnergy
@onready var warning_confirm: NinePatchRect = $WarningConfirm
@onready var warning_reset: NinePatchRect = $WarningReset

const UPGRADE = preload("uid://b33xc4skqictj") #Scene Upgrade_box

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GAME.player_registered.connect(inventory_start.bind())


func inventory_start() -> void:
	if type == "weapon":
		inv_load(GAME.player.weapon_stats, GAME.player.weapon_energy_max, GAME.player.weapon_used_energy)
	else:
		inv_load(GAME.player.player_stats, GAME.player.energy_max, GAME.player.used_energy)


func inv_load(dict : Dictionary, energy_max: int, used_energy: int) -> void:
	
	change_labels(dict, energy_max, used_energy)
	
	for a in grid_container.get_children(): #Removes all nodes under GridContainer
		a.queue_free()
	for n in GAME.player.upgrades: #Adds upgrades from Array in player
		var upgrade_box = UPGRADE.instantiate()
		upgrade_box.upgrade = n.data
		upgrade_box.instance = n
		grid_container.call_deferred("add_child",upgrade_box)


func change_labels(dict, energy_max, used_energy): #Changes all labels
	energy_val.text = str(int(energy_max - used_energy))
	energy_new_val.text = str(int(energy_max - used_energy)) + "/" + str(energy_max)
	energy_new_val.remove_theme_color_override("font_color")
	var stat_names_labels = stat_names.get_children()
	var stat_values_labels = stat_values.get_children()
	var stat_values_new_labels = stat_new_values.get_children()
	var m = 0
	for n in dict:
		stat_names_labels[m].text = dict[n]["name"]
		if dict[n]["value"] >= 100:
			stat_values_labels[m].text = str(int(dict[n]["value"]))
			stat_values_new_labels[m].text = str(int(dict[n]["value"]))
		else:
			stat_values_labels[m].text = str(dict[n]["value"])
			stat_values_new_labels[m].text = str(dict[n]["value"])
		stat_values_new_labels[m].remove_theme_color_override("font_color")
		m += 1


func change_new_labels(dict_temp, dict, energy_max, used_energy_temp, used_energy): #Changes labels displaying change
	energy_new_val.text = str(int(energy_max - used_energy_temp)) + "/" + str(energy_max)
	if used_energy_temp < used_energy:
		energy_new_val.add_theme_color_override("font_color", Color(0.214, 0.786, 0.228, 1.0))
	elif used_energy_temp > used_energy:
		energy_new_val.add_theme_color_override("font_color", Color(0.569, 0.04, 0.173, 1.0))
	else:
		energy_new_val.remove_theme_color_override("font_color")
	
	var stat_values_new_labels = stat_new_values.get_children()
	var m = 0
	for n in dict_temp:
		if dict_temp[n]["value"] >= 100:
			stat_values_new_labels[m].text = str(int(dict_temp[n]["value"]))
		else:
			stat_values_new_labels[m].text = str(dict_temp[n]["value"])
		if dict_temp[n]["value"] > dict[n]["value"]:
			stat_values_new_labels[m].add_theme_color_override("font_color", Color(0.214, 0.786, 0.228, 1.0))
		elif dict_temp[n]["value"] < dict[n]["value"]:
			stat_values_new_labels[m].add_theme_color_override("font_color", Color(0.569, 0.04, 0.173, 1.0))
		else:
			stat_values_new_labels[m].remove_theme_color_override("font_color")
		m += 1


func _process(_delta: float) -> void:
	if GAME.player.upgrade.visible == true:
		if type == "weapon":
			inputs(GAME.player.weapon_stats, GAME.player.weapon_energy_max, GAME.player.weapon_used_energy, GAME.player.weapon_used_energy_temp)
		else:
			inputs(GAME.player.player_stats, GAME.player.energy_max, GAME.player.used_energy, GAME.player.used_energy_temp)


func inputs(dict: Dictionary, energy_max: int, energy_used: int, energy_used_temp: int):
	if Input.is_action_just_pressed("go_left"):
		if energy_used_temp <= energy_max:
			var upgrade_boxes = grid_container.get_children()
			for u in upgrade_boxes:
				u.apply()
			if type == "weapon":
				GAME.player.apply_weapon_changes()
			else:
				GAME.player.apply_player_changes()
			change_labels(dict, energy_max, energy_used)
			warning_confirm.start()
		else:
			warning_energy.start()
	
	if Input.is_action_just_pressed("inventory_reset"):
		var upgrade_boxes = grid_container.get_children()
		for u in upgrade_boxes:
				u.reset_changes()
		change_new_labels(dict, dict, energy_max, energy_used, energy_used)
		warning_reset.start()
	
	if Input.is_action_just_pressed("inventory_change"):
		if type == "player":
			type = "weapon"
		else:
			type = "player"
		inventory_start()
