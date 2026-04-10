extends Node2D
class_name Pet

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var region: NavigationRegion2D = $NavigationRegion2D

var boss_room := GAME.boss_room_pos
const SPEED = 10
var moving := false

func _ready() -> void:
	region.top_level = true
	region.global_position = Vector2.ZERO
	call_deferred("bake_nav")

func bake_nav() -> void:
	var nav_poly := NavigationPolygon.new()
	nav_poly.agent_radius = 4
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT 
	nav_poly.source_geometry_group_name = "Rooms"
	nav_poly.add_outline(GAME.outline)
	region.navigation_polygon = nav_poly
	region.bake_navigation_polygon()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pet", false):
		sprite.play("search")
		nav.target_position = boss_room
		moving = true

	if moving:
		if nav.is_navigation_finished():
			moving = false
			sprite.play("idle")
		else:
			var next := nav.get_next_path_position()
			var direction := (next - global_position).normalized()
			global_position += direction * SPEED * delta

	elif not sprite.is_playing():
		sprite.play("idle")
