extends RefCounted

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	var packed_scene: PackedScene = load("res://scenes/run/infinite_desert_prototype.tscn") as PackedScene
	_assert_true(packed_scene != null, "infinite desert scene should load")
	if packed_scene == null:
		return _failures

	var root: Node = packed_scene.instantiate()
	var player: Node = root.get_node_or_null("Player")
	var weapon: Node = root.get_node_or_null("Player/WeaponController")
	_assert_true(player != null, "infinite desert scene should contain Player")
	_assert_true(root.get_node_or_null("Player/Camera2D") != null, "Player should contain Camera2D")
	_assert_true(weapon != null, "Player should contain WeaponController")
	_assert_true(root.get_node_or_null("ChunkManager") != null, "scene should contain ChunkManager")
	_assert_true(root.get_node_or_null("SpawnDirector") != null, "scene should contain SpawnDirector")
	_assert_true(root.get_node_or_null("CombatFeedback") != null, "scene should contain CombatFeedback")
	_assert_true(root.get_node_or_null("Interface/CombatHUD") != null, "scene should contain CombatHUD")
	if weapon != null:
		_assert_equal(int(weapon.get("ray_collision_mask")), 6, "infinite desert weapon should hit enemies and Terrain")
	root.free()
	return _failures

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	test_count += 1
	if actual != expected:
		_failures.append("%s (expected=%s actual=%s)" % [message, str(expected), str(actual)])
