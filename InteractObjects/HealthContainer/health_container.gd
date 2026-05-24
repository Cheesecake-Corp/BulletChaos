extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GAME.player:
		GAME.player.health = move_toward(GAME.player.health, GAME.player.max_health, 50)
		queue_free()
