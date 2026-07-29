class_name CombatFeedback
extends Node2D

const SHOT_LIFETIME_SECONDS: float = 0.10
const MUZZLE_FLASH_LIFETIME_SECONDS: float = 0.045
const HIT_SPARK_RADIUS: float = 8.0

var _shot_effects: Array[Dictionary] = []

func _ready() -> void:
	set_process(false)

func _process(delta_seconds: float) -> void:
	for effect_index: int in range(_shot_effects.size() - 1, -1, -1):
		var effect: Dictionary = _shot_effects[effect_index]
		var remaining_seconds: float = (effect.get("remaining_seconds", 0.0) as float) - delta_seconds
		if remaining_seconds <= 0.0:
			_shot_effects.remove_at(effect_index)
		else:
			effect["remaining_seconds"] = remaining_seconds
	if _shot_effects.is_empty():
		set_process(false)
	queue_redraw()

func present_shot(origin: Vector2, end_position: Vector2, did_hit: bool) -> void:
	var effect: Dictionary = {
		"origin": origin,
		"end_position": end_position,
		"did_hit": did_hit,
		"remaining_seconds": SHOT_LIFETIME_SECONDS,
	}
	_shot_effects.append(effect)
	set_process(true)
	queue_redraw()

func _draw() -> void:
	for effect: Dictionary in _shot_effects:
		var origin: Vector2 = effect.get("origin", Vector2.ZERO) as Vector2
		var end_position: Vector2 = effect.get("end_position", Vector2.ZERO) as Vector2
		var remaining_seconds: float = effect.get("remaining_seconds", 0.0) as float
		var opacity: float = clampf(remaining_seconds / SHOT_LIFETIME_SECONDS, 0.0, 1.0)
		draw_line(origin, end_position, Color(1.0, 0.86, 0.34, opacity), 2.0, true)
		if remaining_seconds > SHOT_LIFETIME_SECONDS - MUZZLE_FLASH_LIFETIME_SECONDS:
			draw_circle(origin, 7.0, Color(1.0, 0.94, 0.55, opacity))
		if effect.get("did_hit", false) as bool:
			var spark_color: Color = Color(1.0, 0.75, 0.24, opacity)
			draw_line(end_position - Vector2(HIT_SPARK_RADIUS, 0.0), end_position + Vector2(HIT_SPARK_RADIUS, 0.0), spark_color, 3.0, true)
			draw_line(end_position - Vector2(0.0, HIT_SPARK_RADIUS), end_position + Vector2(0.0, HIT_SPARK_RADIUS), spark_color, 3.0, true)
