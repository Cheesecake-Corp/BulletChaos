extends RigidBody2D
class_name Bot_bullet

@export var default_damage := 10
@export var default_speed = 100
@export var lifespan : float = 10

var direction := Vector2(0,0)
var active = false
var damage_mult :float = 1 #Set with the weapon
var speed_mult :float = 1 #Set with the weapon
var speed :float = 0
var damage : float = 0
var time : float = 0
var bot : Enemy


func _ready() -> void:
	speed = default_speed * speed_mult
	damage = default_damage * damage_mult
	visible = false
	max_contacts_reported = 1


func _process(delta: float) -> void:
	if active == true:
		global_position = global_position + direction * speed * delta
		time = move_toward(time, lifespan, delta)
		if time == lifespan:
			disable()


func enable() -> void:
	active = true
	visible = true
	time = 0
	set_deferred("contact_monitor", true)


func disable() -> void:
	active = false
	visible = false
	set_deferred("contact_monitor", false)


func _on_body_entered(body: Node2D) -> void: #Collisions
	if active == true and body != bot:
		if body is Bot_bullet:
			body.disable()
		elif body is Player:
			body.health = body.health - damage
		elif body is Enemy:
			body.take_damage(damage)
		disable()
