extends RefCounted

const SpawnRingSamplerScript: Script = preload("res://src/spawn/spawn_ring_sampler.gd")

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	_test_same_seed_and_index_repeat()
	_test_samples_stay_inside_ring()
	_test_adjacent_indices_produce_different_positions()
	return _failures

func _make_sampler(seed_value: int = 424242) -> Variant:
	var sampler: Variant = SpawnRingSamplerScript.new()
	sampler.configure(seed_value)
	return sampler

func _test_same_seed_and_index_repeat() -> void:
	var center := Vector2(120.0, -44.0)
	var first: Vector2 = _make_sampler().sample(center, 17, 850.0, 1250.0)
	var second: Vector2 = _make_sampler().sample(center, 17, 850.0, 1250.0)
	_assert_near(first.distance_to(second), 0.0, 0.000001, "same seed and sample index should repeat exactly")

func _test_samples_stay_inside_ring() -> void:
	var sampler: Variant = _make_sampler()
	var center := Vector2(-250.0, 300.0)
	for sample_index: int in range(128):
		var candidate: Vector2 = sampler.sample(center, sample_index, 850.0, 1250.0)
		var distance: float = center.distance_to(candidate)
		_assert_true(distance >= 850.0 - 0.001, "ring sample should not be inside the minimum distance")
		_assert_true(distance <= 1250.0 + 0.001, "ring sample should not exceed the maximum distance")

func _test_adjacent_indices_produce_different_positions() -> void:
	var sampler: Variant = _make_sampler(99)
	var first: Vector2 = sampler.sample(Vector2.ZERO, 10, 850.0, 1250.0)
	var second: Vector2 = sampler.sample(Vector2.ZERO, 11, 850.0, 1250.0)
	_assert_true(first.distance_to(second) > 1.0, "adjacent sample indices should produce meaningfully different candidates")

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	test_count += 1
	if absf(actual - expected) > tolerance:
		_failures.append("%s (expected=%f actual=%f)" % [message, expected, actual])
