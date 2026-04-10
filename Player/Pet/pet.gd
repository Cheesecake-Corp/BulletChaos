extends Node2D
class_name Pet

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var region: NavigationRegion2D = $NavigationRegion2D

var boss_room := GAME.boss_room_pos
const SPEED = 10

func _ready() -> void:
	var nav_poly := NavigationPolygon.new()
	nav_poly.agent_radius = 4

	# Set source BEFORE parsing
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	nav_poly.source_geometry_group_name = "Rooms"

	# Add outline AFTER config, BEFORE parse
	nav_poly.add_outline(GAME.outline)

	# Assign polygon to region before parsing (parse needs the region's transform)
	region.navigation_polygon = nav_poly
	region.top_level = true
	region.global_position = Vector2.ZERO

	# Collect geometry from the scene
	var source := NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source, region)

	# Bake async — callback fires when done
	NavigationServer2D.bake_from_source_geometry_data_async(nav_poly, source, _on_bake_done)
	
	
func _on_bake_done() -> void:
	print("Navigation baked!")
	region.navigation_polygon = region.navigation_polygon  
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pet",false) == true:
		sprite.play("search")
		nav.target_position = boss_room
		
		
	elif sprite.is_playing() == false:
		sprite.play("idle")


	
