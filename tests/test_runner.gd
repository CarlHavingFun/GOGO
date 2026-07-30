extends Node

const SUITES: Array[Script] = [
	preload("res://tests/unit/test_weapon_runtime.gd"),
	preload("res://tests/unit/test_deterministic_spread.gd"),
	preload("res://tests/integration/test_m0_scene.gd"),
]

func _ready() -> void:
	var failures: Array[String] = []
	var executed: int = 0
	for suite_script: Script in SUITES:
		var suite: RefCounted = suite_script.new()
		if not suite.has_method("run"):
			failures.append("%s does not expose run()" % suite_script.resource_path)
			continue
		var suite_failures: Array[String] = suite.run()
		executed += int(suite.get("test_count"))
		failures.append_array(suite_failures)

	if failures.is_empty():
		print("M0 TESTS PASS: %d assertions" % executed)
		get_tree().quit(0)
		return

	push_error("M0 TESTS FAIL: %d failure(s)" % failures.size())
	for failure: String in failures:
		push_error(" - %s" % failure)
	get_tree().quit(1)
