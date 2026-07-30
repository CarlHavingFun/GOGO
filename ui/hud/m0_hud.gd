extends CanvasLayer
class_name M0HUD

@onready var fps_label: Label = $DebugPanel/VBox/FPSLabel
@onready var seed_label: Label = $DebugPanel/VBox/SeedLabel
@onready var ammo_label: Label = $DebugPanel/VBox/AmmoLabel
@onready var reload_label: Label = $DebugPanel/VBox/ReloadLabel
@onready var recoil_label: Label = $DebugPanel/VBox/RecoilLabel
@onready var spread_label: Label = $DebugPanel/VBox/SpreadLabel
@onready var status_label: Label = $StatusLabel
@onready var crosshair: Control = $Crosshair
@onready var crosshair_top: ColorRect = $Crosshair/Top
@onready var crosshair_bottom: ColorRect = $Crosshair/Bottom
@onready var crosshair_left: ColorRect = $Crosshair/Left
@onready var crosshair_right: ColorRect = $Crosshair/Right

var _spread_deg: float = 0.0
var _status_lifetime: float = 0.0

func _process(delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	crosshair.position = get_viewport().get_mouse_position()
	_update_crosshair()
	if _status_lifetime > 0.0:
		_status_lifetime = maxf(0.0, _status_lifetime - delta)
		status_label.modulate.a = clampf(_status_lifetime * 2.0, 0.0, 1.0)

func update_weapon_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	seed_label.text = "Seed: %d (T resets)" % int(snapshot.get("seed", 0))
	ammo_label.text = "Ammo: %d / %d" % [
		int(snapshot.get("ammo", 0)),
		int(snapshot.get("magazine_size", 0)),
	]
	var is_reloading: bool = bool(snapshot.get("is_reloading", false))
	var reload_percent: int = int(float(snapshot.get("reload_ratio", 0.0)) * 100.0)
	reload_label.text = "Reload: %s" % ("%d%%" % reload_percent if is_reloading else "READY")
	recoil_label.text = "Recoil: %.1f / 100" % float(snapshot.get("recoil", 0.0))
	_spread_deg = float(snapshot.get("spread_deg", 0.0))
	spread_label.text = "Spread: %.2f°%s" % [
		_spread_deg,
		" + MOVE" if bool(snapshot.get("moving", false)) else "",
	]

func show_feedback(message: String) -> void:
	status_label.text = message
	status_label.modulate.a = 1.0
	_status_lifetime = 1.25

func _update_crosshair() -> void:
	var gap: float = 7.0 + _spread_deg * 3.2
	crosshair_top.position = Vector2(-1.0, -gap - 8.0)
	crosshair_bottom.position = Vector2(-1.0, gap)
	crosshair_left.position = Vector2(-gap - 8.0, -1.0)
	crosshair_right.position = Vector2(gap, -1.0)
