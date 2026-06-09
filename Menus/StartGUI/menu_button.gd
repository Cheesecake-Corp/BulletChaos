extends Button
class_name Menu_button

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var nine_patch_rect_2: NinePatchRect = $NinePatchRect2
@onready var label: Label = $NinePatchRect2/Label

var expand_size = Vector2(10,10)

func _on_mouse_entered() -> void:
	nine_patch_rect.visible = false
	nine_patch_rect_2.visible = true
	size += expand_size
	position -= expand_size/2
	nine_patch_rect_2.size += expand_size
	nine_patch_rect_2.position -= expand_size
	label.scale += expand_size/500
	label.position.y += expand_size.y/4
	z_index += 1


func _on_mouse_exited() -> void:
	nine_patch_rect.visible = true
	nine_patch_rect_2.visible = false
	size -= expand_size
	position += expand_size/2
	nine_patch_rect_2.size -= expand_size
	nine_patch_rect_2.position += expand_size
	label.scale -= expand_size/500
	label.position.y -= expand_size.y/4
	z_index -= 1
