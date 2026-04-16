extends Timer


func _on_area_2d_body_entered(body: Node2D) -> void:
	start()


func _on_area_2d_body_exited(body: Node2D) -> void:
	stop()
