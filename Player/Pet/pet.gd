extends Node2D
class_name Pet

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var region: NavigationRegion2D = $NavigationRegion2D

var boss_room := GAME.boss_room_pos
const SPEED = 100
@export var moving := false
@export var search := false

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


func _physics_process(delta: float) -> void:
	_handle_pet_input()
	_handle_movement(delta)


func _handle_pet_input() -> void:
	if not Input.is_action_just_pressed("pet", false):
		return
	if moving:
		moving = false
	else:
		sprite.play("search")
		search = true
		nav.target_position = boss_room
		moving = true


func _handle_movement(delta: float) -> void:
	if moving:
		_handle_moving_state(delta)
	elif global_position.distance_to(GAME.player.global_position) > 50:
		_follow_player(delta)
	else:
		sprite.play("idle")


func _handle_moving_state(delta: float) -> void:
	if nav.is_navigation_finished():
		moving = false
		sprite.play("idle")
		return

	if search:
		return

	var dist := global_position.distance_to(GAME.player.global_position)
	if dist > 400:
		moving = false
		return
	if dist > 250:
		sprite.play("idle")
		return

	_move_along_path(delta)


func _follow_player(delta: float) -> void:
	nav.target_position = GAME.player.global_position
	sprite.play("walk")
	_move_along_path(delta)


func _move_along_path(delta: float) -> void:
	var next := nav.get_next_path_position()
	var direction := (next - global_position).normalized()
	sprite.flip_h = direction.x < 0
	global_position += direction * SPEED * delta


func _on_animated_sprite_2d_animation_finished() -> void: #Search animation finished
	search = false
