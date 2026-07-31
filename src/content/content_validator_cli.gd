class_name ContentValidatorCLI
extends RefCounted

const VALIDATOR: Script = preload("res://src/content/content_validator.gd")

static func parse_args(args: PackedStringArray) -> Dictionary:
	var parsed: Dictionary = {
		"ok": true,
		"profile": &"g0",
		"format": "jsonl",
		"config": "res://data/content_validation.json",
		"error": "",
	}
	for argument: String in args:
		if argument.begins_with("--profile="):
			var profile: String = argument.trim_prefix("--profile=")
			if profile not in ["g0", "full"]:
				return _parse_error("Unknown profile: %s" % profile)
			parsed["profile"] = StringName(profile)
		elif argument.begins_with("--format="):
			var format: String = argument.trim_prefix("--format=")
			if format != "jsonl":
				return _parse_error("Unknown format: %s" % format)
			parsed["format"] = format
		elif argument.begins_with("--config="):
			var config_path: String = argument.trim_prefix("--config=")
			if not _is_safe_config_path(config_path):
				return _parse_error("Config must be a safe res:// path.")
			parsed["config"] = config_path
		else:
			return _parse_error("Unknown argument: %s" % argument)
	return parsed

static func run(args: PackedStringArray) -> Dictionary:
	var parsed: Dictionary = parse_args(args)
	var report: Dictionary
	if not parsed.get("ok", false):
		report = VALIDATOR.call("validate_snapshot", {}, StringName("__argument_error__"))
		var issues: Array = report.get("issues", [])
		if not issues.is_empty():
			issues[0]["message"] = parsed.get("error", "Invalid arguments.")
	else:
		report = VALIDATOR.call("validate_project", parsed.get("profile", &"g0"), parsed.get("config", "res://data/content_validation.json"))
	for line: String in VALIDATOR.call("format_jsonl", report):
		print(line)
	return report

static func _parse_error(message: String) -> Dictionary:
	return {
		"ok": false,
		"profile": &"",
		"format": "jsonl",
		"config": "",
		"error": message,
	}

static func _is_safe_config_path(path: String) -> bool:
	if not path.begins_with("res://") or path.contains("\\"):
		return false
	for component: String in path.trim_prefix("res://").split("/", false):
		if component == ".." or component == ".":
			return false
	return true
