## DamageNumbers.gd
## High-performance damage numbers for Godot 4.
## Autoload singleton that injects a renderer into the game scene,
## so positions are always correct regardless of camera/zoom.
##
## AUTOLOAD SETUP:
##   Project → Project Settings → Autoload → add this file as "DamageNumbers"
##
## USAGE:
##   DamageNumbers.spawn(global_position, damage)
##   DamageNumbers.spawn_crit(global_position, damage)
##   DamageNumbers.spawn_heal(global_position, amount)
##
## No need to pass 'self' anymore.

extends Node

# ─── Tunables ────────────────────────────────────────────────────────────────

@export var lifetime      : float = 0.85
@export var rise_distance : float = 48.0
@export var font_size     : int   = 22
@export var default_color : Color = Color(1.0, 0.95, 0.3)
@export var outline_color : Color = Color(0.0, 0.0, 0.0, 0.7)
@export var outline_size  : int   = 2
@export var pool_limit    : int   = 200

# ─── Internal ────────────────────────────────────────────────────────────────

class DamageEntry:
	var text      : String
	var world_pos : Vector2   # world space — renderer lives in game scene
	var scatter_x : float
	var color     : Color
	var age       : float

var _entries : Array[DamageEntry] = []
var _font    : Font
var _renderer : Node2D          # injected into the game scene tree

# ─── Renderer inner class ────────────────────────────────────────────────────
# A plain Node2D child we add to the current scene.
# Because it lives IN the game scene (not the autoload CanvasLayer),
# its _draw() coordinate space matches the game world exactly —
# no manual transform needed.

class Renderer extends Node2D:
	var owner_ref : Node   # reference back to DamageNumbers

	func _process(_delta: float) -> void:
		if not owner_ref._entries.is_empty():
			queue_redraw()

	func _draw() -> void:
		var d : Node = owner_ref
		var font     : Font  = d._font
		var ol_size  : int   = d.outline_size
		var ol_color : Color = d.outline_color
		var rise     : float = d.rise_distance
		var lifetime : float = d.lifetime
		var fsize    : int   = d.font_size

		for e in d._entries:
			var t      = e.age / lifetime
			var ease_t := 1.0 - pow(t, 3.0)
			var draw_pos = e.world_pos + Vector2(e.scatter_x, -rise * ease_t)-Vector2(10,-30)

			var sc : float
			if t < 0.15:
				sc = lerp(0.4, 1.15, t / 0.15)
			elif t < 0.25:
				sc = lerp(1.15, 1.0, (t - 0.15) / 0.10)
			else:
				sc = 1.0

			var alpha    := 1.0 if t < 0.7 else remap(t, 0.7, 1.0, 1.0, 0.0)
			var draw_col := Color(e.color.r, e.color.g, e.color.b, e.color.a * alpha)
			var shd_col  := Color(ol_color.r, ol_color.g, ol_color.b, ol_color.a * alpha)
			var size     := fsize * sc

			for ox in [-ol_size, ol_size]:
				for oy in [-ol_size, ol_size]:
					draw_string(font, draw_pos + Vector2(ox, oy), e.text,
						HORIZONTAL_ALIGNMENT_CENTER, -1, int(size), shd_col)

			draw_string(font, draw_pos, e.text,
				HORIZONTAL_ALIGNMENT_CENTER, -1, int(size), draw_col)

# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	_font = ThemeDB.fallback_font
	# Watch for scene changes so we re-inject the renderer
	get_tree().root.child_entered_tree.connect(_on_root_child_entered)
	_inject_renderer()


func _on_root_child_entered(_node: Node) -> void:
	# A new scene was loaded — re-inject renderer into it
	_inject_renderer()


func _inject_renderer() -> void:
	# Remove old renderer if it exists and is orphaned
	if is_instance_valid(_renderer):
		_renderer.queue_free()

	var r       := Renderer.new()
	r.owner_ref  = self
	r.z_index    = 100          # draw on top of everything
	_renderer    = r

	# Add to the current scene (not the autoload tree)
	get_tree().current_scene.add_child(r)


func _process(delta: float) -> void:
	if _entries.is_empty():
		return
	var i := _entries.size() - 1
	while i >= 0:
		_entries[i].age += delta
		if _entries[i].age >= lifetime:
			_entries.remove_at(i)
		i -= 1

# ─── Public API ──────────────────────────────────────────────────────────────

func spawn(
	world_pos  : Vector2,
	amount     : Variant,
	color      : Color  = default_color,
	font_scale : float  = 1.0,
	prefix     : String = ""
) -> void:
	# Ensure renderer is alive (scene may have changed)
	if not is_instance_valid(_renderer):
		_inject_renderer()

	var e       := DamageEntry.new()
	e.text       = prefix + str(amount)
	e.world_pos  = world_pos
	e.scatter_x  = randf_range(-12.0, 12.0)
	e.color      = color
	e.age        = 0.0

	_entries.append(e)
	if _entries.size() > pool_limit:
		_entries.remove_at(0)


func spawn_crit(world_pos: Vector2, amount: Variant) -> void:
	spawn(world_pos, amount, Color(1.0, 0.25, 0.1), 1.6)


func spawn_heal(world_pos: Vector2, amount: Variant) -> void:
	spawn(world_pos, amount, Color(0.3, 1.0, 0.4), 1.0, "+")
