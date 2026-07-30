extends RefCounted

const WeaponDefinitionScript: Script = preload("res://systems/combat/weapon_definition.gd")
const DeterministicSpreadScript: Script = preload("res://systems/combat/deterministic_spread.gd")

var test_count: int = 0
var _failures: Array[String] = []

func run() -> Array[String]:
	_test_equal_seed_equal_sequence()
	_test_different_seed_changes_sequence()
	_test_recoil_and_movement_expand_envelope()
	return _failures

func _make_definition() -> Variant:
	var definition: Variant = WeaponDefinitionScript.new()
	definition.base_spread_deg = 1.4
	definition.move_spread_deg = 1.3
	definition.recoil_spread_factor = 1.0
	return definition

func _test_equal_seed_equal_sequence() -> void:
	var first: Variant = DeterministicSpreadScript.new()
	var second: Variant = DeterministicSpreadScript.new()
	first.configure(424242)
	second.configure(424242)
	var definition: Variant = _make_definition()
	for index: int in range(64):
		var first_value: float = first.sample_offset_deg(definition, float(index), index % 2 == 0)
		var second_value: float = second.sample_offset_deg(definition, float(index), index % 2 == 0)
		_assert_near(first_value, second_value, 0.000001, "equal seeds should match at sample %d" % index)

func _test_different_seed_changes_sequence() -> void:
	var first: Variant = DeterministicSpreadScript.new()
	var second: Variant = DeterministicSpreadScript.new()
	first.configure(11)
	second.configure(12)
	var definition: Variant = _make_definition()
	var any_difference: bool = false
	for _index: int in range(16):
		if not is_equal_approx(first.sample_offset_deg(definition, 40.0, true), second.sample_offset_deg(definition, 40.0, true)):
			any_difference = true
			break
	_assert_true(any_difference, "different seeds should not emit an identical sequence")

func _test_recoil_and_movement_expand_envelope() -> void:
	var spread: Variant = DeterministicSpreadScript.new()
	var definition: Variant = _make_definition()
	_assert_near(spread.current_spread_deg(definition, 0.0, false), 1.4, 0.000001, "base spread should match the AK definition")
	_assert_true(spread.current_spread_deg(definition, 0.0, true) > 1.4, "movement should expand spread")
	_assert_true(spread.current_spread_deg(definition, 100.0, false) > 1.4, "recoil should expand spread")

func _assert_true(value: bool, message: String) -> void:
	test_count += 1
	if not value:
		_failures.append(message)

func _assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	test_count += 1
	if absf(actual - expected) > tolerance:
		_failures.append("%s (expected=%f actual=%f)" % [message, expected, actual])
