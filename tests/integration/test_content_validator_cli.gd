extends RefCounted

const TOOL_PATH: String = "res://tools/validate_content.gd"
const VALID_CONFIG: String = "res://tests/fixtures/content_validator/g0_valid/data/content_validation.json"
const MALFORMED_DATASETS_CONFIG: String = "res://tests/fixtures/content_validator/g0_invalid/data/datasets_array.json"
const INVALID_FIELD_TYPE_CONFIG: String = "res://tests/fixtures/content_validator/g0_invalid/data/invalid_field_type.json"
const GOVERNANCE_ROOT: String = "res://tests/fixtures/content_validator/governance/"
const MISSING_REFERENCE_CONFIG: String = GOVERNANCE_ROOT + "missing_reference/data/content_validation.json"
const CORRUPT_REFERENCE_CONFIG: String = GOVERNANCE_ROOT + "corrupt_reference/data/content_validation.json"
const MISSING_CARD_CONFIG: String = GOVERNANCE_ROOT + "missing_card/data/content_validation.json"
const INVALID_CARD_CONFIG: String = GOVERNANCE_ROOT + "invalid_card/data/content_validation.json"

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_valid_g0_fixture_exits_zero_with_consistent_jsonl(failures)
	_test_full_profile_exits_one_for_future_not_ready_catalogs(failures)
	_test_unknown_profile_exits_two(failures)
	_test_malformed_config_content_returns_jsonl_error(failures)
	_test_invalid_config_field_type_returns_jsonl_error(failures)
	_test_governance_artifact_failures_exit_one_with_stable_rules(failures)
	return failures

func _test_valid_g0_fixture_exits_zero_with_consistent_jsonl(failures: Array[String]) -> void:
	var execution: Dictionary = _execute(PackedStringArray([
		"--profile=g0", "--format=jsonl", "--config=" + VALID_CONFIG,
	]))
	_assert_equal(execution.get("exit_code"), 0, "The valid G0 fixture CLI process must exit zero.", failures)
	var objects: Array[Dictionary] = _parse_jsonl(execution.get("output", ""), failures)
	_assert_true(not objects.is_empty(), "The CLI must emit JSONL.", failures)
	if objects.is_empty():
		return
	var summary: Dictionary = objects[-1]
	_assert_equal(summary.get("type"), "summary", "The last and only terminal JSONL line must be a summary.", failures)
	_assert_equal(summary.get("gate_status"), "pass", "Valid G0 CLI output must report a passing gate.", failures)
	_assert_equal(_type_count(objects, "summary"), 1, "The CLI must emit exactly one summary line.", failures)
	for line_index: int in range(objects.size() - 1):
		_assert_equal(objects[line_index].get("type"), "issue", "Every line before the summary must be an issue.", failures)
	var emitted_counts: Dictionary = {"error": 0, "warning": 0, "not_ready": 0}
	for object_index: int in range(objects.size() - 1):
		var severity: String = objects[object_index].get("severity", "")
		if severity == "ERROR":
			emitted_counts["error"] += 1
		elif severity == "WARNING":
			emitted_counts["warning"] += 1
		elif severity == "NOT_READY":
			emitted_counts["not_ready"] += 1
	var summary_counts: Dictionary = summary.get("counts", {})
	for count_name: String in ["error", "warning", "not_ready"]:
		_assert_equal(int(summary_counts.get(count_name, -1)), emitted_counts[count_name], "Summary %s count must equal emitted issue severities." % count_name, failures)

func _test_full_profile_exits_one_for_future_not_ready_catalogs(failures: Array[String]) -> void:
	var execution: Dictionary = _execute(PackedStringArray([
		"--profile=full", "--format=jsonl", "--config=" + VALID_CONFIG,
	]))
	_assert_equal(execution.get("exit_code"), 1, "The full profile must fail while catalogs remain NOT_READY.", failures)
	var objects: Array[Dictionary] = _parse_jsonl(execution.get("output", ""), failures)
	if not objects.is_empty():
		_assert_equal(objects[-1].get("catalog_status"), "not_ready", "Full CLI summary must expose catalog readiness.", failures)

func _test_unknown_profile_exits_two(failures: Array[String]) -> void:
	var execution: Dictionary = _execute(PackedStringArray([
		"--profile=unknown", "--format=jsonl", "--config=" + VALID_CONFIG,
	]))
	_assert_equal(execution.get("exit_code"), 2, "Unknown CLI profiles must exit two.", failures)
	_parse_jsonl(execution.get("output", ""), failures)

func _test_malformed_config_content_returns_jsonl_error(failures: Array[String]) -> void:
	var execution: Dictionary = _execute(PackedStringArray([
		"--profile=g0", "--format=jsonl", "--config=" + MALFORMED_DATASETS_CONFIG,
	]))
	_assert_equal(execution.get("exit_code"), 1, "Malformed config content must be a validation failure, not a crash.", failures)
	var objects: Array[Dictionary] = _parse_jsonl(execution.get("output", ""), failures)
	_assert_true(not objects.is_empty(), "Malformed config content must still emit JSONL.", failures)
	if not objects.is_empty():
		var summary: Dictionary = objects[-1]
		_assert_equal(summary.get("type"), "summary", "Malformed config output must end in a summary.", failures)
		_assert_true(int((summary.get("counts", {}) as Dictionary).get("error", 0)) > 0, "Malformed config summary must count a CFG001 error.", failures)

func _test_invalid_config_field_type_returns_jsonl_error(failures: Array[String]) -> void:
	var execution: Dictionary = _execute(PackedStringArray([
		"--profile=g0", "--format=jsonl", "--config=" + INVALID_FIELD_TYPE_CONFIG,
	]))
	_assert_equal(execution.get("exit_code"), 1, "Invalid config field types must be validation failures, not runtime errors.", failures)
	var objects: Array[Dictionary] = _parse_jsonl(execution.get("output", ""), failures)
	_assert_true(not objects.is_empty(), "Invalid config field types must still emit JSONL.", failures)
	if not objects.is_empty():
		var summary: Dictionary = objects[-1]
		_assert_equal(summary.get("type"), "summary", "Invalid field-type output must end in a summary.", failures)
		_assert_true(int((summary.get("counts", {}) as Dictionary).get("error", 0)) > 0, "Invalid field-type summary must count CFG001.", failures)

func _test_governance_artifact_failures_exit_one_with_stable_rules(failures: Array[String]) -> void:
	var cases: Array[Dictionary] = [
		{"config": MISSING_REFERENCE_CONFIG, "rule": "AST006", "forbidden": "AST007", "label": "missing reference"},
		{"config": CORRUPT_REFERENCE_CONFIG, "rule": "AST006", "forbidden": "AST007", "label": "corrupt reference"},
		{"config": MISSING_CARD_CONFIG, "rule": "AST007", "forbidden": "AST006", "label": "missing card"},
		{"config": INVALID_CARD_CONFIG, "rule": "AST007", "forbidden": "AST006", "label": "invalid card"},
	]
	for case: Dictionary in cases:
		var execution: Dictionary = _execute(PackedStringArray([
			"--profile=g0", "--format=jsonl", "--config=" + case["config"],
		]))
		_assert_equal(execution.get("exit_code"), 1, "The %s G0 fixture must exit one." % case["label"], failures)
		var objects: Array[Dictionary] = _parse_jsonl(execution.get("output", ""), failures)
		_assert_equal(_rule_count(objects, case["rule"]), 1, "The %s fixture must emit exactly one %s." % [case["label"], case["rule"]], failures)
		_assert_equal(_rule_count(objects, case["forbidden"]), 0, "The %s fixture must not cascade into %s." % [case["label"], case["forbidden"]], failures)
		if not objects.is_empty():
			_assert_equal(int((objects[-1].get("counts", {}) as Dictionary).get("error", 0)), 1, "The %s fixture must report one ERROR." % case["label"], failures)

func _execute(tool_args: PackedStringArray) -> Dictionary:
	var args: PackedStringArray = [
		"--headless",
		"--no-header",
		"--audio-driver",
		"Dummy",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--script",
		TOOL_PATH,
		"--",
	]
	args.append_array(tool_args)
	var output: Array[String] = []
	var exit_code: int = OS.execute(OS.get_executable_path(), args, output, true)
	return {"exit_code": exit_code, "output": "".join(output)}

func _parse_jsonl(output: String, failures: Array[String]) -> Array[Dictionary]:
	var objects: Array[Dictionary] = []
	for raw_line: String in output.split("\n", false):
		var line: String = raw_line.strip_edges()
		if line.is_empty():
			continue
		var parsed: Variant = JSON.parse_string(line)
		if not parsed is Dictionary:
			failures.append("Every nonempty CLI output line must be a JSON object. Got: %s" % line)
			continue
		objects.append(parsed)
	return objects

func _type_count(objects: Array[Dictionary], type_name: String) -> int:
	var count: int = 0
	for object: Dictionary in objects:
		if object.get("type") == type_name:
			count += 1
	return count

func _rule_count(objects: Array[Dictionary], rule: String) -> int:
	var count: int = 0
	for object: Dictionary in objects:
		if object.get("type") == "issue" and object.get("rule") == rule:
			count += 1
	return count

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])
