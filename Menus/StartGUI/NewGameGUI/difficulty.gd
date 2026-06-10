extends Control

@onready var button: Button = $Button
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var v_box_container: VBoxContainer = $VBoxContainer

var diff: String = ""

func _ready() -> void:
	nine_patch_rect.visible = false
	v_box_container.visible = false
	button.visible = true


func _on_button_pressed() -> void:
	button.visible = false
	nine_patch_rect.visible = true
	v_box_container.visible = true
	v_box_container.z_index = 9
	nine_patch_rect.z_index = 9
	get_parent().hide_button("Commands", true)


func set_difficulty(diff_str: String):
	diff = diff_str
	button.text = diff
	button.visible = true
	nine_patch_rect.visible = false
	v_box_container.visible = false
	v_box_container.z_index = 0
	nine_patch_rect.z_index = 0
	get_parent().hide_button("Commands", false)


func _on_very_easy_pressed() -> void:
	set_difficulty("Peaceful")


func _on_easy_pressed() -> void:
	set_difficulty("Easy")


func _on_normal_pressed() -> void:
	set_difficulty("Normal")


func _on_hard_pressed() -> void:
	set_difficulty("Hard")


func _on_insane_pressed() -> void:
	set_difficulty("Insane")
