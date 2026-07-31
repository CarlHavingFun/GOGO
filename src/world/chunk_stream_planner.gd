extends RefCounted
class_name ChunkStreamPlanner

func world_to_chunk(world_position: Vector2, chunk_size: float) -> Vector2i:
	if chunk_size <= 0.0:
		push_error("Chunk size must be greater than zero")
		return Vector2i.ZERO
	return Vector2i(
		floori(world_position.x / chunk_size),
		floori(world_position.y / chunk_size)
	)

func desired_coords(center: Vector2i, radius: int) -> Array[Vector2i]:
	var safe_radius: int = maxi(radius, 0)
	var result: Array[Vector2i] = []
	for x_offset: int in range(-safe_radius, safe_radius + 1):
		for y_offset: int in range(-safe_radius, safe_radius + 1):
			result.append(center + Vector2i(x_offset, y_offset))
	return result

func build_load_queue(
	active_coords: Array[Vector2i],
	center: Vector2i,
	radius: int,
	heading: Vector2
) -> Array[Vector2i]:
	var active_lookup: Dictionary = {}
	for coord: Vector2i in active_coords:
		active_lookup[coord] = true

	var queue: Array[Vector2i] = []
	for coord: Vector2i in desired_coords(center, radius):
		if not active_lookup.has(coord):
			queue.append(coord)

	var normalized_heading: Vector2 = heading.normalized() if heading.length_squared() > 0.0001 else Vector2.ZERO
	queue.sort_custom(func(first: Vector2i, second: Vector2i) -> bool:
		var first_score: float = _priority_score(first, center, normalized_heading)
		var second_score: float = _priority_score(second, center, normalized_heading)
		if not is_equal_approx(first_score, second_score):
			return first_score < second_score
		if first.x != second.x:
			return first.x < second.x
		return first.y < second.y
	)
	return queue

func coords_to_unload(active_coords: Array[Vector2i], center: Vector2i, radius: int) -> Array[Vector2i]:
	var safe_radius: int = maxi(radius, 0)
	var result: Array[Vector2i] = []
	for coord: Vector2i in active_coords:
		if absi(coord.x - center.x) > safe_radius or absi(coord.y - center.y) > safe_radius:
			result.append(coord)
	return result

func _priority_score(coord: Vector2i, center: Vector2i, heading: Vector2) -> float:
	var offset_i: Vector2i = coord - center
	var manhattan_distance: int = absi(offset_i.x) + absi(offset_i.y)
	if offset_i == Vector2i.ZERO or heading == Vector2.ZERO:
		return float(manhattan_distance) * 10.0
	var direction: Vector2 = Vector2(offset_i).normalized()
	var forward_bias: float = direction.dot(heading) * 3.0
	return float(manhattan_distance) * 10.0 - forward_bias
