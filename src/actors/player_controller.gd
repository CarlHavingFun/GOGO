class_name PlayerController
extends CharacterBody2D

signal aim_direction_changed(direction: Vector2)

const MOVE_SPEED_PIXELS_PER_SECOND: float = 300.0
const BODY_RADIUS: float = 18.0

var _aim_direction: Vector2 = Vector2.RIGHT

func _physics_process(_delta_seconds: float) -> void:
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = normalized_movement_direction(raw_input) * MOVE_SPEED_PIXELS_PER_SECOND
	move_and_slide()
	_update_aim_direction()
	queue_redraw()

func normalized_movement_direction(raw_input: Vector2) -> Vector2:
	return raw_input.limit_length(1.0)

func get_aim_direction() -> Vector2:
	return _aim_direction

func is_moving() -> bool:
	return velocity.length_squared() > 0.01

func _update_aim_direction() -> void:
	var next_direction: Vector2 = global_position.direction_to(get_global_mouse_position())
	if next_direction.is_zero_approx() or next_direction.is_equal_approx(_aim_direction):
		return
	_aim_direction = next_direction
	aim_direction_changed.emit(_aim_direction)

func _draw() -> void:
	draw_circle(Vector2.ZERO, BODY_RADIUS, Color("55b7ff"))
	draw_arc(Vector2.ZERO, BODY_RADIUS, 0.0, TAU, 32, Color("d9f2ff"), 2.0, true)
	draw_line(Vector2.ZERO, _aim_direction * 34.0, Color("f2f7ff"), 7.0, true)
