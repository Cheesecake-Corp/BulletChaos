extends Node2D
class_name Room

enum direction{LEFT,RIGHT,TOP,DOWN}
var exits = []
var size = {}
var navsq = Vector2()
var complete := false

func spawn():
	var dir = scene_file_path.get_base_dir()
	var path = dir.path_join("Stuff.tscn")

	add_child(load(path).instantiate())
