extends Button
@onready var control: Control = $Control
@onready var name_: Label = $Name
@onready var energy: Label = $Energy
@onready var lvl: Label = $LVL
@onready var description: Label = $Control/Description

var upgrade: Upgrade
var level: int

func _ready() -> void:
	if upgrade:
		name_.text = upgrade.name
		energy.text = str(upgrade.energy)
		lvl.text = str(level)
		description.text = upgrade.description


func _process(_delta: float) -> void:
	if is_hovered():
		z_index = 1
		control.visible = true
		update_minimum_size()
	else:
		control.visible = false
		z_index = 0
		update_minimum_size()
	

func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		upgrade.enabled = true
	else:
		upgrade.enabled = false
