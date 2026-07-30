class_name ContentValidator
extends RefCounted

const LOADER: Script = preload("res://src/content/content_snapshot_loader.gd")
const VALID_PROFILES: Array[StringName] = [&"g0", &"full"]
const DATASET_STATES: Array[String] = ["not_implemented", "legacy", "partial", "ready"]
const GAMEPLAY_DATASETS: Array[String] = [
	"weapons", "throwables", "characters", "upgrades", "enemies", "waves", "unlocks",
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
	var config: Dictionary = snapshot.get("config", {})
	var datasets: Dictionary = config.get("datasets", {})
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
	if config.get("schema_version") != 1:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "schema_version", "Config schema_version must equal 1.", 1, config.get("schema_version"), "G0"))
	if config.get("current_gate") not in GATE_ORDER:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "current_gate", "Config current_gate is unknown.", GATE_ORDER, config.get("current_gate"), "G0"))
	if not config.get("datasets", null) is Dictionary:
		issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, "datasets", "Config datasets must be an object.", "Dictionary", typeof(config.get("datasets")), "G0"))
		return
	for dataset_name_value: Variant in datasets:
		var dataset_name: String = String(dataset_name_value)
		var dataset_config_value: Variant = datasets[dataset_name_value]
		if not dataset_config_value is Dictionary:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset config must be an object.", "Dictionary", typeof(dataset_config_value), "G0"))
			continue
		var dataset_config: Dictionary = dataset_config_value
		var state: String = dataset_config.get("state", "")
		var target_gate: String = dataset_config.get("target_gate", "G0")
		if state not in DATASET_STATES:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset has unknown state.", DATASET_STATES, state, target_gate))
		var path: String = dataset_config.get("path", "")
		if not _is_safe_res_path(path):
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset path must be a safe res:// path.", "safe res:// path", path, target_gate))
		if target_gate not in GATE_ORDER:
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset target_gate is unknown.", GATE_ORDER, target_gate, "G0"))
		if state == "not_implemented" and _dataset_records(snapshot, dataset_name).size() > 0:
			issues.append(_issue("ERROR", "CFG001", path, 0, dataset_name, "Dataset declared not_implemented contains existing records.", 0, _dataset_records(snapshot, dataset_name).size(), target_gate))

static func _validate_readiness(snapshot: Dictionary, datasets: Dictionary, issues: Array[Dictionary]) -> void:
	for dataset_name_value: Variant in datasets:
		var dataset_name: String = String(dataset_name_value)
		var dataset_config_value: Variant = datasets[dataset_name_value]
		if not dataset_config_value is Dictionary:
			continue
		var dataset_config: Dictionary = dataset_config_value
		var state: String = dataset_config.get("state", "")
		if state not in DATASET_STATES:
			continue
		var records: Array = _dataset_records(snapshot, dataset_name)
		var target_gate: String = dataset_config.get("target_gate", "G0")
		var rule: String = _readiness_rule(dataset_name)
		if state == "not_implemented":
			issues.append(_not_ready_issue(rule, dataset_config.get("path", ""), dataset_name, _not_implemented_message(dataset_name, dataset_config), _expected_for(dataset_config), records.size(), target_gate))
		elif state == "legacy":
			issues.append(_not_ready_issue(rule, dataset_config.get("path", ""), dataset_name, "%s is declared legacy" % dataset_name, "ready", "legacy", target_gate))
		elif state == "partial":
			var expected: Variant = _expected_for(dataset_config)
			if expected != null and not _records_meet_expected(dataset_name, records, expected):
				issues.append(_not_ready_issue(rule, dataset_config.get("path", ""), dataset_name, "%s catalog is partial" % dataset_name, expected, records.size(), target_gate))
		elif state == "ready":
			var expected: Variant = _expected_for(dataset_config)
			if expected != null and not _records_meet_expected(dataset_name, records, expected):
				issues.append(_issue("ERROR", rule, dataset_config.get("path", ""), 0, dataset_name, "Ready dataset does not meet declared completeness.", expected, records.size(), target_gate))

static func _validate_design_documents(documents: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var records: Array = documents.get("records", [])
	var actual_files: Array = documents.get("actual_markdown_files", [])
	var registered_files: Dictionary = {}
	for record_value: Variant in records:
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var file_name: String = record.get("file", "")
		var path: String = record.get("source_path", dataset_config.get("path", ""))
		if not _is_safe_relative_path(file_name):
			issues.append(_issue("ERROR", "DOC001", path, record.get("source_line", 0), file_name, "Manifest path is missing or unsafe.", "safe relative Markdown path", file_name, dataset_config.get("target_gate", "G0")))
			continue
		if registered_files.has(file_name):
			issues.append(_issue("ERROR", "DOC001", path, record.get("source_line", 0), file_name, "Manifest path is duplicated.", "unique path", file_name, dataset_config.get("target_gate", "G0")))
		else:
			registered_files[file_name] = true
		if not record.get("exists", false):
			issues.append(_issue("ERROR", "DOC002", path, record.get("source_line", 0), file_name, "Registered Markdown file does not exist.", true, false, dataset_config.get("target_gate", "G0")))
			continue
		if record.get("bytes") != record.get("actual_bytes"):
			issues.append(_issue("ERROR", "DOC003", path, record.get("source_line", 0), file_name, "Markdown byte count does not match manifest.", record.get("bytes"), record.get("actual_bytes"), dataset_config.get("target_gate", "G0")))
		if record.get("sha256") != record.get("actual_sha256"):
			issues.append(_issue("ERROR", "DOC003", path, record.get("source_line", 0), file_name, "Markdown SHA-256 does not match manifest.", record.get("sha256"), record.get("actual_sha256"), dataset_config.get("target_gate", "G0")))
	for actual_file_value: Variant in actual_files:
		var actual_file: String = String(actual_file_value)
		var file_name: String = actual_file.get_file()
		if not registered_files.has(file_name):
			issues.append(_issue("ERROR", "DOC002", actual_file, 0, file_name, "Markdown file is not registered in the manifest.", "registered", "unregistered", dataset_config.get("target_gate", "G0")))

static func _validate_assets(assets: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var header: PackedStringArray = assets.get("header", PackedStringArray())
	var rows: Array = assets.get("rows", [])
	var target_gate: String = dataset_config.get("target_gate", "G0")
	if header != ASSET_HEADER:
		issues.append(_issue("ERROR", "AST001", dataset_config.get("path", ""), 1, "asset_manifest", "Asset manifest must use the exact 28-column header.", ASSET_HEADER, header, target_gate))
	var seen_ids: Dictionary = {}
	var xiaodong_states: Array[String] = []
	var has_xiaodong_a5: bool = false
	for row_value: Variant in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		var asset_id: String = row.get("asset_id", "")
		var source_path: String = row.get("source_path", dataset_config.get("path", ""))
		var source_line: int = row.get("source_line", 0)
		if row.get("_column_count", ASSET_HEADER.size()) != ASSET_HEADER.size():
			issues.append(_issue("ERROR", "AST001", source_path, source_line, asset_id, "Asset row must contain exactly 28 columns.", 28, row.get("_column_count"), target_gate))
		_validate_asset_schema(row, seen_ids, source_path, source_line, target_gate, issues)
		_validate_asset_evidence(row, source_path, source_line, target_gate, issues)
		_validate_asset_prompt(row, source_path, source_line, target_gate, issues)
		if row.get("phase") == "A5" and row.get("subject") == "xiaodong":
			has_xiaodong_a5 = true
			xiaodong_states.append(row.get("state", ""))
	if has_xiaodong_a5:
		var sorted_actual: Array[String] = xiaodong_states.duplicate()
		var sorted_expected: Array[String] = XIAODONG_A5_STATES.duplicate()
		sorted_actual.sort()
		sorted_expected.sort()
		if sorted_actual != sorted_expected:
			issues.append(_issue("ERROR", "AST005", dataset_config.get("path", ""), 0, "xiaodong", "A5 Xiaodong must have exactly idle/walk/hit/death/skill_breakin/portrait.", sorted_expected, sorted_actual, target_gate))

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
	for dataset_name: String in GAMEPLAY_DATASETS:
		var dataset_config: Dictionary = datasets.get(dataset_name, {})
		var state: String = dataset_config.get("state", "")
		if state not in ["partial", "ready"]:
			continue
		var records: Array = gameplay.get(dataset_name, [])
		var seen_ids: Dictionary = {}
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

static func _validate_gameplay_id(
	record: Dictionary,
	dataset_name: String,
	dataset_config: Dictionary,
	seen_ids: Dictionary,
	issues: Array[Dictionary]
) -> void:
	var identifier: String = String(record.get("id", ""))
	var path: String = record.get("source_path", dataset_config.get("path", ""))
	var target_gate: String = dataset_config.get("target_gate", "G0")
	if not _is_snake_case(identifier):
		issues.append(_issue("ERROR", "ID001", path, record.get("source_line", 0), identifier, "Gameplay ID must be nonempty snake_case.", "snake_case", identifier, target_gate))
	if seen_ids.has(identifier):
		issues.append(_issue("ERROR", "ID001", path, record.get("source_line", 0), identifier, "Gameplay ID must be unique within %s." % dataset_name, "unique", identifier, target_gate))
	else:
		seen_ids[identifier] = true

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
	if record.has("pierce_count") and int(record.get("pierce_count", -1)) < 0:
		issues.append(_record_issue("WPN001", record, dataset_config, "Weapon pierce_count must be nonnegative.", ">= 0", record.get("pierce_count")))
	if record.has("pierce_decay") and (float(record.get("pierce_decay", -1.0)) < 0.0 or float(record.get("pierce_decay", 2.0)) > 1.0):
		issues.append(_record_issue("WPN001", record, dataset_config, "Weapon pierce_decay must be within 0..1.", "0..1", record.get("pierce_decay")))
	if record.has("weakpoint_multiplier") and float(record.get("weakpoint_multiplier", 0.0)) < 1.0:
		issues.append(_record_issue("WPN001", record, dataset_config, "Weapon weakpoint_multiplier must be at least 1.", ">= 1", record.get("weakpoint_multiplier")))

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
	var expected_range: Array = dataset_config.get("expected_range", [1, 20])
	var wave_number_value: Variant = record.get("wave", record.get("number", null))
	var lower: int = int(expected_range[0]) if expected_range.size() >= 2 else 1
	var upper: int = int(expected_range[1]) if expected_range.size() >= 2 else 20
	if not wave_number_value is int or int(wave_number_value) < lower or int(wave_number_value) > upper:
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
		var target_records: Array = gameplay.get(target_dataset, [])
		var target_config: Dictionary = datasets.get(target_dataset, {})
		var expected_id: String = String(record[field])
		if target_records.is_empty():
			issues.append(_not_ready_issue("REF001", record.get("source_path", source_config.get("path", "")), String(record.get("id", "")), "Reference target dataset %s is not present." % target_dataset, expected_id, 0, target_config.get("target_gate", source_config.get("target_gate", "G0"))))
			continue
		var resolved: bool = false
		for target_record_value: Variant in target_records:
			if target_record_value is Dictionary and String((target_record_value as Dictionary).get("id", "")) == expected_id:
				resolved = true
				break
		if not resolved:
			issues.append(_record_issue("REF001", record, source_config, "Reference %s does not resolve." % field, expected_id, null))

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
		"ERROR", rule, record.get("source_path", dataset_config.get("path", "")),
		record.get("source_line", 0), String(record.get("id", "")), message,
		expected, actual, dataset_config.get("target_gate", "G0")
	)

static func _dataset_records(snapshot: Dictionary, dataset_name: String) -> Array:
	if dataset_name == "assets":
		return snapshot.get("assets", {}).get("rows", [])
	if dataset_name == "design_documents":
		return snapshot.get("design_documents", {}).get("records", [])
	return snapshot.get("gameplay", {}).get(dataset_name, [])

static func _dataset_state(datasets: Dictionary, dataset_name: String) -> String:
	var dataset_config: Dictionary = datasets.get(dataset_name, {})
	return dataset_config.get("state", "")

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
