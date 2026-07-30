extends RefCounted

const WeaponDefinitionScript: Script = preload("res://systems/combat/weapon_definition.gd")
const WeaponRuntimeScript: Script = preload("res://systems/combat/weapon_runtime.gd")

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	_test_magazine_and_cooldown()
	_test_reload_completion()
	_test_non_empty_reload_can_be_cancelled_by_fire()
	_test_empty_reload_cannot_be_cancelled_by_fire()
	_test_definition_validation()
	return _failures

func _make_definition() -> Variant:
	var definition: Variant = WeaponDefinitionScript.new()
	definition.id = &"ak_m0"
	definition.display_name = "AK"
	definition.base_damage = 24.0
	definition.shots_per_sec = 8.5
	definition.magazine_size = 30
	definition.reload_sec = 2.2
	definition.base_spread_deg = 1.4
	definition.move_spread_deg = 1.3
	definition.recoil_per_shot = 9.0
	definition.recoil_recovery_per_sec = 38.0
	definition.recoil_spread_factor = 1.0
	definition.max_range_px = 1400.0
	return definition

func _make_runtime() -> Variant:
	var runtime: Variant = WeaponRuntimeScript.new()
	runtime.configure(_make_definition())
	return runtime

func _test_magazine_and_cooldown() -> void:
	var runtime: Variant = _make_runtime()
	_assert_true(runtime.fire(), "first shot should fire")
	_assert_equal(runtime.ammo_in_mag, 29, "first shot should consume one round")
	_assert_false(runtime.fire(), "cooldown should reject an immediate second shot")
	runtime.tick(1.0 / 8.5)
	_assert_true(runtime.fire(), "shot should fire when cooldown has elapsed")

	for index: int in range(28):
		runtime.tick(1.0 / 8.5)
		_assert_true(runtime.fire(), "shot %d should fire before magazine is empty" % (index + 3))
	_assert_equal(runtime.ammo_in_mag, 0, "thirty shots should empty the magazine")
	runtime.tick(1.0 / 8.5)
	_assert_false(runtime.fire(), "the thirty-first shot should be rejected")

func _test_reload_completion() -> void:
	var runtime: Variant = _make_runtime()
	_assert_true(runtime.fire(), "setup shot should fire")
	_assert_true(runtime.start_reload(), "partial magazine should start reload")
	runtime.tick(2.19)
	_assert_true(runtime.is_reloading, "reload should still be active before duration")
	_assert_equal(runtime.ammo_in_mag, 29, "reload must not add rounds early")
	runtime.tick(0.01)
	_assert_false(runtime.is_reloading, "reload should complete at duration")
	_assert_equal(runtime.ammo_in_mag, 30, "completed reload should refill magazine")

func _test_non_empty_reload_can_be_cancelled_by_fire() -> void:
	var runtime: Variant = _make_runtime()
	_assert_true(runtime.fire(), "setup shot should fire")
	runtime.tick(1.0)
	_assert_true(runtime.start_reload(), "partial magazine should start reload")
	_assert_true(runtime.cancel_reload_for_shot(), "non-empty reload should be cancellable")
	_assert_false(runtime.is_reloading, "cancelled reload should stop")
	_assert_equal(runtime.ammo_in_mag, 29, "cancel must not grant ammunition")
	_assert_true(runtime.fire(), "a shot may fire after cancelling the reload")
	_assert_equal(runtime.ammo_in_mag, 28, "cancelled reload shot should consume ammunition")

func _test_empty_reload_cannot_be_cancelled_by_fire() -> void:
	var runtime: Variant = _make_runtime()
	for _index: int in range(30):
		_assert_true(runtime.fire(), "setup should empty magazine")
		runtime.tick(1.0 / 8.5)
	_assert_true(runtime.start_reload(), "empty magazine should start reload")
	_assert_false(runtime.cancel_reload_for_shot(), "empty reload should not be cancellable")
	_assert_true(runtime.is_reloading, "empty reload must remain active")
	_assert_false(runtime.fire(), "empty reload cannot fire")

func _test_definition_validation() -> void:
	var definition: Variant = _make_definition()
	_assert_equal(definition.validate().size(), 0, "valid AK definition should pass validation")
	definition.shots_per_sec = 0.0
	definition.magazine_size = 0
	definition.reload_sec = -1.0
	definition.max_range_px = 0.0
	_assert_equal(definition.validate().size(), 4, "invalid timing, magazine and range fields should be reported")

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_false(value: bool, message: String) -> void:
	_assert_true(not value, message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	test_count += 1
	if actual != expected:
		_failures.append("%s (expected=%s actual=%s)" % [message, expected, actual])
