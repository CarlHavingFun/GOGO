class_name WeaponRuntime
extends RefCounted

const RELOAD_COMPLETION_EPSILON: float = 0.0001

var weapon_definition: Resource
var current_ammo: int
var is_reloading: bool = false
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
		start_reload()
		return false
	if _shot_cooldown_remaining > 0.0:
		return false
	current_ammo -= 1
	recoil = minf(recoil + _recoil_per_shot(), 100.0)
	_shot_cooldown_remaining = 1.0 / _shots_per_second()
	if current_ammo == 0:
		start_reload()
	return true

func start_reload() -> bool:
	if is_reloading or current_ammo >= _magazine_size():
		return false
	is_reloading = true
	_reload_remaining = _reload_duration()
	return true

func tick(delta_seconds: float) -> void:
	_shot_cooldown_remaining = maxf(0.0, _shot_cooldown_remaining - delta_seconds)
	recoil = maxf(0.0, recoil - _recoil_recovery_per_second() * delta_seconds)
	if not is_reloading:
		return
	_reload_remaining -= delta_seconds
	if _reload_remaining <= RELOAD_COMPLETION_EPSILON:
		current_ammo = _magazine_size()
		is_reloading = false
		_reload_remaining = 0.0

func _cancel_reload() -> void:
	is_reloading = false
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
