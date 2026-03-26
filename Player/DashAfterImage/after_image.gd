extends Sprite2D

@export var lifetime := 0.25
@export var start_alpha := 0.8

var timer := 0.0

func _ready():
	modulate.a = start_alpha

func _process(delta):
	timer += delta
	var t = timer / lifetime
	modulate.a = lerp(start_alpha, 0.0, t)

	if timer >= lifetime:
		queue_free()
