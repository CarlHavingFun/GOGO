extends CharacterBody2D
class_name PrototypeChaser

signal defeated(enemy: Node, result: Dictionary)

@export var movement_speed: float = 105.0
@export var max_health: float = 72.0

var health: float = 72.0
var is_active: bool = false
var _target: Node2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 4
	_ensure_collision_shape()
	deactivate()
	queue_redraw()

func activate(spawn_position: Vector2, target_node: Node2D) -> void:
	global_position = spawn_position
	_target = target_node
	health = max_health
	is_active = true
	visible = true
	collision_layer = 2
	collision_mask = 4
	velocity = Vector2.ZERO
	set_physics_process(true)
	queue_redraw()

func deactivate() -> void:
	is_active = false
	visible = false
	collision_layer = 0
	velocity = Vector2.ZERO
	_target = null
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if not is_active:
		return
	if _target == null or not is_instance_valid(_target):
		deactivate()
		return
	var delta_to_target: Vector2 = _target.global_position - global_position
	if delta_to_target.length_squared() <= 36.0 * 36.0:
		velocity = Vector2.ZERO
	else:
		velocity = delta_to_target.normalized() * movement_speed
	move_and_slide()
	if velocity.length_squared() > 0.0001:
		rotation = velocity.angle()

func apply_damage(amount: float, hit_position: Vector2) -> Dictionary:
	if not is_active:
		return {
			"hit": false,
			"killed": false,
			"damage": 0.0,
			"remaining_health": 0.0,
			"position": hit_position,
		}

	var applied_damage: float = maxf(amount, 0.0)
	health = maxf(0.0, health - applied_damage)
	var was_killed: bool = health <= 0.0
	var result := {
		"hit": true,
		"killed": was_killed,
		"damage": applied_damage,
		"remaining_health": health,
		"position": hit_position,
	}
	if was_killed:
		deactivate()
		defeated.emit(self, result)
	else:
		queue_redraw()
	return result

func _ensure_collision_shape() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision_shape := CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = 18.0
	collision_shape.shape = circle_shape
	add_child(collision_shape)

func _draw() -> void:
	var body_color := Color("ef476f")
	if max_health > 0.0:
		body_color = body_color.lerp(Color("ffd166"), 1.0 - health / max_health)
	draw_circle(Vector2.ZERO, 18.0, body_color)
	draw_circle(Vector2.ZERO, 18.0, Color("ffd6e0"), false, 3.0)
	draw_line(Vector2(-8.0, -6.0), Vector2(8.0, -6.0), Color("2b2d42"), 3.0)
	draw_line(Vector2.ZERO, Vector2(24.0, 0.0), Color("2b2d42"), 4.0)
