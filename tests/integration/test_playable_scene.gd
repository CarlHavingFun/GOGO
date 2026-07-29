extends RefCounted

const PLAYER_CONTROLLER_PATH: String = "res://src/actors/player_controller.gd"
const PLAYABLE_SCENE_PATH: String = "res://scenes/run/m0_ak_lab.tscn"
const DIAGONAL_COMPONENT: float = 0.70710678
const FLOAT_TOLERANCE: float = 0.0001
const PHYSICS_FRAMES_PER_SECOND: int = 60
const EXPECTED_SHOTS_AFTER_ONE_SECOND: int = 9
const EXPECTED_SHOTS_AFTER_TWO_SECONDS: int = 17

var _shot_end_positions: Array[Vector2] = []
var _hit_positions: Array[Vector2] = []
var _hit_damages: Array[int] = []

func run_async() -> Array[String]:
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
	await _test_feedback_presentation_nodes_and_state(playable_scene, failures)
	await _test_held_fire_in_real_scene(playable_scene, failures)
	return failures

func _test_diagonal_movement_is_normalized(player_script: Script, failures: Array[String]) -> void:
	var player: Variant = player_script.new()
	var direction: Vector2 = player.call("normalized_movement_direction", Vector2(1.0, 1.0)) as Vector2
	_assert_float_equal(direction.x, DIAGONAL_COMPONENT, "Diagonal movement X must be normalized.", failures)
	_assert_float_equal(direction.y, DIAGONAL_COMPONENT, "Diagonal movement Y must be normalized.", failures)
	_assert_float_equal(direction.length(), 1.0, "Diagonal movement must not exceed unit length.", failures)
	player.free()

func _test_feedback_presentation_nodes_and_state(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	var scene_instance: Node = playable_scene.instantiate()
	scene_tree.root.add_child(scene_instance)
	await scene_tree.process_frame
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var crosshair: Node = scene_instance.get_node_or_null("Interface/Crosshair")
	var combat_hud: Node = scene_instance.get_node_or_null("Interface/CombatHUD")
	var weapon_view: Node = scene_instance.get_node_or_null("Player/PlayerWeaponView")
	var audio_feedback: Node = scene_instance.get_node_or_null("AudioFeedback")
	_assert_true(crosshair != null, "The real scene must assemble a dedicated Crosshair.", failures)
	_assert_true(combat_hud != null, "The real scene must assemble a dedicated CombatHUD.", failures)
	_assert_true(weapon_view != null, "The real scene must assemble a dedicated PlayerWeaponView.", failures)
	_assert_true(audio_feedback != null, "The real scene must assemble dedicated AudioFeedback.", failures)
	if combat_hud != null:
		_assert_true(combat_hud.has_method("get_ammo_text"), "CombatHUD must expose its rendered ammo state.", failures)
		_assert_true(combat_hud.has_method("get_status_text"), "CombatHUD must expose its rendered combat status.", failures)
		if combat_hud.has_method("get_ammo_text"):
			_assert_equal(combat_hud.call("get_ammo_text"), "30 / ∞", "HUD must render magazine ammo with infinite reserve.", failures)
		if combat_hud.has_method("get_status_text"):
			_assert_equal(combat_hud.call("get_status_text"), "READY", "A loaded idle AK must present READY.", failures)
	if crosshair != null:
		_assert_true(
			crosshair.has_method("get_displayed_spread_degrees"),
			"Crosshair must expose the same final spread used by combat.",
			failures
		)
		if crosshair.has_method("get_displayed_spread_degrees"):
			_assert_float_equal(
				crosshair.call("get_displayed_spread_degrees") as float,
				weapon.get_current_spread_degrees(),
				"Crosshair spread must match WeaponController final spread.",
				failures
			)
	var state: Dictionary = weapon.get_weapon_state()
	_assert_true(state.has("reload_progress"), "Weapon state must expose reload progress to presentation.", failures)
	_assert_true(state.has("reload_is_automatic"), "Weapon state must expose reload source to presentation.", failures)
	_assert_true(state.has("recoil_bias_degrees"), "Weapon state must expose deterministic recoil bias.", failures)
	_assert_true(state.has("recoil_state"), "Weapon state must expose a readable recoil state.", failures)
	scene_instance.queue_free()
	await scene_tree.process_frame

func _test_held_fire_in_real_scene(playable_scene: PackedScene, failures: Array[String]) -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	var scene_instance: Node = playable_scene.instantiate()
	scene_tree.root.add_child(scene_instance)
	await scene_tree.physics_frame
	var player: PlayerController = scene_instance.get_node("Player") as PlayerController
	var weapon: WeaponController = scene_instance.get_node("Player/WeaponController") as WeaponController
	var dummy: TrainingDummy = scene_instance.get_node("DummyCenter") as TrainingDummy
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.set("_aim_direction", Vector2.RIGHT)
	dummy.reset_delay_seconds = 100.0
	weapon.shot_fired.connect(_record_shot)
	weapon.hit_confirmed.connect(_record_hit)
	Input.action_press("fire")
	for _physics_frame: int in range(PHYSICS_FRAMES_PER_SECOND):
		await scene_tree.physics_frame
	_assert_equal(
		_shot_end_positions.size(),
		EXPECTED_SHOTS_AFTER_ONE_SECOND,
		"Held fire at 60 Hz should produce about nine shots in the first second.",
		failures
	)
	for _physics_frame: int in range(PHYSICS_FRAMES_PER_SECOND):
		await scene_tree.physics_frame
	Input.action_release("fire")
	await scene_tree.physics_frame
	_assert_equal(
		_shot_end_positions.size(),
		EXPECTED_SHOTS_AFTER_TWO_SECONDS,
		"Held fire should preserve the 8.5 shots/sec cadence over two seconds.",
		failures
	)
	_assert_equal(
		weapon.get_current_ammo(),
		30 - EXPECTED_SHOTS_AFTER_TWO_SECONDS,
		"Successful real-scene shots must consume matching ammo.",
		failures
	)
	_assert_equal(
		weapon.get_draw_index(),
		EXPECTED_SHOTS_AFTER_TWO_SECONDS,
		"Each successful real-scene shot must consume exactly one spread draw.",
		failures
	)
	_assert_true(dummy.get_current_health() < dummy.max_health, "At least one real ray must damage the dummy.", failures)
	_assert_true(not _hit_positions.is_empty(), "A damaging real ray must emit hit_confirmed.", failures)
	_assert_equal(
		_hit_damages.size(),
		3,
		"Only the three shots that apply 24 damage may emit hit_confirmed before knockdown.",
		failures
	)
	if not _hit_positions.is_empty() and not _shot_end_positions.is_empty():
		_assert_true(
			_hit_positions[0].is_equal_approx(_shot_end_positions[0]),
			"shot_fired and hit_confirmed must expose the same first-shot endpoint.",
			failures
		)
	var damage_after_knockdown: int = dummy.take_hit(24, dummy.global_position)
	_assert_equal(
		damage_after_knockdown,
		0,
		"take_hit must report zero actual damage while the dummy is knocked down.",
		failures
	)
	for _physics_frame: int in range(PHYSICS_FRAMES_PER_SECOND):
		await scene_tree.physics_frame
	var shots_before_restart: int = _shot_end_positions.size()
	Input.action_press("fire")
	await scene_tree.physics_frame
	Input.action_release("fire")
	await scene_tree.physics_frame
	_assert_equal(
		_shot_end_positions.size(),
		shots_before_restart + 1,
		"Stopped fire must not bank negative cooldown and burst on restart.",
		failures
	)
	for _physics_frame: int in range(8):
		await scene_tree.physics_frame
	Input.action_press("reload")
	await scene_tree.physics_frame
	Input.action_release("reload")
	await scene_tree.physics_frame
	_assert_true(weapon.get_is_reloading(), "Reload input must start a partial-magazine reload.", failures)
	var shots_before_reload_cancel: int = _shot_end_positions.size()
	Input.action_press("fire")
	await scene_tree.physics_frame
	Input.action_release("fire")
	await scene_tree.physics_frame
	_assert_equal(
		_shot_end_positions.size(),
		shots_before_reload_cancel + 1,
		"Fire input must cancel a non-empty reload and shoot when cadence allows.",
		failures
	)
	_assert_true(not weapon.get_is_reloading(), "Cancelling fire must leave reload state.", failures)
	Input.action_release("fire")
	Input.action_release("reload")
	for _audio_cleanup_frame: int in range(15):
		await scene_tree.physics_frame
	scene_instance.queue_free()
	await scene_tree.process_frame

func _record_shot(_origin: Vector2, end_position: Vector2, _did_hit: bool) -> void:
	_shot_end_positions.append(end_position)

func _record_hit(_target: TrainingDummy, damage: int, hit_position: Vector2) -> void:
	_hit_damages.append(damage)
	_hit_positions.append(hit_position)

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _assert_float_equal(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > FLOAT_TOLERANCE:
		failures.append("%s Expected %.4f, got %.4f." % [message, expected, actual])
