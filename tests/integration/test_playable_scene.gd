extends RefCounted

const PLAYER_CONTROLLER_PATH: String = "res://src/actors/player_controller.gd"
const PLAYABLE_SCENE_PATH: String = "res://scenes/run/m0_ak_lab.tscn"
const DIAGONAL_COMPONENT: float = 0.70710678
const FLOAT_TOLERANCE: float = 0.0001

func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(PLAYER_CONTROLLER_PATH):
		failures.append("PlayerController is required for playable-scene integration tests.")
	if not ResourceLoader.exists(PLAYABLE_SCENE_PATH):
		failures.append("The M0 AK lab scene is required for playable-scene integration tests.")
	if not failures.is_empty():
		return failures
	var player_script: Script = load(PLAYER_CONTROLLER_PATH) as Script
	var playable_scene: PackedScene = load(PLAYABLE_SCENE_PATH) as PackedScene
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController must parse and instantiate.")
	if playable_scene == null:
		failures.append("The M0 AK lab must load as a PackedScene.")
	if not failures.is_empty():
		return failures
	_test_diagonal_movement_is_normalized(player_script, failures)
	_test_playable_scene_instantiates(playable_scene, failures)
	return failures

func _test_diagonal_movement_is_normalized(player_script: Script, failures: Array[String]) -> void:
	var player: Variant = player_script.new()
	var direction: Vector2 = player.call("normalized_movement_direction", Vector2(1.0, 1.0)) as Vector2
	_assert_float_equal(direction.x, DIAGONAL_COMPONENT, "Diagonal movement X must be normalized.", failures)
	_assert_float_equal(direction.y, DIAGONAL_COMPONENT, "Diagonal movement Y must be normalized.", failures)
	_assert_float_equal(direction.length(), 1.0, "Diagonal movement must not exceed unit length.", failures)
	player.free()

func _test_playable_scene_instantiates(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_instance: Node = playable_scene.instantiate()
	_assert_true(scene_instance != null, "The M0 AK lab must instantiate.", failures)
	scene_instance.free()

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_float_equal(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > FLOAT_TOLERANCE:
		failures.append("%s Expected %.4f, got %.4f." % [message, expected, actual])
