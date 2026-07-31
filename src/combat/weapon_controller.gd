class_name WeaponController
extends Node2D

signal shot_fired(origin: Vector2, end_position: Vector2, did_hit: bool)
signal hit_confirmed(target: Node, damage: int, hit_position: Vector2)
signal empty_triggered()
signal ammo_changed(current_ammo: int, magazine_size: int)
signal reload_started(duration_seconds: float, is_automatic: bool)
signal reload_ended(completed: bool, was_automatic: bool)
signal reload_state_changed(is_reloading: bool)
signal state_changed()

const MUZZLE_OFFSET_PIXELS: float = 30.0

@export var weapon_definition: WeaponDefinition
@export var combat_seed: int = 24680
@export var shooter_path: NodePath = NodePath("..")
@export var feedback_path: NodePath
@export_flags_2d_physics var ray_collision_mask: int = 2

var _runtime: WeaponRuntime
var _spread_sampler: SpreadSampler
var _shooter: PlayerController
var _feedback: CombatFeedback
var _last_ammo: int = -1
var _last_is_reloading: bool = false
var _last_recoil: float = -1.0
var _last_draw_index: int = -1
var _last_spread_degrees: float = -1.0
var _last_reload_progress: float = -1.0
var _last_reload_is_automatic: bool = false
var _last_shot_bias_degrees: float = 0.0
var _last_shot_spread_degrees: float = 0.0

func _ready() -> void:
	if weapon_definition == null:
		push_error("WeaponController requires a WeaponDefinition resource.")
		set_physics_process(false)
		return
	_shooter = get_node_or_null(shooter_path) as PlayerController
	_feedback = get_node_or_null(feedback_path) as CombatFeedback
	if _shooter == null:
		push_error("WeaponController requires a PlayerController shooter.")
		set_physics_process(false)
		return
	if _feedback == null:
		push_error("WeaponController requires a CombatFeedback node.")
		set_physics_process(false)
		return
	_runtime = WeaponRuntime.new(weapon_definition)
	_spread_sampler = SpreadSampler.new(combat_seed)
	_emit_state_if_changed(true)

func _physics_process(delta_seconds: float) -> void:
	if _runtime == null:
		return
	if Input.is_action_just_pressed("reset_seed"):
		_spread_sampler.configure(combat_seed)
		state_changed.emit()
	var was_reloading: bool = _runtime.is_reloading
	var was_reload_automatic: bool = _runtime.reload_is_automatic
	var fire_is_held: bool = Input.is_action_pressed("fire")
	_runtime.tick(delta_seconds, fire_is_held)
	_emit_reload_transition(was_reloading, _runtime.is_reloading, was_reload_automatic)
	if Input.is_action_just_pressed("reload"):
		was_reloading = _runtime.is_reloading
		was_reload_automatic = _runtime.reload_is_automatic
		_runtime.start_reload(false)
		_emit_reload_transition(was_reloading, _runtime.is_reloading, was_reload_automatic)
	if Input.is_action_just_pressed("fire") and get_current_ammo() == 0:
		empty_triggered.emit()
	if fire_is_held:
		while _attempt_fire():
			pass
	_emit_state_if_changed()

func get_current_ammo() -> int:
	return 0 if _runtime == null else _runtime.current_ammo

func get_magazine_size() -> int:
	return 0 if weapon_definition == null else weapon_definition.magazine_size

func get_is_reloading() -> bool:
	return false if _runtime == null else _runtime.is_reloading

func get_reload_progress() -> float:
	return 0.0 if _runtime == null else _runtime.get_reload_progress()

func get_reload_is_automatic() -> bool:
	return false if _runtime == null else _runtime.reload_is_automatic

func get_recoil() -> float:
	return 0.0 if _runtime == null else _runtime.recoil

func get_combat_seed() -> int:
	return combat_seed

func get_draw_index() -> int:
	return 0 if _spread_sampler == null else _spread_sampler.draw_index

func get_current_spread_degrees() -> float:
	if _runtime == null:
		return 0.0
	return _runtime.get_current_spread_degrees(_shooter != null and _shooter.is_moving())

func get_recoil_bias_degrees() -> float:
	return _get_recoil_bias_degrees_for_recoil(get_recoil())

func get_last_shot_bias_degrees() -> float:
	return _last_shot_bias_degrees

func get_last_shot_spread_degrees() -> float:
	return _last_shot_spread_degrees

func _get_recoil_bias_degrees_for_recoil(recoil_value: float) -> float:
	if weapon_definition == null:
		return 0.0
	return -weapon_definition.maximum_recoil_bias_degrees * recoil_value / 100.0

func get_visual_aim_direction() -> Vector2:
	if _shooter == null:
		return Vector2.RIGHT
	return _shooter.get_aim_direction().rotated(deg_to_rad(get_recoil_bias_degrees())).normalized()

func get_visual_kickback_pixels() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.maximum_visual_kick_pixels * get_recoil() / 100.0

func get_maximum_visual_kick_pixels() -> float:
	return 0.0 if weapon_definition == null else weapon_definition.maximum_visual_kick_pixels

func get_recoil_state() -> String:
	var current_recoil: float = get_recoil()
	if current_recoil < 20.0:
		return "STABLE"
	if current_recoil < 99.5:
		return "BUILDING"
	return "MAX"

func get_weapon_state() -> Dictionary:
	return {
		"ammo": get_current_ammo(),
		"magazine_size": get_magazine_size(),
		"is_reloading": get_is_reloading(),
		"reload_progress": get_reload_progress(),
		"reload_is_automatic": get_reload_is_automatic(),
		"recoil": get_recoil(),
		"recoil_bias_degrees": get_recoil_bias_degrees(),
		"recoil_state": get_recoil_state(),
		"combat_seed": get_combat_seed(),
		"draw_index": get_draw_index(),
		"spread_degrees": get_current_spread_degrees(),
	}

func _attempt_fire() -> bool:
	var was_reloading: bool = _runtime.is_reloading
	var was_reload_automatic: bool = _runtime.reload_is_automatic
	var is_shooter_moving: bool = _shooter.is_moving()
	var pre_shot_recoil: float = _runtime.recoil
	var shot_bias_degrees: float = _get_recoil_bias_degrees_for_recoil(pre_shot_recoil)
	var shot_spread_degrees: float = _runtime.get_spread_degrees_for_recoil(
		pre_shot_recoil,
		is_shooter_moving
	)
	if not _runtime.try_fire():
		_emit_reload_transition(was_reloading, _runtime.is_reloading, was_reload_automatic)
		return false
	var aim_direction: Vector2 = _shooter.get_aim_direction()
	var visible_aim_direction: Vector2 = aim_direction.rotated(deg_to_rad(shot_bias_degrees)).normalized()
	var origin: Vector2 = _shooter.global_position + visible_aim_direction * MUZZLE_OFFSET_PIXELS
	var shot_direction: Vector2 = _sample_shot_direction(
		aim_direction,
		shot_bias_degrees,
		shot_spread_degrees
	)
	_last_shot_bias_degrees = shot_bias_degrees
	_last_shot_spread_degrees = shot_spread_degrees
	var maximum_end_position: Vector2 = origin + shot_direction * weapon_definition.range_pixels
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, maximum_end_position)
	var excluded_rids: Array[RID] = [_shooter.get_rid()]
	query.exclude = excluded_rids
	query.collision_mask = ray_collision_mask
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	var did_hit: bool = not result.is_empty()
	var end_position: Vector2 = maximum_end_position
	if did_hit:
		end_position = result.get("position", maximum_end_position) as Vector2
		var collider: Node = result.get("collider") as Node
		var damage_result: Dictionary = _apply_damage(collider, end_position)
		var applied_damage: int = int(damage_result.get("damage", 0))
		if applied_damage > 0:
			hit_confirmed.emit(collider, applied_damage, end_position)
	_feedback.present_shot(origin, end_position, did_hit)
	shot_fired.emit(origin, end_position, did_hit)
	_emit_reload_transition(was_reloading, _runtime.is_reloading, was_reload_automatic)
	return true

func _apply_damage(collider: Node, hit_position: Vector2) -> Dictionary:
	if collider == null:
		return {}
	if collider.has_method("take_hit"):
		var applied_damage: int = int(collider.call("take_hit", weapon_definition.damage, hit_position))
		var knocked_down: bool = collider.has_method("get_is_knocked_down") and bool(collider.call("get_is_knocked_down"))
		return {"hit": applied_damage > 0, "damage": applied_damage, "killed": knocked_down}
	if collider.has_method("apply_damage"):
		var result: Variant = collider.call("apply_damage", float(weapon_definition.damage), hit_position)
		if result is Dictionary:
			return result
	return {}

func _sample_shot_direction(
	aim_direction: Vector2,
	shot_bias_degrees: float,
	shot_spread_degrees: float
) -> Vector2:
	var safe_aim_direction: Vector2 = Vector2.RIGHT if aim_direction.is_zero_approx() else aim_direction.normalized()
	var spread_offset_degrees: float = _spread_sampler.sample_spread(
		shot_spread_degrees,
		0.0,
		false
	)
	var final_offset_degrees: float = shot_bias_degrees + spread_offset_degrees
	return safe_aim_direction.rotated(deg_to_rad(final_offset_degrees))

func _emit_reload_transition(was_reloading: bool, is_reloading: bool, was_automatic: bool) -> void:
	var source_did_change: bool = (
		was_reloading
		and is_reloading
		and was_automatic != get_reload_is_automatic()
	)
	if was_reloading == is_reloading and not source_did_change:
		return
	if was_reloading:
		reload_state_changed.emit(false)
		reload_ended.emit(not source_did_change and get_current_ammo() == get_magazine_size(), was_automatic)
	if is_reloading:
		reload_state_changed.emit(true)
		reload_started.emit(weapon_definition.reload_duration, get_reload_is_automatic())

func _emit_state_if_changed(force: bool = false) -> void:
	var current_ammo: int = get_current_ammo()
	var is_reloading: bool = get_is_reloading()
	var recoil: float = get_recoil()
	var draw_index: int = get_draw_index()
	var spread_degrees: float = get_current_spread_degrees()
	var reload_progress: float = get_reload_progress()
	var reload_is_automatic: bool = get_reload_is_automatic()
	var ammo_did_change: bool = current_ammo != _last_ammo
	var state_did_change: bool = (
		force
		or ammo_did_change
		or is_reloading != _last_is_reloading
		or not is_equal_approx(recoil, _last_recoil)
		or draw_index != _last_draw_index
		or not is_equal_approx(spread_degrees, _last_spread_degrees)
		or not is_equal_approx(reload_progress, _last_reload_progress)
		or reload_is_automatic != _last_reload_is_automatic
	)
	if ammo_did_change or force:
		ammo_changed.emit(current_ammo, get_magazine_size())
	if state_did_change:
		state_changed.emit()
	_last_ammo = current_ammo
	_last_is_reloading = is_reloading
	_last_recoil = recoil
	_last_draw_index = draw_index
	_last_spread_degrees = spread_degrees
	_last_reload_progress = reload_progress
	_last_reload_is_automatic = reload_is_automatic
