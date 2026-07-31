extends RefCounted
class_name SpawnRingSampler

const MODULUS: int = 2147483647
const MULTIPLIER: int = 1103515245
const INCREMENT: int = 12345

var world_seed: int = 424242

func configure(seed_value: int) -> void:
	world_seed = _normalize(seed_value)

func sample(
	center: Vector2,
	sample_index: int,
	minimum_distance: float,
	maximum_distance: float
) -> Vector2:
	var safe_minimum: float = maxf(minimum_distance, 0.0)
	var safe_maximum: float = maxf(maximum_distance, safe_minimum)
	var rng := RandomNumberGenerator.new()
	rng.seed = _sample_seed(sample_index)
	var angle: float = rng.randf_range(0.0, TAU)
	var radius_squared: float = lerpf(
		safe_minimum * safe_minimum,
		safe_maximum * safe_maximum,
		rng.randf()
	)
	var radius: float = sqrt(radius_squared)
	return center + Vector2.RIGHT.rotated(angle) * radius

func _sample_seed(sample_index: int) -> int:
	var index_value: int = _normalize(sample_index)
	return int((world_seed * MULTIPLIER + index_value * INCREMENT + 1) % MODULUS)

func _normalize(value: int) -> int:
	var normalized: int = value % MODULUS
	if normalized < 0:
		normalized += MODULUS
	return normalized
