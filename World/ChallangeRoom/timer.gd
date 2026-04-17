extends Timer


func _on_area_2d_body_entered(_body: Node2D) -> void:
	start()


func _on_area_2d_body_exited(_body: Node2D) -> void:
	stop()
