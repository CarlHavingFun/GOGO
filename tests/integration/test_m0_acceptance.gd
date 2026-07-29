extends RefCounted

const PLAYABLE_SCENE_PATH: String = "res://scenes/run/m0_ak_lab.tscn"
const PHYSICS_FPS: int = 60
const MAGAZINE_SIZE: int = 30
const RELOAD_DURATION_SECONDS: float = 2.2
const DETERMINISM_SHOT_COUNT: int = 6
const FLOAT_TOLERANCE: float = 0.0001

var _recorded_endpoints: Array[Vector2] = []
var _recorded_biases: Array[float] = []
var _recorded_spreads: Array[float] = []
var _recorded_damages: Array[int] = []

func run_async() -> Array[String]:
	var failures: Array[String] = []
	var playable_scene: PackedScene = load(PLAYABLE_SCENE_PATH) as PackedScene
	if playable_scene == null:
		failures.append("The M0 AK lab scene must load for acceptance coverage.")
		return failures
	await _test_empty_magazine_auto_reload_hud(playable_scene, failures)
	await _test_manual_reload_cancellation_hud(playable_scene, failures)
	await _test_real_hit_and_knockdown_hud(playable_scene, failures)
	await _test_fresh_scene_seed_determinism(playable_scene, failures)
	return failures

func _test_empty_magazine_auto_reload_hud(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_instance: Node = await _spawn_scene(playable_scene)
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var hud: CombatHUD = scene_instance.get_node("Interface/CombatHUD") as CombatHUD
	var player: PlayerController = scene_instance.get_node("Player") as PlayerController
	_configure_stationary_aim(player, Vector2.UP)
	Input.action_press("fire")
	for _physics_frame: int in range(PHYSICS_FPS * 5):
		await _physics_frame()
		if weapon.get_draw_index() == MAGAZINE_SIZE:
			break
	Input.action_release("fire")
	await _process_frame()
	_assert_equal(weapon.get_draw_index(), MAGAZINE_SIZE, "A held trigger must commit all 30 rounds before auto reload.", failures)
	_assert_equal(weapon.get_current_ammo(), 0, "The 30th round must leave the magazine visibly empty.", failures)
	_assert_true(weapon.get_is_reloading(), "The 30th round must immediately start automatic reload.", failures)
	_assert_true(weapon.get_reload_is_automatic(), "The empty-magazine reload source must be automatic.", failures)
	_assert_equal(hud.get_ammo_text(), "0 / ∞", "HUD must visibly show the empty magazine during auto reload.", failures)
	_assert_equal(hud.get_status_text(), "AUTO RELOAD", "HUD must visibly identify automatic reload.", failures)
	_assert_equal(hud.get_feedback_text(), "AUTO RELOAD", "HUD feedback must announce automatic reload.", failures)
	for _physics_frame: int in range(ceili(RELOAD_DURATION_SECONDS * PHYSICS_FPS) + 2):
		await _physics_frame()
	await _process_frame()
	_assert_equal(weapon.get_current_ammo(), MAGAZINE_SIZE, "Auto reload must refill the magazine after 2.2 seconds.", failures)
	_assert_true(not weapon.get_is_reloading(), "Auto reload must finish after 2.2 seconds.", failures)
	_assert_equal(hud.get_ammo_text(), "30 / ∞", "HUD must show a refilled magazine after auto reload.", failures)
	_assert_equal(hud.get_feedback_text(), "RELOAD COMPLETE", "HUD must confirm completed auto reload.", failures)
	await _cleanup_scene(scene_instance)

func _test_manual_reload_cancellation_hud(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_instance: Node = await _spawn_scene(playable_scene)
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var hud: CombatHUD = scene_instance.get_node("Interface/CombatHUD") as CombatHUD
	var player: PlayerController = scene_instance.get_node("Player") as PlayerController
	_configure_stationary_aim(player, Vector2.UP)
	await _tap_action(&"fire")
	for _physics_frame: int in range(8):
		await _physics_frame()
	await _tap_action(&"reload")
	await _process_frame()
	_assert_true(weapon.get_is_reloading(), "R must start a reload when the magazine is non-empty.", failures)
	_assert_true(not weapon.get_reload_is_automatic(), "R reload must be marked manual.", failures)
	_assert_equal(hud.get_status_text(), "MANUAL RELOAD", "HUD must visibly identify manual reload.", failures)
	_assert_equal(hud.get_feedback_text(), "MANUAL RELOAD", "HUD feedback must announce manual reload.", failures)
	var draw_index_before_cancel: int = weapon.get_draw_index()
	await _tap_action(&"fire")
	await _process_frame()
	_assert_true(not weapon.get_is_reloading(), "Fire must cancel a manual reload while the magazine is non-empty.", failures)
	_assert_equal(weapon.get_draw_index(), draw_index_before_cancel + 1, "The cancelling fire input must still commit a shot.", failures)
	_assert_equal(hud.get_feedback_text(), "RELOAD CANCELED", "HUD must report a canceled manual reload.", failures)
	await _cleanup_scene(scene_instance)

func _test_real_hit_and_knockdown_hud(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_instance: Node = await _spawn_scene(playable_scene)
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var hud: CombatHUD = scene_instance.get_node("Interface/CombatHUD") as CombatHUD
	var player: PlayerController = scene_instance.get_node("Player") as PlayerController
	var dummy: TrainingDummy = scene_instance.get_node("DummyCenter") as TrainingDummy
	_configure_stationary_aim(player, Vector2.RIGHT)
	_recorded_damages.clear()
	weapon.hit_confirmed.connect(_record_damage)
	for shot_index: int in range(3):
		await _tap_action(&"fire")
		await _process_frame()
		if shot_index == 0:
			_assert_equal(hud.get_feedback_text(), "HIT  +24", "HUD must use the actual first-hit damage.", failures)
		for _physics_frame: int in range(8):
			await _physics_frame()
	_assert_equal(_recorded_damages.size(), 3, "Three real center-target hits must emit actual damage.", failures)
	if not _recorded_damages.is_empty():
		_assert_equal(_recorded_damages[0], 24, "A real hit must report the AK's actual 24 damage.", failures)
	_assert_true(dummy.get_is_knocked_down(), "Three real 24-damage hits must knock the 72-health target down.", failures)
	_assert_equal(hud.get_feedback_text(), "TARGET DOWN  +24", "HUD must visibly report the final damaging knockdown hit.", failures)
	await _cleanup_scene(scene_instance)

func _test_fresh_scene_seed_determinism(playable_scene: PackedScene, failures: Array[String]) -> void:
	var first_sequence: Dictionary = await _record_seeded_sequence(playable_scene)
	var second_sequence: Dictionary = await _record_seeded_sequence(playable_scene)
	var first_endpoints: Array[Vector2] = first_sequence["endpoints"] as Array[Vector2]
	var second_endpoints: Array[Vector2] = second_sequence["endpoints"] as Array[Vector2]
	var first_biases: Array[float] = first_sequence["biases"] as Array[float]
	var second_biases: Array[float] = second_sequence["biases"] as Array[float]
	var first_spreads: Array[float] = first_sequence["spreads"] as Array[float]
	var second_spreads: Array[float] = second_sequence["spreads"] as Array[float]
	_assert_equal(first_endpoints.size(), DETERMINISM_SHOT_COUNT, "The first fresh scene must record the requested deterministic shot count.", failures)
	_assert_equal(second_endpoints.size(), DETERMINISM_SHOT_COUNT, "The second fresh scene must record the requested deterministic shot count.", failures)
	_assert_equal(first_sequence["draw_index"], DETERMINISM_SHOT_COUNT, "The first sequence must consume one RNG draw per shot.", failures)
	_assert_equal(second_sequence["draw_index"], DETERMINISM_SHOT_COUNT, "The second sequence must consume one RNG draw per shot.", failures)
	for shot_index: int in range(mini(first_endpoints.size(), second_endpoints.size())):
		_assert_vector_equal(first_endpoints[shot_index], second_endpoints[shot_index], "Matching seed and input must reproduce endpoint %d." % (shot_index + 1), failures)
		_assert_float_equal(first_biases[shot_index], second_biases[shot_index], "Matching seed and input must reproduce last-shot bias %d." % (shot_index + 1), failures)
		_assert_float_equal(first_spreads[shot_index], second_spreads[shot_index], "Matching seed and input must reproduce last-shot spread %d." % (shot_index + 1), failures)

func _record_seeded_sequence(playable_scene: PackedScene) -> Dictionary:
	var scene_instance: Node = await _spawn_scene(playable_scene)
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var player: PlayerController = scene_instance.get_node("Player") as PlayerController
	_configure_stationary_aim(player, Vector2.RIGHT)
	_recorded_endpoints.clear()
	_recorded_biases.clear()
	_recorded_spreads.clear()
	weapon.shot_fired.connect(_record_seeded_shot.bind(weapon))
	Input.action_press("fire")
	for _physics_frame: int in range(PHYSICS_FPS):
		await _physics_frame()
		if _recorded_endpoints.size() == DETERMINISM_SHOT_COUNT:
			break
	Input.action_release("fire")
	var sequence: Dictionary = {
		"endpoints": _recorded_endpoints.duplicate(),
		"biases": _recorded_biases.duplicate(),
		"spreads": _recorded_spreads.duplicate(),
		"draw_index": weapon.get_draw_index(),
	}
	await _cleanup_scene(scene_instance)
	return sequence

func _record_damage(_target: TrainingDummy, damage: int, _hit_position: Vector2) -> void:
	_recorded_damages.append(damage)

func _record_seeded_shot(_origin: Vector2, endpoint: Vector2, _did_hit: bool, weapon: WeaponController) -> void:
	_recorded_endpoints.append(endpoint)
	_recorded_biases.append(weapon.get_last_shot_bias_degrees())
	_recorded_spreads.append(weapon.get_last_shot_spread_degrees())

func _spawn_scene(playable_scene: PackedScene) -> Node:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	var scene_instance: Node = playable_scene.instantiate()
	scene_tree.root.add_child(scene_instance)
	await scene_tree.physics_frame
	return scene_instance

func _configure_stationary_aim(player: PlayerController, aim_direction: Vector2) -> void:
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.set("_aim_direction", aim_direction)

func _cleanup_scene(scene_instance: Node) -> void:
	Input.action_release("fire")
	Input.action_release("reload")
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	for _audio_cleanup_frame: int in range(15):
		await scene_tree.physics_frame
	scene_instance.queue_free()
	await scene_tree.process_frame

func _physics_frame() -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	await scene_tree.physics_frame

func _process_frame() -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	await scene_tree.process_frame

func _tap_action(action_name: StringName) -> void:
	Input.action_press(action_name)
	await _physics_frame()
	await _process_frame()
	Input.action_release(action_name)
	await _physics_frame()

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _assert_float_equal(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > FLOAT_TOLERANCE:
		failures.append("%s Expected %.4f, got %.4f." % [message, expected, actual])

func _assert_vector_equal(actual: Vector2, expected: Vector2, message: String, failures: Array[String]) -> void:
	if not actual.is_equal_approx(expected):
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])
