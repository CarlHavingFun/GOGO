extends RefCounted

const LOADER_PATH: String = "res://src/content/content_snapshot_loader.gd"
const VALIDATOR_PATH: String = "res://src/content/content_validator.gd"
const CLI_PATH: String = "res://src/content/content_validator_cli.gd"
const VALID_ROOT: String = "res://tests/fixtures/content_validator/g0_valid/"
const VALID_CONFIG: String = VALID_ROOT + "data/content_validation.json"
const INVALID_ROOT: String = "res://tests/fixtures/content_validator/g0_invalid/"
const INVALID_CONFIG: String = INVALID_ROOT + "data/content_validation.json"
const NOT_IMPLEMENTED_ABSENT_CONFIG: String = INVALID_ROOT + "data/not_implemented_absent.json"
const NOT_IMPLEMENTED_PRESENT_CONFIG: String = INVALID_ROOT + "data/not_implemented_present.json"
const DESIGN_FIXTURE_SHA256: String = "559f2884854bd2335f027facfa19a2b4e181a44b3ad74ba55cb8c2366419486e"
const ASSET_HEADER: PackedStringArray = [
	"asset_id", "phase", "category", "subject", "state", "path", "logical_canvas",
	"pivot", "frames", "fps", "prompt_section", "status", "notes",
	"generation_canvas", "direction", "collision_reference", "palette",
	"negative_constraints", "godot_import", "reviewer", "reference_source",
	"reference_sha256", "reference_rights_policy", "sprite_layout",
	"source_output", "cleaned_output", "qa_record", "godot_evidence",
]

var _loader_script: Script
var _validator_script: Script
var _cli_script: Script

func run() -> Array[String]:
	var failures: Array[String] = []
	_loader_script = load(LOADER_PATH) as Script
	_validator_script = load(VALIDATOR_PATH) as Script
	_cli_script = load(CLI_PATH) as Script
	if _loader_script == null:
		failures.append("ContentSnapshotLoader class is required for real fixture loading.")
	if _validator_script == null:
		failures.append("ContentValidator class is required for behavior validation.")
	if _cli_script == null:
		failures.append("ContentValidatorCLI class is required for argument and run behavior.")
	if not failures.is_empty():
		return failures
	_test_loader_normalizes_real_json_csv_and_markdown(failures)
	_test_loader_reads_real_gameplay_resources_without_inventing_rows(failures)
	_test_loader_returns_content_issues_instead_of_throwing(failures)
	_test_malformed_config_types_return_cfg001_instead_of_crashing(failures)
	_test_cfg001_requires_exact_config_and_dataset_key_sets(failures)
	_test_cfg001_requires_exact_dataset_fields_and_metadata(failures)
	_test_cfg001_rejects_unknown_state_and_dishonest_not_implemented(failures)
	_test_not_implemented_assets_and_design_use_absent_or_empty_preflight(failures)
	_test_doc_rules_cover_paths_registration_bytes_and_hashes(failures)
	_test_ast001_requires_exact_header_and_full_rows(failures)
	_test_ast002_checks_ids_enums_dimensions_timing_and_paths(failures)
	_test_ast003_enforces_the_status_evidence_matrix(failures)
	_test_ast004_requires_generated_prompt_constraints(failures)
	_test_ast005_requires_the_xiaodong_a5_deliverable_set(failures)
	_test_gameplay_rules_run_for_present_partial_records(failures)
	_test_every_partial_dataset_is_not_ready(failures)
	_test_readiness_profiles_counts_sorting_and_exit_codes(failures)
	_test_jsonl_and_cli_public_interfaces(failures)
	return failures

func _test_loader_normalizes_real_json_csv_and_markdown(failures: Array[String]) -> void:
	var result: Dictionary = _loader_script.call("load_project", VALID_ROOT, VALID_CONFIG)
	_assert_equal(result.get("load_issues", []), [], "The valid fixture must load without content errors.", failures)
	var snapshot: Dictionary = result.get("snapshot", {})
	_assert_equal(snapshot.keys().size(), 4, "The normalized snapshot must have exactly four top-level sections.", failures)
	_assert_true(snapshot.has("config") and snapshot.has("design_documents") and snapshot.has("assets") and snapshot.has("gameplay"), "The normalized snapshot must expose the contracted sections.", failures)
	var assets: Dictionary = snapshot.get("assets", {})
	var header: PackedStringArray = assets.get("header", PackedStringArray())
	var rows: Array = assets.get("rows", [])
	_assert_equal(header, ASSET_HEADER, "The loader must preserve the exact 28-column header.", failures)
	_assert_equal(rows.size(), 6, "The valid CSV fixture must produce the six planned A5 Xiaodong records.", failures)
	if rows.size() == 6:
		var row: Dictionary = rows[0]
		_assert_equal(row.get("notes"), "comma, preserved", "FileAccess CSV parsing must preserve a quoted comma.", failures)
		_assert_equal(row.get("source_line"), 2, "The first CSV data record must preserve physical line 2.", failures)
		_assert_true(String(row.get("source_path", "")).ends_with("assets/asset_manifest.csv"), "Asset records must carry their source path.", failures)
	var documents: Dictionary = snapshot.get("design_documents", {})
	var markdown_files: Array = documents.get("actual_markdown_files", [])
	var records: Array = documents.get("records", [])
	_assert_equal(markdown_files.size(), 1, "The loader must enumerate every Markdown file beside the fixture manifest.", failures)
	if markdown_files.size() == 1:
		_assert_true(String(markdown_files[0]).ends_with("/design/00.md"), "Markdown enumeration must return the real safe fixture path.", failures)
	_assert_equal(records.size(), 1, "The manifest fixture must produce one normalized document record.", failures)
	if records.size() == 1:
		var record: Dictionary = records[0]
		_assert_equal(record.get("actual_bytes"), 19, "The loader must compute the Markdown byte count.", failures)
		_assert_equal(record.get("actual_sha256"), DESIGN_FIXTURE_SHA256, "The loader must compute the Markdown SHA-256.", failures)
		_assert_equal(record.get("source_line"), 0, "JSON records without physical row data must use source line zero.", failures)
	var gameplay: Dictionary = snapshot.get("gameplay", {})
	for dataset_name: String in ["weapons", "throwables", "characters", "upgrades", "enemies", "waves", "unlocks"]:
		_assert_true(gameplay.has(dataset_name), "Missing gameplay dataset %s must normalize to an empty array." % dataset_name, failures)
		_assert_true(gameplay.get(dataset_name) is Array, "Gameplay dataset %s must be represented as an array." % dataset_name, failures)

func _test_loader_returns_content_issues_instead_of_throwing(failures: Array[String]) -> void:
	var result: Dictionary = _loader_script.call("load_project", INVALID_ROOT, INVALID_CONFIG)
	_assert_true(result.has("snapshot") and result.has("load_issues"), "Content errors must return snapshot and load_issues instead of throwing.", failures)
	var load_issues: Array = result.get("load_issues", [])
	_assert_true(not load_issues.is_empty(), "The invalid fixture must expose deterministic loader issues.", failures)
	var unsafe_asset_paths: int = 0
	for issue_value: Variant in load_issues:
		var issue: Dictionary = issue_value
		_assert_equal(issue.get("severity"), "ERROR", "Loader content failures must be reported as errors.", failures)
		_assert_true(issue.has("rule") and issue.has("path") and issue.has("line"), "Loader issues must use the stable issue shape.", failures)
		if issue.get("rule") == "AST002" and String(issue.get("message", "")).contains("safe project-relative"):
			unsafe_asset_paths += 1
	_assert_equal(unsafe_asset_paths, 2, "The real loader must reject both parent traversal and absolute asset paths.", failures)

func _test_loader_reads_real_gameplay_resources_without_inventing_rows(failures: Array[String]) -> void:
	var result: Dictionary = _loader_script.call("load_project", "res://", "res://data/content_validation.json")
	var gameplay: Dictionary = result.get("snapshot", {}).get("gameplay", {})
	var weapons: Array = gameplay.get("weapons", [])
	_assert_equal(weapons.size(), 1, "The production partial weapons directory must load only its one real Resource.", failures)
	if weapons.size() == 1:
		var weapon: Dictionary = weapons[0]
		_assert_equal(weapon.get("id"), "wpn_ak", "Resource loading must normalize StringName gameplay IDs.", failures)
		_assert_true(String(weapon.get("source_path", "")).ends_with("data/weapons/ak.tres"), "Gameplay records must carry the real Resource source path.", failures)
		_assert_equal(weapon.get("source_line"), 0, "Resource records must use source line zero.", failures)
	for future_dataset: String in ["throwables", "characters", "upgrades", "enemies", "waves", "unlocks"]:
		_assert_equal(gameplay.get(future_dataset, []), [], "Missing future dataset %s must remain an empty array." % future_dataset, failures)

func _test_malformed_config_types_return_cfg001_instead_of_crashing(failures: Array[String]) -> void:
	var config_array_snapshot: Dictionary = _base_snapshot()
	config_array_snapshot["config"] = []
	var config_report: Dictionary = _validate(config_array_snapshot, &"g0")
	_assert_true(_has_issue(config_report, "CFG001", "config", "object"), "A non-object snapshot config must return CFG001.", failures)
	var datasets_array_snapshot: Dictionary = _base_snapshot()
	datasets_array_snapshot["config"]["datasets"] = []
	var datasets_report: Dictionary = _validate(datasets_array_snapshot, &"g0")
	_assert_true(_has_issue(datasets_report, "CFG001", "datasets", "object"), "A non-object datasets value must return CFG001.", failures)

func _test_cfg001_requires_exact_config_and_dataset_key_sets(failures: Array[String]) -> void:
	var extra_top_level: Dictionary = _base_snapshot()
	extra_top_level["config"]["implicit_default"] = true
	var extra_top_report: Dictionary = _validate(extra_top_level, &"g0")
	_assert_true(_has_issue(extra_top_report, "CFG001", "config", "exact keys"), "Config must reject extra top-level keys.", failures)
	var missing_dataset: Dictionary = _base_snapshot()
	missing_dataset["config"]["datasets"].erase("unlocks")
	var missing_report: Dictionary = _validate(missing_dataset, &"g0")
	_assert_true(_has_issue(missing_report, "CFG001", "datasets", "exact keys"), "Config must reject a missing dataset key.", failures)
	var extra_dataset: Dictionary = _base_snapshot()
	extra_dataset["config"]["datasets"]["invented"] = {
		"state": "not_implemented",
		"path": "res://data/invented",
		"target_gate": "M5",
	}
	var extra_report: Dictionary = _validate(extra_dataset, &"g0")
	_assert_true(_has_issue(extra_report, "CFG001", "datasets", "exact keys"), "Config must reject an extra dataset key.", failures)

func _test_cfg001_requires_exact_dataset_fields_and_metadata(failures: Array[String]) -> void:
	var missing_target_gate: Dictionary = _base_snapshot()
	missing_target_gate["config"]["datasets"]["assets"].erase("target_gate")
	var target_report: Dictionary = _validate(missing_target_gate, &"g0")
	_assert_true(_has_issue(target_report, "CFG001", "assets", "target_gate"), "Assets must explicitly declare target_gate.", failures)
	var extra_field: Dictionary = _base_snapshot()
	extra_field["config"]["datasets"]["design_documents"]["default_state"] = "ready"
	var extra_report: Dictionary = _validate(extra_field, &"g0")
	_assert_true(_has_issue(extra_report, "CFG001", "design_documents", "exact fields"), "Dataset configs must reject implicit or extra fields.", failures)
	var missing_count: Dictionary = _base_snapshot()
	missing_count["config"]["datasets"]["weapons"].erase("expected_count")
	var count_report: Dictionary = _validate(missing_count, &"g0")
	_assert_true(_has_issue(count_report, "CFG001", "weapons", "expected_count"), "Weapons must explicitly declare expected_count.", failures)
	var fractional_count: Dictionary = _base_snapshot()
	fractional_count["config"]["datasets"]["characters"]["expected_count"] = 5.5
	var fractional_report: Dictionary = _validate(fractional_count, &"g0")
	_assert_true(_has_issue(fractional_report, "CFG001", "characters", "integer"), "Expected counts must be integral numbers.", failures)
	var missing_categories: Dictionary = _base_snapshot()
	missing_categories["config"]["datasets"]["upgrades"]["expected_categories"].erase("contract")
	var category_report: Dictionary = _validate(missing_categories, &"g0")
	_assert_true(_has_issue(category_report, "CFG001", "upgrades", "expected_categories"), "Upgrade category metadata must use the exact five-key matrix.", failures)
	var invalid_range: Dictionary = _base_snapshot()
	invalid_range["config"]["datasets"]["waves"]["expected_range"] = [1, "20"]
	var range_report: Dictionary = _validate(invalid_range, &"g0")
	_assert_true(_has_issue(range_report, "CFG001", "waves", "expected_range"), "Wave range metadata must contain two integral numbers.", failures)

func _test_cfg001_rejects_unknown_state_and_dishonest_not_implemented(failures: Array[String]) -> void:
	var unknown_snapshot: Dictionary = _base_snapshot()
	unknown_snapshot["config"]["datasets"]["assets"]["state"] = "almost_ready"
	var unknown_report: Dictionary = _validate(unknown_snapshot, &"g0")
	_assert_true(_has_issue(unknown_report, "CFG001", "assets", "unknown"), "CFG001 must reject an unknown dataset state.", failures)
	var dishonest_snapshot: Dictionary = _base_snapshot()
	dishonest_snapshot["config"]["datasets"]["assets"]["state"] = "not_implemented"
	dishonest_snapshot["assets"]["rows"] = [_valid_asset_row()]
	var dishonest_report: Dictionary = _validate(dishonest_snapshot, &"g0")
	_assert_true(_has_issue(dishonest_report, "CFG001", "assets", "not_implemented"), "CFG001 must reject records behind not_implemented readiness.", failures)

func _test_not_implemented_assets_and_design_use_absent_or_empty_preflight(failures: Array[String]) -> void:
	var absent_result: Dictionary = _loader_script.call("load_project", INVALID_ROOT, NOT_IMPLEMENTED_ABSENT_CONFIG)
	var absent_issues: Array = absent_result.get("load_issues", [])
	_assert_true(not _has_load_issue(absent_issues, "AST001", "asset_manifest"), "An absent not_implemented asset path must not emit AST001.", failures)
	_assert_true(not _has_load_issue(absent_issues, "DOC001", "manifest"), "An absent not_implemented design path must not emit DOC001.", failures)
	var present_result: Dictionary = _loader_script.call("load_project", INVALID_ROOT, NOT_IMPLEMENTED_PRESENT_CONFIG)
	var present_issues: Array = present_result.get("load_issues", [])
	_assert_true(_has_load_issue(present_issues, "CFG001", "assets"), "A header-only asset CSV is dishonest not_implemented content.", failures)
	_assert_true(_has_load_issue(present_issues, "CFG001", "design_documents"), "An empty manifest file is dishonest not_implemented content.", failures)
	_assert_true(not _has_load_issue(present_issues, "AST001", "asset_manifest"), "Dishonest not_implemented assets must stop before AST loading.", failures)
	_assert_true(not _has_load_issue(present_issues, "DOC001", "manifest"), "Dishonest not_implemented design must stop before DOC loading.", failures)
	var header_snapshot: Dictionary = _base_snapshot()
	header_snapshot["config"]["datasets"]["assets"]["state"] = "not_implemented"
	header_snapshot["assets"]["header"] = ASSET_HEADER.duplicate()
	header_snapshot["assets"]["rows"] = []
	var header_report: Dictionary = _validate(header_snapshot, &"g0")
	_assert_true(_has_issue(header_report, "CFG001", "assets", "not_implemented"), "A normalized header-only asset catalog must count as existing content.", failures)
	var manifest_snapshot: Dictionary = _base_snapshot()
	manifest_snapshot["config"]["datasets"]["design_documents"]["state"] = "not_implemented"
	manifest_snapshot["design_documents"]["manifest"] = {"documents": []}
	manifest_snapshot["design_documents"]["records"] = []
	var manifest_report: Dictionary = _validate(manifest_snapshot, &"g0")
	_assert_true(_has_issue(manifest_report, "CFG001", "design_documents", "not_implemented"), "A normalized empty manifest must count as existing content.", failures)

func _test_doc_rules_cover_paths_registration_bytes_and_hashes(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	snapshot["design_documents"]["records"] = [
		_document_record("../escape.md", 10, "aa", 10, "aa", true),
		_document_record("duplicate.md", 10, "aa", 10, "aa", true),
		_document_record("duplicate.md", 10, "aa", 10, "aa", true),
		_document_record("", 0, "", 0, "", false),
		_document_record("missing.md", 10, "aa", 10, "aa", false),
		_document_record("mismatch.md", 10, "aa", 11, "bb", true),
	]
	snapshot["design_documents"]["actual_markdown_files"] = [
		"res://fixture/design/duplicate.md",
		"res://fixture/design/mismatch.md",
		"res://fixture/design/unregistered.md",
	]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(_issue_count(report, "DOC001") >= 3, "DOC001 must catch unsafe, duplicate, and missing manifest paths.", failures)
	_assert_true(_issue_count(report, "DOC002") >= 2, "DOC002 must catch unregistered and nonexistent Markdown.", failures)
	_assert_true(_issue_count(report, "DOC003") >= 2, "DOC003 must catch byte-count and SHA-256 mismatches independently.", failures)

func _test_ast001_requires_exact_header_and_full_rows(failures: Array[String]) -> void:
	var header_snapshot: Dictionary = _base_snapshot()
	header_snapshot["assets"]["header"] = PackedStringArray(Array(ASSET_HEADER).slice(0, 27))
	header_snapshot["assets"]["rows"] = [_valid_asset_row()]
	var header_report: Dictionary = _validate(header_snapshot, &"g0")
	_assert_true(_has_issue(header_report, "AST001", "asset_manifest", "28-column"), "AST001 must reject any non-exact header.", failures)
	var row_snapshot: Dictionary = _base_snapshot()
	var short_row: Dictionary = _valid_asset_row()
	short_row["_column_count"] = 27
	row_snapshot["assets"]["rows"] = [short_row]
	var row_report: Dictionary = _validate(row_snapshot, &"g0")
	_assert_true(_has_issue(row_report, "AST001", "weapon_fixture_base", "28 columns"), "AST001 must reject a short CSV row.", failures)

func _test_ast002_checks_ids_enums_dimensions_timing_and_paths(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	var first: Dictionary = _valid_asset_row()
	var second: Dictionary = _valid_asset_row()
	second["asset_id"] = "Bad-ID"
	second["phase"] = "A9"
	second["category"] = "unknown"
	second["state"] = "accepted_for_concept"
	second["status"] = "accepted_for_concept"
	second["path"] = "../escape.png"
	second["logical_canvas"] = "wide"
	second["frames"] = "0"
	second["fps"] = "-1"
	second["source_line"] = 3
	var duplicate: Dictionary = _valid_asset_row()
	duplicate["source_line"] = 4
	snapshot["assets"]["rows"] = [first, second, duplicate]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(_issue_count(report, "AST002") >= 9, "AST002 must independently validate uniqueness, snake_case, enums, canvas, frames/FPS, and safe paths.", failures)
	_assert_true(_has_issue(report, "AST002", "Bad-ID", "accepted_for_concept"), "accepted_for_concept must be invalid in state and status.", failures)

func _test_ast003_enforces_the_status_evidence_matrix(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	var generated: Dictionary = _valid_asset_row()
	generated["asset_id"] = "generated_missing_source"
	generated["status"] = "generated"
	generated["source_line"] = 3
	var cleaned: Dictionary = _valid_asset_row()
	cleaned["asset_id"] = "cleaned_missing_outputs"
	cleaned["status"] = "cleaned"
	cleaned["source_output"] = "evidence/source.png"
	cleaned["_source_output_exists"] = true
	cleaned["source_line"] = 4
	var approved: Dictionary = _valid_asset_row()
	approved["asset_id"] = "approved_missing_review"
	approved["status"] = "approved"
	approved["source_output"] = "evidence/source.png"
	approved["_source_output_exists"] = true
	approved["cleaned_output"] = "evidence/clean.png"
	approved["_cleaned_output_exists"] = true
	approved["_path_exists"] = true
	approved["source_line"] = 5
	var in_game: Dictionary = approved.duplicate(true)
	in_game["asset_id"] = "in_game_missing_import"
	in_game["status"] = "in_game"
	in_game["qa_record"] = "evidence/qa.json"
	in_game["_qa_record_exists"] = true
	in_game["reviewer"] = "qa"
	in_game["source_line"] = 6
	var rejected: Dictionary = _valid_asset_row()
	rejected["asset_id"] = "rejected_missing_evidence"
	rejected["status"] = "rejected"
	rejected["_path_exists"] = true
	rejected["source_line"] = 7
	snapshot["assets"]["rows"] = [generated, cleaned, approved, in_game, rejected]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(_issue_count(report, "AST003") >= 10, "AST003 must enforce generated, cleaned, approved, in_game, and rejected evidence independently.", failures)
	var planned_snapshot: Dictionary = _base_snapshot()
	planned_snapshot["assets"]["rows"] = [_valid_asset_row()]
	var planned_report: Dictionary = _validate(planned_snapshot, &"g0")
	_assert_equal(_issue_count(planned_report, "AST003"), 0, "A planned row may omit stable output and all four evidence paths.", failures)

func _test_ast004_requires_generated_prompt_constraints(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	var row: Dictionary = _valid_asset_row()
	row["asset_id"] = "generated_without_prompt"
	row["status"] = "generated"
	row["source_output"] = "evidence/source.png"
	row["_source_output_exists"] = true
	row["prompt_section"] = ""
	row["negative_constraints"] = ""
	snapshot["assets"]["rows"] = [row]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_equal(_issue_count(report, "AST004"), 2, "AST004 must require prompt and negative constraints for generated-or-later assets.", failures)

func _test_ast005_requires_the_xiaodong_a5_deliverable_set(failures: Array[String]) -> void:
	var empty_report: Dictionary = _validate(_base_snapshot(), &"g0")
	_assert_true(_has_issue(empty_report, "AST005", "xiaodong", "exactly"), "AST005 must reject a ready asset catalog with zero Xiaodong A5 rows.", failures)
	var snapshot: Dictionary = _base_snapshot()
	var states: Array[String] = ["idle", "walk", "hit", "death", "skill_breakin", "idle"]
	var rows: Array[Dictionary] = []
	for state_index: int in range(states.size()):
		var row: Dictionary = _valid_asset_row()
		row["asset_id"] = "xiaodong_%s_%d" % [states[state_index], state_index]
		row["phase"] = "A5"
		row["category"] = "character" if states[state_index] != "portrait" else "ui"
		row["subject"] = "xiaodong"
		row["state"] = states[state_index]
		row["source_line"] = state_index + 2
		rows.append(row)
	snapshot["assets"]["rows"] = rows
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(_has_issue(report, "AST005", "xiaodong", "exactly"), "AST005 must reject duplicate/missing A5 Xiaodong deliverables.", failures)
	rows[5]["state"] = "portrait"
	var complete_report: Dictionary = _validate(snapshot, &"g0")
	_assert_equal(_issue_count(complete_report, "AST005"), 0, "AST005 must accept exactly idle/walk/hit/death/skill_breakin/portrait.", failures)

func _test_gameplay_rules_run_for_present_partial_records(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	snapshot["config"]["datasets"]["weapons"]["state"] = "partial"
	snapshot["gameplay"]["weapons"] = [{
		"id": "Bad Weapon",
		"character_id": "missing_character",
		"damage": 0,
		"shots_per_second": -1.0,
		"magazine_size": 0,
		"reload_duration": 0.0,
		"range_pixels": -1.0,
		"source_path": "res://data/weapons/bad.tres",
		"source_line": 0,
	}]
	snapshot["config"]["datasets"]["upgrades"]["state"] = "partial"
	snapshot["gameplay"]["upgrades"] = [
		{
			"id": "upgrade_one",
			"category": "unknown",
			"source_path": "res://data/upgrades/one.tres",
			"source_line": 0,
		},
		{
			"id": "mutation_one",
			"category": "mutation",
			"requires_upgrade_id": "",
			"source_path": "res://data/upgrades/mutation.tres",
			"source_line": 0,
		},
	]
	snapshot["config"]["datasets"]["characters"]["state"] = "partial"
	snapshot["gameplay"]["characters"] = [{
		"id": "character_one",
		"display_name": "",
		"source_path": "res://data/characters/one.tres",
		"source_line": 0,
	}]
	snapshot["config"]["datasets"]["waves"]["state"] = "partial"
	snapshot["gameplay"]["waves"] = [{
		"id": "wave_one",
		"wave": 21,
		"source_path": "res://data/waves/one.tres",
		"source_line": 0,
	}]
	snapshot["config"]["datasets"]["unlocks"]["state"] = "partial"
	snapshot["gameplay"]["unlocks"] = [{
		"id": "unlock_one",
		"target_id": "",
		"source_path": "res://data/unlocks/one.tres",
		"source_line": 0,
	}]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(_has_issue(report, "ID001", "Bad Weapon", "snake_case"), "ID001 must run for every present partial gameplay record.", failures)
	_assert_true(_issue_count(report, "WPN001") >= 5, "WPN001 must validate present partial weapon numeric schema.", failures)
	_assert_true(_has_issue(report, "REF001", "Bad Weapon", "does not resolve"), "REF001 must reject an unresolved reference when the target dataset is present.", failures)
	_assert_true(_has_issue(report, "UPG002", "upgrade_one", "category"), "UPG002 must validate present partial upgrade categories.", failures)
	_assert_true(_has_issue(report, "MUT001", "mutation_one", "prerequisite"), "MUT001 must validate present partial mutation prerequisites.", failures)
	_assert_true(_has_issue(report, "CHR001", "character_one", "display_name"), "CHR001 must validate present partial character records.", failures)
	_assert_true(_has_issue(report, "WAVE001", "wave_one", "range"), "WAVE001 must validate present partial wave numbers.", failures)
	_assert_true(_has_issue(report, "ULK001", "unlock_one", "target_id"), "ULK001 must validate present partial unlock records.", failures)

func _test_every_partial_dataset_is_not_ready(failures: Array[String]) -> void:
	var unlock_snapshot: Dictionary = _base_snapshot()
	unlock_snapshot["config"]["datasets"]["unlocks"]["state"] = "partial"
	var unlock_report: Dictionary = _validate(unlock_snapshot, &"g0")
	_assert_true(
		_has_issue_with_severity(unlock_report, "ULK001", "unlocks", "NOT_READY"),
		"A partial dataset without expected metadata must still emit NOT_READY.",
		failures
	)
	var matched_count_snapshot: Dictionary = _base_snapshot()
	matched_count_snapshot["config"]["datasets"]["weapons"]["state"] = "partial"
	matched_count_snapshot["config"]["datasets"]["weapons"]["expected_count"] = 0
	var matched_count_report: Dictionary = _validate(matched_count_snapshot, &"g0")
	_assert_true(
		_has_issue_with_severity(matched_count_report, "WPN001", "weapons", "NOT_READY"),
		"A partial dataset must remain NOT_READY even when its record count matches expected_count.",
		failures
	)

func _test_readiness_profiles_counts_sorting_and_exit_codes(failures: Array[String]) -> void:
	var fixture_report: Dictionary = _validator_script.call("validate_project", &"g0", VALID_CONFIG)
	_assert_equal(fixture_report.get("gate_status"), "pass", "Future NOT_READY datasets must not fail the G0 gate.", failures)
	_assert_equal(fixture_report.get("catalog_status"), "not_ready", "Future incomplete catalogs must remain visibly not_ready.", failures)
	_assert_equal(_validator_script.call("exit_code", fixture_report), 0, "A valid G0 fixture with future gaps must exit zero.", failures)
	var full_report: Dictionary = _validator_script.call("validate_project", &"full", VALID_CONFIG)
	_assert_equal(_validator_script.call("exit_code", full_report), 1, "Any NOT_READY issue must fail the full profile.", failures)
	var legacy_snapshot: Dictionary = _base_snapshot()
	legacy_snapshot["config"]["datasets"]["assets"]["state"] = "legacy"
	var legacy_report: Dictionary = _validate(legacy_snapshot, &"g0")
	_assert_equal(_validator_script.call("exit_code", legacy_report), 1, "G0-targeted legacy readiness must fail G0.", failures)
	var counts: Dictionary = fixture_report.get("counts", {})
	var issues: Array = fixture_report.get("issues", [])
	_assert_equal(counts.get("error"), _severity_count(issues, "ERROR"), "Error count must derive exclusively from issues.", failures)
	_assert_equal(counts.get("warning"), _severity_count(issues, "WARNING"), "Warning count must derive exclusively from issues.", failures)
	_assert_equal(counts.get("not_ready"), _severity_count(issues, "NOT_READY"), "NOT_READY count must derive exclusively from issues.", failures)
	var previous_key: String = ""
	for issue_value: Variant in issues:
		var issue: Dictionary = issue_value
		var current_key: String = "%s|%s|%s|%010d|%s" % [
			issue.get("severity", ""), issue.get("rule", ""), issue.get("path", ""),
			int(issue.get("line", 0)), issue.get("subject", ""),
		]
		_assert_true(previous_key <= current_key, "Issues must be deterministically sorted by severity, rule, path, line, subject.", failures)
		previous_key = current_key

func _test_jsonl_and_cli_public_interfaces(failures: Array[String]) -> void:
	var report: Dictionary = _validator_script.call("validate_project", &"g0", VALID_CONFIG)
	var lines: PackedStringArray = _validator_script.call("format_jsonl", report)
	var issues: Array = report.get("issues", [])
	_assert_equal(lines.size(), issues.size() + 1, "JSONL must contain one line per issue and exactly one summary.", failures)
	for line_index: int in range(lines.size()):
		var parsed: Variant = JSON.parse_string(lines[line_index])
		_assert_true(parsed is Dictionary, "Every formatted JSONL line must parse as an object.", failures)
		if parsed is Dictionary:
			var object: Dictionary = parsed
			_assert_equal(object.get("type"), "summary" if line_index == lines.size() - 1 else "issue", "Only the final JSONL object may be the summary.", failures)
	var parsed_args: Dictionary = _cli_script.call("parse_args", PackedStringArray([
		"--profile=g0", "--format=jsonl", "--config=" + VALID_CONFIG,
	]))
	_assert_equal(parsed_args.get("ok"), true, "CLI parsing must accept the contracted arguments.", failures)
	_assert_equal(parsed_args.get("profile"), &"g0", "CLI parsing must preserve the g0 profile.", failures)
	var bad_args: Dictionary = _cli_script.call("parse_args", PackedStringArray(["--profile=unknown"]))
	_assert_equal(bad_args.get("ok"), false, "CLI parsing must reject unknown profiles.", failures)

func _validate(snapshot: Dictionary, profile: StringName) -> Dictionary:
	return _validator_script.call("validate_snapshot", snapshot, profile)

func _base_snapshot() -> Dictionary:
	var datasets: Dictionary = {
		"assets": {"state": "ready", "path": "res://assets/asset_manifest.csv", "target_gate": "G0"},
		"design_documents": {"state": "ready", "path": "res://docs/design/manifest.json", "target_gate": "G0"},
		"weapons": {"state": "not_implemented", "path": "res://data/weapons", "target_gate": "M4", "expected_count": 5},
		"throwables": {"state": "not_implemented", "path": "res://data/throwables", "target_gate": "M4", "expected_count": 4},
		"characters": {"state": "not_implemented", "path": "res://data/characters", "target_gate": "M4", "expected_count": 5},
		"upgrades": {
			"state": "not_implemented", "path": "res://data/upgrades", "target_gate": "M4", "expected_count": 47,
			"expected_categories": {"calibration": 8, "engine": 10, "mutation": 9, "module": 15, "contract": 5},
		},
		"enemies": {"state": "not_implemented", "path": "res://data/enemies", "target_gate": "M4", "expected_count": 14},
		"waves": {"state": "not_implemented", "path": "res://data/waves", "target_gate": "M4", "expected_range": [1, 20]},
		"unlocks": {"state": "not_implemented", "path": "res://data/unlocks", "target_gate": "M5"},
	}
	return {
		"config": {"schema_version": 1, "current_gate": "G0", "datasets": datasets},
		"design_documents": {"manifest": {"documents": []}, "actual_markdown_files": [], "records": []},
		"assets": {"header": ASSET_HEADER.duplicate(), "rows": []},
		"gameplay": {
			"weapons": [], "throwables": [], "characters": [], "upgrades": [],
			"enemies": [], "waves": [], "unlocks": [],
		},
	}

func _valid_asset_row() -> Dictionary:
	return {
		"asset_id": "weapon_fixture_base",
		"phase": "A1",
		"category": "weapon",
		"subject": "fixture",
		"state": "base",
		"path": "assets/fixture/weapon_fixture_base.png",
		"logical_canvas": "160x96",
		"pivot": "grip_point",
		"frames": "1",
		"fps": "0",
		"prompt_section": "",
		"status": "planned",
		"notes": "fixture",
		"generation_canvas": "",
		"direction": "right",
		"collision_reference": "",
		"palette": "",
		"negative_constraints": "",
		"godot_import": "",
		"reviewer": "",
		"reference_source": "",
		"reference_sha256": "",
		"reference_rights_policy": "original",
		"sprite_layout": "single",
		"source_output": "",
		"cleaned_output": "",
		"qa_record": "",
		"godot_evidence": "",
		"source_path": "res://assets/asset_manifest.csv",
		"source_line": 2,
		"_column_count": 28,
		"_path_exists": false,
		"_source_output_exists": false,
		"_cleaned_output_exists": false,
		"_qa_record_exists": false,
		"_godot_evidence_exists": false,
	}

func _document_record(file_name: String, bytes: int, sha256: String, actual_bytes: int, actual_sha256: String, exists: bool) -> Dictionary:
	return {
		"file": file_name,
		"bytes": bytes,
		"sha256": sha256,
		"actual_bytes": actual_bytes,
		"actual_sha256": actual_sha256,
		"exists": exists,
		"source_path": "res://fixture/design/manifest.json",
		"source_line": 0,
	}

func _has_issue(report: Dictionary, rule: String, subject: String, message_fragment: String) -> bool:
	for issue_value: Variant in report.get("issues", []):
		var issue: Dictionary = issue_value
		if issue.get("rule") == rule and String(issue.get("subject", "")).contains(subject) and String(issue.get("message", "")).contains(message_fragment):
			return true
	return false

func _has_issue_with_severity(report: Dictionary, rule: String, subject: String, severity: String) -> bool:
	for issue_value: Variant in report.get("issues", []):
		var issue: Dictionary = issue_value
		if issue.get("rule") == rule and issue.get("subject") == subject and issue.get("severity") == severity:
			return true
	return false

func _issue_count(report: Dictionary, rule: String) -> int:
	var count: int = 0
	for issue_value: Variant in report.get("issues", []):
		var issue: Dictionary = issue_value
		if issue.get("rule") == rule:
			count += 1
	return count

func _severity_count(issues: Array, severity: String) -> int:
	var count: int = 0
	for issue_value: Variant in issues:
		var issue: Dictionary = issue_value
		if issue.get("severity") == severity:
			count += 1
	return count

func _has_load_issue(issues: Array, rule: String, subject: String) -> bool:
	for issue_value: Variant in issues:
		if issue_value is Dictionary:
			var issue: Dictionary = issue_value
			if issue.get("rule") == rule and issue.get("subject") == subject:
				return true
	return false

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s Expected %s, got %s." % [message, str(expected), str(actual)])
