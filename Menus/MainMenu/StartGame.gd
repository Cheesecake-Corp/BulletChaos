extends TextureButton

@onready var line_edit: LineEdit = $"../LineEdit"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _pressed() -> void:
	get_tree().change_scene_to_file("res://World/MainWorld.tscn")
	GAME.change_seed(line_edit.text)
# Called every frame. 'delta' is the elapsed time since the previous frame.
