extends RefCounted

const ChunkStreamPlannerScript: Script = preload("res://systems/world/chunk_stream_planner.gd")

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	_test_radius_two_produces_twenty_five_coords()
	_test_world_to_chunk_uses_floor_for_negative_positions()
	_test_forward_chunk_is_prioritized_when_center_is_active()
	_test_coords_outside_radius_are_unloaded()
	return _failures

func _make_planner() -> Variant:
	return ChunkStreamPlannerScript.new()

func _test_radius_two_produces_twenty_five_coords() -> void:
	var coords: Array[Vector2i] = _make_planner().desired_coords(Vector2i(4, -2), 2)
	_assert_equal(coords.size(), 25, "radius two should produce a five by five desired set")
	_assert_true(coords.has(Vector2i(4, -2)), "desired set should contain the center chunk")
	_assert_true(coords.has(Vector2i(2, -4)), "desired set should contain the negative corner offset")
	_assert_true(coords.has(Vector2i(6, 0)), "desired set should contain the positive corner offset")

func _test_world_to_chunk_uses_floor_for_negative_positions() -> void:
	var planner: Variant = _make_planner()
	_assert_equal(planner.world_to_chunk(Vector2(-1.0, -1.0), 1024.0), Vector2i(-1, -1), "negative positions just below zero should map to chunk minus one")
	_assert_equal(planner.world_to_chunk(Vector2(-1025.0, -1025.0), 1024.0), Vector2i(-2, -2), "positions beyond a negative boundary should map to the next negative chunk")
	_assert_equal(planner.world_to_chunk(Vector2(1024.0, 1024.0), 1024.0), Vector2i(1, 1), "positive exact boundaries should map to the next chunk")

func _test_forward_chunk_is_prioritized_when_center_is_active() -> void:
	var planner: Variant = _make_planner()
	var active: Array[Vector2i] = [Vector2i.ZERO]
	var queue: Array[Vector2i] = planner.build_load_queue(active, Vector2i.ZERO, 1, Vector2.RIGHT)
	_assert_true(not queue.is_empty(), "load queue should contain missing neighbours")
	if not queue.is_empty():
		_assert_equal(queue[0], Vector2i(1, 0), "the nearest forward chunk should be first when moving right")

func _test_coords_outside_radius_are_unloaded() -> void:
	var planner: Variant = _make_planner()
	var active: Array[Vector2i] = [
		Vector2i(-2, 0),
		Vector2i.ZERO,
		Vector2i(1, 1),
		Vector2i(2, 0),
	]
	var unload: Array[Vector2i] = planner.coords_to_unload(active, Vector2i.ZERO, 1)
	_assert_true(unload.has(Vector2i(-2, 0)), "left coordinate outside radius should unload")
	_assert_true(unload.has(Vector2i(2, 0)), "right coordinate outside radius should unload")
	_assert_true(not unload.has(Vector2i.ZERO), "center coordinate should remain active")
	_assert_true(not unload.has(Vector2i(1, 1)), "coordinate on the radius corner should remain active")

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	test_count += 1
	if actual != expected:
		_failures.append("%s (expected=%s actual=%s)" % [message, str(expected), str(actual)])
