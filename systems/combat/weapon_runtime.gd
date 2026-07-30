extends RefCounted
class_name WeaponRuntime

var definition: WeaponDefinition
var ammo_in_mag: int = 0
var recoil_value: float = 0.0
var fire_cooldown: float = 0.0
var reload_progress: float = 0.0
var is_reloading: bool = false

func configure(value: WeaponDefinition) -> void:
	definition = value
	ammo_in_mag = definition.magazine_size if definition != null else 0
	recoil_value = 0.0
	fire_cooldown = 0.0
	reload_progress = 0.0
	is_reloading = false

func tick(delta: float) -> void:
	if definition == null:
		return
	var safe_delta: float = maxf(delta, 0.0)
	fire_cooldown = maxf(0.0, fire_cooldown - safe_delta)
	recoil_value = maxf(0.0, recoil_value - definition.recoil_recovery_per_sec * safe_delta)
	if not is_reloading:
		return
	reload_progress += safe_delta
	if reload_progress + 0.000001 >= definition.reload_sec:
		complete_reload()

func can_fire() -> bool:
	return (
		definition != null
		and not is_reloading
		and ammo_in_mag > 0
		and fire_cooldown <= 0.000001
	)

func fire() -> bool:
	if not can_fire():
		return false
	ammo_in_mag -= 1
	fire_cooldown = 1.0 / definition.shots_per_sec
	recoil_value = minf(100.0, recoil_value + definition.recoil_per_shot)
	return true

func start_reload() -> bool:
	if definition == null or is_reloading or ammo_in_mag >= definition.magazine_size:
		return false
	is_reloading = true
	reload_progress = 0.0
	return true

func cancel_reload_for_shot() -> bool:
	if not is_reloading or ammo_in_mag <= 0:
		return false
	is_reloading = false
	reload_progress = 0.0
	return true

func complete_reload() -> void:
	if definition == null:
		return
	ammo_in_mag = definition.magazine_size
	is_reloading = false
	reload_progress = 0.0

func reload_ratio() -> float:
	if definition == null or not is_reloading:
		return 0.0
	return clampf(reload_progress / definition.reload_sec, 0.0, 1.0)
