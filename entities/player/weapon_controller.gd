extends Node2D
class_name WeaponController

signal shot_resolved(origin: Vector2, end_point: Vector2, hit: bool, result: Dictionary)
signal weapon_state_changed(snapshot: Dictionary)
signal dry_fired()
signal reload_started()
signal reload_completed()
signal feedback_requested(message: String)

@export var weapon_definition: WeaponDefinition
@export var initial_seed: int = 424242
@export_flags_2d_physics var target_collision_mask: int = 2

var runtime := WeaponRuntime.new()
var spread := DeterministicSpread.new()
var current_seed: int = 0
var _player: PlayerController
var _enabled: bool = false

func _ready() -> void:
	_player = get_parent() as PlayerController
	if _player == null:
		push_error("WeaponController must be a child of PlayerController")
		return
	if weapon_definition == null:
		push_error("WeaponController is missing WeaponDefinition")
		return
	var validation_errors: PackedStringArray = weapon_definition.validate()
	if not validation_errors.is_empty():
		push_error("Invalid WeaponDefinition: %s" % "; ".join(validation_errors))
		return
	runtime.configure(weapon_definition)
	reset_spread_seed(initial_seed)
	_enabled = true

func _physics_process(delta: float) -> void:
	if not _enabled:
		return
	var was_reloading: bool = runtime.is_reloading
	runtime.tick(delta)
	if was_reloading and not runtime.is_reloading:
		reload_completed.emit()
		feedback_requested.emit("RELOAD COMPLETE")

	if Input.is_action_just_pressed("reset_seed"):
		reset_spread_seed(initial_seed)
		feedback_requested.emit("SEED RESET: %d" % current_seed)

	if Input.is_action_just_pressed("reload"):
		_begin_reload()

	if Input.is_action_pressed("fire"):
		_handle_trigger()

	weapon_state_changed.emit(get_snapshot())

func _handle_trigger() -> void:
	if runtime.is_reloading:
		if not runtime.cancel_reload_for_shot():
			return
		feedback_requested.emit("RELOAD CANCELLED")

	if runtime.ammo_in_mag <= 0:
		dry_fired.emit()
		_begin_reload()
		return
	if runtime.fire_cooldown > 0.000001:
		return
	_fire_hitscan()

func _fire_hitscan() -> void:
	var moving: bool = _player.is_moving()
	var recoil_before_shot: float = runtime.recoil_value
	var spread_offset_deg: float = spread.sample_offset_deg(weapon_definition, recoil_before_shot, moving)
	if not runtime.fire():
		return

	var origin: Vector2 = global_position
	var aim_delta: Vector2 = get_global_mouse_position() - origin
	var base_direction: Vector2 = _player.get_aim_direction()
	if aim_delta.length_squared() > 0.0001:
		base_direction = aim_delta.normalized()
	var shot_direction: Vector2 = base_direction.rotated(deg_to_rad(spread_offset_deg)).normalized()
	var intended_end: Vector2 = origin + shot_direction * weapon_definition.max_range_px
	var query := PhysicsRayQueryParameters2D.create(origin, intended_end, target_collision_mask)
	query.exclude = [_player.get_rid()]
	var hit_data: Dictionary = _player.get_world_2d().direct_space_state.intersect_ray(query)
	var actual_end: Vector2 = intended_end
	var result: Dictionary = {}
	var did_hit: bool = not hit_data.is_empty()
	if did_hit:
		var hit_position: Variant = hit_data.get("position", intended_end)
		if hit_position is Vector2:
			actual_end = hit_position
		var collider: Object = hit_data.get("collider") as Object
		if collider != null and collider.has_method("apply_damage"):
			var damage_result: Variant = collider.call("apply_damage", weapon_definition.base_damage, actual_end)
			if damage_result is Dictionary:
				result = damage_result

	shot_resolved.emit(origin, actual_end, did_hit, result)
	if runtime.ammo_in_mag == 0:
		_begin_reload()

func _begin_reload() -> void:
	if runtime.start_reload():
		reload_started.emit()
		feedback_requested.emit("RELOADING")

func reset_spread_seed(seed_value: int) -> void:
	current_seed = seed_value
	spread.configure(seed_value)

func get_snapshot() -> Dictionary:
	if weapon_definition == null:
		return {}
	var moving: bool = _player != null and _player.is_moving()
	return {
		"weapon": weapon_definition.display_name,
		"seed": current_seed,
		"ammo": runtime.ammo_in_mag,
		"magazine_size": weapon_definition.magazine_size,
		"is_reloading": runtime.is_reloading,
		"reload_ratio": runtime.reload_ratio(),
		"recoil": runtime.recoil_value,
		"spread_deg": spread.current_spread_deg(weapon_definition, runtime.recoil_value, moving),
		"moving": moving,
	}
