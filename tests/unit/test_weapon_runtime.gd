extends RefCounted

const AK_PATH: String = "res://data/weapons/ak.tres"
const RUNTIME_PATH: String = "res://src/combat/weapon_runtime.gd"
const WEAPON_DEF_PATH: String = "res://data/weapons/weapon_def.gd"
const FLOAT_TOLERANCE: float = 0.0001

func run() -> Array[String]:
	var failures: Array[String] = []
	var weapon_def_script: Script = load(WEAPON_DEF_PATH) as Script
	var runtime_script: Script = load(RUNTIME_PATH) as Script
	var ak_definition: Resource = load(AK_PATH) as Resource
	if weapon_def_script == null:
		failures.append("WeaponDef script is required for weapon runtime behavior tests.")
	if runtime_script == null:
		failures.append("WeaponRuntime script is required for weapon runtime behavior tests.")
	elif not runtime_script.can_instantiate():
		failures.append("WeaponRuntime script must parse and instantiate for behavior tests.")
	if ak_definition == null:
		failures.append("AK weapon Resource is required for weapon runtime behavior tests.")
	if not failures.is_empty():
		return failures
	_test_ak_design_values(ak_definition, failures)
	_test_successful_fire_consumes_one_round(runtime_script, ak_definition, failures)
	_test_manual_reload_refills_a_partially_empty_magazine(runtime_script, ak_definition, failures)
	_test_empty_magazine_starts_automatic_reload(runtime_script, ak_definition, failures)
	_test_firing_cancels_reload_when_magazine_is_not_empty(runtime_script, ak_definition, failures)
	_test_firing_does_not_cancel_reload_when_magazine_is_empty(runtime_script, ak_definition, failures)
	_test_recoil_is_clamped_and_recovers_during_tick(runtime_script, ak_definition, failures)
	_test_continuous_fire_expands_spread_and_stopping_recovers(runtime_script, ak_definition, failures)
	_test_reload_progress_and_source_are_observable(runtime_script, ak_definition, failures)
	return failures

func _test_ak_design_values(ak_definition: Resource, failures: Array[String]) -> void:
	_assert_equal(ak_definition.get("damage"), 24, "AK damage must be 24.", failures)
	_assert_equal(ak_definition.get("shots_per_second"), 8.5, "AK fire rate must be 8.5 shots/sec.", failures)
	_assert_equal(ak_definition.get("magazine_size"), 30, "AK magazine must hold 30 rounds.", failures)
	_assert_equal(ak_definition.get("reload_duration"), 2.20, "AK reload must take 2.20 sec.", failures)
	_assert_equal(ak_definition.get("base_spread_degrees"), 1.4, "AK base spread must be 1.4 degrees.", failures)
	_assert_equal(ak_definition.get("moving_spread_addition_degrees"), 1.3, "AK moving spread addition must be 1.3 degrees.", failures)
	_assert_equal(ak_definition.get("recoil_per_shot"), 9.0, "AK recoil must be 9 per shot.", failures)
	_assert_equal(ak_definition.get("recoil_recovery_per_second"), 38.0, "AK recoil recovery must be 38 per sec.", failures)
	_assert_equal(ak_definition.get("recoil_spread_coefficient"), 2.4, "AK recoil spread coefficient must be 2.4.", failures)
	_assert_equal(ak_definition.get("maximum_recoil_bias_degrees"), 4.5, "AK maximum recoil bias must be 4.5 degrees.", failures)
	_assert_equal(ak_definition.get("maximum_visual_kick_pixels"), 12.0, "AK maximum visual kick must be 12px.", failures)
	_assert_equal(ak_definition.get("range_pixels"), 1400.0, "AK range must be 1400px.", failures)

func _test_successful_fire_consumes_one_round(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	_assert_true(runtime.call("try_fire"), "A loaded AK should fire.", failures)
	_assert_equal(runtime.get("current_ammo"), 29, "A successful shot must consume exactly one round.", failures)

func _test_manual_reload_refills_a_partially_empty_magazine(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	runtime.call("try_fire")
	_assert_true(runtime.call("start_reload"), "A partially empty magazine should allow manual reload.", failures)
	_assert_true(runtime.get("is_reloading"), "Manual reload should enter the reloading state.", failures)
	runtime.call("tick", 2.19)
	_assert_equal(runtime.get("current_ammo"), 29, "Reload should not complete before 2.20 sec.", failures)
	runtime.call("tick", 0.01)
	_assert_equal(runtime.get("current_ammo"), 30, "Completed reload must refill the magazine.", failures)
	_assert_true(not runtime.get("is_reloading"), "Completed reload should leave the reloading state.", failures)

func _test_empty_magazine_starts_automatic_reload(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	_fire_entire_magazine(runtime, failures)
	_assert_true(runtime.get("is_reloading"), "The final successful shot should immediately start automatic reload.", failures)
	runtime.call("tick", 2.20)
	_assert_equal(runtime.get("current_ammo"), 30, "Automatic reload must refill the magazine.", failures)

func _test_firing_cancels_reload_when_magazine_is_not_empty(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	runtime.call("try_fire")
	runtime.call("tick", 1.0 / 8.5)
	runtime.call("start_reload")
	_assert_true(runtime.call("try_fire"), "Fire should be allowed while cancelling a non-empty reload.", failures)
	_assert_true(not runtime.get("is_reloading"), "A fire request should cancel reload when rounds remain.", failures)
	_assert_equal(runtime.get("current_ammo"), 28, "The cancelling fire request must still consume one round.", failures)

func _test_firing_does_not_cancel_reload_when_magazine_is_empty(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	_fire_entire_magazine(runtime, failures)
	runtime.call("try_fire")
	runtime.call("tick", 0.25)
	_assert_true(not runtime.call("try_fire"), "An empty reloading magazine cannot fire.", failures)
	_assert_true(runtime.get("is_reloading"), "A fire request must not cancel reload when the magazine is empty.", failures)

func _test_recoil_is_clamped_and_recovers_during_tick(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	_fire_entire_magazine(runtime, failures)
	_assert_true(runtime.get("recoil") <= 100.0, "Recoil must never exceed 100.", failures)
	runtime.call("tick", 100.0)
	_assert_float_equal(runtime.get("recoil"), 0.0, "Recoil should recover to zero during tick.", failures)

func _test_continuous_fire_expands_spread_and_stopping_recovers(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var runtime: Variant = runtime_script.new(ak_definition)
	if not runtime.has_method("get_current_spread_degrees"):
		failures.append("WeaponRuntime must expose final spread for combat and presentation.")
		return
	var base_spread: float = runtime.call("get_current_spread_degrees", false) as float
	for shot_index: int in range(3):
		_assert_true(runtime.call("try_fire"), "Short burst shot %d should fire." % (shot_index + 1), failures)
		if shot_index < 2:
			runtime.call("tick", 1.0 / 8.5)
	var short_burst_spread: float = runtime.call("get_current_spread_degrees", false) as float
	for shot_index: int in range(9):
		runtime.call("tick", 1.0 / 8.5)
		_assert_true(runtime.call("try_fire"), "Continuous-fire shot %d should fire." % (shot_index + 4), failures)
	var continuous_fire_spread: float = runtime.call("get_current_spread_degrees", false) as float
	_assert_float_equal(base_spread, 1.4, "Base spread should match the AK definition at zero recoil.", failures)
	_assert_true(short_burst_spread > base_spread, "A short burst should begin building spread.", failures)
	_assert_true(
		continuous_fire_spread > short_burst_spread * 1.35,
		"Continuous fire must spread substantially wider than a short burst.",
		failures
	)
	runtime.call("tick", 3.0)
	_assert_float_equal(
		runtime.call("get_current_spread_degrees", false) as float,
		base_spread,
		"Stopping fire must recover final spread to the base value.",
		failures
	)

func _test_reload_progress_and_source_are_observable(runtime_script: Script, ak_definition: Resource, failures: Array[String]) -> void:
	var manual_runtime: Variant = runtime_script.new(ak_definition)
	if not manual_runtime.has_method("get_reload_progress"):
		failures.append("WeaponRuntime must expose reload progress.")
		return
	_assert_true(manual_runtime.call("try_fire"), "A round should be spent before manual reload.", failures)
	_assert_true(manual_runtime.call("start_reload"), "Manual reload should start.", failures)
	_assert_true(not (manual_runtime.get("reload_is_automatic") as bool), "R reload must be marked manual.", failures)
	_assert_float_equal(
		manual_runtime.call("get_reload_progress") as float,
		0.0,
		"Reload progress must start at zero.",
		failures
	)
	manual_runtime.call("tick", 1.1)
	_assert_float_equal(
		manual_runtime.call("get_reload_progress") as float,
		0.5,
		"Reload progress must expose elapsed reload fraction.",
		failures
	)
	var automatic_runtime: Variant = runtime_script.new(ak_definition)
	_fire_entire_magazine(automatic_runtime, failures)
	_assert_true(automatic_runtime.get("reload_is_automatic") as bool, "The last round must mark reload automatic.", failures)
	automatic_runtime.call("tick", 0.55)
	_assert_float_equal(
		automatic_runtime.call("get_reload_progress") as float,
		0.25,
		"Automatic reload progress must be observable.",
		failures
	)

func _fire_entire_magazine(runtime: Variant, failures: Array[String]) -> void:
	for shot_index: int in range(30):
		_assert_true(runtime.call("try_fire"), "Shot %d of a full magazine should fire." % (shot_index + 1), failures)
		if shot_index < 29:
			runtime.call("tick", 1.0 / 8.5)
	_assert_equal(runtime.get("current_ammo"), 0, "Thirty shots must empty the AK magazine.", failures)

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _assert_float_equal(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > FLOAT_TOLERANCE:
		failures.append("%s Expected %.4f, got %.4f." % [message, expected, actual])
