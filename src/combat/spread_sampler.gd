class_name SpreadSampler
extends RefCounted

var _random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
var current_seed: int = 0
var draw_index: int = 0

func _init(seed_value: int = 0) -> void:
	configure(seed_value)

func configure(seed_value: int) -> void:
	current_seed = seed_value
	draw_index = 0
	_random_number_generator.seed = seed_value

func current_spread_deg(definition: WeaponDefinition, recoil_value: float, moving: bool) -> float:
	if definition == null:
		return 0.0
	var movement_spread: float = definition.moving_spread_addition_degrees if moving else 0.0
	var base_envelope: float = definition.base_spread_degrees + movement_spread
	var recoil_ratio: float = clampf(recoil_value, 0.0, 100.0) / 100.0
	return base_envelope * (1.0 + recoil_ratio * definition.recoil_spread_coefficient)

func sample_offset_deg(definition: WeaponDefinition, recoil_value: float, moving: bool) -> float:
	return _sample(current_spread_deg(definition, recoil_value, moving))

func sample_spread(base_spread_degrees: float, moving_spread_addition_degrees: float, is_moving: bool) -> float:
	var maximum_spread_degrees: float = base_spread_degrees
	if is_moving:
		maximum_spread_degrees += moving_spread_addition_degrees
	return _sample(maximum_spread_degrees)

func _sample(maximum_spread_degrees: float) -> float:
	var sample: float = _random_number_generator.randf_range(-maximum_spread_degrees, maximum_spread_degrees)
	draw_index += 1
	return sample
