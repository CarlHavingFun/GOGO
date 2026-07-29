extends RefCounted

const SAMPLER_PATH: String = "res://src/combat/spread_sampler.gd"

func run() -> Array[String]:
	var failures: Array[String] = []
	var sampler_script: Script = load(SAMPLER_PATH) as Script
	if sampler_script == null:
		failures.append("SpreadSampler script is required for deterministic spread tests.")
		return failures
	if not sampler_script.can_instantiate():
		failures.append("SpreadSampler script must parse and instantiate for deterministic spread tests.")
		return failures
	_test_same_seed_and_inputs_produce_the_same_sequence(sampler_script, failures)
	return failures

func _test_same_seed_and_inputs_produce_the_same_sequence(sampler_script: Script, failures: Array[String]) -> void:
	var first_sampler: Variant = sampler_script.new(24680)
	var second_sampler: Variant = sampler_script.new(24680)
	var first_sequence: Array[float] = []
	var second_sequence: Array[float] = []
	for draw_number: int in range(3):
		first_sequence.append(first_sampler.call("sample_spread", 1.4, 1.3, true))
		second_sequence.append(second_sampler.call("sample_spread", 1.4, 1.3, true))
	_assert_equal(first_sequence, second_sequence, "Same seed and inputs must reproduce the spread sequence.", failures)
	_assert_equal(first_sampler.get("draw_index"), 3, "Sampler must record each random draw.", failures)
	_assert_equal(second_sampler.get("draw_index"), 3, "Each sampler must own its draw index.", failures)
	for sample: float in first_sequence:
		_assert_true(sample >= -2.7 and sample <= 2.7, "Moving spread sample must remain within +/- 2.7 degrees.", failures)

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])
