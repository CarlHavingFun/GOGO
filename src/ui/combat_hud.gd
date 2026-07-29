class_name CombatHUD
extends Control

const FEEDBACK_DURATION_SECONDS: float = 0.85
const READY_COLOR: Color = Color("75f0b3")
const WARNING_COLOR: Color = Color("ffd166")
const DANGER_COLOR: Color = Color("ff5f6d")

@export var weapon_controller_path: NodePath

@onready var _ammo_label: Label = $AmmoPanel/Ammo
@onready var _status_label: Label = $AmmoPanel/Status
@onready var _reload_bar: ProgressBar = $AmmoPanel/ReloadProgress
@onready var _feedback_label: Label = $Feedback
@onready var _debug_label: Label = $DebugPanel/Debug

var _weapon_controller: WeaponController
var _ammo_text: String = ""
var _status_text: String = ""
var _feedback_text: String = ""
var _feedback_remaining_seconds: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weapon_controller = get_node_or_null(weapon_controller_path) as WeaponController
	if _weapon_controller == null:
		push_error("CombatHUD requires a WeaponController.")
		set_process(false)
		return
	_weapon_controller.hit_confirmed.connect(_on_hit_confirmed)
	_weapon_controller.empty_triggered.connect(_on_empty_triggered)
	_weapon_controller.reload_started.connect(_on_reload_started)
	_weapon_controller.reload_ended.connect(_on_reload_ended)
	_refresh_view()

func _process(delta_seconds: float) -> void:
	if _feedback_remaining_seconds > 0.0:
		_feedback_remaining_seconds = maxf(0.0, _feedback_remaining_seconds - delta_seconds)
		if _feedback_remaining_seconds <= 0.0:
			_feedback_text = ""
			_feedback_label.text = ""
	_refresh_view()

func get_ammo_text() -> String:
	return _ammo_text

func get_status_text() -> String:
	return _status_text

func get_feedback_text() -> String:
	return _feedback_text

func _refresh_view() -> void:
	_ammo_text = "%d / ∞" % _weapon_controller.get_current_ammo()
	_status_text = _derive_status_text()
	_ammo_label.text = _ammo_text
	_status_label.text = _status_text
	_status_label.add_theme_color_override("font_color", _get_status_color())
	_reload_bar.visible = _weapon_controller.get_is_reloading()
	_reload_bar.value = _weapon_controller.get_reload_progress() * 100.0
	_debug_label.text = _build_debug_text()

func _derive_status_text() -> String:
	if _weapon_controller.get_is_reloading():
		return "AUTO RELOAD" if _weapon_controller.get_reload_is_automatic() else "MANUAL RELOAD"
	if _weapon_controller.get_current_ammo() == 0:
		return "EMPTY"
	return "READY"

func _get_status_color() -> Color:
	if _status_text == "READY":
		return READY_COLOR
	if _status_text == "EMPTY":
		return DANGER_COLOR
	return WARNING_COLOR

func _build_debug_text() -> String:
	return (
		"FPS  %d\nSEED  %d\nRNG DRAW  %d\nMAG  %d / %d\nRECOIL  %05.1f  %s\nSPREAD  %.2f°"
		% [
			Engine.get_frames_per_second(),
			_weapon_controller.get_combat_seed(),
			_weapon_controller.get_draw_index(),
			_weapon_controller.get_current_ammo(),
			_weapon_controller.get_magazine_size(),
			_weapon_controller.get_recoil(),
			_weapon_controller.get_recoil_state(),
			_weapon_controller.get_current_spread_degrees(),
		]
	)

func _on_hit_confirmed(target: TrainingDummy, damage: int, _hit_position: Vector2) -> void:
	if target.get_is_knocked_down():
		_present_feedback("TARGET DOWN  +%d" % damage)
	else:
		_present_feedback("HIT  +%d" % damage)

func _on_empty_triggered() -> void:
	_present_feedback("EMPTY")

func _on_reload_started(_duration_seconds: float, is_automatic: bool) -> void:
	_present_feedback("AUTO RELOAD" if is_automatic else "MANUAL RELOAD")

func _on_reload_ended(completed: bool, _was_automatic: bool) -> void:
	_present_feedback("RELOAD COMPLETE" if completed else "RELOAD CANCELED")

func _present_feedback(message: String) -> void:
	_feedback_text = message
	_feedback_remaining_seconds = FEEDBACK_DURATION_SECONDS
	_feedback_label.text = message
