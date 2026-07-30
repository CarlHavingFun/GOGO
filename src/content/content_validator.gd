class_name ContentValidator
extends RefCounted

const LOADER: Script = preload("res://src/content/content_snapshot_loader.gd")
const VALID_PROFILES: Array[StringName] = [&"g0", &"full"]
const DATASET_STATES: Array[String] = ["not_implemented", "legacy", "partial", "ready"]
const CONFIG_FIELDS: Array[String] = ["schema_version", "current_gate", "datasets"]
const DATASET_NAMES: Array[String] = [
	"assets", "design_documents", "weapons", "throwables", "characters",
	"upgrades", "enemies", "waves", "unlocks",
]
const GAMEPLAY_DATASETS: Array[String] = [
	"weapons", "throwables", "characters", "upgrades", "enemies", "waves", "unlocks",
]
const EXPECTED_COUNT_DATASETS: Array[String] = [
	"weapons", "throwables", "characters", "upgrades", "enemies",
]
const GATE_ORDER: Array[String] = ["G0", "M0", "M1", "M2", "M3", "M4", "M5"]
const ASSET_HEADER: PackedStringArray = [
	"asset_id", "phase", "category", "subject", "state", "path", "logical_canvas",
	"pivot", "frames", "fps", "prompt_section", "status", "notes",
	"generation_canvas", "direction", "collision_reference", "palette",
	"negative_constraints", "godot_import", "reviewer", "reference_source",
	"reference_sha256", "reference_rights_policy", "sprite_layout",
	"source_output", "cleaned_output", "qa_record", "godot_evidence",
]
const ASSET_PHASES: Array[String] = ["A1", "A2", "A3", "A4", "A5"]
const ASSET_CATEGORIES: Array[String] = [
	"arena", "boss", "character", "effect", "enemy", "pickup", "projectile",
	"throwable", "ui", "weapon",
]
const ASSET_STATUSES: Array[String] = ["planned", "generated", "cleaned", "approved", "in_game", "rejected"]
const GENERATED_OR_LATER: Array[String] = ["generated", "cleaned", "approved", "in_game", "rejected"]
const XIAODONG_A5_STATES: Array[String] = ["idle", "walk", "hit", "death", "skill_breakin", "portrait"]
const UPGRADE_CATEGORIES: Array[String] = ["calibration", "engine", "mutation", "module", "contract"]

static func validate_project(
	profile: StringName = &"g0",
	config_path: String = "res://data/content_validation.json"
) -> Dictionary:
	var project_root: String = _project_root_for_config(config_path)
	var loaded: Dictionary = LOADER.call("load_project", project_root, config_path)
	var report: Dictionary = validate_snapshot(loaded.get("snapshot", {}), profile)
	var issues: Array[Dictionary] = []
	for issue_value: Variant in report.get("issues", []):
		issues.append(issue_value)
	for issue_value: Variant in loaded.get("load_issues", []):
		issues.append(issue_value)
	return _build_report(String(profile), issues, report.get("argument_error", false))

static func validate_snapshot(snapshot: Dictionary, profile: StringName) -> Dictionary:
	if profile not in VALID_PROFILES:
		return _argument_error_report("Unknown profile: %s" % String(profile))
	var issues: Array[Dictionary] = []
	var config_value: Variant = snapshot.get("config", null)
	if not config_value is Dictionary:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "config", "Config must be an object.", "Dictionary", typeof(config_value), "G0"))
		return _build_report(String(profile), issues)
	var config: Dictionary = config_value
	var datasets_value: Variant = config.get("datasets", null)
	if not datasets_value is Dictionary:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "datasets", "Config datasets must be an object.", "Dictionary", typeof(datasets_value), "G0"))
		return _build_report(String(profile), issues)
	var datasets: Dictionary = datasets_value
	_validate_config(snapshot, config, datasets, issues)
	_validate_readiness(snapshot, datasets, issues)
	var design_state: String = _dataset_state(datasets, "design_documents")
	if design_state == "ready":
		_validate_design_documents(snapshot.get("design_documents", {}), datasets.get("design_documents", {}), issues)
	var asset_state: String = _dataset_state(datasets, "assets")
	if asset_state == "ready":
		_validate_assets(snapshot.get("assets", {}), datasets.get("assets", {}), issues)
	_validate_gameplay(snapshot.get("gameplay", {}), datasets, issues)
	return _build_report(String(profile), issues)

static func format_jsonl(report: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = []
	for issue_value: Variant in report.get("issues", []):
		var issue: Dictionary = (issue_value as Dictionary).duplicate(true)
		var output_issue: Dictionary = {"type": "issue"}
		output_issue.merge(issue)
		lines.append(JSON.stringify(output_issue))
	var summary: Dictionary = {
		"type": "summary",
		"profile": report.get("profile", ""),
		"gate_status": report.get("gate_status", "fail"),
		"catalog_status": report.get("catalog_status", "not_ready"),
		"counts": report.get("counts", {"error": 0, "warning": 0, "not_ready": 0}),
	}
	if report.get("argument_error", false):
		summary["argument_error"] = true
	lines.append(JSON.stringify(summary))
	return lines

static func exit_code(report: Dictionary) -> int:
	if report.get("argument_error", false):
		return 2
	return 0 if report.get("gate_status", "fail") == "pass" else 1

static func _validate_config(
	snapshot: Dictionary,
	config: Dictionary,
	datasets: Dictionary,
	issues: Array[Dictionary]
) -> void:
	if not _has_exact_keys(config, CONFIG_FIELDS):
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "config", "Config must use the exact keys schema_version/current_gate/datasets.", CONFIG_FIELDS, config.keys(), "G0"))
	var schema_version: Variant = config.get("schema_version", null)
	if not _is_integral_number(schema_version) or int(schema_version) != 1:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "schema_version", "Config schema_version must be integer 1.", 1, schema_version, "G0"))
	var current_gate: Variant = config.get("current_gate", null)
	if not current_gate is String or String(current_gate) not in GATE_ORDER:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "current_gate", "Config current_gate must be a known gate string.", GATE_ORDER, current_gate, "G0"))
	if not _has_exact_keys(datasets, DATASET_NAMES):
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "datasets", "Config datasets must use the exact keys from the contract.", DATASET_NAMES, datasets.keys(), "G0"))
	for dataset_name: String in DATASET_NAMES:
		var dataset_config_value: Variant = datasets.get(dataset_name, null)
		if not dataset_config_value is Dictionary:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset config must be an object.", "Dictionary", typeof(dataset_config_value), "G0"))
			continue
		var dataset_config: Dictionary = dataset_config_value
		var required_fields: Array[String] = _required_dataset_fields(dataset_name)
		if not _has_exact_keys(dataset_config, required_fields):
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset must use the exact fields %s." % "/".join(required_fields), required_fields, dataset_config.keys(), "G0"))
		var state_value: Variant = dataset_config.get("state", null)
		var path_value: Variant = dataset_config.get("path", null)
		var target_gate_value: Variant = dataset_config.get("target_gate", null)
		var target_gate: String = String(target_gate_value) if target_gate_value is String else ""
		if not state_value is String or String(state_value) not in DATASET_STATES:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset has unknown or non-string state.", DATASET_STATES, state_value, target_gate))
		if not path_value is String or not _is_safe_res_path(String(path_value)):
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset path must be a safe res:// string.", "safe res:// path", path_value, target_gate))
		if not target_gate_value is String or String(target_gate_value) not in GATE_ORDER:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset target_gate must be a known gate string.", GATE_ORDER, target_gate_value, "G0"))
		if dataset_name in EXPECTED_COUNT_DATASETS:
			var expected_count: Variant = dataset_config.get("expected_count", null)
			if not _is_integral_number(expected_count) or int(expected_count) < 0:
				issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset expected_count must be a nonnegative integer.", "nonnegative integer", expected_count, target_gate))
		if dataset_name == "upgrades":
			_validate_expected_categories(dataset_config.get("expected_categories", null), target_gate, issues)
		elif dataset_name == "waves":
			_validate_expected_range(dataset_config.get("expected_range", null), target_gate, issues)
		if not _dataset_config_is_runtime_safe(dataset_name, dataset_config):
			continue
		var state: String = dataset_config["state"]
		var path: String = dataset_config["path"]
		if state == "not_implemented" and _dataset_has_content(snapshot, dataset_name):
			issues.append(_issue("ERROR", "CFG001", path, 0, dataset_name, "Dataset declared not_implemented contains existing content.", false, true, target_gate))

static func _validate_readiness(snapshot: Dictionary, datasets: Dictionary, issues: Array[Dictionary]) -> void:
	for dataset_name: String in DATASET_NAMES:
		var dataset_config_value: Variant = datasets.get(dataset_name, null)
		if not _dataset_config_is_runtime_safe(dataset_name, dataset_config_value):
			continue
		var dataset_config: Dictionary = dataset_config_value
		var state: String = dataset_config["state"]
		if state not in DATASET_STATES:
			continue
		var records: Array = _dataset_records(snapshot, dataset_name)
		var target_gate: String = dataset_config["target_gate"]
		var rule: String = _readiness_rule(dataset_name)
		if state == "not_implemented":
			issues.append(_not_ready_issue(rule, dataset_config["path"], dataset_name, _not_implemented_message(dataset_name, dataset_config), _expected_for(dataset_config), records.size(), target_gate))
		elif state == "legacy":
			issues.append(_not_ready_issue(rule, dataset_config["path"], dataset_name, "%s is declared legacy" % dataset_name, "ready", "legacy", target_gate))
		elif state == "partial":
			var expected: Variant = _expected_for(dataset_config)
			issues.append(_not_ready_issue(rule, dataset_config["path"], dataset_name, "%s catalog is partial" % dataset_name, expected, records.size(), target_gate))
		elif state == "ready":
			var expected: Variant = _expected_for(dataset_config)
			if expected != null and not _records_meet_expected(dataset_name, records, expected):
				issues.append(_issue("ERROR", rule, dataset_config["path"], 0, dataset_name, "Ready dataset does not meet declared completeness.", expected, records.size(), target_gate))

static func _validate_design_documents(documents: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var records: Array = documents.get("records", [])
	var actual_files: Array = documents.get("actual_markdown_files", [])
	var registered_files: Dictionary = {}
	for record_value: Variant in records:
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var file_name: String = record.get("file", "")
		var path: String = record.get("source_path", dataset_config["path"])
		if not _is_safe_relative_path(file_name):
			issues.append(_issue("ERROR", "DOC001", path, record.get("source_line", 0), file_name, "Manifest path is missing or unsafe.", "safe relative Markdown path", file_name, dataset_config["target_gate"]))
			continue
		if registered_files.has(file_name):
			issues.append(_issue("ERROR", "DOC001", path, record.get("source_line", 0), file_name, "Manifest path is duplicated.", "unique path", file_name, dataset_config["target_gate"]))
		else:
			registered_files[file_name] = true
		if not record.get("exists", false):
			issues.append(_issue("ERROR", "DOC002", path, record.get("source_line", 0), file_name, "Registered Markdown file does not exist.", true, false, dataset_config["target_gate"]))
			continue
		if record.get("bytes") != record.get("actual_bytes"):
			issues.append(_issue("ERROR", "DOC003", path, record.get("source_line", 0), file_name, "Markdown byte count does not match manifest.", record.get("bytes"), record.get("actual_bytes"), dataset_config["target_gate"]))
		if record.get("sha256") != record.get("actual_sha256"):
			issues.append(_issue("ERROR", "DOC003", path, record.get("source_line", 0), file_name, "Markdown SHA-256 does not match manifest.", record.get("sha256"), record.get("actual_sha256"), dataset_config["target_gate"]))
	for actual_file_value: Variant in actual_files:
		var actual_file: String = String(actual_file_value)
		var file_name: String = actual_file.get_file()
		if not registered_files.has(file_name):
			issues.append(_issue("ERROR", "DOC002", actual_file, 0, file_name, "Markdown file is not registered in the manifest.", "registered", "unregistered", dataset_config["target_gate"]))

static func _validate_assets(assets: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var header: PackedStringArray = assets.get("header", PackedStringArray())
	var rows: Array = assets.get("rows", [])
	var target_gate: String = dataset_config["target_gate"]
	if header != ASSET_HEADER:
		issues.append(_issue("ERROR", "AST001", dataset_config["path"], 1, "asset_manifest", "Asset manifest must use the exact 28-column header.", ASSET_HEADER, header, target_gate))
	var seen_ids: Dictionary = {}
	var xiaodong_states: Array[String] = []
	for row_value: Variant in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		var asset_id: String = row.get("asset_id", "")
		var source_path: String = row.get("source_path", dataset_config["path"])
		var source_line: int = row.get("source_line", 0)
		if row.get("_column_count", ASSET_HEADER.size()) != ASSET_HEADER.size():
			issues.append(_issue("ERROR", "AST001", source_path, source_line, asset_id, "Asset row must contain exactly 28 columns.", 28, row.get("_column_count"), target_gate))
		_validate_asset_schema(row, seen_ids, source_path, source_line, target_gate, issues)
		_validate_asset_evidence(row, source_path, source_line, target_gate, issues)
		_validate_asset_prompt(row, source_path, source_line, target_gate, issues)
		if row.get("phase") == "A5" and row.get("subject") == "xiaodong":
			xiaodong_states.append(row.get("state", ""))
	var sorted_actual: Array[String] = xiaodong_states.duplicate()
	var sorted_expected: Array[String] = XIAODONG_A5_STATES.duplicate()
	sorted_actual.sort()
	sorted_expected.sort()
	if sorted_actual != sorted_expected:
		issues.append(_issue("ERROR", "AST005", dataset_config["path"], 0, "xiaodong", "A5 Xiaodong must have exactly idle/walk/hit/death/skill_breakin/portrait.", sorted_expected, sorted_actual, target_gate))

static func _validate_asset_schema(
	row: Dictionary,
	seen_ids: Dictionary,
	source_path: String,
	source_line: int,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	var asset_id: String = row.get("asset_id", "")
	if not _is_snake_case(asset_id):
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset ID must be nonempty snake_case.", "snake_case", asset_id, target_gate))
	if seen_ids.has(asset_id):
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset ID must be unique.", "unique", asset_id, target_gate))
	else:
		seen_ids[asset_id] = true
	var phase: String = row.get("phase", "")
	if phase not in ASSET_PHASES:
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset phase enum is invalid.", ASSET_PHASES, phase, target_gate))
	var category: String = row.get("category", "")
	if category not in ASSET_CATEGORIES:
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset category enum is invalid.", ASSET_CATEGORIES, category, target_gate))
	var state: String = row.get("state", "")
	if not _is_snake_case(state) or state == "accepted_for_concept":
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset state enum is invalid; accepted_for_concept is forbidden.", "snake_case action/variant", state, target_gate))
	var status: String = row.get("status", "")
	if status not in ASSET_STATUSES:
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset status enum is invalid; accepted_for_concept is forbidden.", ASSET_STATUSES, status, target_gate))
	for canvas_field: String in ["logical_canvas", "generation_canvas"]:
		var canvas: String = row.get(canvas_field, "")
		if canvas_field == "generation_canvas" and canvas.is_empty():
			continue
		if not _is_canvas(canvas):
			issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "%s must use WIDTHxHEIGHT positive integers." % canvas_field, "WIDTHxHEIGHT", canvas, target_gate))
	var frames_text: String = String(row.get("frames", ""))
	var fps_text: String = String(row.get("fps", ""))
	var frames: int = frames_text.to_int() if frames_text.is_valid_int() else -1
	var fps: float = fps_text.to_float() if fps_text.is_valid_float() else -1.0
	if frames < 1:
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset frames must be a positive integer.", ">= 1", row.get("frames"), target_gate))
	if fps < 0.0 or (frames == 1 and not is_zero_approx(fps)) or (frames > 1 and fps <= 0.0):
		issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "Asset FPS must be zero for one frame and positive for animation.", "0 iff frames=1", row.get("fps"), target_gate))
	for path_field: String in ["path", "source_output", "cleaned_output", "qa_record", "godot_evidence"]:
		var path: String = row.get(path_field, "")
		if not path.is_empty() and not _is_safe_relative_path(path):
			issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "%s must be a safe project-relative path." % path_field, "safe relative path", path, target_gate))

static func _validate_asset_evidence(
	row: Dictionary,
	source_path: String,
	source_line: int,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	var asset_id: String = row.get("asset_id", "")
	var status: String = row.get("status", "")
	if status == "planned":
		for evidence_field: String in ["source_output", "cleaned_output", "qa_record", "godot_evidence"]:
			if not String(row.get(evidence_field, "")).is_empty():
				issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Planned assets must leave %s empty." % evidence_field, "", row.get(evidence_field), target_gate))
		return
	if status in ["generated", "cleaned", "approved", "in_game", "rejected"]:
		_require_existing_asset_path(row, "source_output", source_path, source_line, target_gate, issues)
	if status in ["cleaned", "approved", "in_game"]:
		_require_existing_asset_path(row, "cleaned_output", source_path, source_line, target_gate, issues)
		_require_existing_asset_path(row, "path", source_path, source_line, target_gate, issues)
	if status in ["approved", "in_game"]:
		_require_existing_asset_path(row, "qa_record", source_path, source_line, target_gate, issues)
		if String(row.get("reviewer", "")).strip_edges().is_empty():
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Approved-or-later assets require a reviewer.", "nonempty reviewer", row.get("reviewer"), target_gate))
	if status == "in_game":
		_require_existing_asset_path(row, "godot_evidence", source_path, source_line, target_gate, issues)
		if String(row.get("godot_import", "")).strip_edges().is_empty():
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "In-game assets require godot_import.", "nonempty godot_import", row.get("godot_import"), target_gate))
	if status == "rejected":
		_require_existing_asset_path(row, "qa_record", source_path, source_line, target_gate, issues)
		if row.get("_path_exists", false):
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Rejected assets must not have a stable path artifact.", false, true, target_gate))

static func _require_existing_asset_path(
	row: Dictionary,
	field: String,
	source_path: String,
	source_line: int,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	var value: String = row.get(field, "")
	if value.is_empty() or not row.get("_%s_exists" % field, false):
		issues.append(_issue("ERROR", "AST003", source_path, source_line, row.get("asset_id", ""), "%s must name an existing file for this lifecycle status." % field, "existing file", value, target_gate))

static func _validate_asset_prompt(
	row: Dictionary,
	source_path: String,
	source_line: int,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	if row.get("status", "") not in GENERATED_OR_LATER:
		return
	for field: String in ["prompt_section", "negative_constraints"]:
		if String(row.get(field, "")).strip_edges().is_empty():
			issues.append(_issue("ERROR", "AST004", source_path, source_line, row.get("asset_id", ""), "Generated-or-later assets require nonempty %s." % field, "nonempty", row.get(field), target_gate))

static func _validate_gameplay(gameplay: Dictionary, datasets: Dictionary, issues: Array[Dictionary]) -> void:
	var seen_ids: Dictionary = {}
	for dataset_name: String in GAMEPLAY_DATASETS:
		var dataset_config_value: Variant = datasets.get(dataset_name, null)
		if not _dataset_config_is_runtime_safe(dataset_name, dataset_config_value):
			continue
		var dataset_config: Dictionary = dataset_config_value
		var state: String = dataset_config["state"]
		if state not in ["partial", "ready"]:
			continue
		var records: Array = gameplay.get(dataset_name, [])
		for record_value: Variant in records:
			if not record_value is Dictionary:
				continue
			var record: Dictionary = record_value
			_validate_gameplay_id(record, dataset_name, dataset_config, seen_ids, issues)
			if dataset_name == "weapons":
				_validate_weapon(record, dataset_config, issues)
			elif dataset_name == "upgrades":
				_validate_upgrade(record, dataset_config, issues)
			elif dataset_name == "characters":
				_validate_character(record, dataset_config, issues)
			elif dataset_name == "waves":
				_validate_wave(record, dataset_config, issues)
			elif dataset_name == "unlocks":
				_validate_unlock(record, dataset_config, issues)
			_validate_references(record, gameplay, datasets, dataset_config, issues)
	if _dataset_state(datasets, "upgrades") == "ready":
		_validate_upgrade_catalog(gameplay.get("upgrades", []), datasets["upgrades"], issues)
	if _dataset_state(datasets, "characters") == "ready" and _dataset_state(datasets, "upgrades") == "ready":
		_validate_character_catalog(gameplay.get("characters", []), gameplay.get("upgrades", []), datasets["characters"], issues)
	if _dataset_state(datasets, "weapons") == "ready" and _dataset_state(datasets, "upgrades") == "ready":
		_validate_mutation_catalog(gameplay.get("weapons", []), gameplay.get("upgrades", []), datasets["weapons"], issues)
	if _dataset_state(datasets, "waves") == "ready" and _dataset_state(datasets, "enemies") == "ready":
		_validate_wave_catalog(gameplay.get("waves", []), gameplay.get("enemies", []), datasets["waves"], issues)
	if _dataset_state(datasets, "unlocks") == "ready":
		_validate_unlock_catalog(gameplay.get("unlocks", []), datasets["unlocks"], issues)

static func _validate_gameplay_id(
	record: Dictionary,
	dataset_name: String,
	dataset_config: Dictionary,
	seen_ids: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var identifier: String = String(record.get("id", ""))
	var path: String = record.get("source_path", dataset_config["path"])
	var target_gate: String = dataset_config["target_gate"]
	if not _is_snake_case(identifier):
		issues.append(_issue("ERROR", "ID001", path, record.get("source_line", 0), identifier, "Gameplay ID must be nonempty snake_case.", "snake_case", identifier, target_gate))
	if seen_ids.has(identifier):
		issues.append(_issue("ERROR", "ID001", path, record.get("source_line", 0), identifier, "Gameplay ID must be unique across gameplay datasets.", "unique across gameplay datasets", seen_ids[identifier], target_gate))
	else:
		seen_ids[identifier] = dataset_name

static func _validate_weapon(record: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var positive_fields: Array[String] = [
		"damage", "shots_per_second", "magazine_size", "reload_duration", "range_pixels",
	]
	for field: String in positive_fields:
		if not record.has(field) or not record[field] is int and not record[field] is float or float(record[field]) <= 0.0:
			issues.append(_record_issue("WPN001", record, dataset_config, "Weapon %s must be numeric and positive." % field, "> 0", record.get(field)))
	for field: String in [
		"base_spread_degrees", "moving_spread_addition_degrees", "recoil_per_shot",
		"recoil_recovery_per_second", "recoil_spread_coefficient",
		"maximum_recoil_bias_degrees", "maximum_visual_kick_pixels",
	]:
		if record.has(field) and (not record[field] is int and not record[field] is float or float(record[field]) < 0.0):
			issues.append(_record_issue("WPN001", record, dataset_config, "Weapon %s must be numeric and nonnegative." % field, ">= 0", record.get(field)))
	if record.has("pierce_count"):
		var pierce_count: Variant = record.get("pierce_count")
		if not _is_integral_number(pierce_count) or int(pierce_count) < 0:
			issues.append(_record_issue("WPN001", record, dataset_config, "Weapon pierce_count must be a nonnegative integer.", ">= 0", pierce_count))
	if record.has("pierce_decay"):
		var pierce_decay: Variant = record.get("pierce_decay")
		if not pierce_decay is int and not pierce_decay is float or not is_finite(float(pierce_decay)) or float(pierce_decay) < 0.0 or float(pierce_decay) > 1.0:
			issues.append(_record_issue("WPN001", record, dataset_config, "Weapon pierce_decay must be within 0..1.", "0..1", pierce_decay))
	if record.has("weakpoint_multiplier"):
		var weakpoint_multiplier: Variant = record.get("weakpoint_multiplier")
		if not weakpoint_multiplier is int and not weakpoint_multiplier is float or not is_finite(float(weakpoint_multiplier)) or float(weakpoint_multiplier) < 1.0:
			issues.append(_record_issue("WPN001", record, dataset_config, "Weapon weakpoint_multiplier must be at least 1.", ">= 1", weakpoint_multiplier))

static func _validate_upgrade(record: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var category: String = record.get("category", "")
	if category not in UPGRADE_CATEGORIES:
		issues.append(_record_issue("UPG002", record, dataset_config, "Upgrade category is unknown.", UPGRADE_CATEGORIES, category))
	if category == "mutation" and record.has("requires_upgrade_id") and String(record.get("requires_upgrade_id")).is_empty():
		issues.append(_record_issue("MUT001", record, dataset_config, "Mutation prerequisite reference must be nonempty when declared.", "upgrade id", record.get("requires_upgrade_id")))

static func _validate_character(record: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	if record.has("display_name") and String(record.get("display_name", "")).strip_edges().is_empty():
		issues.append(_record_issue("CHR001", record, dataset_config, "Character display_name must be nonempty when declared.", "nonempty", record.get("display_name")))

static func _validate_wave(record: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var expected_range: Array = dataset_config["expected_range"]
	var wave_number_value: Variant = record.get("wave", record.get("number", null))
	var lower: int = int(expected_range[0]) if expected_range.size() >= 2 else 1
	var upper: int = int(expected_range[1]) if expected_range.size() >= 2 else 20
	if not _is_integral_number(wave_number_value) or int(wave_number_value) < lower or int(wave_number_value) > upper:
		issues.append(_record_issue("WAVE001", record, dataset_config, "Wave number must be an integer in the declared range.", expected_range, wave_number_value))

static func _validate_unlock(record: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	if record.has("target_id") and String(record.get("target_id", "")).is_empty():
		issues.append(_record_issue("ULK001", record, dataset_config, "Unlock target_id must be nonempty when declared.", "gameplay id", record.get("target_id")))

static func _validate_references(
	record: Dictionary,
	gameplay: Dictionary,
	datasets: Dictionary,
	source_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var reference_targets: Dictionary = {
		"weapon_id": "weapons",
		"throwable_id": "throwables",
		"character_id": "characters",
		"upgrade_id": "upgrades",
		"enemy_id": "enemies",
		"wave_id": "waves",
		"unlock_id": "unlocks",
		"requires_upgrade_id": "upgrades",
	}
	for field_value: Variant in reference_targets:
		var field: String = String(field_value)
		if not record.has(field) or String(record.get(field, "")).is_empty():
			continue
		var target_dataset: String = reference_targets[field]
		if not datasets.has(target_dataset):
			continue
		var target_config_value: Variant = datasets[target_dataset]
		if not target_config_value is Dictionary or not _dataset_config_is_runtime_safe(target_dataset, target_config_value):
			continue
		var target_config: Dictionary = target_config_value
		var target_records: Array = gameplay.get(target_dataset, [])
		var expected_id: String = String(record[field])
		if target_records.is_empty():
			issues.append(_not_ready_issue("REF001", record.get("source_path", source_config["path"]), String(record.get("id", "")), "Reference target dataset %s is not present." % target_dataset, expected_id, 0, target_config["target_gate"]))
			continue
		var resolved: bool = false
		for target_record_value: Variant in target_records:
			if target_record_value is Dictionary and String((target_record_value as Dictionary).get("id", "")) == expected_id:
				resolved = true
				break
		if not resolved:
			issues.append(_record_issue("REF001", record, source_config, "Reference %s does not resolve." % field, expected_id, null))

static func _validate_upgrade_catalog(
	records: Array,
	dataset_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var expected_categories: Dictionary = dataset_config["expected_categories"]
	var actual_categories: Dictionary = {}
	for category: String in UPGRADE_CATEGORIES:
		actual_categories[category] = 0
	for record_value: Variant in records:
		if not record_value is Dictionary:
			continue
		var category: String = String((record_value as Dictionary).get("category", ""))
		if actual_categories.has(category):
			actual_categories[category] += 1
	var category_counts_match: bool = true
	for category: String in UPGRADE_CATEGORIES:
		if int(actual_categories[category]) != int(expected_categories[category]):
			category_counts_match = false
	if not category_counts_match:
		issues.append(_issue(
			"ERROR", "UPG001", dataset_config["path"], 0, "upgrades",
			"Upgrade category counts must match the declared matrix.",
			expected_categories, actual_categories, dataset_config["target_gate"]
		))

	var upgrades_by_id: Dictionary = _records_by_id(records)
	for record_value: Variant in records:
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var identifier: String = String(record.get("id", ""))
		var conflicts_value: Variant = record.get("conflicts", [])
		if not conflicts_value is Array:
			issues.append(_record_issue("UPG002", record, dataset_config, "Upgrade conflicts must be an array.", "Array", conflicts_value))
			continue
		var conflicts: Array = conflicts_value
		for conflict_value: Variant in conflicts:
			var conflict_id: String = String(conflict_value)
			if conflict_id == identifier:
				issues.append(_record_issue("UPG002", record, dataset_config, "Upgrade conflicts must not reference self.", "different upgrade id", conflict_id))
				continue
			if not upgrades_by_id.has(conflict_id):
				issues.append(_record_issue("UPG002", record, dataset_config, "Upgrade conflict does not resolve.", "existing upgrade id", conflict_id))
				continue
			var target_record: Dictionary = upgrades_by_id[conflict_id]
			var target_conflicts_value: Variant = target_record.get("conflicts", [])
			var target_conflicts: Array = target_conflicts_value if target_conflicts_value is Array else []
			if identifier not in target_conflicts:
				issues.append(_record_issue("UPG002", record, dataset_config, "Upgrade conflict must be symmetric.", identifier, target_conflicts))

static func _validate_character_catalog(
	characters: Array,
	upgrades: Array,
	dataset_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var upgrades_by_id: Dictionary = _records_by_id(upgrades)
	for character_value: Variant in characters:
		if not character_value is Dictionary:
			continue
		var character: Dictionary = character_value
		var character_id: String = String(character.get("id", ""))
		var module_ids_value: Variant = character.get("module_ids", [])
		var module_ids: Array = module_ids_value if module_ids_value is Array else []
		var distinct_module_ids: Dictionary = {}
		for module_id_value: Variant in module_ids:
			distinct_module_ids[String(module_id_value)] = true
		if not module_ids_value is Array or module_ids.size() != 3 or distinct_module_ids.size() != 3:
			issues.append(_record_issue("CHR001", character, dataset_config, "Character must declare exactly three distinct module IDs.", "exactly 3 distinct module ids", module_ids_value))
		for module_id_value: Variant in module_ids:
			var module_id: String = String(module_id_value)
			if not upgrades_by_id.has(module_id) or String((upgrades_by_id[module_id] as Dictionary).get("category", "")) != "module":
				issues.append(_record_issue("CHR001", character, dataset_config, "Character module ID must resolve to a module upgrade.", "existing module upgrade id", module_id))
				continue
			var module_record: Dictionary = upgrades_by_id[module_id]
			var owner_id: String = String(module_record.get("character_id", ""))
			if owner_id != character_id:
				issues.append(_record_issue("CHR001", character, dataset_config, "Character module back-reference must name its owner.", character_id, owner_id))

static func _validate_mutation_catalog(
	weapons: Array,
	upgrades: Array,
	dataset_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var mutations_by_weapon: Dictionary = {}
	for upgrade_value: Variant in upgrades:
		if not upgrade_value is Dictionary:
			continue
		var upgrade: Dictionary = upgrade_value
		if upgrade.get("category") != "mutation":
			continue
		var weapon_id: String = String(upgrade.get("weapon_id", ""))
		mutations_by_weapon[weapon_id] = int(mutations_by_weapon.get(weapon_id, 0)) + 1
	for weapon_value: Variant in weapons:
		if not weapon_value is Dictionary:
			continue
		var weapon: Dictionary = weapon_value
		var weapon_id: String = String(weapon.get("id", ""))
		var mutation_count: int = int(mutations_by_weapon.get(weapon_id, 0))
		if mutation_count < 1:
			issues.append(_record_issue("MUT001", weapon, dataset_config, "Every weapon must have at least one mutation upgrade.", ">= 1 mutation", mutation_count))

static func _validate_wave_catalog(
	waves: Array,
	enemies: Array,
	dataset_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var expected_range: Array = dataset_config["expected_range"]
	var lower: int = int(expected_range[0])
	var upper: int = int(expected_range[1])
	var enemies_by_id: Dictionary = _records_by_id(enemies)
	var seen_numbers: Dictionary = {}
	for wave_value: Variant in waves:
		if not wave_value is Dictionary:
			continue
		var wave: Dictionary = wave_value
		var wave_number_value: Variant = wave.get("wave", wave.get("number", null))
		if _is_integral_number(wave_number_value):
			var wave_number: int = int(wave_number_value)
			if seen_numbers.has(wave_number):
				issues.append(_record_issue("WAVE001", wave, dataset_config, "Wave number must be unique.", "unique wave number", wave_number_value))
			else:
				seen_numbers[wave_number] = true
		var enemy_ids_value: Variant = wave.get("enemy_ids", [])
		if not enemy_ids_value is Array or enemy_ids_value.is_empty():
			issues.append(_record_issue("WAVE001", wave, dataset_config, "Wave must declare at least one enemy ID.", "nonempty enemy_ids", enemy_ids_value))
			continue
		for enemy_id_value: Variant in enemy_ids_value:
			var enemy_id: String = String(enemy_id_value)
			if not enemies_by_id.has(enemy_id):
				issues.append(_record_issue("WAVE001", wave, dataset_config, "Wave enemy reference does not resolve.", enemy_id, null))
	var missing_numbers: Array[int] = []
	for wave_number: int in range(lower, upper + 1):
		if not seen_numbers.has(wave_number):
			missing_numbers.append(wave_number)
	if not missing_numbers.is_empty():
		issues.append(_issue(
			"ERROR", "WAVE001", dataset_config["path"], 0, "waves",
			"Wave catalog is missing declared wave numbers.",
			expected_range, missing_numbers, dataset_config["target_gate"]
		))

static func _validate_unlock_catalog(
	records: Array,
	dataset_config: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var unlocks_by_id: Dictionary = _records_by_id(records)
	var dependency_counts: Dictionary = {}
	var dependents: Dictionary = {}
	for identifier_value: Variant in unlocks_by_id:
		var identifier: String = String(identifier_value)
		dependency_counts[identifier] = 0
		dependents[identifier] = []
	for record_value: Variant in records:
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var identifier: String = String(record.get("id", ""))
		var dependencies_value: Variant = record.get("requires_unlock_ids", [])
		if not dependencies_value is Array:
			issues.append(_record_issue("ULK001", record, dataset_config, "Unlock dependencies must be an array.", "Array", dependencies_value))
			continue
		var distinct_dependencies: Dictionary = {}
		for dependency_value: Variant in dependencies_value:
			var dependency_id: String = String(dependency_value)
			if distinct_dependencies.has(dependency_id):
				continue
			distinct_dependencies[dependency_id] = true
			if not unlocks_by_id.has(dependency_id):
				issues.append(_record_issue("ULK001", record, dataset_config, "Unlock dependency does not resolve.", "existing unlock id", dependency_id))
				continue
			dependency_counts[identifier] = int(dependency_counts.get(identifier, 0)) + 1
			var dependency_dependents: Array = dependents.get(dependency_id, [])
			dependency_dependents.append(identifier)
			dependents[dependency_id] = dependency_dependents
	var queue: Array[String] = []
	for identifier_value: Variant in dependency_counts:
		var identifier: String = String(identifier_value)
		if int(dependency_counts[identifier]) == 0:
			queue.append(identifier)
	queue.sort()
	var visited_count: int = 0
	while not queue.is_empty():
		var identifier: String = queue.pop_front()
		visited_count += 1
		var dependency_dependents: Array = dependents.get(identifier, [])
		dependency_dependents.sort()
		for dependent_value: Variant in dependency_dependents:
			var dependent_id: String = String(dependent_value)
			dependency_counts[dependent_id] = int(dependency_counts[dependent_id]) - 1
			if int(dependency_counts[dependent_id]) == 0:
				queue.append(dependent_id)
		queue.sort()
	if visited_count != unlocks_by_id.size():
		issues.append(_issue(
			"ERROR", "ULK001", dataset_config["path"], 0, "unlocks",
			"Unlock dependency graph must be acyclic.",
			"acyclic", "cycle", dataset_config["target_gate"]
		))

static func _records_by_id(records: Array) -> Dictionary:
	var records_by_id: Dictionary = {}
	for record_value: Variant in records:
		if record_value is Dictionary:
			var record: Dictionary = record_value
			records_by_id[String(record.get("id", ""))] = record
	return records_by_id

static func _build_report(profile: String, input_issues: Array[Dictionary], argument_error: bool = false) -> Dictionary:
	var issues: Array[Dictionary] = input_issues.duplicate(true)
	issues.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_key: Array = [first.get("severity", ""), first.get("rule", ""), first.get("path", ""), int(first.get("line", 0)), first.get("subject", "")]
		var second_key: Array = [second.get("severity", ""), second.get("rule", ""), second.get("path", ""), int(second.get("line", 0)), second.get("subject", "")]
		for index: int in range(first_key.size()):
			if first_key[index] == second_key[index]:
				continue
			return first_key[index] < second_key[index]
		return false
	)
	var counts: Dictionary = {"error": 0, "warning": 0, "not_ready": 0}
	for issue: Dictionary in issues:
		if issue.get("severity") == "ERROR":
			counts["error"] += 1
		elif issue.get("severity") == "WARNING":
			counts["warning"] += 1
		elif issue.get("severity") == "NOT_READY":
			counts["not_ready"] += 1
	var gate_status: String = "pass"
	if argument_error or counts["error"] > 0:
		gate_status = "fail"
	elif profile == "full" and counts["not_ready"] > 0:
		gate_status = "fail"
	elif profile == "g0":
		for issue: Dictionary in issues:
			if issue.get("severity") == "NOT_READY" and _gate_is_g0_or_earlier(issue.get("target_gate", "G0")):
				gate_status = "fail"
				break
	var report: Dictionary = {
		"profile": profile,
		"gate_status": gate_status,
		"catalog_status": "not_ready" if counts["not_ready"] > 0 else "ready",
		"counts": counts,
		"issues": issues,
	}
	if argument_error:
		report["argument_error"] = true
	return report

static func _argument_error_report(message: String) -> Dictionary:
	var issues: Array[Dictionary] = [
		_issue("ERROR", "CLI001", "", 0, "arguments", message, "valid CLI arguments", null, "G0"),
	]
	return _build_report("", issues, true)

static func _issue(
	severity: String,
	rule: String,
	path: String,
	line: int,
	subject: String,
	message: String,
	expected: Variant,
	actual: Variant,
	target_gate: String
) -> Dictionary:
	return {
		"severity": severity,
		"rule": rule,
		"path": path.trim_prefix("res://"),
		"line": line,
		"subject": subject,
		"message": message,
		"expected": expected,
		"actual": actual,
		"target_gate": target_gate,
	}

static func _not_ready_issue(
	rule: String,
	path: String,
	subject: String,
	message: String,
	expected: Variant,
	actual: Variant,
	target_gate: String
) -> Dictionary:
	return _issue("NOT_READY", rule, path, 0, subject, message, expected, actual, target_gate)

static func _record_issue(
	rule: String,
	record: Dictionary,
	dataset_config: Dictionary,
	message: String,
	expected: Variant,
	actual: Variant
) -> Dictionary:
	return _issue(
		"ERROR", rule, record.get("source_path", dataset_config["path"]),
		record.get("source_line", 0), String(record.get("id", "")), message,
		expected, actual, dataset_config["target_gate"]
	)

static func _dataset_records(snapshot: Dictionary, dataset_name: String) -> Array:
	if dataset_name == "assets":
		return snapshot.get("assets", {}).get("rows", [])
	if dataset_name == "design_documents":
		return snapshot.get("design_documents", {}).get("records", [])
	return snapshot.get("gameplay", {}).get(dataset_name, [])

static func _dataset_has_content(snapshot: Dictionary, dataset_name: String) -> bool:
	if dataset_name == "assets":
		var assets_value: Variant = snapshot.get("assets", {})
		if not assets_value is Dictionary:
			return false
		var assets: Dictionary = assets_value
		var header_value: Variant = assets.get("header", PackedStringArray())
		var has_header: bool = (
			(header_value is PackedStringArray or header_value is Array)
			and header_value.size() > 0
		)
		var rows_value: Variant = assets.get("rows", [])
		return has_header or (rows_value is Array and rows_value.size() > 0)
	if dataset_name == "design_documents":
		var documents_value: Variant = snapshot.get("design_documents", {})
		if not documents_value is Dictionary:
			return false
		var documents: Dictionary = documents_value
		var manifest_value: Variant = documents.get("manifest", {})
		var files_value: Variant = documents.get("actual_markdown_files", [])
		var records_value: Variant = documents.get("records", [])
		return (
			(manifest_value is Dictionary and not manifest_value.is_empty())
			or (files_value is Array and files_value.size() > 0)
			or (records_value is Array and records_value.size() > 0)
		)
	return not _dataset_records(snapshot, dataset_name).is_empty()

static func _dataset_state(datasets: Dictionary, dataset_name: String) -> String:
	var dataset_config_value: Variant = datasets.get(dataset_name, null)
	if not _dataset_config_is_runtime_safe(dataset_name, dataset_config_value):
		return ""
	var dataset_config: Dictionary = dataset_config_value
	return dataset_config["state"]

static func _required_dataset_fields(dataset_name: String) -> Array[String]:
	var fields: Array[String] = ["state", "path", "target_gate"]
	if dataset_name in EXPECTED_COUNT_DATASETS:
		fields.append("expected_count")
	if dataset_name == "upgrades":
		fields.append("expected_categories")
	elif dataset_name == "waves":
		fields.append("expected_range")
	return fields

static func _has_exact_keys(dictionary: Dictionary, expected_keys: Array[String]) -> bool:
	var actual_keys: Array[String] = []
	for key: Variant in dictionary:
		actual_keys.append(String(key))
	var sorted_expected: Array[String] = expected_keys.duplicate()
	actual_keys.sort()
	sorted_expected.sort()
	return actual_keys == sorted_expected

static func _is_integral_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_finite(value) and value == floorf(value)
	return false

static func _validate_expected_categories(
	value: Variant,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	if not value is Dictionary:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "upgrades", "Upgrade expected_categories must be the exact five-key integer matrix.", UPGRADE_CATEGORIES, value, target_gate))
		return
	var categories: Dictionary = value
	var valid: bool = _has_exact_keys(categories, UPGRADE_CATEGORIES)
	for category: String in UPGRADE_CATEGORIES:
		if not _is_integral_number(categories.get(category, null)) or int(categories.get(category, -1)) < 0:
			valid = false
	if not valid:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "upgrades", "Upgrade expected_categories must be the exact five-key nonnegative integer matrix.", UPGRADE_CATEGORIES, categories, target_gate))

static func _validate_expected_range(
	value: Variant,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	var valid: bool = value is Array and value.size() == 2
	if valid:
		valid = _is_integral_number(value[0]) and _is_integral_number(value[1]) and int(value[0]) <= int(value[1])
	if not valid:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "waves", "Wave expected_range must contain two ordered integral numbers.", "two ordered integers", value, target_gate))

static func _dataset_config_is_runtime_safe(dataset_name: String, value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var dataset_config: Dictionary = value
	if not _has_exact_keys(dataset_config, _required_dataset_fields(dataset_name)):
		return false
	if not dataset_config["state"] is String or String(dataset_config["state"]) not in DATASET_STATES:
		return false
	if not dataset_config["path"] is String or not _is_safe_res_path(dataset_config["path"]):
		return false
	if not dataset_config["target_gate"] is String or String(dataset_config["target_gate"]) not in GATE_ORDER:
		return false
	if dataset_name in EXPECTED_COUNT_DATASETS:
		if not _is_integral_number(dataset_config["expected_count"]) or int(dataset_config["expected_count"]) < 0:
			return false
	if dataset_name == "upgrades":
		var categories_value: Variant = dataset_config["expected_categories"]
		if not categories_value is Dictionary or not _has_exact_keys(categories_value, UPGRADE_CATEGORIES):
			return false
		for category: String in UPGRADE_CATEGORIES:
			if not _is_integral_number(categories_value.get(category, null)) or int(categories_value.get(category, -1)) < 0:
				return false
	elif dataset_name == "waves":
		var range_value: Variant = dataset_config["expected_range"]
		if not range_value is Array or range_value.size() != 2:
			return false
		if not _is_integral_number(range_value[0]) or not _is_integral_number(range_value[1]) or int(range_value[0]) > int(range_value[1]):
			return false
	return true

static func _readiness_rule(dataset_name: String) -> String:
	var rules: Dictionary = {
		"assets": "AST001",
		"design_documents": "DOC001",
		"weapons": "WPN001",
		"throwables": "REF001",
		"characters": "CHR001",
		"upgrades": "UPG001",
		"enemies": "ID001",
		"waves": "WAVE001",
		"unlocks": "ULK001",
	}
	return rules.get(dataset_name, "CFG001")

static func _not_implemented_message(dataset_name: String, dataset_config: Dictionary) -> String:
	if dataset_name == "upgrades" and dataset_config.has("expected_count"):
		return "%d-upgrade catalog is declared not_implemented" % int(dataset_config["expected_count"])
	return "%s is declared not_implemented" % dataset_name

static func _expected_for(dataset_config: Dictionary) -> Variant:
	if dataset_config.has("expected_count"):
		return dataset_config["expected_count"]
	if dataset_config.has("expected_range"):
		return dataset_config["expected_range"]
	return null

static func _records_meet_expected(dataset_name: String, records: Array, expected: Variant) -> bool:
	if dataset_name == "waves" and expected is Array and expected.size() >= 2:
		return records.size() == int(expected[1]) - int(expected[0]) + 1
	return records.size() == int(expected)

static func _project_root_for_config(config_path: String) -> String:
	var marker: String = "data/content_validation.json"
	if config_path.ends_with(marker):
		return config_path.trim_suffix(marker)
	return "res://"

static func _gate_is_g0_or_earlier(gate: String) -> bool:
	var gate_index: int = GATE_ORDER.find(gate)
	return gate_index < 0 or gate_index <= GATE_ORDER.find("G0")

static func _is_snake_case(value: String) -> bool:
	if value.is_empty():
		return false
	var expression: RegEx = RegEx.new()
	expression.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return expression.search(value) != null

static func _is_canvas(value: String) -> bool:
	var expression: RegEx = RegEx.new()
	expression.compile("^[1-9][0-9]*x[1-9][0-9]*$")
	return expression.search(value) != null

static func _is_safe_res_path(path: String) -> bool:
	return path.begins_with("res://") and _is_safe_relative_path(path)

static func _is_safe_relative_path(path: String) -> bool:
	if path.is_empty() or path.begins_with("/") or path.contains("\\"):
		return false
	var relative: String = path.trim_prefix("res://")
	for component: String in relative.split("/", false):
		if component == ".." or component == ".":
			return false
	return not relative.contains("://")
