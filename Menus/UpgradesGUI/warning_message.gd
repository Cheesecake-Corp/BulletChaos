extends NinePatchRect

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("go_right") or Input.is_action_just_pressed("inventory"):
		self.visible = false

func start():
	self.visible = true
