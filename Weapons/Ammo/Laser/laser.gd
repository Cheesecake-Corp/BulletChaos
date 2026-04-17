extends Projectile
class_name Laser

@onready var rigid_body_2d: RigidBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
signal damage(collider : Enemy)
@onready var timer_2: Timer = $Timer2


func _physics_process(_delta: float) -> void:
	if not visible:
		return
	modulate.a = move_toward(modulate.a,.5,1/timer.wait_time)
	print(modulate.a)


func _on_timer_2_timeout() -> void:
	var space := get_world_2d().direct_space_state

	var shape := RectangleShape2D.new()
	shape.size = Vector2(collision_shape_2d.shape.get_rect().size.x, 2) # thin beam

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(rotation, global_position)
	params.collision_mask = 1 << 2
	params.exclude = [self]

	var hits := space.intersect_shape(params, 32)
	for hit in hits:
		if hit["collider"] is Enemy:
			var collider : Enemy = hit["collider"]
			damage.emit(collider)
	timer_2.start()
