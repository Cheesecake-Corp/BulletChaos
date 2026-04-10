extends TextureProgressBar
func _ready() -> void:
	visible = false

func _value_changed(new_value: float) -> void:
	if new_value >= max_value:
		visible = false
	else:
		visible = true
