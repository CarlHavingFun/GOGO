extends Resource
class_name WeaponDefinition

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_damage: float = 0.0
@export var shots_per_sec: float = 1.0
@export var magazine_size: int = 1
@export var reload_sec: float = 1.0
@export var base_spread_deg: float = 0.0
@export var move_spread_deg: float = 0.0
@export var recoil_per_shot: float = 0.0
@export var recoil_recovery_per_sec: float = 0.0
@export var recoil_spread_factor: float = 1.0
@export var max_range_px: float = 1000.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if shots_per_sec <= 0.0:
		errors.append("shots_per_sec must be greater than zero")
	if magazine_size <= 0:
		errors.append("magazine_size must be greater than zero")
	if reload_sec <= 0.0:
		errors.append("reload_sec must be greater than zero")
	if max_range_px <= 0.0:
		errors.append("max_range_px must be greater than zero")
	return errors
