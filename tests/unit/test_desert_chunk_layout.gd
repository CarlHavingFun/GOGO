extends RefCounted

const DesertChunkLayoutScript: Script = preload("res://src/world/desert_chunk_layout.gd")

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	_test_same_seed_and_coord_repeat()
	_test_negative_coord_repeat()
	_test_coordinate_range_has_module_variety()
	_test_supply_outposts_are_sparse_but_present()
	return _failures

func _make_layout(seed_value: int = 424242) -> Variant:
	var layout: Variant = DesertChunkLayoutScript.new()
	layout.configure(seed_value)
	return layout

func _test_same_seed_and_coord_repeat() -> void:
	var first: Dictionary = _make_layout().describe(Vector2i(7, -3))
	var second: Dictionary = _make_layout().describe(Vector2i(7, -3))
	_assert_equal(first, second, "same world seed and chunk coordinate should repeat exactly")

func _test_negative_coord_repeat() -> void:
	var layout: Variant = _make_layout(77)
	var first: Dictionary = layout.describe(Vector2i(-19, -31))
	var second: Dictionary = layout.describe(Vector2i(-19, -31))
	_assert_equal(first, second, "negative chunk coordinates should be deterministic")
	_assert_true(int(first.get("chunk_seed", -1)) >= 0, "chunk seed should be normalized to a non-negative value")

func _test_coordinate_range_has_module_variety() -> void:
	var layout: Variant = _make_layout()
	var modules: Dictionary = {}
	for x: int in range(-6, 7):
		for y: int in range(-6, 7):
			var description: Dictionary = layout.describe(Vector2i(x, y))
			modules[StringName(description.get("module_id", &""))] = true
	_assert_true(modules.size() >= 4, "a representative coordinate range should contain at least four module types")

func _test_supply_outposts_are_sparse_but_present() -> void:
	var layout: Variant = _make_layout()
	var poi_count: int = 0
	var sample_count: int = 0
	for x: int in range(-10, 11):
		for y: int in range(-10, 11):
			sample_count += 1
			var description: Dictionary = layout.describe(Vector2i(x, y))
			if StringName(description.get("poi_id", &"")) == &"supply_outpost":
				poi_count += 1
	_assert_true(poi_count > 0, "the deterministic sample should contain at least one supply outpost")
	_assert_true(poi_count * 5 < sample_count, "supply outposts should occupy less than twenty percent of sampled chunks")

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	test_count += 1
	if actual != expected:
		_failures.append("%s (expected=%s actual=%s)" % [message, str(expected), str(actual)])
