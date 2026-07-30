extends RefCounted
class_name DeterministicSpread

var _rng := RandomNumberGenerator.new()
var current_seed: int = 0

func configure(seed_value: int) -> void:
	current_seed = seed_value
	_rng.seed = seed_value

func current_spread_deg(definition: WeaponDefinition, recoil_value: float, moving: bool) -> float:
	if definition == null:
		return 0.0
	var movement_spread: float = definition.move_spread_deg if moving else 0.0
	var base_envelope: float = definition.base_spread_deg + movement_spread
	var recoil_ratio: float = clampf(recoil_value, 0.0, 100.0) / 100.0
	return base_envelope * (1.0 + recoil_ratio * definition.recoil_spread_factor)

func sample_offset_deg(definition: WeaponDefinition, recoil_value: float, moving: bool) -> float:
	var envelope: float = current_spread_deg(definition, recoil_value, moving)
	return _rng.randf_range(-envelope, envelope)
