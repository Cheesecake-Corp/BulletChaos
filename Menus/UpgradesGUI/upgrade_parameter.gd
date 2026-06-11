extends HBoxContainer
class_name UpgradeParameter
@onready var label: Label = $Label
@onready var label_2: Label = $Label2

func set_values(_name : String, _value : String):
	label.text = _name
	label_2.text = _value
