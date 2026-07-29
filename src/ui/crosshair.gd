class_name CombatCrosshair
extends Control

const HIT_MARK_DURATION_SECONDS: float = 0.16
const ARM_LENGTH_PIXELS: float = 9.0
const BASE_GAP_PIXELS: float = 7.0
const SPREAD_TO_GAP_PIXELS: float = 2.6
const STABLE_COLOR: Color = Color("75f0b3")
const BUILDING_COLOR: Color = Color("ffd166")
const MAX_COLOR: Color = Color("ff5f6d")

@export var weapon_controller_path: NodePath

var _weapon_controller: WeaponController
var _hit_mark_remaining_seconds: float = 0.0
var _previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE
var _mouse_mode_was_overridden: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weapon_controller = get_node_or_null(weapon_controller_path) as WeaponController
	if _weapon_controller == null:
		push_error("CombatCrosshair requires a WeaponController.")
		set_process(false)
		return
	_weapon_controller.hit_confirmed.connect(_on_hit_confirmed)
	if DisplayServer.get_name() != "headless":
		_previous_mouse_mode = Input.mouse_mode
		if _previous_mouse_mode != Input.MOUSE_MODE_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			_mouse_mode_was_overridden = true
	queue_redraw()

func _exit_tree() -> void:
	if _mouse_mode_was_overridden:
		Input.mouse_mode = _previous_mouse_mode

func _process(delta_seconds: float) -> void:
	_hit_mark_remaining_seconds = maxf(0.0, _hit_mark_remaining_seconds - delta_seconds)
	queue_redraw()

func get_displayed_spread_degrees() -> float:
	return 0.0 if _weapon_controller == null else _weapon_controller.get_current_spread_degrees()

func get_crosshair_center() -> Vector2:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	if _weapon_controller == null:
		return mouse_position
	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()
	var origin_screen_position: Vector2 = canvas_transform * _weapon_controller.global_position
	var raw_screen_direction: Vector2 = mouse_position - origin_screen_position
	if raw_screen_direction.is_zero_approx():
		raw_screen_direction = Vector2.RIGHT
	return (
		origin_screen_position
		+ raw_screen_direction.rotated(deg_to_rad(_weapon_controller.get_recoil_bias_degrees()))
	)

func _on_hit_confirmed(_target: TrainingDummy, _damage: int, _hit_position: Vector2) -> void:
	_hit_mark_remaining_seconds = HIT_MARK_DURATION_SECONDS
	queue_redraw()

func _draw() -> void:
	if _weapon_controller == null:
		return
	var center: Vector2 = get_crosshair_center()
	var gap: float = BASE_GAP_PIXELS + get_displayed_spread_degrees() * SPREAD_TO_GAP_PIXELS
	var crosshair_color: Color = _get_recoil_color()
	draw_line(center + Vector2(gap, 0.0), center + Vector2(gap + ARM_LENGTH_PIXELS, 0.0), crosshair_color, 2.0, true)
	draw_line(center - Vector2(gap, 0.0), center - Vector2(gap + ARM_LENGTH_PIXELS, 0.0), crosshair_color, 2.0, true)
	draw_line(center + Vector2(0.0, gap), center + Vector2(0.0, gap + ARM_LENGTH_PIXELS), crosshair_color, 2.0, true)
	draw_line(center - Vector2(0.0, gap), center - Vector2(0.0, gap + ARM_LENGTH_PIXELS), crosshair_color, 2.0, true)
	draw_circle(center, 1.75, crosshair_color)
	if _hit_mark_remaining_seconds > 0.0:
		var opacity: float = _hit_mark_remaining_seconds / HIT_MARK_DURATION_SECONDS
		var hit_color: Color = Color(1.0, 1.0, 1.0, opacity)
		draw_line(center + Vector2(-7.0, -7.0), center + Vector2(7.0, 7.0), hit_color, 2.5, true)
		draw_line(center + Vector2(7.0, -7.0), center + Vector2(-7.0, 7.0), hit_color, 2.5, true)

func _get_recoil_color() -> Color:
	match _weapon_controller.get_recoil_state():
		"STABLE":
			return STABLE_COLOR
		"MAX":
			return MAX_COLOR
		_:
			return BUILDING_COLOR
