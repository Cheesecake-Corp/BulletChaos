extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GAME.player:
		GAME.player.take_damage(-50)
		queue_free()
