class_name TrainingDummy
extends StaticBody2D

signal hit_taken(damage: int, hit_position: Vector2, remaining_health: int)
signal knocked_down()
signal reset_completed()

const HIT_FLASH_DURATION_SECONDS: float = 0.10

@export var max_health: int = 72
@export var reset_delay_seconds: float = 1.25

var current_health: int = 72
var is_knocked_down: bool = false
var _hit_flash_remaining_seconds: float = 0.0
var _reset_remaining_seconds: float = 0.0
var _last_hit_local_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_health = max_health
	queue_redraw()

func _process(delta_seconds: float) -> void:
	_hit_flash_remaining_seconds = maxf(0.0, _hit_flash_remaining_seconds - delta_seconds)
	if is_knocked_down:
		_reset_remaining_seconds -= delta_seconds
		if _reset_remaining_seconds <= 0.0:
			_reset_dummy()
	queue_redraw()

func take_hit(damage: int, hit_position: Vector2) -> int:
	if is_knocked_down:
		return 0
	var applied_damage: int = mini(current_health, maxi(0, damage))
	if applied_damage == 0:
		return 0
	current_health -= applied_damage
	_last_hit_local_position = to_local(hit_position)
	_hit_flash_remaining_seconds = HIT_FLASH_DURATION_SECONDS
	hit_taken.emit(applied_damage, hit_position, current_health)
	if current_health == 0:
		is_knocked_down = true
		_reset_remaining_seconds = reset_delay_seconds
		knocked_down.emit()
	queue_redraw()
	return applied_damage

func get_current_health() -> int:
	return current_health

func get_is_knocked_down() -> bool:
	return is_knocked_down

func _reset_dummy() -> void:
	current_health = max_health
	is_knocked_down = false
	_reset_remaining_seconds = 0.0
	_last_hit_local_position = Vector2.ZERO
	reset_completed.emit()

func _draw() -> void:
	var body_color: Color = Color("ff646f") if _hit_flash_remaining_seconds > 0.0 else Color("e2a24c")
	if is_knocked_down:
		draw_rect(Rect2(-38.0, -8.0, 76.0, 16.0), body_color, true)
		draw_line(Vector2(-42.0, 10.0), Vector2(42.0, 10.0), Color("733e2c"), 4.0, true)
		return
	draw_circle(Vector2(0.0, -30.0), 14.0, body_color)
	draw_rect(Rect2(-16.0, -16.0, 32.0, 56.0), body_color, true)
	draw_line(Vector2(-16.0, 40.0), Vector2(-24.0, 55.0), Color("733e2c"), 5.0, true)
	draw_line(Vector2(16.0, 40.0), Vector2(24.0, 55.0), Color("733e2c"), 5.0, true)
	if _hit_flash_remaining_seconds > 0.0:
		draw_circle(_last_hit_local_position, 6.0, Color("fff3b0"))
