extends Control

@onready var button: Button = $Button
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

var mode: String = ""

func _ready() -> void:
	nine_patch_rect.visible = false
	v_box_container.visible = false
	button.visible = true


func _on_button_pressed() -> void:
	button.visible = false
	nine_patch_rect.visible = true
	v_box_container.visible = true
	v_box_container.z_index = 10
	nine_patch_rect.z_index = 10
	get_parent().hide_button("Difficulty", true)


func _on_survival_pressed() -> void:
	set_mode("Survival")


func _on_endless_pressed() -> void:
	set_mode("Endless")


func _on_immortal_pressed() -> void:
	set_mode("Immortal")


func set_mode(mode_str: String):
	mode = mode_str
	button.text = mode
	button.visible = true
	nine_patch_rect.visible = false
	v_box_container.visible = false
	v_box_container.z_index = 0
	nine_patch_rect.z_index = 0
	get_parent().hide_button("Difficulty", false)
