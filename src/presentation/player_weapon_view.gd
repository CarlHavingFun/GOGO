class_name PlayerWeaponView
extends Node2D

const KICK_DECAY_PER_SECOND: float = 15.0
const GUN_COLOR: Color = Color("c7d2df")
const BARREL_COLOR: Color = Color("f2f7ff")
const AIM_LINE_COLOR: Color = Color(0.47, 0.82, 1.0, 0.42)

@export var weapon_controller_path: NodePath

var _weapon_controller: WeaponController
var _shot_kick_strength: float = 0.0

func _ready() -> void:
	_weapon_controller = get_node_or_null(weapon_controller_path) as WeaponController
	if _weapon_controller == null:
		push_error("PlayerWeaponView requires a WeaponController.")
		set_process(false)
		return
	_weapon_controller.shot_fired.connect(_on_shot_fired)
	queue_redraw()

func _process(delta_seconds: float) -> void:
	_shot_kick_strength = maxf(0.0, _shot_kick_strength - KICK_DECAY_PER_SECOND * delta_seconds)
	queue_redraw()

func _on_shot_fired(_origin: Vector2, _end_position: Vector2, _did_hit: bool) -> void:
	_shot_kick_strength = 1.0
	queue_redraw()

func _draw() -> void:
	if _weapon_controller == null:
		return
	var aim_direction: Vector2 = _weapon_controller.get_visual_aim_direction()
	var perpendicular: Vector2 = Vector2(-aim_direction.y, aim_direction.x)
	var sustained_kick: float = _weapon_controller.get_visual_kickback_pixels() * 0.35
	var impulse_kick: float = _weapon_controller.get_maximum_visual_kick_pixels() * 0.65 * _shot_kick_strength
	var receiver_origin: Vector2 = -aim_direction * (sustained_kick + impulse_kick)
	var receiver_polygon: PackedVector2Array = PackedVector2Array([
		receiver_origin - perpendicular * 5.0,
		receiver_origin + perpendicular * 5.0,
		receiver_origin + aim_direction * 24.0 + perpendicular * 4.0,
		receiver_origin + aim_direction * 24.0 - perpendicular * 4.0,
	])
	draw_colored_polygon(receiver_polygon, GUN_COLOR)
	var barrel_start: Vector2 = receiver_origin + aim_direction * 22.0
	var muzzle_position: Vector2 = receiver_origin + aim_direction * 38.0
	draw_line(barrel_start, muzzle_position, BARREL_COLOR, 4.0, true)
	draw_line(muzzle_position - perpendicular * 4.0, muzzle_position + perpendicular * 4.0, BARREL_COLOR, 2.0, true)
	draw_line(muzzle_position, receiver_origin + aim_direction * 105.0, AIM_LINE_COLOR, 1.5, true)
