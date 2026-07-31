class_name WeaponRuntime
extends RefCounted

const RELOAD_COMPLETION_EPSILON: float = 0.0001

var weapon_definition: WeaponDefinition
var current_ammo: int = 0
var is_reloading: bool = false
var reload_is_automatic: bool = false
var recoil: float = 0.0
var _reload_remaining: float = 0.0
var _shot_cooldown_remaining: float = 0.0

# Foundation M0 compatibility names. They are views over the same runtime state,
# not a second implementation or a second source of truth.
var definition: WeaponDefinition:
	get:
		return weapon_definition
	set(value):
		configure(value)

var ammo_in_mag: int:
	get:
		return current_ammo
	set(value):
		current_ammo = maxi(value, 0)

var recoil_value: float:
	get:
		return recoil
	set(value):
		recoil = clampf(value, 0.0, 100.0)

var fire_cooldown: float:
	get:
		return _shot_cooldown_remaining
	set(value):
		_shot_cooldown_remaining = maxf(value, 0.0)

var reload_progress: float:
	get:
		return get_reload_progress()
	set(value):
		_reload_remaining = maxf(_reload_duration() * (1.0 - clampf(value, 0.0, 1.0)), 0.0)

func _init(definition_value: WeaponDefinition = null) -> void:
	if definition_value != null:
		configure(definition_value)

func configure(value: WeaponDefinition) -> void:
	weapon_definition = value
	current_ammo = _magazine_size()
	is_reloading = false
	reload_is_automatic = false
	recoil = 0.0
	_reload_remaining = 0.0
	_shot_cooldown_remaining = 0.0

func can_fire() -> bool:
	return weapon_definition != null and not is_reloading and current_ammo > 0 and _shot_cooldown_remaining <= RELOAD_COMPLETION_EPSILON

func fire() -> bool:
	return try_fire()

func try_fire() -> bool:
	if weapon_definition == null:
		return false
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
	recoil = minf(recoil + weapon_definition.recoil_per_shot, 100.0)
	_shot_cooldown_remaining += 1.0 / weapon_definition.shots_per_second
	if current_ammo == 0:
		start_reload(true)
	return true

func start_reload(is_automatic: bool = false) -> bool:
	if weapon_definition == null or is_reloading or current_ammo >= _magazine_size():
		return false
	is_reloading = true
	reload_is_automatic = is_automatic
	_reload_remaining = _reload_duration()
	return true

func cancel_reload_for_shot() -> bool:
	if not is_reloading or current_ammo <= 0:
		return false
	_cancel_reload()
	return true

func complete_reload() -> void:
	if weapon_definition == null:
		return
	current_ammo = _magazine_size()
	is_reloading = false
	reload_is_automatic = false
	_reload_remaining = 0.0

func tick(delta_seconds: float, trigger_is_held: bool = false) -> void:
	if weapon_definition == null:
		return
	var safe_delta: float = maxf(delta_seconds, 0.0)
	if trigger_is_held and current_ammo > 0 and not is_reloading:
		_shot_cooldown_remaining -= safe_delta
	else:
		_shot_cooldown_remaining = maxf(0.0, _shot_cooldown_remaining - safe_delta)
	var should_recover_recoil: bool = not trigger_is_held or current_ammo == 0 or is_reloading
	if should_recover_recoil:
		recoil = maxf(0.0, recoil - weapon_definition.recoil_recovery_per_second * safe_delta)
	if not is_reloading:
		return
	_reload_remaining -= safe_delta
	if _reload_remaining <= RELOAD_COMPLETION_EPSILON:
		complete_reload()

func get_reload_progress() -> float:
	if not is_reloading or _reload_duration() <= 0.0:
		return 0.0
	return clampf(1.0 - _reload_remaining / _reload_duration(), 0.0, 1.0)

func reload_ratio() -> float:
	return get_reload_progress()

func get_current_spread_degrees(is_moving: bool) -> float:
	return get_spread_degrees_for_recoil(recoil, is_moving)

func get_spread_degrees_for_recoil(recoil_value_value: float, is_moving: bool) -> float:
	if weapon_definition == null:
		return 0.0
	var movement_adjusted_spread: float = weapon_definition.base_spread_degrees
	if is_moving:
		movement_adjusted_spread += weapon_definition.moving_spread_addition_degrees
	var recoil_multiplier: float = 1.0 + clampf(recoil_value_value, 0.0, 100.0) / 100.0 * weapon_definition.recoil_spread_coefficient
	return movement_adjusted_spread * recoil_multiplier

func _cancel_reload() -> void:
	is_reloading = false
	reload_is_automatic = false
	_reload_remaining = 0.0

func _magazine_size() -> int:
	return 0 if weapon_definition == null else weapon_definition.magazine_size

func _reload_duration() -> float:
	return 0.0 if weapon_definition == null else weapon_definition.reload_duration
