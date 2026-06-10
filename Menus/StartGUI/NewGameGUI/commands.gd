extends Control

@onready var button: Button = $Button
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var v_box_container: VBoxContainer = $VBoxContainer

var commands: String = ""

func _ready() -> void:
	nine_patch_rect.visible = false
	v_box_container.visible = false
	button.visible = true


func _on_button_pressed() -> void:
	button.visible = false
	nine_patch_rect.visible = true
	v_box_container.visible = true
	v_box_container.z_index = 8
	nine_patch_rect.z_index = 8
	get_parent().hide_button("Seed", true)


func set_commands(commands_str: String):
	commands = commands_str
	button.text = commands
	button.visible = true
	nine_patch_rect.visible = false
	v_box_container.visible = false
	v_box_container.z_index = 0
	nine_patch_rect.z_index = 0
	get_parent().hide_button("Seed", false)


func _on_enable_pressed() -> void:
	set_commands("Enabled")


func _on_disable_pressed() -> void:
	set_commands("Disabled")
