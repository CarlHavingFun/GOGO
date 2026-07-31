class_name WeaponDefinition
extends Resource

@export var id: StringName = &""
@export var tags: Array[StringName] = []
@export var display_name: String = ""
@export var damage: int = 0
@export var shots_per_second: float = 0.0
@export var magazine_size: int = 0
@export var reload_duration: float = 0.0
@export var base_spread_degrees: float = 0.0
@export var moving_spread_addition_degrees: float = 0.0
@export var recoil_per_shot: float = 0.0
@export var recoil_recovery_per_second: float = 0.0
@export var recoil_spread_coefficient: float = 0.0
@export var maximum_recoil_bias_degrees: float = 0.0
@export var maximum_visual_kick_pixels: float = 0.0
@export var range_pixels: float = 0.0
@export var pierce_count: int = 0
@export_range(0.0, 1.0, 0.01) var pierce_decay: float = 1.0
@export_range(1.0, 10.0, 0.01) var weakpoint_multiplier: float = 1.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if shots_per_second <= 0.0:
		errors.append("shots_per_second must be greater than zero")
	if magazine_size <= 0:
		errors.append("magazine_size must be greater than zero")
	if reload_duration <= 0.0:
		errors.append("reload_duration must be greater than zero")
	if range_pixels <= 0.0:
		errors.append("range_pixels must be greater than zero")
	if damage < 0:
		errors.append("damage must not be negative")
	return errors
