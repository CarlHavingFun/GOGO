extends Node2D
class_name InfiniteDesertChunk

const TERRAIN_LAYER_VALUE: int = 4
const SAND_COLOR := Color("c9a56a")
const SAND_DARK_COLOR := Color("ad8954")
const STONE_COLOR := Color("6f665c")
const STONE_EDGE_COLOR := Color("b9a58d")
const CRATE_COLOR := Color("8a5f3d")
const CRATE_EDGE_COLOR := Color("d1a36f")
const WRECK_COLOR := Color("4f5b5f")
const WRECK_EDGE_COLOR := Color("93a1a1")

@export var chunk_size: float = 1024.0

var chunk_coord := Vector2i.ZERO
var descriptor: Dictionary = {}
var _obstacles: Array[Dictionary] = []
var _configured: bool = false

func configure(coord: Vector2i, description: Dictionary, size_value: float = 1024.0) -> void:
	chunk_coord = coord
	descriptor = description.duplicate(true)
	chunk_size = maxf(size_value, 64.0)
	position = Vector2(coord.x, coord.y) * chunk_size
	_build_module()
	_configured = true
	queue_redraw()

func _draw() -> void:
	if not _configured:
		return

	var bounds := Rect2(Vector2.ZERO, Vector2(chunk_size, chunk_size))
	draw_rect(bounds, SAND_COLOR, true)
	_draw_seeded_decorations()
	for obstacle: Dictionary in _obstacles:
		var rect: Rect2 = obstacle.get("rect", Rect2())
		var fill_color: Color = obstacle.get("fill", STONE_COLOR)
		var edge_color: Color = obstacle.get("edge", STONE_EDGE_COLOR)
		draw_rect(rect, fill_color, true)
		draw_rect(rect, edge_color, false, 4.0)

	if StringName(descriptor.get("poi_id", &"")) == &"supply_outpost":
		var marker_center := Vector2(chunk_size * 0.5, chunk_size * 0.5)
		draw_circle(marker_center, 34.0, Color("f6bd60"), false, 6.0)
		draw_line(marker_center + Vector2(-18.0, 0.0), marker_center + Vector2(18.0, 0.0), Color("fff3b0"), 5.0)
		draw_line(marker_center + Vector2(0.0, -18.0), marker_center + Vector2(0.0, 18.0), Color("fff3b0"), 5.0)

	draw_rect(bounds, Color(0.35, 0.28, 0.20, 0.45), false, 2.0)

func _draw_seeded_decorations() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(descriptor.get("decoration_seed", 0))
	for _index: int in range(28):
		var patch_position := Vector2(
			rng.randf_range(24.0, chunk_size - 24.0),
			rng.randf_range(24.0, chunk_size - 24.0)
		)
		var patch_size := Vector2(
			rng.randf_range(12.0, 58.0),
			rng.randf_range(8.0, 34.0)
		)
		draw_rect(Rect2(patch_position - patch_size * 0.5, patch_size), Color(SAND_DARK_COLOR, rng.randf_range(0.12, 0.28)), true)

func _build_module() -> void:
	_obstacles.clear()
	for child: Node in get_children():
		child.queue_free()

	var module_id: StringName = descriptor.get("module_id", &"open_square")
	var turns: int = int(descriptor.get("rotation_quarters", 0))
	match module_id:
		&"open_square":
			_add_rotated_obstacle(Rect2(190.0, 190.0, 104.0, 104.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(730.0, 190.0, 104.0, 104.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(190.0, 730.0, 104.0, 104.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(730.0, 730.0, 104.0, 104.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
		&"long_lane":
			_add_rotated_obstacle(Rect2(270.0, 120.0, 88.0, 784.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(666.0, 120.0, 88.0, 784.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
		&"l_corner":
			_add_rotated_obstacle(Rect2(330.0, 300.0, 360.0, 80.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(330.0, 300.0, 80.0, 360.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
		&"double_crate":
			_add_rotated_obstacle(Rect2(360.0, 430.0, 128.0, 128.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(536.0, 430.0, 128.0, 128.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
		&"narrow_side":
			_add_rotated_obstacle(Rect2(190.0, 230.0, 520.0, 88.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(610.0, 520.0, 224.0, 88.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
		&"wreck_cover":
			_add_rotated_obstacle(Rect2(376.0, 390.0, 272.0, 112.0), turns, WRECK_COLOR, WRECK_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(250.0, 610.0, 176.0, 64.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(620.0, 250.0, 154.0, 64.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
		&"supply_outpost":
			_add_rotated_obstacle(Rect2(300.0, 280.0, 424.0, 72.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(300.0, 280.0, 72.0, 344.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(652.0, 280.0, 72.0, 344.0), turns, STONE_COLOR, STONE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(420.0, 650.0, 88.0, 88.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
			_add_rotated_obstacle(Rect2(536.0, 650.0, 88.0, 88.0), turns, CRATE_COLOR, CRATE_EDGE_COLOR)
		_:
			push_warning("Unknown infinite desert module: %s" % String(module_id))

func _add_rotated_obstacle(rect: Rect2, quarter_turns: int, fill_color: Color, edge_color: Color) -> void:
	var transformed_rect: Rect2 = _rotate_rect(rect, quarter_turns)
	_obstacles.append({
		"rect": transformed_rect,
		"fill": fill_color,
		"edge": edge_color,
	})

	var body := StaticBody2D.new()
	body.name = "Terrain_%d" % _obstacles.size()
	body.collision_layer = TERRAIN_LAYER_VALUE
	body.collision_mask = 0
	body.position = transformed_rect.get_center()
	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = transformed_rect.size
	collision_shape.shape = rectangle_shape
	body.add_child(collision_shape)
	add_child(body)

func _rotate_rect(rect: Rect2, quarter_turns: int) -> Rect2:
	var turns: int = quarter_turns % 4
	if turns < 0:
		turns += 4
	var chunk_center := Vector2(chunk_size * 0.5, chunk_size * 0.5)
	var relative_center: Vector2 = rect.get_center() - chunk_center
	for _turn: int in range(turns):
		relative_center = Vector2(-relative_center.y, relative_center.x)
	var rotated_size: Vector2 = rect.size
	if turns % 2 == 1:
		rotated_size = Vector2(rect.size.y, rect.size.x)
	return Rect2(chunk_center + relative_center - rotated_size * 0.5, rotated_size)
