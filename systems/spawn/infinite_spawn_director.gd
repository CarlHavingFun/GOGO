extends Node2D
class_name InfiniteSpawnDirector

signal enemy_spawned(enemy: Node)
signal enemy_recycled(enemy: Node, reason: StringName)

const SpawnRingSamplerScript: Script = preload("res://systems/spawn/spawn_ring_sampler.gd")
const PrototypeChaserScript: Script = preload("res://entities/enemies/prototype_chaser.gd")

@export var player_path: NodePath = NodePath("../Player")
@export var chunk_manager_path: NodePath = NodePath("../ChunkManager")
@export var world_seed: int = 424242
@export var minimum_spawn_distance: float = 850.0
@export var maximum_spawn_distance: float = 1250.0
@export var recycle_distance: float = 2100.0
@export var spawn_interval_sec: float = 0.75
@export var maximum_active_enemies: int = 24
@export var prewarm_count: int = 8
@export var candidate_attempts: int = 12
@export var visibility_margin: float = 80.0

var deferred_spawn_count: int = 0

var _player: Node2D
var _chunk_manager: Node
var _sampler: Variant = SpawnRingSamplerScript.new()
var _active_enemies: Array[Node] = []
var _pooled_enemies: Array[Node] = []
var _spawn_timer: float = 0.0
var _sample_index: int = 0

func _ready() -> void:
	_player = get_node_or_null(player_path) as Node2D
	_chunk_manager = get_node_or_null(chunk_manager_path)
	if _player == null or _chunk_manager == null:
		push_error("InfiniteSpawnDirector requires valid player_path and chunk_manager_path")
		set_process(false)
		return
	_sampler.configure(world_seed)
	for _index: int in range(maxi(prewarm_count, 0)):
		_pooled_enemies.append(_create_enemy())

func _process(delta: float) -> void:
	if _player == null:
		return
	_recycle_distant_enemies()
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = maxf(spawn_interval_sec, 0.05)
	if _active_enemies.size() >= maxi(maximum_active_enemies, 0):
		return
	_try_spawn_enemy()

func active_enemy_count() -> int:
	return _active_enemies.size()

func pooled_enemy_count() -> int:
	return _pooled_enemies.size()

func _try_spawn_enemy() -> void:
	for _attempt: int in range(maxi(candidate_attempts, 1)):
		var candidate: Vector2 = _sampler.sample(
			_player.global_position,
			_sample_index,
			minimum_spawn_distance,
			maximum_spawn_distance
		)
		_sample_index += 1
		if not bool(_chunk_manager.call("is_world_position_active", candidate)):
			continue
		if _candidate_is_visible(candidate):
			continue
		if _candidate_hits_terrain(candidate):
			continue

		var enemy: Node = _acquire_enemy()
		enemy.call("activate", candidate, _player)
		_active_enemies.append(enemy)
		enemy_spawned.emit(enemy)
		return
	deferred_spawn_count += 1

func _candidate_is_visible(candidate: Vector2) -> bool:
	var viewport_size: Vector2 = get_viewport_rect().size
	var half_extent: Vector2 = viewport_size * 0.5 + Vector2.ONE * visibility_margin
	var visible_rect := Rect2(_player.global_position - half_extent, half_extent * 2.0)
	return visible_rect.has_point(candidate)

func _candidate_hits_terrain(candidate: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = candidate
	query.collision_mask = 4
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()

func _create_enemy() -> Node:
	var enemy: Node = PrototypeChaserScript.new()
	enemy.name = "PrototypeChaser_%d" % get_child_count()
	add_child(enemy)
	enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))
	enemy.call("deactivate")
	return enemy

func _acquire_enemy() -> Node:
	if _pooled_enemies.is_empty():
		return _create_enemy()
	return _pooled_enemies.pop_back()

func _recycle_distant_enemies() -> void:
	for index: int in range(_active_enemies.size() - 1, -1, -1):
		var enemy: Node = _active_enemies[index]
		if enemy == null or not is_instance_valid(enemy):
			_active_enemies.remove_at(index)
			continue
		var enemy_2d: Node2D = enemy as Node2D
		if enemy_2d == null or enemy_2d.global_position.distance_to(_player.global_position) <= recycle_distance:
			continue
		_active_enemies.remove_at(index)
		_return_to_pool(enemy, &"distance")

func _on_enemy_defeated(enemy: Node, _result: Dictionary) -> void:
	if not _active_enemies.has(enemy):
		return
	_active_enemies.erase(enemy)
	_return_to_pool(enemy, &"defeated")

func _return_to_pool(enemy: Node, reason: StringName) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	enemy.call("deactivate")
	if not _pooled_enemies.has(enemy):
		_pooled_enemies.append(enemy)
	enemy_recycled.emit(enemy, reason)
