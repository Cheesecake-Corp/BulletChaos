extends HBoxContainer
class_name UpgradeParameter
@onready var label: Label = $Label
@onready var label_2: Label = $Label2

func set_values(name : String, value : String):
	label.text = name
	label_2.text = value
