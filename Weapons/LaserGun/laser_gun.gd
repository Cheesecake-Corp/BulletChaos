extends Weapon

func _on_body_entered(_body: Node, bullet: Projectile) -> void:
	if not bullet.visible:
		return
	if _body is Enemy:
		_body = _body as Enemy
		_body.take_damage(final_damage)
		# TODO: Implement stun

func _use(b : Laser):
	super(b)
	b.timer_2.start()
	

func create_bullets():
	var time = bullet_scene.instantiate().get_meta("max_time")
	for i in range((time-base_reload_time)*1000/use_rate + 1):
		var b : Laser = bullet_scene.instantiate()
		b.visible = false
		b.global_position = global_position
		b.freeze = true
		b.contact_monitor = true
		b.max_contacts_reported = 1
		
		b.damage.connect(_on_body_entered.bind(b))
		
		available_bullets.append(b)
		get_tree().current_scene.call_deferred("add_child", b)
