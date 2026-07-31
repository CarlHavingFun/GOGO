class_name WeaponRuntime
extends RefCounted

const RELOAD_COMPLETION_EPSILON: float = 0.0001

var weapon_definition: Resource
var current_ammo: int
var is_reloading: bool = false
var reload_is_automatic: bool = false
var recoil: float = 0.0
var _reload_remaining: float = 0.0
var _shot_cooldown_remaining: float = 0.0

func _init(definition: Resource) -> void:
	weapon_definition = definition
	current_ammo = _magazine_size()

func try_fire() -> bool:
	if is_reloading:
		if current_ammo == 0:
			return false
		_cancel_reload()
	if current_ammo == 0:
		start_reload(true)
		return false
	if _shot_cooldown_remaining > 0.0:
		return false
	current_ammo -= 1
	recoil = minf(recoil + _recoil_per_shot(), 100.0)
	_shot_cooldown_remaining += 1.0 / _shots_per_second()
	if current_ammo == 0:
		start_reload(true)
	return true

func start_reload(is_automatic: bool = false) -> bool:
	if is_reloading or current_ammo >= _magazine_size():
		return false
	is_reloading = true
	reload_is_automatic = is_automatic
	_reload_remaining = _reload_duration()
	return true

func tick(delta_seconds: float, trigger_is_held: bool = false) -> void:
	var can_preserve_cooldown_overflow: bool = trigger_is_held and current_ammo > 0 and not is_reloading
	if can_preserve_cooldown_overflow:
		_shot_cooldown_remaining -= delta_seconds
	else:
		_shot_cooldown_remaining = maxf(0.0, _shot_cooldown_remaining - delta_seconds)
	var should_recover_recoil: bool = not trigger_is_held or current_ammo == 0 or is_reloading
	if should_recover_recoil:
		recoil = maxf(0.0, recoil - _recoil_recovery_per_second() * delta_seconds)
	if not is_reloading:
		return
	_reload_remaining -= delta_seconds
	if _reload_remaining <= RELOAD_COMPLETION_EPSILON:
		current_ammo = _magazine_size()
		is_reloading = false
		reload_is_automatic = false
		_reload_remaining = 0.0

func get_reload_progress() -> float:
	if not is_reloading:
		return 0.0
	return clampf(1.0 - _reload_remaining / _reload_duration(), 0.0, 1.0)

func get_current_spread_degrees(is_moving: bool) -> float:
	return get_spread_degrees_for_recoil(recoil, is_moving)

func get_spread_degrees_for_recoil(recoil_value: float, is_moving: bool) -> float:
	var movement_adjusted_spread: float = _base_spread_degrees()
	if is_moving:
		movement_adjusted_spread += _moving_spread_addition_degrees()
	var recoil_multiplier: float = 1.0 + recoil_value / 100.0 * _recoil_spread_coefficient()
	return movement_adjusted_spread * recoil_multiplier

func _cancel_reload() -> void:
	is_reloading = false
	reload_is_automatic = false
	_reload_remaining = 0.0

func _magazine_size() -> int:
	return weapon_definition.get("magazine_size") as int

func _shots_per_second() -> float:
	return weapon_definition.get("shots_per_second") as float

func _reload_duration() -> float:
	return weapon_definition.get("reload_duration") as float

func _recoil_per_shot() -> float:
	return weapon_definition.get("recoil_per_shot") as float

func _recoil_recovery_per_second() -> float:
	return weapon_definition.get("recoil_recovery_per_second") as float

func _base_spread_degrees() -> float:
	return weapon_definition.get("base_spread_degrees") as float

func _moving_spread_addition_degrees() -> float:
	return weapon_definition.get("moving_spread_addition_degrees") as float

func _recoil_spread_coefficient() -> float:
	return weapon_definition.get("recoil_spread_coefficient") as float
