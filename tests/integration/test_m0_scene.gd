extends RefCounted

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	var packed_scene: PackedScene = load("res://run/m0_shooting_toy.tscn") as PackedScene
	_assert_true(packed_scene != null, "M0 scene should load")
	if packed_scene == null:
		return _failures
	var root: Node = packed_scene.instantiate()
	_assert_true(root.get_node_or_null("Player") != null, "M0 scene should contain Player")
	_assert_true(root.get_node_or_null("Player/WeaponController") != null, "Player should contain WeaponController")
	_assert_true(root.get_node_or_null("TargetDummy") != null, "M0 scene should contain TargetDummy")
	_assert_true(root.get_node_or_null("HUD") != null, "M0 scene should contain HUD")
	root.free()
	return _failures

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)
