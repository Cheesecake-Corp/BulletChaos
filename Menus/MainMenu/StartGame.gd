extends TextureButton

@onready var line_edit: LineEdit = $"../LineEdit"
@onready var line_edit_2: LineEdit = $"../LineEdit2"
signal activated
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _pressed() -> void:
	get_tree().change_scene_to_file("res://World/MainWorld.tscn")
	GAME.change_seed(line_edit.text)
	activated.emit()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_button_button_up() -> void:
	if line_edit_2.text.is_valid_int():
		GAME.starter_money = int(line_edit_2.text)
