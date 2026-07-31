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
	"forge_mode", "raw_layout", "prompt_path", "pipeline_meta", "scale_profile",
	"source_output", "cleaned_output", "qa_record", "godot_evidence",
]
const LEGACY_ASSET_HEADER: PackedStringArray = [
	"asset_id", "phase", "category", "subject", "state", "path", "logical_canvas",
	"pivot", "frames", "fps", "prompt_section", "status", "notes",
	"generation_canvas", "direction", "collision_reference", "palette",
	"negative_constraints", "godot_import", "reviewer", "reference_source",
	"reference_sha256", "reference_rights_policy", "sprite_layout",
	"source_output", "cleaned_output", "qa_record", "godot_evidence",
]
const ASSET_PHASES: Array[String] = ["A0", "A1", "A2", "A3", "A4", "A5"]
const ASSET_CATEGORIES: Array[String] = [
	"arena", "boss", "character", "effect", "enemy", "pickup", "projectile",
	"reference", "throwable", "ui", "weapon",
]
const ASSET_STATUSES: Array[String] = ["planned", "generated", "cleaned", "approved", "in_game", "rejected"]
const GENERATED_OR_LATER: Array[String] = ["generated", "cleaned", "approved", "in_game", "rejected"]
const FORGE_MODES: Array[String] = ["generate2dsprite", "generate2dmap", "runtime_native", "procedural_placeholder"]
const ASSET_MANIFEST_SCHEMA_FIELDS: Array[String] = ["canonical_columns", "legacy_fixture_columns", "forge_modes"]
const XIAODONG_A5_DELIVERABLES: Dictionary = {
	"character_xiaodong_idle": {
		"category": "character", "state": "idle",
		"path": "assets/characters/xiaodong/character_xiaodong_idle.png",
		"logical_canvas": "128x128", "pivot": "feet_center",
		"frames": "4", "fps": "5", "direction": "down_right",
		"sprite_layout": "horizontal_4x1",
	},
	"character_xiaodong_walk": {
		"category": "character", "state": "walk",
		"path": "assets/characters/xiaodong/character_xiaodong_walk.png",
		"logical_canvas": "128x128", "pivot": "feet_center",
		"frames": "64", "fps": "10", "direction": "eight_way",
		"sprite_layout": "grid_8x8",
	},
	"character_xiaodong_hit": {
		"category": "character", "state": "hit",
		"path": "assets/characters/xiaodong/character_xiaodong_hit.png",
		"logical_canvas": "128x128", "pivot": "feet_center",
		"frames": "2", "fps": "12", "direction": "down_right",
		"sprite_layout": "horizontal_2x1",
	},
	"character_xiaodong_death": {
		"category": "character", "state": "death",
		"path": "assets/characters/xiaodong/character_xiaodong_death.png",
		"logical_canvas": "128x128", "pivot": "feet_center",
		"frames": "6", "fps": "10", "direction": "down_right",
		"sprite_layout": "horizontal_6x1",
	},
	"character_xiaodong_skill_breakin": {
		"category": "character", "state": "skill_breakin",
		"path": "assets/characters/xiaodong/character_xiaodong_skill_breakin.png",
		"logical_canvas": "128x128", "pivot": "feet_center",
		"frames": "6", "fps": "12", "direction": "down_right",
		"sprite_layout": "horizontal_6x1",
	},
	"portrait_xiaodong": {
		"category": "ui", "state": "portrait",
		"path": "assets/ui/portraits/portrait_xiaodong.png",
		"logical_canvas": "128x128", "pivot": "center",
		"frames": "1", "fps": "0", "direction": "none",
		"sprite_layout": "single",
	},
	"character_xiaodong_grip_pistol_back": {
		"category": "character", "state": "grip_pistol_back",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_back.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
	"character_xiaodong_grip_pistol_front": {
		"category": "character", "state": "grip_pistol_front",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_front.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
	"character_xiaodong_grip_rifle_back": {
		"category": "character", "state": "grip_rifle_back",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_back.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
	"character_xiaodong_grip_rifle_front": {
		"category": "character", "state": "grip_rifle_front",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_front.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
	"character_xiaodong_grip_sniper_back": {
		"category": "character", "state": "grip_sniper_back",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_back.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
	"character_xiaodong_grip_sniper_front": {
		"category": "character", "state": "grip_sniper_front",
		"path": "assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_front.png",
		"logical_canvas": "128x128", "pivot": "shoulder_pivot",
		"frames": "8", "fps": "0", "direction": "eight_way",
		"sprite_layout": "horizontal_8x1",
	},
}
const XIAODONG_STATIC_DIRECTIONAL_BANK_IDS: Array[String] = [
	"character_xiaodong_grip_pistol_back",
	"character_xiaodong_grip_pistol_front",
	"character_xiaodong_grip_rifle_back",
	"character_xiaodong_grip_rifle_front",
	"character_xiaodong_grip_sniper_back",
	"character_xiaodong_grip_sniper_front",
]
const XIAODONG_DESIGN_CARD_PATH: String = "assets/characters/xiaodong/character_xiaodong_design.md"
const XIAODONG_REFERENCE_PATH: String = "assets/source/references/characters/xiaodong/reference_01.jpg"
const XIAODONG_REFERENCE_BYTES: int = 77554
const XIAODONG_REFERENCE_WIDTH: int = 853
const XIAODONG_REFERENCE_HEIGHT: int = 1280
const XIAODONG_REFERENCE_SHA256: String = "fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52"
const XIAODONG_CARD_FIELDS: Array[String] = [
	"schema_version", "subject", "design_stage", "asset_stage", "artifact_state",
	"decision", "candidate_count", "reference", "boundary",
]
const XIAODONG_CARD_REFERENCE_FIELDS: Array[String] = [
	"path", "bytes", "width", "height", "sha256", "rights_policy",
]
const XIAODONG_CARD_BOUNDARY_FIELDS: Array[String] = [
	"c0_changes_a5_status", "c0_enters_godot", "a5_status", "a5_gate",
]
const XIAODONG_ARTIFACT_STATES: Array[String] = ["not_generated", "generated", "cleaned", "rejected"]
const XIAODONG_DECISIONS: Array[String] = ["pending_review", "accepted_for_concept", "revise", "rejected"]
const UPGRADE_CATEGORIES: Array[String] = ["calibration", "engine", "mutation", "module", "contract"]
const GAMEPLAY_ID_PREFIXES: Dictionary = {
	"characters": "char_",
	"weapons": "wpn_",
	"throwables": "throw_",
	"upgrades": "upgrade_",
	"enemies": "enemy_",
}

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
		if not _has_required_keys_with_optional(dataset_config, required_fields, ["manifest_schema"] if dataset_name == "assets" else []):
			issues.append(_issue("ERROR", "CFG001", "data/content_validation.json", 0, dataset_name, "Dataset must use the exact fields %s." % "/".join(required_fields), required_fields, dataset_config.keys(), "G0"))
		if dataset_name == "assets" and dataset_config.has("manifest_schema"):
			_validate_asset_manifest_schema(dataset_config["manifest_schema"], issues)
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
	var design_root: String = String(dataset_config["path"]).get_base_dir()
	if not records.is_empty():
		design_root = String((records[0] as Dictionary).get("source_path", design_root)).get_base_dir()
	for actual_file_value: Variant in actual_files:
		var actual_file: String = String(actual_file_value)
		var file_name: String = actual_file.trim_prefix(design_root + "/")
		if not registered_files.has(file_name):
			issues.append(_issue("ERROR", "DOC002", actual_file, 0, file_name, "Markdown file is not registered in the manifest.", "registered", "unregistered", dataset_config["target_gate"]))

static func _validate_assets(assets: Dictionary, dataset_config: Dictionary, issues: Array[Dictionary]) -> void:
	var header: PackedStringArray = assets.get("header", PackedStringArray())
	var rows: Array = assets.get("rows", [])
	var target_gate: String = dataset_config["target_gate"]
	var is_legacy_header: bool = header == LEGACY_ASSET_HEADER
	if header != ASSET_HEADER and not is_legacy_header:
		issues.append(_issue("ERROR", "AST001", dataset_config["path"], 1, "asset_manifest", "Asset manifest must use the canonical 33-column header or the supported legacy 28-column fixture header.", ASSET_HEADER, header, target_gate))
	var seen_ids: Dictionary = {}
	var xiaodong_rows: Dictionary = {}
	var xiaodong_row_count: int = 0
	var duplicate_xiaodong_ids: Array[String] = []
	for row_value: Variant in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		var asset_id: String = row.get("asset_id", "")
		var source_path: String = row.get("source_path", dataset_config["path"])
		var source_line: int = row.get("source_line", 0)
		var expected_column_count: int = LEGACY_ASSET_HEADER.size() if is_legacy_header else ASSET_HEADER.size()
		if row.get("_column_count", expected_column_count) != expected_column_count:
			issues.append(_issue("ERROR", "AST001", source_path, source_line, asset_id, "Asset row must contain exactly %d columns." % expected_column_count, expected_column_count, row.get("_column_count"), target_gate))
		_validate_asset_schema(row, seen_ids, source_path, source_line, target_gate, issues)
		_validate_asset_evidence(row, source_path, source_line, target_gate, issues)
		_validate_asset_prompt(row, source_path, source_line, target_gate, issues)
		_validate_asset_forge_contract(row, source_path, source_line, target_gate, issues)
		if row.get("phase") == "A5" and row.get("subject") == "xiaodong":
			xiaodong_row_count += 1
			var xiaodong_asset_id: String = String(row.get("asset_id", ""))
			if xiaodong_rows.has(xiaodong_asset_id):
				duplicate_xiaodong_ids.append(xiaodong_asset_id)
			xiaodong_rows[xiaodong_asset_id] = row

	var expected_ids: Array[String] = []
	for expected_id_value: Variant in XIAODONG_A5_DELIVERABLES.keys():
		expected_ids.append(String(expected_id_value))
	expected_ids.sort()
	var actual_ids: Array[String] = []
	for actual_id_value: Variant in xiaodong_rows.keys():
		actual_ids.append(String(actual_id_value))
	actual_ids.sort()

	var contract_reasons: Array[String] = []
	if xiaodong_row_count != 12:
		contract_reasons.append("row count differs: expected=12 actual=%d" % xiaodong_row_count)
	if not duplicate_xiaodong_ids.is_empty():
		duplicate_xiaodong_ids.sort()
		contract_reasons.append("duplicate asset IDs: %s" % duplicate_xiaodong_ids)
	if actual_ids != expected_ids:
		contract_reasons.append("asset IDs differ: expected=%s actual=%s" % [expected_ids, actual_ids])
	for expected_id: String in expected_ids:
		if not xiaodong_rows.has(expected_id):
			continue
		var expected: Dictionary = XIAODONG_A5_DELIVERABLES[expected_id]
		var actual: Dictionary = xiaodong_rows[expected_id]
		for field_value: Variant in expected.keys():
			var field: String = String(field_value)
			if actual.get(field) != expected[field]:
				contract_reasons.append("%s %s differs: expected=%s actual=%s" % [
					expected_id, field, expected[field], actual.get(field),
				])
	var has_exact_xiaodong_rows: bool = contract_reasons.is_empty()
	if not has_exact_xiaodong_rows:
		issues.append(_issue(
			"ERROR",
			"AST005",
			dataset_config["path"],
			0,
			"xiaodong",
			"A5 Xiaodong must match the exact twelve-item deliverable contract.",
			XIAODONG_A5_DELIVERABLES,
			contract_reasons,
			target_gate
		))
	_validate_xiaodong_governance(
		assets.get("governance", null),
		rows,
		has_exact_xiaodong_rows,
		issues
	)

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
	var valid_single_frame: bool = frames == 1 and is_zero_approx(fps)
	var valid_animation: bool = frames > 1 and fps > 0.0
	var valid_static_bank: bool = _is_static_directional_bank(row, frames, fps)
	if fps < 0.0 or not (valid_single_frame or valid_animation or valid_static_bank):
		issues.append(_issue(
			"ERROR",
			"AST002",
			source_path,
			source_line,
			asset_id,
			"Asset FPS must describe a single frame, animation, or exact eight-direction static bank.",
			"1 frame/0 FPS, animation/>0 FPS, or 8-frame eight_way horizontal_8x1/0 FPS",
			{"frames": row.get("frames"), "fps": row.get("fps")},
			target_gate
		))
	for path_field: String in ["path", "source_output", "cleaned_output", "qa_record", "godot_evidence", "prompt_path", "pipeline_meta"]:
		var path: String = row.get(path_field, "")
		if not path.is_empty() and not _is_safe_relative_path(path):
			issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "%s must be a safe project-relative path." % path_field, "safe relative path", path, target_gate))

static func _is_static_directional_bank(row: Dictionary, frames: int, fps: float) -> bool:
	return (
		row.get("asset_id") in XIAODONG_STATIC_DIRECTIONAL_BANK_IDS
		and frames == 8
		and is_zero_approx(fps)
		and row.get("direction") == "eight_way"
		and row.get("sprite_layout") == "horizontal_8x1"
	)

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
		for evidence_field: String in ["source_output", "cleaned_output", "qa_record", "godot_evidence", "prompt_path", "pipeline_meta"]:
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
		_require_existing_asset_path(row, "godot_evidence", source_path, source_line, target_gate, issues)
		if String(row.get("reviewer", "")).strip_edges().is_empty():
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Approved-or-later assets require a reviewer.", "nonempty reviewer", row.get("reviewer"), target_gate))
	if status == "in_game":
		if String(row.get("godot_import", "")).strip_edges().is_empty():
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "In-game assets require godot_import.", "nonempty godot_import", row.get("godot_import"), target_gate))
	if status == "rejected":
		_require_existing_asset_path(row, "qa_record", source_path, source_line, target_gate, issues)
		if not String(row.get("path", "")).strip_edges().is_empty() or row.get("_path_exists", false):
			issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Rejected assets must not have a stable runtime path.", "empty path", row.get("path"), target_gate))

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

static func _validate_asset_forge_contract(
	row: Dictionary,
	source_path: String,
	source_line: int,
	target_gate: String,
	issues: Array[Dictionary]
) -> void:
	var status: String = String(row.get("status", ""))
	var asset_id: String = String(row.get("asset_id", ""))
	if status == "planned":
		return
	if status in ["generated", "cleaned", "approved", "in_game"]:
		for field: String in ["forge_mode", "raw_layout", "prompt_path", "source_output"]:
			if String(row.get(field, "")).strip_edges().is_empty():
				issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Generated-or-later assets require %s." % field, "nonempty", row.get(field), target_gate))
		for evidence_field: String in ["prompt_path"]:
			_require_existing_asset_path(row, evidence_field, source_path, source_line, target_gate, issues)
		var forge_mode: String = String(row.get("forge_mode", ""))
		if not forge_mode.is_empty() and forge_mode not in FORGE_MODES:
			issues.append(_issue("ERROR", "AST002", source_path, source_line, asset_id, "forge_mode is not a supported generation mode.", FORGE_MODES, forge_mode, target_gate))
	if status in ["cleaned", "approved", "in_game"] and String(row.get("pipeline_meta", "")).strip_edges().is_empty():
		issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Cleaned-or-later assets require pipeline_meta.", "nonempty", row.get("pipeline_meta"), target_gate))
	if status in ["cleaned", "approved", "in_game"]:
		_require_existing_asset_path(row, "pipeline_meta", source_path, source_line, target_gate, issues)
	if status in ["approved", "in_game"] and String(row.get("godot_evidence", "")).strip_edges().is_empty():
		issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Approved-or-later assets require Godot evidence.", "nonempty", row.get("godot_evidence"), target_gate))
	var frames_text: String = String(row.get("frames", ""))
	var is_multi_frame_character: bool = row.get("category") == "character" and frames_text.is_valid_int() and frames_text.to_int() > 1 and row.get("state") not in ["portrait", "grip_pistol_back", "grip_pistol_front", "grip_rifle_back", "grip_rifle_front", "grip_sniper_back", "grip_sniper_front"]
	if status in ["generated", "cleaned", "approved", "in_game"] and is_multi_frame_character and String(row.get("scale_profile", "")).strip_edges().is_empty():
		issues.append(_issue("ERROR", "AST003", source_path, source_line, asset_id, "Multi-action character assets require a shared scale_profile.", "nonempty", row.get("scale_profile"), target_gate))

static func _validate_xiaodong_governance(
	governance_value: Variant,
	rows: Array,
	has_exact_xiaodong_rows: bool,
	issues: Array[Dictionary]
) -> void:
	var xiaodong: Dictionary = {}
	if governance_value is Dictionary:
		var xiaodong_value: Variant = (governance_value as Dictionary).get("xiaodong", null)
		if xiaodong_value is Dictionary:
			xiaodong = xiaodong_value
	var card_validation: Dictionary = _validate_xiaodong_design_card(
		xiaodong.get("design_card", null),
		issues
	)
	var reference_reasons: Array[String] = []
	var actual_reference_value: Variant = xiaodong.get("reference", null)
	var actual_reference: Dictionary = {}
	if not actual_reference_value is Dictionary:
		reference_reasons.append("fixed reference evidence is missing or not an object")
	else:
		actual_reference = actual_reference_value
		if actual_reference.get("path") != XIAODONG_REFERENCE_PATH:
			reference_reasons.append("loader reference path is not the fixed registry path")
		if actual_reference.get("exists") != true:
			reference_reasons.append("fixed reference file is missing")
		else:
			if actual_reference.get("bytes") != XIAODONG_REFERENCE_BYTES:
				reference_reasons.append("reference byte count differs from the approved original")
			if actual_reference.get("jpeg_decoded") != true:
				reference_reasons.append("reference bytes do not decode as JPEG")
			if actual_reference.get("width") != XIAODONG_REFERENCE_WIDTH or actual_reference.get("height") != XIAODONG_REFERENCE_HEIGHT:
				reference_reasons.append("decoded reference dimensions differ from 853x1280")
			if actual_reference.get("sha256") != XIAODONG_REFERENCE_SHA256:
				reference_reasons.append("reference SHA-256 differs from the approved original")

	if card_validation.get("valid", false):
		var card_record: Dictionary = card_validation["record"]
		var card_reference: Dictionary = card_record["reference"]
		if card_reference.get("path") != XIAODONG_REFERENCE_PATH:
			reference_reasons.append("design-card reference path differs from the fixed registry path")
		if card_reference.get("bytes") != XIAODONG_REFERENCE_BYTES:
			reference_reasons.append("design-card reference byte count differs from the approved original")
		if card_reference.get("width") != XIAODONG_REFERENCE_WIDTH or card_reference.get("height") != XIAODONG_REFERENCE_HEIGHT:
			reference_reasons.append("design-card reference dimensions differ from 853x1280")
		if card_reference.get("sha256") != XIAODONG_REFERENCE_SHA256:
			reference_reasons.append("design-card reference SHA-256 differs from the approved original")
		if card_reference.get("rights_policy") != "R2":
			reference_reasons.append("design-card reference rights policy must be R2")

	if has_exact_xiaodong_rows:
		for row_value: Variant in rows:
			if not row_value is Dictionary:
				continue
			var row: Dictionary = row_value
			if row.get("phase") != "A5" or row.get("subject") != "xiaodong":
				continue
			var asset_id: String = String(row.get("asset_id", "xiaodong"))
			if row.get("reference_source") != XIAODONG_REFERENCE_PATH:
				reference_reasons.append("%s reference_source differs from the fixed registry path" % asset_id)
			if row.get("reference_sha256") != XIAODONG_REFERENCE_SHA256:
				reference_reasons.append("%s reference_sha256 differs from the approved original" % asset_id)
			if row.get("reference_rights_policy") != "R2":
				reference_reasons.append("%s reference_rights_policy must be R2" % asset_id)
			if row.get("status") != "planned":
				reference_reasons.append("%s A5 lifecycle status must remain planned" % asset_id)

	if not reference_reasons.is_empty():
		issues.append(_issue(
			"ERROR",
			"AST006",
			XIAODONG_REFERENCE_PATH,
			0,
			"xiaodong_reference",
			"Xiaodong R2 reference integrity and three-way evidence consistency failed.",
			{
				"bytes": XIAODONG_REFERENCE_BYTES,
				"width": XIAODONG_REFERENCE_WIDTH,
				"height": XIAODONG_REFERENCE_HEIGHT,
				"sha256": XIAODONG_REFERENCE_SHA256,
				"rights_policy": "R2",
				"a5_status": "planned",
			},
			reference_reasons,
			"G0"
		))

static func _validate_xiaodong_design_card(
	card_value: Variant,
	issues: Array[Dictionary]
) -> Dictionary:
	var reasons: Array[String] = []
	var card: Dictionary = {}
	var record: Dictionary = {}
	if not card_value is Dictionary:
		reasons.append("fixed design-card evidence is missing or not an object")
	else:
		card = card_value
		var card_evidence_fields: Array[String] = [
			"path", "exists", "machine_block_count", "parse_error", "record",
		]
		if not _has_exact_keys(card, card_evidence_fields):
			reasons.append("normalized design-card evidence has an invalid field set")
		if card.get("path") != XIAODONG_DESIGN_CARD_PATH:
			reasons.append("design-card path is not the fixed registry path")
		if card.get("exists") != true:
			reasons.append("fixed design card is missing")
		else:
			var block_count_valid: bool = (
				_is_integral_number(card.get("machine_block_count", null))
				and int(card.get("machine_block_count", -1)) == 1
			)
			if not block_count_valid:
				reasons.append("design card must contain exactly one gogo-governance+json block")
			elif not card.get("parse_error", null) is String or not String(card.get("parse_error", "")).is_empty():
				reasons.append("design-card machine block is missing, unterminated, or invalid JSON")
			else:
				var record_value: Variant = card.get("record", null)
				if not record_value is Dictionary:
					reasons.append("design-card machine record must be an object")
				else:
					record = record_value
					_validate_xiaodong_card_record(record, reasons)
	if not reasons.is_empty():
		issues.append(_issue(
			"ERROR",
			"AST007",
			XIAODONG_DESIGN_CARD_PATH,
			0,
			"xiaodong_design_card",
			"Xiaodong design-card machine contract or C0/A5/Godot boundary is invalid.",
			"one valid gogo-governance+json record with the approved lifecycle and boundary",
			reasons,
			"G0"
		))
		return {"valid": false, "record": {}}
	return {"valid": true, "record": record}

static func _validate_xiaodong_card_record(record: Dictionary, reasons: Array[String]) -> void:
	if not _has_exact_keys(record, XIAODONG_CARD_FIELDS):
		reasons.append("machine record must use the exact contract field set")
	if not _is_integral_number(record.get("schema_version", null)) or int(record.get("schema_version", -1)) != 1:
		reasons.append("schema_version must be integer 1")
	if record.get("subject") != "xiaodong":
		reasons.append("subject must be xiaodong")
	if record.get("design_stage") != "C0":
		reasons.append("design_stage must be C0")
	if record.get("asset_stage") != "A5":
		reasons.append("asset_stage must be A5")

	var artifact_state_value: Variant = record.get("artifact_state", null)
	var decision_value: Variant = record.get("decision", null)
	var count_value: Variant = record.get("candidate_count", null)
	var artifact_state: String = String(artifact_state_value) if artifact_state_value is String else ""
	var decision: String = String(decision_value) if decision_value is String else ""
	var valid_count: bool = _is_integral_number(count_value) and int(count_value) >= 0
	var candidate_count: int = int(count_value) if valid_count else -1
	if artifact_state not in XIAODONG_ARTIFACT_STATES:
		reasons.append("artifact_state uses an unknown lifecycle value")
	if decision not in XIAODONG_DECISIONS:
		reasons.append("decision uses an unknown review value")
	if not valid_count:
		reasons.append("candidate_count must be a nonnegative integer")
	if valid_count:
		if artifact_state == "not_generated" and (candidate_count != 0 or decision != "pending_review"):
			reasons.append("not_generated requires zero candidates and pending_review")
		if candidate_count == 0 and (artifact_state != "not_generated" or decision != "pending_review"):
			reasons.append("zero candidates requires not_generated and pending_review")
		if candidate_count > 0 and artifact_state == "not_generated":
			reasons.append("positive candidates cannot remain not_generated")
		if decision == "accepted_for_concept" and (candidate_count == 0 or artifact_state not in ["generated", "cleaned"]):
			reasons.append("accepted_for_concept requires positive candidates in generated or cleaned state")

	var reference_value: Variant = record.get("reference", null)
	if not reference_value is Dictionary:
		reasons.append("reference must be an object")
	else:
		var reference: Dictionary = reference_value
		if not _has_exact_keys(reference, XIAODONG_CARD_REFERENCE_FIELDS):
			reasons.append("reference must use the exact path/bytes/width/height/sha256/rights_policy fields")
		if not reference.get("path", null) is String:
			reasons.append("reference path must be a string")
		if not _is_integral_number(reference.get("bytes", null)):
			reasons.append("reference bytes must be an integer")
		if not _is_integral_number(reference.get("width", null)) or not _is_integral_number(reference.get("height", null)):
			reasons.append("reference dimensions must be integers")
		if not reference.get("sha256", null) is String or not reference.get("rights_policy", null) is String:
			reasons.append("reference SHA-256 and rights policy must be strings")

	var boundary_value: Variant = record.get("boundary", null)
	if not boundary_value is Dictionary:
		reasons.append("boundary must be an object")
	else:
		var boundary: Dictionary = boundary_value
		if not _has_exact_keys(boundary, XIAODONG_CARD_BOUNDARY_FIELDS):
			reasons.append("boundary must use the exact four invariant fields")
		if boundary.get("c0_changes_a5_status") != false:
			reasons.append("C0 must not change A5 status")
		if boundary.get("c0_enters_godot") != false:
			reasons.append("C0 must not enter Godot")
		if boundary.get("a5_status") != "planned":
			reasons.append("A5 status must remain planned")
		if boundary.get("a5_gate") != "M4":
			reasons.append("A5 gate must remain M4")

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
	var required_prefix: String = GAMEPLAY_ID_PREFIXES.get(dataset_name, "")
	if not required_prefix.is_empty() and not identifier.begins_with(required_prefix):
		issues.append(_issue("ERROR", "ID001", path, record.get("source_line", 0), identifier, "Gameplay ID must use the canonical dataset namespace.", required_prefix, identifier, target_gate))
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

static func _has_required_keys_with_optional(
	dictionary: Dictionary,
	required_keys: Array,
	optional_keys: Array
) -> bool:
	var allowed_keys: Array[String] = required_keys.duplicate()
	for optional_key: String in optional_keys:
		if not allowed_keys.has(optional_key):
			allowed_keys.append(optional_key)
	var actual_keys: Array[String] = []
	for key: Variant in dictionary:
		actual_keys.append(String(key))
	actual_keys.sort()
	allowed_keys.sort()
	for actual_key: String in actual_keys:
		if not allowed_keys.has(actual_key):
			return false
	for required_key: String in required_keys:
		if not dictionary.has(required_key):
			return false
	return true

static func _validate_asset_manifest_schema(value: Variant, issues: Array[Dictionary]) -> void:
	if not _asset_manifest_schema_is_valid(value):
		issues.append(_issue(
			"ERROR", "CFG001", "data/content_validation.json", 0, "assets.manifest_schema",
			"Asset manifest schema must declare canonical/legacy column counts and legal Forge modes.",
			{"canonical_columns": 33, "legacy_fixture_columns": 28, "forge_modes": FORGE_MODES},
			value, "G0"
		))

static func _asset_manifest_schema_is_valid(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var schema: Dictionary = value
	if not _has_exact_keys(schema, ASSET_MANIFEST_SCHEMA_FIELDS):
		return false
	if not _is_integral_number(schema.get("canonical_columns")) or int(schema["canonical_columns"]) != ASSET_HEADER.size():
		return false
	if not _is_integral_number(schema.get("legacy_fixture_columns")) or int(schema["legacy_fixture_columns"]) != LEGACY_ASSET_HEADER.size():
		return false
	return schema.get("forge_modes") == FORGE_MODES

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
	if not _has_required_keys_with_optional(dataset_config, _required_dataset_fields(dataset_name), ["manifest_schema"] if dataset_name == "assets" else []):
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
	if dataset_name == "assets" and dataset_config.has("manifest_schema") and not _asset_manifest_schema_is_valid(dataset_config["manifest_schema"]):
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
