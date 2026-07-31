extends Node2D
class_name InfiniteChunkManager

signal chunk_loaded(coord: Vector2i, module_id: StringName)
signal chunk_unloaded(coord: Vector2i)

const DesertChunkLayoutScript: Script = preload("res://systems/world/desert_chunk_layout.gd")
const ChunkStreamPlannerScript: Script = preload("res://systems/world/chunk_stream_planner.gd")
const InfiniteDesertChunkScript: Script = preload("res://arenas/infinite_desert/infinite_desert_chunk.gd")

@export var player_path: NodePath = NodePath("../Player")
@export var world_seed: int = 424242
@export var chunk_size: float = 1024.0
@export var active_radius: int = 2
@export var max_chunk_builds_per_frame: int = 1

var _player: Node2D
var _layout: Variant = DesertChunkLayoutScript.new()
var _planner: Variant = ChunkStreamPlannerScript.new()
var _active_chunks: Dictionary = {}
var _load_queue: Array[Vector2i] = []
var _queued_lookup: Dictionary = {}
var _current_center := Vector2i(2147483647, 2147483647)

func _ready() -> void:
	_player = get_node_or_null(player_path) as Node2D
	if _player == null:
		push_error("InfiniteChunkManager could not resolve player_path: %s" % player_path)
		set_process(false)
		return
	_layout.configure(world_seed)
	_refresh_stream()
	_build_next_chunk()

func _process(_delta: float) -> void:
	if _player == null:
		return
	var player_chunk: Vector2i = _planner.world_to_chunk(_player.global_position, chunk_size)
	if player_chunk != _current_center:
		_refresh_stream()

	var build_budget: int = maxi(max_chunk_builds_per_frame, 0)
	for _build_index: int in range(build_budget):
		if not _build_next_chunk():
			break

func force_refresh() -> void:
	if _player != null:
		_refresh_stream()

func get_active_chunk_count() -> int:
	return _active_chunks.size()

func get_active_coords() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for coord: Vector2i in _active_chunks.keys():
		result.append(coord)
	return result

func get_load_queue_size() -> int:
	return _load_queue.size()

func get_current_chunk_coord() -> Vector2i:
	return _current_center

func is_chunk_active(coord: Vector2i) -> bool:
	return _active_chunks.has(coord)

func is_world_position_active(world_position: Vector2) -> bool:
	return is_chunk_active(_planner.world_to_chunk(world_position, chunk_size))

func _refresh_stream() -> void:
	_current_center = _planner.world_to_chunk(_player.global_position, chunk_size)
	var active_coords: Array[Vector2i] = get_active_coords()
	for coord: Vector2i in _planner.coords_to_unload(active_coords, _current_center, active_radius):
		_unload_chunk(coord)

	var heading := Vector2.ZERO
	if _player is CharacterBody2D:
		heading = (_player as CharacterBody2D).velocity
	_load_queue = _planner.build_load_queue(get_active_coords(), _current_center, active_radius, heading)
	_queued_lookup.clear()
	for coord: Vector2i in _load_queue:
		_queued_lookup[coord] = true

func _build_next_chunk() -> bool:
	while not _load_queue.is_empty():
		var coord: Vector2i = _load_queue.pop_front()
		_queued_lookup.erase(coord)
		if _active_chunks.has(coord):
			continue
		if absi(coord.x - _current_center.x) > active_radius or absi(coord.y - _current_center.y) > active_radius:
			continue

		var description: Dictionary = _layout.describe(coord)
		var chunk: Node2D = InfiniteDesertChunkScript.new()
		chunk.call("configure", coord, description, chunk_size)
		add_child(chunk)
		_active_chunks[coord] = chunk
		chunk_loaded.emit(coord, StringName(description.get("module_id", &"")))
		return true
	return false

func _unload_chunk(coord: Vector2i) -> void:
	if not _active_chunks.has(coord):
		return
	var chunk: Node = _active_chunks[coord] as Node
	_active_chunks.erase(coord)
	if chunk != null:
		chunk.queue_free()
	chunk_unloaded.emit(coord)
