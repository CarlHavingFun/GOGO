extends SceneTree

const TEST_PATHS: Array[String] = [
	"res://tests/unit/test_weapon_runtime.gd",
	"res://tests/unit/test_spread_sampler.gd",
	"res://tests/unit/test_content_validator.gd",
	"res://tests/integration/test_playable_scene.gd",
	"res://tests/integration/test_m0_acceptance.gd",
	"res://tests/integration/test_content_validator_cli.gd",
	"res://tests/integration/test_infinite_desert_scene.gd",
	"res://tests/unit/test_deterministic_spread.gd",
	"res://tests/unit/test_chunk_stream_planner.gd",
	"res://tests/unit/test_desert_chunk_layout.gd",
	"res://tests/unit/test_spawn_ring_sampler.gd",
]

func _initialize() -> void:
	_run_all_tests.call_deferred()

func _run_all_tests() -> void:
	var failures: Array[String] = []
	for test_path: String in TEST_PATHS:
		var test_script: Script = load(test_path) as Script
		if test_script == null:
			failures.append("Unable to load test script: %s" % test_path)
			continue
		var test_instance: Variant = test_script.new()
		var test_failures: Array[String] = []
		if test_instance.has_method("run_async"):
			test_failures = await test_instance.run_async()
		else:
			test_failures = test_instance.run()
		failures.append_array(test_failures)
	if failures.is_empty():
		print("TESTS PASSED")
	else:
		for failure: String in failures:
			push_error(failure)
		print("TESTS FAILED: %d" % failures.size())
	quit(failures.size())
