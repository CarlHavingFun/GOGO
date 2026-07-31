extends Node

const SUITES: Array[Script] = [
	preload("res://tests/unit/test_weapon_runtime.gd"),
	preload("res://tests/unit/test_deterministic_spread.gd"),
	preload("res://tests/unit/test_desert_chunk_layout.gd"),
	preload("res://tests/unit/test_chunk_stream_planner.gd"),
	preload("res://tests/unit/test_spawn_ring_sampler.gd"),
	preload("res://tests/integration/test_m0_scene.gd"),
	preload("res://tests/integration/test_infinite_desert_scene.gd"),
]

func _ready() -> void:
	var failures: Array[String] = []
	var executed: int = 0
	for suite_script: Script in SUITES:
		var suite: Variant = suite_script.new()
		if not suite.has_method("run"):
			failures.append("%s does not expose run()" % suite_script.resource_path)
			continue
		var raw_failures: Variant = suite.call("run")
		executed += int(suite.get("test_count"))
		for failure: Variant in raw_failures:
			failures.append(str(failure))

	if failures.is_empty():
		print("GOGO TESTS PASS: %d assertions" % executed)
		get_tree().quit(0)
		return

	push_error("GOGO TESTS FAIL: %d failure(s)" % failures.size())
	for failure: String in failures:
		push_error(" - %s" % failure)
	get_tree().quit(1)
