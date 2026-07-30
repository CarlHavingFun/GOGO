extends SceneTree

const VALIDATOR: Script = preload("res://src/content/content_validator.gd")
const CLI: Script = preload("res://src/content/content_validator_cli.gd")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var report: Dictionary = CLI.call("run", OS.get_cmdline_user_args())
	quit(VALIDATOR.call("exit_code", report))
