extends CharacterBody2D
class_name PlayerController

@export var movement_speed: float = 300.0
@export var clamp_to_arena: bool = true
@export var arena_bounds := Rect2(48.0, 48.0, 1184.0, 624.0)

var aim_direction := Vector2.RIGHT
var _moving: bool = false

func _ready() -> void:
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * movement_speed
	_moving = input_vector.length_squared() > 0.0001
	move_and_slide()
	if clamp_to_arena:
		global_position.x = clampf(global_position.x, arena_bounds.position.x, arena_bounds.end.x)
		global_position.y = clampf(global_position.y, arena_bounds.position.y, arena_bounds.end.y)

	var aim_delta: Vector2 = get_global_mouse_position() - global_position
	if aim_delta.length_squared() > 0.0001:
		aim_direction = aim_delta.normalized()
		rotation = aim_direction.angle()
	queue_redraw()

func is_moving() -> bool:
	return _moving

func get_aim_direction() -> Vector2:
	return aim_direction

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color("5aa9e6"))
	draw_circle(Vector2.ZERO, 18.0, Color("d9f0ff"), false, 2.0)
	draw_line(Vector2.ZERO, Vector2(32.0, 0.0), Color("f6bd60"), 6.0, true)
	draw_circle(Vector2(32.0, 0.0), 4.0, Color("fff3b0"))
