extends StaticBody2D
class_name TargetDummy

signal damaged(result: Dictionary)
signal killed(result: Dictionary)

@export var max_health: float = 120.0
@export var respawn_sec: float = 1.0

var health: float = 120.0
var alive: bool = true
var _flash: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	queue_redraw()

func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 7.0)
		queue_redraw()

func apply_damage(amount: float, hit_position: Vector2) -> Dictionary:
	if not alive:
		return {
			"hit": false,
			"killed": false,
			"damage": 0.0,
			"remaining_health": 0.0,
			"position": hit_position,
		}

	var applied_damage: float = maxf(amount, 0.0)
	health = maxf(0.0, health - applied_damage)
	_flash = 1.0
	var was_killed: bool = health <= 0.0
	var result := {
		"hit": true,
		"killed": was_killed,
		"damage": applied_damage,
		"remaining_health": health,
		"position": hit_position,
	}
	damaged.emit(result)
	if was_killed:
		alive = false
		collision_shape.set_deferred("disabled", true)
		modulate.a = 0.22
		killed.emit(result)
		_respawn_after_delay()
	queue_redraw()
	return result

func _respawn_after_delay() -> void:
	await get_tree().create_timer(respawn_sec).timeout
	health = max_health
	alive = true
	modulate.a = 1.0
	collision_shape.set_deferred("disabled", false)
	queue_redraw()

func _draw() -> void:
	var body_color := Color("ef476f")
	if _flash > 0.0:
		body_color = body_color.lerp(Color.WHITE, _flash)
	draw_rect(Rect2(-28.0, -44.0, 56.0, 88.0), body_color, true)
	draw_rect(Rect2(-28.0, -44.0, 56.0, 88.0), Color("ffd6e0"), false, 3.0)
	draw_circle(Vector2(0.0, -12.0), 10.0, Color("2b2d42"))
	draw_line(Vector2(-14.0, 18.0), Vector2(14.0, 18.0), Color("2b2d42"), 4.0)

	var bar_rect := Rect2(-32.0, -58.0, 64.0, 7.0)
	draw_rect(bar_rect, Color(0.08, 0.09, 0.12, 0.9), true)
	var ratio: float = health / max_health if max_health > 0.0 else 0.0
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), Color("06d6a0"), true)
