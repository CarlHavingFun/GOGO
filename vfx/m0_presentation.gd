extends Node2D
class_name M0Presentation

func show_shot(origin: Vector2, end_point: Vector2, hit: bool, result: Dictionary) -> void:
	var tracer := Line2D.new()
	tracer.width = 3.0
	tracer.default_color = Color("fff3b0") if not hit else Color("ffd166")
	tracer.points = PackedVector2Array([to_local(origin), to_local(end_point)])
	add_child(tracer)
	_fade_and_free(tracer, 0.10)

	var direction: Vector2 = (end_point - origin).normalized()
	var muzzle := Line2D.new()
	muzzle.width = 9.0
	muzzle.default_color = Color("f8961e")
	muzzle.points = PackedVector2Array([to_local(origin), to_local(origin + direction * 24.0)])
	add_child(muzzle)
	_fade_and_free(muzzle, 0.055)

	if hit:
		_spawn_hit_pulse(end_point, bool(result.get("killed", false)))
		if not result.is_empty():
			_spawn_floating_text(
				end_point,
				"DUMMY DOWN" if bool(result.get("killed", false)) else "-%d" % int(result.get("damage", 0.0))
			)

func show_dry_fire(position: Vector2) -> void:
	_spawn_floating_text(position + Vector2(0.0, -34.0), "CLICK")

func show_reload(position: Vector2) -> void:
	_spawn_floating_text(position + Vector2(0.0, -42.0), "RELOAD")

func _spawn_hit_pulse(world_position: Vector2, killed_target: bool) -> void:
	var pulse := Polygon2D.new()
	pulse.polygon = _circle_polygon(8.0, 16)
	pulse.color = Color("06d6a0") if killed_target else Color.WHITE
	pulse.position = to_local(world_position)
	add_child(pulse)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(pulse, "scale", Vector2(2.4, 2.4), 0.14)
	tween.tween_property(pulse, "modulate:a", 0.0, 0.14)
	tween.chain().tween_callback(Callable(pulse, "queue_free"))

func _spawn_floating_text(world_position: Vector2, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.position = to_local(world_position) - Vector2(48.0, 14.0)
	label.size = Vector2(96.0, 28.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("ffffff"))
	add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 28.0, 0.42)
	tween.tween_property(label, "modulate:a", 0.0, 0.42)
	tween.chain().tween_callback(Callable(label, "queue_free"))

func _fade_and_free(node: CanvasItem, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(Callable(node, "queue_free"))

func _circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index: int in range(segments):
		var angle: float = TAU * float(index) / float(segments)
		points.append(Vector2.from_angle(angle) * radius)
	return points
