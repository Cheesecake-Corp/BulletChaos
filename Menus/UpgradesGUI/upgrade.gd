extends Button
@onready var control: Control = $Control

func _process(delta: float) -> void:
	if is_hovered():
		z_index = 1
		control.visible = true
		update_minimum_size()
	else:
		control.visible = false
		z_index = 0
		update_minimum_size()
	
