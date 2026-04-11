extends Node2D
class_name Pet

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var region: NavigationRegion2D = $NavigationRegion2D

var boss_room := GAME.boss_room_pos
const SPEED = 100
var moving := false
var search := false

func _ready() -> void:
	region.top_level = true
	region.global_position = Vector2.ZERO
	call_deferred("bake_nav")

func bake_nav() -> void:
	var nav_poly := NavigationPolygon.new()
	nav_poly.agent_radius = 15
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT 
	nav_poly.source_geometry_group_name = "Rooms"
	nav_poly.add_outline(GAME.outline)
	region.navigation_polygon = nav_poly
	region.bake_navigation_polygon()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pet", false): #Player pressed B
		if moving == false:
			sprite.play("search")
			search = true
			nav.target_position = boss_room
			moving = true
		else: #Stops searching for boss room
			moving = false

	if moving:
		if nav.is_navigation_finished():
			moving = false
			sprite.play("idle")
		elif search == false:
			sprite.play("walk")
			var next := nav.get_next_path_position()
			var direction := (next - global_position).normalized()
			if direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			global_position += direction * SPEED * delta
			
	elif abs(global_position.x - GAME.player.global_position.x) > 50 or abs(global_position.y - GAME.player.global_position.y) > 50: #Follows player
		nav.target_position = GAME.player.global_position
		var direction := (nav.get_next_path_position() - global_position).normalized()
		sprite.play("walk")
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		global_position += direction * SPEED * delta
	else:
		sprite.play("idle")


func _on_animated_sprite_2d_animation_finished() -> void: #Search animation finished
	search = false
