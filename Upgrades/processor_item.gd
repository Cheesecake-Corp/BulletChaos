extends Node2D

var amount : int

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GAME.player:
		GAME.player.processors += amount
		queue_free()
