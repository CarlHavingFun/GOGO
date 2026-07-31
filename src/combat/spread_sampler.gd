class_name SpreadSampler
extends RefCounted

var _random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
var draw_index: int = 0

func _init(seed: int) -> void:
	_random_number_generator.seed = seed

func sample_spread(base_spread_degrees: float, moving_spread_addition_degrees: float, is_moving: bool) -> float:
	var maximum_spread_degrees: float = base_spread_degrees
	if is_moving:
		maximum_spread_degrees += moving_spread_addition_degrees
	var sample: float = _random_number_generator.randf_range(-maximum_spread_degrees, maximum_spread_degrees)
	draw_index += 1
	return sample
