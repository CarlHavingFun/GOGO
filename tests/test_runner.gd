extends SceneTree

const TEST_PATHS: Array[String] = [
	"res://tests/unit/test_weapon_runtime.gd",
	"res://tests/unit/test_spread_sampler.gd",
	"res://tests/integration/test_playable_scene.gd",
]

func _initialize() -> void:
	var failures: Array[String] = []
	for test_path: String in TEST_PATHS:
		var test_script: Script = load(test_path) as Script
		if test_script == null:
			failures.append("Unable to load test script: %s" % test_path)
			continue
		var test_instance: Variant = test_script.new()
		var test_failures: Array[String] = test_instance.run()
		failures.append_array(test_failures)
	if failures.is_empty():
		print("TESTS PASSED")
	else:
		for failure: String in failures:
			push_error(failure)
		print("TESTS FAILED: %d" % failures.size())
	quit(failures.size())
