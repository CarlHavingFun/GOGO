extends Node2D
class_name M0RunRoot

@onready var player: PlayerController = $Player
@onready var weapon_controller: WeaponController = $Player/WeaponController
@onready var dummy: TargetDummy = $TargetDummy
@onready var presentation: M0Presentation = $Presentation
@onready var hud: M0HUD = $HUD

func _ready() -> void:
	weapon_controller.shot_resolved.connect(_on_shot_resolved)
	weapon_controller.weapon_state_changed.connect(hud.update_weapon_state)
	weapon_controller.dry_fired.connect(_on_dry_fired)
	weapon_controller.reload_started.connect(_on_reload_started)
	weapon_controller.feedback_requested.connect(hud.show_feedback)
	dummy.damaged.connect(_on_dummy_damaged)
	dummy.killed.connect(_on_dummy_killed)
	hud.update_weapon_state(weapon_controller.get_snapshot())
	queue_redraw()

func _draw() -> void:
	var arena := Rect2(32.0, 32.0, 1216.0, 656.0)
	draw_rect(arena, Color("18202b"), true)
	for x: int in range(64, 1248, 64):
		draw_line(Vector2(x, 32.0), Vector2(x, 688.0), Color(0.18, 0.23, 0.30, 0.55), 1.0)
	for y: int in range(64, 688, 64):
		draw_line(Vector2(32.0, y), Vector2(1248.0, y), Color(0.18, 0.23, 0.30, 0.55), 1.0)
	draw_rect(arena, Color("8ecae6"), false, 4.0)

func _on_shot_resolved(origin: Vector2, end_point: Vector2, hit: bool, result: Dictionary) -> void:
	presentation.show_shot(origin, end_point, hit, result)

func _on_dry_fired() -> void:
	presentation.show_dry_fire(player.global_position)
	hud.show_feedback("EMPTY — AUTO RELOAD")

func _on_reload_started() -> void:
	presentation.show_reload(player.global_position)

func _on_dummy_damaged(result: Dictionary) -> void:
	if not bool(result.get("killed", false)):
		hud.show_feedback("HIT %d  |  HP %d" % [
			int(result.get("damage", 0.0)),
			int(result.get("remaining_health", 0.0)),
		])

func _on_dummy_killed(_result: Dictionary) -> void:
	hud.show_feedback("DUMMY DOWN — RESPAWN 1.0s")
