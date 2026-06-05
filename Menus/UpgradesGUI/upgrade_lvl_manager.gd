extends Control
class_name UpgradeLVLManager
@onready var name_label: Label = $StatTable/VBoxContainer/Name
@onready var energy_number_old: Label = $StatTable/VBoxContainer/GridContainer/EnergyNumberOld
@onready var lvl_number_old: Label = $StatTable/VBoxContainer/GridContainer/LvlNumberOld
@onready var energy_number_new: Label = $StatTable/VBoxContainer/GridContainer/EnergyNumberNew
@onready var lvl_number_new: Label = $StatTable/VBoxContainer/GridContainer/LvlNumberNew
const UPGRADE_PARAMETER = preload("uid://b8pawb34qe2mr")
@onready var parameters: VBoxContainer = $StatTable/VBoxContainer/ScrollContainer/Parameters
@onready var confirmation: Button = $StatTable/VBoxContainer/HBoxContainer/Button
@onready var warning: NinePatchRect = $StatTable2


var level_change = 0
var stats : Array[Dictionary]
var be : int
var bl : int
var cost := 0
var upgrade_instance : ModInstance

func open_upgrades(upgrade_name : String, base_energy : int, base_level : int, stats : Array[Dictionary], upgrade : ModInstance):
	visible=true
	for child in parameters.get_children():
		child.free()
	level_change = 0
	be = base_energy
	bl = base_level
	name_label.text = upgrade_name
	energy_number_old.text = str(base_energy)
	energy_number_new.text = str(base_energy)
	lvl_number_old.text = str(base_level)
	lvl_number_new.text = str(base_level)
	upgrade_instance = upgrade
	self.stats = stats
	for s in stats:
		parameters.call_deferred("add_child",UPGRADE_PARAMETER.instantiate())
	call_deferred("update_values")

func update_values(): 
	energy_number_new.text = str(be + level_change)
	lvl_number_new.text =str(bl + level_change)
	cost = 0 if level_change <= 0 else (2**(bl+1))*(2**(level_change)-1)
	
	confirmation.text = "COST\n" + str(cost)

	var children = parameters.get_children()
	var i = 0
	for par in stats:
		children[i].set_values(str(par["name"]),str(par["value"] + par["change"] * level_change))
		i += 1
	

func _on_lower_button_up() -> void:
	if bl + level_change == 0:
		return
	level_change -= 1
	call_deferred("update_values")

func _on_higher_button_up() -> void:
	if bl + level_change == 66:
		return
	level_change += 1
	call_deferred("update_values")

func finish_upgrade_after_warning(accepted : bool):
	if accepted:
		upgrade_instance.enabled = false
	else:
		GAME.player.processors += cost
		upgrade_instance.level -= level_change
	GAME.player.apply_player_changes()
	GAME.player.apply_weapon_changes()
	self.visible = false if accepted else true
	warning.visible = false
	GAME.upgrade_menu.inventory_start()
	
func _on_confirm() -> void:
	if GAME.player.processors < cost:
		return
	else:
		GAME.player.processors -= cost
		upgrade_instance.level += level_change
		
		GAME.player.apply_player_changes()
		GAME.player.apply_weapon_changes()
		GAME.player.recalculate_stats()
		if GAME.player.energy["player_energy_max"] - GAME.player.energy["player_energy_used_temp"] - level_change < 0 and upgrade_instance is PlayerModInstance:	
			warning.visible = true
			return
		if GAME.player.energy["weapon_energy_max"] - GAME.player.energy["weapon_energy_used_temp"] - level_change < 0 and upgrade_instance is WeaponModInstance:
			warning.visible = true
			return
			
			
		self.visible = false
		GAME.upgrade_menu.inventory_start()
