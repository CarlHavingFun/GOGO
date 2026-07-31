extends RefCounted
class_name DesertChunkLayout

const MODULUS: int = 2147483647
const PRIMARY_MULTIPLIER: int = 48271
const SECONDARY_MULTIPLIER: int = 69621
const COMMON_MODULES: Array[StringName] = [
	&"open_square",
	&"long_lane",
	&"l_corner",
	&"double_crate",
	&"narrow_side",
	&"wreck_cover",
]

var world_seed: int = 424242

func configure(seed_value: int) -> void:
	world_seed = _normalize(seed_value)

func chunk_seed(coord: Vector2i) -> int:
	var mixed: int = _mix(world_seed, _normalize(coord.x))
	mixed = _mix(mixed, _normalize(coord.y))
	return mixed

func describe(coord: Vector2i) -> Dictionary:
	var seed_value: int = chunk_seed(coord)
	var poi_roll: int = _mix(seed_value, 0x51F15E) % 13
	var module_id: StringName
	var poi_id: StringName = &""
	if poi_roll == 0:
		module_id = &"supply_outpost"
		poi_id = &"supply_outpost"
	else:
		var module_index: int = _mix(seed_value, 0x13579B) % COMMON_MODULES.size()
		module_id = COMMON_MODULES[module_index]

	return {
		"coord": coord,
		"chunk_seed": seed_value,
		"module_id": module_id,
		"rotation_quarters": _mix(seed_value, 0x2468AC) % 4,
		"poi_id": poi_id,
		"decoration_seed": _mix(seed_value, 0x6D2B79),
	}

func _mix(value: int, salt: int) -> int:
	var normalized_value: int = _normalize(value)
	var normalized_salt: int = _normalize(salt)
	return int((normalized_value * PRIMARY_MULTIPLIER + normalized_salt * SECONDARY_MULTIPLIER + 1) % MODULUS)

func _normalize(value: int) -> int:
	var normalized: int = value % MODULUS
	if normalized < 0:
		normalized += MODULUS
	return normalized
