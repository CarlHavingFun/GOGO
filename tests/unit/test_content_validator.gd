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
const GOVERNANCE_ROOT: String = "res://tests/fixtures/content_validator/governance/"
const MISSING_REFERENCE_CONFIG: String = GOVERNANCE_ROOT + "missing_reference/data/content_validation.json"
const CORRUPT_REFERENCE_CONFIG: String = GOVERNANCE_ROOT + "corrupt_reference/data/content_validation.json"
const FULL_VALID_FIXTURE: String = "res://tests/fixtures/content_validator/full_valid.json"
const FULL_INVALID_FIXTURE: String = "res://tests/fixtures/content_validator/full_invalid.json"
const DESIGN_FIXTURE_SHA256: String = "559f2884854bd2335f027facfa19a2b4e181a44b3ad74ba55cb8c2366419486e"
const XIAODONG_REFERENCE_PATH: String = "assets/source/references/characters/xiaodong/reference_01.jpg"
const XIAODONG_REFERENCE_SHA256: String = "fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52"
const CORRUPT_REFERENCE_SHA256: String = "d20f6ffd523b78a86cd2f916fa34af5d1918d75f7b142237c752ad6b254213ab"
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
	_test_loader_normalizes_xiaodong_card_and_original_jpeg_bytes(failures)
	_test_loader_rejects_inactive_governance_machine_blocks(failures)
	_test_loader_fails_closed_on_raw_html_before_governance_block(failures)
	_test_loader_fails_closed_on_raw_html_after_governance_block(failures)
	_test_loader_ignores_indented_html_comment_literals(failures)
	_test_loader_does_not_treat_invalid_backtick_info_as_a_fence(failures)
	_test_loader_normalizes_missing_and_corrupt_references_without_throwing(failures)
	_test_loader_reads_real_gameplay_resources_without_inventing_rows(failures)
	_test_loader_returns_content_issues_instead_of_throwing(failures)
	_test_malformed_config_types_return_cfg001_instead_of_crashing(failures)
	_test_cfg001_requires_exact_config_and_dataset_key_sets(failures)
	_test_cfg001_requires_exact_dataset_fields_and_metadata(failures)
	_test_reference_validation_skips_a_missing_target_config(failures)
	_test_reference_validation_skips_a_non_dictionary_target_config(failures)
	_test_cfg001_rejects_unknown_state_and_dishonest_not_implemented(failures)
	_test_not_implemented_assets_and_design_use_absent_or_empty_preflight(failures)
	_test_doc_rules_cover_paths_registration_bytes_and_hashes(failures)
	_test_ast001_requires_exact_header_and_full_rows(failures)
	_test_ast002_checks_ids_enums_dimensions_timing_and_paths(failures)
	_test_ast003_enforces_the_status_evidence_matrix(failures)
	_test_ast004_requires_generated_prompt_constraints(failures)
	_test_ast005_requires_the_xiaodong_a5_deliverable_set(failures)
	_test_ast006_requires_three_way_xiaodong_reference_consistency(failures)
	_test_ast007_requires_one_valid_card_lifecycle_and_boundary(failures)
	_test_gameplay_rules_run_for_present_partial_records(failures)
	_test_full_catalog_fixtures_are_exact_behavior_inputs(failures)
	_test_id001_rejects_malformed_wrong_prefix_duplicate_and_cross_domain_ids(failures)
	_test_ref001_rejects_missing_complete_catalog_references(failures)
	_test_wpn001_rejects_each_bounded_weapon_stat(failures)
	_test_upg001_requires_total_and_category_counts(failures)
	_test_upg002_requires_existing_nonself_symmetric_conflicts(failures)
	_test_chr001_requires_three_distinct_owned_modules(failures)
	_test_mut001_requires_a_mutation_for_every_weapon(failures)
	_test_wave001_requires_exact_numbers_and_enemy_references(failures)
	_test_ulk001_requires_existing_acyclic_dependencies(failures)
	_test_production_full_profile_remains_not_ready(failures)
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

func _test_loader_normalizes_xiaodong_card_and_original_jpeg_bytes(failures: Array[String]) -> void:
	var result: Dictionary = _loader_script.call("load_project", VALID_ROOT, VALID_CONFIG)
	var snapshot: Dictionary = result.get("snapshot", {})
	var assets: Dictionary = snapshot.get("assets", {})
	var governance: Dictionary = assets.get("governance", {})
	var xiaodong: Dictionary = governance.get("xiaodong", {})
	var card: Dictionary = xiaodong.get("design_card", {})
	var reference: Dictionary = xiaodong.get("reference", {})
	_assert_equal(snapshot.keys().size(), 4, "Governance normalization must retain exactly four top-level snapshot keys.", failures)
	_assert_equal(card.get("path"), "assets/characters/xiaodong/character_xiaodong_design.md", "The loader must use the fixed Xiaodong card path.", failures)
	_assert_equal(card.get("exists"), true, "The static valid Xiaodong card must exist.", failures)
	_assert_equal(card.get("machine_block_count"), 1, "Only the exact gogo-governance+json fence must be counted.", failures)
	_assert_equal(card.get("parse_error"), "", "The valid governance machine block must parse without error.", failures)
	var record: Dictionary = card.get("record", {})
	_assert_equal(record.get("subject"), "xiaodong", "The exact machine block must normalize its subject.", failures)
	_assert_equal(record.get("candidate_count"), 0, "The initial card candidate count must normalize as integer zero.", failures)
	_assert_equal(reference.get("path"), XIAODONG_REFERENCE_PATH, "The loader must use the fixed Xiaodong reference path.", failures)
	_assert_equal(reference.get("exists"), true, "The static valid reference must exist.", failures)
	_assert_equal(reference.get("bytes"), 77554, "The loader must preserve the original JPEG byte count.", failures)
	_assert_equal(reference.get("jpeg_decoded"), true, "The original bytes must decode through the JPEG decoder.", failures)
	_assert_equal(reference.get("width"), 853, "The decoded JPEG width must be normalized.", failures)
	_assert_equal(reference.get("height"), 1280, "The decoded JPEG height must be normalized.", failures)
	_assert_equal(reference.get("sha256"), XIAODONG_REFERENCE_SHA256, "The original JPEG bytes must produce the approved SHA-256.", failures)
	var duplicate_card: Dictionary = {
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		"```gogo-governance+json\n{}\n```\n```gogo-governance+json\n{}\n```\n",
		duplicate_card
	)
	_assert_equal(duplicate_card.get("machine_block_count"), 2, "The loader must preserve duplicate exact machine-block evidence for AST007.", failures)
	_assert_equal(duplicate_card.get("record"), {}, "The loader must not select a record from duplicate machine blocks.", failures)

func _test_loader_rejects_inactive_governance_machine_blocks(failures: Array[String]) -> void:
	var inactive_cases: Array[Dictionary] = [
		{
			"label": "four-backtick outer fence",
			"markdown": "````markdown\n```gogo-governance+json\n{}\n```\n````\n",
		},
		{
			"label": "tilde outer fence",
			"markdown": "~~~markdown\n```gogo-governance+json\n{}\n```\n~~~~\n",
		},
		{
			"label": "multiline HTML comment",
			"markdown": "<!-- inactive example\n```gogo-governance+json\n{}\n```\n-->\n",
		},
	]
	for case: Dictionary in inactive_cases:
		var card: Dictionary = {
			"path": "assets/characters/xiaodong/character_xiaodong_design.md",
			"exists": true,
			"machine_block_count": 0,
			"parse_error": "",
			"record": {},
		}
		_loader_script.call("_normalize_governance_machine_block", case["markdown"], card)
		_assert_equal(card.get("machine_block_count"), 0, "An exact opener inside a %s must remain inactive." % case["label"], failures)
		var snapshot: Dictionary = _base_snapshot()
		snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
		_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 1, "An inactive %s example must not satisfy AST007." % case["label"], failures)

	var valid_record: Dictionary = _valid_xiaodong_governance()["design_card"]["record"]
	var closed_outer_fence_card: Dictionary = {
		"path": "assets/characters/xiaodong/character_xiaodong_design.md",
		"exists": true,
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		"````markdown\n```gogo-governance+json\n{}\n```\n`````\n```gogo-governance+json\n%s\n```\n" % JSON.stringify(valid_record),
		closed_outer_fence_card
	)
	_assert_equal(closed_outer_fence_card.get("machine_block_count"), 1, "A longer closing fence must end its outer context before a top-level exact block.", failures)
	_assert_equal(closed_outer_fence_card.get("record", {}).get("subject"), "xiaodong", "The top-level exact block after a longer close must be the parsed record.", failures)

	var unterminated_card: Dictionary = {
		"path": "assets/characters/xiaodong/character_xiaodong_design.md",
		"exists": true,
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		"```gogo-governance+json\n{}\n",
		unterminated_card
	)
	_assert_equal(unterminated_card.get("machine_block_count"), 0, "An unterminated exact block must not count as a complete machine block.", failures)
	_assert_equal(unterminated_card.get("parse_error"), "unterminated gogo-governance+json block", "An unterminated exact block must retain deterministic parse evidence.", failures)
	var unterminated_snapshot: Dictionary = _base_snapshot()
	unterminated_snapshot["assets"]["governance"]["xiaodong"]["design_card"] = unterminated_card
	_assert_equal(_issue_count(_validate(unterminated_snapshot, &"g0"), "AST007"), 1, "An unterminated exact block must produce one stable AST007 issue.", failures)

func _test_loader_fails_closed_on_raw_html_before_governance_block(failures: Array[String]) -> void:
	var valid_record: Dictionary = _valid_xiaodong_governance()["design_card"]["record"]
	var exact_block: String = "```gogo-governance+json\n%s\n```\n" % JSON.stringify(valid_record)
	var raw_html_cases: Array[Dictionary] = [
		{"label": "pre block", "markdown": "<pre>\n" + exact_block + "</pre>\n"},
		{"label": "processing instruction", "markdown": "<?governance example?>\n" + exact_block},
		{"label": "doctype declaration", "markdown": "<!DOCTYPE html>\n" + exact_block},
		{"label": "CDATA block", "markdown": "<![CDATA[\n" + exact_block + "]]>\n"},
		{"label": "three-space-indented type-six div block", "markdown": "   <div>\n" + exact_block + "</div>\n"},
		{"label": "type-seven custom tag", "markdown": "<governance-example>inactive</governance-example>\n" + exact_block},
	]
	for case: Dictionary in raw_html_cases:
		var card: Dictionary = {
			"path": "assets/characters/xiaodong/character_xiaodong_design.md",
			"exists": true,
			"machine_block_count": 0,
			"parse_error": "",
			"record": {},
		}
		_loader_script.call("_normalize_governance_machine_block", case["markdown"], card)
		_assert_equal(card.get("machine_block_count"), 0, "A %s before the first active block must fail closed." % case["label"], failures)
		_assert_equal(
			card.get("parse_error"),
			"raw HTML before gogo-governance+json block is not supported",
			"A %s must retain deterministic fail-closed evidence." % case["label"],
			failures
		)
		var snapshot: Dictionary = _base_snapshot()
		snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
		_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 1, "A %s must produce exactly one AST007." % case["label"], failures)

	var safe_contexts: Array[Dictionary] = [
		{
			"label": "outer Markdown fence",
			"markdown": "````html\n<pre>\n````\n" + exact_block,
		},
		{
			"label": "HTML comment",
			"markdown": "<!--\n<pre>\n-->\n" + exact_block,
		},
		{
			"label": "four-space indented code",
			"markdown": "    <pre>\n" + exact_block,
		},
	]
	for case: Dictionary in safe_contexts:
		var card: Dictionary = {
			"path": "assets/characters/xiaodong/character_xiaodong_design.md",
			"exists": true,
			"machine_block_count": 0,
			"parse_error": "",
			"record": {},
		}
		_loader_script.call("_normalize_governance_machine_block", case["markdown"], card)
		_assert_equal(card.get("machine_block_count"), 1, "Raw-HTML-like text inside a %s must not reject a later top-level block." % case["label"], failures)
		_assert_equal(card.get("parse_error"), "", "A %s must not create raw HTML parse evidence." % case["label"], failures)
		var snapshot: Dictionary = _base_snapshot()
		snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
		_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 0, "A valid block after a %s must satisfy AST007." % case["label"], failures)

func _test_loader_fails_closed_on_raw_html_after_governance_block(failures: Array[String]) -> void:
	var valid_record: Dictionary = _valid_xiaodong_governance()["design_card"]["record"]
	var exact_block: String = "```gogo-governance+json\n%s\n```\n" % JSON.stringify(valid_record)
	var card: Dictionary = {
		"path": "assets/characters/xiaodong/character_xiaodong_design.md",
		"exists": true,
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		exact_block + "<pre>\n```\n</pre>\n" + exact_block,
		card
	)
	_assert_equal(card.get("machine_block_count"), 1, "Raw HTML ordering pollution must not manufacture a second parsed machine block.", failures)
	_assert_equal(
		card.get("parse_error"),
		"raw HTML before gogo-governance+json block is not supported",
		"Top-level raw HTML after the first active block must retain deterministic fail-closed evidence.",
		failures
	)
	var snapshot: Dictionary = _base_snapshot()
	snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
	_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 1, "Top-level raw HTML after the first active block must produce exactly one AST007.", failures)

func _test_loader_ignores_indented_html_comment_literals(failures: Array[String]) -> void:
	var valid_record: Dictionary = _valid_xiaodong_governance()["design_card"]["record"]
	var card: Dictionary = {
		"path": "assets/characters/xiaodong/character_xiaodong_design.md",
		"exists": true,
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		"    <!-- literal\n```gogo-governance+json\n%s\n```\n" % JSON.stringify(valid_record),
		card
	)
	_assert_equal(card.get("machine_block_count"), 1, "A four-space indented comment literal must not hide a later top-level machine block.", failures)
	_assert_equal(card.get("parse_error"), "", "Indented code containing a comment literal must not create parse evidence.", failures)
	var snapshot: Dictionary = _base_snapshot()
	snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
	_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 0, "A valid block after an indented comment literal must satisfy AST007.", failures)

func _test_loader_does_not_treat_invalid_backtick_info_as_a_fence(failures: Array[String]) -> void:
	var valid_record: Dictionary = _valid_xiaodong_governance()["design_card"]["record"]
	var card: Dictionary = {
		"path": "assets/characters/xiaodong/character_xiaodong_design.md",
		"exists": true,
		"machine_block_count": 0,
		"parse_error": "",
		"record": {},
	}
	_loader_script.call(
		"_normalize_governance_machine_block",
		"```not-a-fence`info\n```gogo-governance+json\n%s\n```\n" % JSON.stringify(valid_record),
		card
	)
	_assert_equal(card.get("machine_block_count"), 1, "A backtick marker with a backtick in its info string must not hide the following top-level block.", failures)
	_assert_equal(card.get("parse_error"), "", "An invalid backtick fence opener must not create parse evidence.", failures)
	var snapshot: Dictionary = _base_snapshot()
	snapshot["assets"]["governance"]["xiaodong"]["design_card"] = card
	_assert_equal(_issue_count(_validate(snapshot, &"g0"), "AST007"), 0, "A valid top-level block after an invalid backtick opener must satisfy AST007.", failures)

func _test_loader_normalizes_missing_and_corrupt_references_without_throwing(failures: Array[String]) -> void:
	var missing: Dictionary = _loader_script.call(
		"load_project",
		GOVERNANCE_ROOT + "missing_reference/",
		MISSING_REFERENCE_CONFIG
	)
	var missing_reference: Dictionary = missing.get("snapshot", {}).get("assets", {}).get("governance", {}).get("xiaodong", {}).get("reference", {})
	_assert_equal(missing_reference.get("exists"), false, "A missing fixed reference must normalize as absent without throwing.", failures)
	_assert_equal(missing_reference.get("bytes"), 0, "A missing fixed reference must normalize to zero bytes.", failures)
	_assert_equal(missing_reference.get("jpeg_decoded"), false, "A missing fixed reference must not claim JPEG decoding.", failures)
	var corrupt: Dictionary = _loader_script.call(
		"load_project",
		GOVERNANCE_ROOT + "corrupt_reference/",
		CORRUPT_REFERENCE_CONFIG
	)
	var corrupt_reference: Dictionary = corrupt.get("snapshot", {}).get("assets", {}).get("governance", {}).get("xiaodong", {}).get("reference", {})
	_assert_equal(corrupt_reference.get("exists"), true, "A corrupt fixed reference must still normalize its filesystem existence.", failures)
	_assert_equal(corrupt_reference.get("bytes"), 22, "A corrupt SOI/EOI fixture must retain its original byte count.", failures)
	_assert_equal(corrupt_reference.get("sha256"), CORRUPT_REFERENCE_SHA256, "A corrupt SOI/EOI fixture must retain its original SHA-256 evidence.", failures)
	_assert_equal(corrupt_reference.get("jpeg_decoded"), false, "Unapproved SOI/EOI bytes must not claim successful JPEG decoding.", failures)

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

func _test_reference_validation_skips_a_missing_target_config(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	snapshot["config"]["datasets"]["weapons"]["state"] = "partial"
	snapshot["config"]["datasets"].erase("characters")
	snapshot["gameplay"]["weapons"] = [_valid_weapon_with_character_reference()]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(
		_has_issue(report, "CFG001", "characters", "object"),
		"A missing reference target config must return CFG001 instead of aborting validation.",
		failures
	)
	_assert_true(
		_has_issue(report, "REF001", "wpn_one", "upgrades is not present"),
		"A missing target config must not abort processing of later valid references.",
		failures
	)

func _test_reference_validation_skips_a_non_dictionary_target_config(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	snapshot["config"]["datasets"]["weapons"]["state"] = "partial"
	snapshot["config"]["datasets"]["characters"] = []
	snapshot["gameplay"]["weapons"] = [_valid_weapon_with_character_reference()]
	var report: Dictionary = _validate(snapshot, &"g0")
	_assert_true(
		_has_issue(report, "CFG001", "characters", "object"),
		"A non-Dictionary reference target config must return CFG001 instead of aborting validation.",
		failures
	)
	_assert_true(
		_has_issue(report, "REF001", "wpn_one", "upgrades is not present"),
		"A non-Dictionary target config must not abort processing of later valid references.",
		failures
	)

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

func _test_ast006_requires_three_way_xiaodong_reference_consistency(failures: Array[String]) -> void:
	var binary_mismatch: Dictionary = _base_snapshot()
	binary_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
	binary_mismatch["assets"]["governance"]["xiaodong"]["reference"]["bytes"] = 1
	_assert_true(
		_has_issue(_validate(binary_mismatch, &"g0"), "AST006", "xiaodong_reference", "integrity"),
		"AST006 must reject an actual reference byte-count mismatch.",
		failures
	)

	var dimension_mismatch: Dictionary = _base_snapshot()
	dimension_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
	dimension_mismatch["assets"]["governance"]["xiaodong"]["reference"]["width"] = 852
	_assert_true(
		_has_issue(_validate(dimension_mismatch, &"g0"), "AST006", "xiaodong_reference", "integrity"),
		"AST006 must reject decoded reference dimension mismatches.",
		failures
	)

	var sha_mismatch: Dictionary = _base_snapshot()
	sha_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
	sha_mismatch["assets"]["governance"]["xiaodong"]["reference"]["sha256"] = "00"
	_assert_true(
		_has_issue(_validate(sha_mismatch, &"g0"), "AST006", "xiaodong_reference", "integrity"),
		"AST006 must reject the actual reference SHA-256 mismatch.",
		failures
	)

	var card_mismatch: Dictionary = _base_snapshot()
	card_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
	card_mismatch["assets"]["governance"]["xiaodong"]["design_card"]["record"]["reference"]["width"] = 852
	_assert_true(
		_has_issue(_validate(card_mismatch, &"g0"), "AST006", "xiaodong_reference", "integrity"),
		"AST006 must reject a card reference dimension mismatch.",
		failures
	)

	var manifest_mismatch: Dictionary = _base_snapshot()
	manifest_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
	manifest_mismatch["assets"]["rows"][0]["reference_source"] = "assets/source/references/characters/xiaodong/other.jpg"
	manifest_mismatch["assets"]["rows"][1]["reference_sha256"] = "00"
	manifest_mismatch["assets"]["rows"][2]["reference_rights_policy"] = "original"
	_assert_true(
		_has_issue(_validate(manifest_mismatch, &"g0"), "AST006", "xiaodong_reference", "integrity"),
		"AST006 must reject Xiaodong A5 CSV path/SHA/R2 tuple mismatches.",
		failures
	)

func _test_ast007_requires_one_valid_card_lifecycle_and_boundary(failures: Array[String]) -> void:
	var missing_card: Dictionary = _base_snapshot()
	missing_card["assets"]["governance"]["xiaodong"]["design_card"]["exists"] = false
	missing_card["assets"]["governance"]["xiaodong"]["design_card"]["machine_block_count"] = 0
	_assert_equal(_issue_count(_validate(missing_card, &"g0"), "AST007"), 1, "A missing card must produce one stable AST007 issue.", failures)

	var duplicate_block: Dictionary = _base_snapshot()
	duplicate_block["assets"]["governance"]["xiaodong"]["design_card"]["machine_block_count"] = 2
	_assert_equal(_issue_count(_validate(duplicate_block, &"g0"), "AST007"), 1, "Duplicate exact machine blocks must produce one stable AST007 issue.", failures)

	var invalid_machine_block: Dictionary = _base_snapshot()
	invalid_machine_block["assets"]["governance"]["xiaodong"]["design_card"]["parse_error"] = "invalid JSON object"
	invalid_machine_block["assets"]["governance"]["xiaodong"]["design_card"]["record"] = {}
	_assert_equal(_issue_count(_validate(invalid_machine_block, &"g0"), "AST007"), 1, "An invalid machine block must produce one stable AST007 issue.", failures)

	var invalid_lifecycle: Dictionary = _base_snapshot()
	invalid_lifecycle["assets"]["governance"]["xiaodong"]["design_card"]["record"]["candidate_count"] = 1
	_assert_equal(_issue_count(_validate(invalid_lifecycle, &"g0"), "AST007"), 1, "not_generated with a positive candidate count must fail AST007.", failures)

	var invalid_boundary: Dictionary = _base_snapshot()
	invalid_boundary["assets"]["governance"]["xiaodong"]["design_card"]["record"]["boundary"]["c0_enters_godot"] = true
	_assert_equal(_issue_count(_validate(invalid_boundary, &"g0"), "AST007"), 1, "C0 entering Godot must fail AST007.", failures)

	var accepted: Dictionary = _base_snapshot()
	var accepted_record: Dictionary = accepted["assets"]["governance"]["xiaodong"]["design_card"]["record"]
	accepted_record["artifact_state"] = "generated"
	accepted_record["decision"] = "accepted_for_concept"
	accepted_record["candidate_count"] = 1
	_assert_equal(_issue_count(_validate(accepted, &"g0"), "AST007"), 0, "A generated positive-count accepted_for_concept card must remain rerunnable.", failures)

	var forward_compatible_revise: Dictionary = _base_snapshot()
	var revise_record: Dictionary = forward_compatible_revise["assets"]["governance"]["xiaodong"]["design_card"]["record"]
	revise_record["artifact_state"] = "cleaned"
	revise_record["decision"] = "revise"
	revise_record["candidate_count"] = 2
	_assert_equal(_issue_count(_validate(forward_compatible_revise, &"g0"), "AST007"), 0, "Non-accepted valid-enum lifecycle combinations must remain forward compatible.", failures)

func _test_gameplay_rules_run_for_present_partial_records(failures: Array[String]) -> void:
	var snapshot: Dictionary = _base_snapshot()
	snapshot["config"]["datasets"]["weapons"]["state"] = "partial"
	snapshot["gameplay"]["weapons"] = [{
		"id": "Bad Weapon",
		"character_id": "char_missing",
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
			"id": "upgrade_mut_one",
			"category": "mutation",
			"requires_upgrade_id": "",
			"source_path": "res://data/upgrades/mutation.tres",
			"source_line": 0,
		},
	]
	snapshot["config"]["datasets"]["characters"]["state"] = "partial"
	snapshot["gameplay"]["characters"] = [{
		"id": "char_one",
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
	_assert_true(_has_issue(report, "MUT001", "upgrade_mut_one", "prerequisite"), "MUT001 must validate present partial mutation prerequisites.", failures)
	_assert_true(_has_issue(report, "CHR001", "char_one", "display_name"), "CHR001 must validate present partial character records.", failures)
	_assert_true(_has_issue(report, "WAVE001", "wave_one", "range"), "WAVE001 must validate present partial wave numbers.", failures)
	_assert_true(_has_issue(report, "ULK001", "unlock_one", "target_id"), "ULK001 must validate present partial unlock records.", failures)

func _test_full_catalog_fixtures_are_exact_behavior_inputs(failures: Array[String]) -> void:
	var snapshot: Dictionary = _load_json_fixture(FULL_VALID_FIXTURE, failures)
	if snapshot.is_empty():
		return
	var gameplay: Dictionary = snapshot.get("gameplay", {})
	_assert_equal((gameplay.get("characters", []) as Array).size(), 5, "The full fixture must contain exactly five characters.", failures)
	_assert_equal((gameplay.get("weapons", []) as Array).size(), 5, "The full fixture must contain exactly five weapons.", failures)
	_assert_equal((gameplay.get("throwables", []) as Array).size(), 4, "The full fixture must contain exactly four throwables.", failures)
	_assert_equal((gameplay.get("enemies", []) as Array).size(), 14, "The full fixture must contain exactly fourteen enemies.", failures)
	_assert_equal((gameplay.get("upgrades", []) as Array).size(), 47, "The full fixture must contain exactly forty-seven upgrades.", failures)
	_assert_equal((gameplay.get("waves", []) as Array).size(), 20, "The full fixture must contain exactly twenty waves.", failures)
	_assert_equal(
		_upgrade_category_counts(snapshot),
		{"calibration": 8, "engine": 10, "mutation": 9, "module": 15, "contract": 5},
		"The full fixture must use the exact 8/10/9/15/5 upgrade matrix.",
		failures
	)
	for character_value: Variant in gameplay.get("characters", []):
		var character: Dictionary = character_value
		var module_ids: Array = character.get("module_ids", [])
		var distinct_ids: Dictionary = {}
		for module_id: Variant in module_ids:
			distinct_ids[String(module_id)] = true
		_assert_equal(module_ids.size(), 3, "Each fixture character must declare three module IDs.", failures)
		_assert_equal(distinct_ids.size(), 3, "Each fixture character must declare three distinct module IDs.", failures)
	var valid_report: Dictionary = _validate(snapshot, &"full")
	_assert_equal(valid_report.get("gate_status"), "pass", "The exact synthetic catalog must pass full validation.", failures)
	_assert_equal(valid_report.get("catalog_status"), "ready", "The exact synthetic catalog must be ready.", failures)
	_assert_equal(valid_report.get("issues", []), [], "The exact synthetic catalog must have no validation issues.", failures)

	var invalid_report: Dictionary = _validate(_load_json_fixture(FULL_INVALID_FIXTURE, failures), &"full")
	_assert_equal(invalid_report.get("gate_status"), "fail", "The explicit invalid fixture must fail full validation.", failures)
	_assert_issue_fields(invalid_report, "REF001", "wpn_invalid", "char_missing", null, "The invalid fixture must expose a missing reference.", failures)
	_assert_issue_fields(invalid_report, "WPN001", "wpn_invalid", "> 0", 0, "The invalid fixture must expose a bounded weapon stat.", failures)
	_assert_issue_fields(invalid_report, "UPG001", "upgrades", 47, 2, "The invalid fixture must expose the upgrade total.", failures)
	_assert_issue_fields(invalid_report, "UPG002", "upgrade_mut_01", "different upgrade id", "upgrade_mut_01", "The invalid fixture must expose a self conflict.", failures)
	_assert_issue_fields(invalid_report, "CHR001", "char_01", "exactly 3 distinct module ids", ["upgrade_module_01", "upgrade_module_01"], "The invalid fixture must expose an invalid module set.", failures)
	_assert_issue_fields(invalid_report, "MUT001", "wpn_invalid", ">= 1 mutation", 0, "The invalid fixture must expose a weapon without a mutation.", failures)
	_assert_issue_fields(invalid_report, "WAVE001", "wave_01", [1, 20], 21, "The invalid fixture must expose an out-of-range wave.", failures)
	_assert_issue_fields(invalid_report, "ULK001", "unlocks", "acyclic", "cycle", "The invalid fixture must expose an unlock cycle.", failures)

func _test_id001_rejects_malformed_wrong_prefix_duplicate_and_cross_domain_ids(failures: Array[String]) -> void:
	var malformed: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(malformed, "enemies", "enemy_01")["id"] = "Bad Enemy"
	_assert_issue_fields(_validate(malformed, &"full"), "ID001", "Bad Enemy", "snake_case", "Bad Enemy", "ID001 must reject malformed IDs.", failures)

	var prefix_mutations: Array[Dictionary] = [
		{"dataset": "characters", "valid": "char_01", "invalid": "character_01", "expected": "char_"},
		{"dataset": "weapons", "valid": "wpn_01", "invalid": "weapon_01", "expected": "wpn_"},
		{"dataset": "throwables", "valid": "throw_01", "invalid": "throwable_01", "expected": "throw_"},
		{"dataset": "upgrades", "valid": "upgrade_cal_01", "invalid": "calibration_01", "expected": "upgrade_"},
		{"dataset": "enemies", "valid": "enemy_01", "invalid": "foe_01", "expected": "enemy_"},
	]
	for mutation: Dictionary in prefix_mutations:
		var wrong_prefix: Dictionary = _full_valid_snapshot(failures)
		_record_by_id(wrong_prefix, mutation["dataset"], mutation["valid"])["id"] = mutation["invalid"]
		_assert_issue_fields(
			_validate(wrong_prefix, &"full"),
			"ID001",
			mutation["invalid"],
			mutation["expected"],
			mutation["invalid"],
			"ID001 must enforce the %s namespace for %s." % [mutation["expected"], mutation["dataset"]],
			failures
		)

	var duplicate: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(duplicate, "enemies", "enemy_02")["id"] = "enemy_01"
	_assert_issue_fields(_validate(duplicate, &"full"), "ID001", "enemy_01", "unique across gameplay datasets", "enemies", "ID001 must reject duplicate IDs in one domain.", failures)

	var cross_domain: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(cross_domain, "throwables", "throw_01")["id"] = "wpn_01"
	_assert_issue_fields(_validate(cross_domain, &"full"), "ID001", "wpn_01", "unique across gameplay datasets", "weapons", "ID001 must reject IDs reused across domains.", failures)

	var unscoped_datasets: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(unscoped_datasets, "waves", "wave_01")["id"] = "chapter_one"
	_record_by_id(unscoped_datasets, "unlocks", "unlock_root")["id"] = "gate_root"
	_assert_equal(_issue_count(_validate(unscoped_datasets, &"full"), "ID001"), 0, "ID001 must not invent prefix policies for waves or unlocks.", failures)

func _test_ref001_rejects_missing_complete_catalog_references(failures: Array[String]) -> void:
	var missing_character: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_character, "weapons", "wpn_01")["character_id"] = "char_missing"
	_assert_issue_fields(_validate(missing_character, &"full"), "REF001", "wpn_01", "char_missing", null, "REF001 must reject a missing character reference.", failures)

	var missing_weapon: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_weapon, "throwables", "throw_01")["weapon_id"] = "wpn_missing"
	_assert_issue_fields(_validate(missing_weapon, &"full"), "REF001", "throw_01", "wpn_missing", null, "REF001 must reject a missing weapon reference.", failures)

	var missing_enemy: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_enemy, "waves", "wave_01")["enemy_id"] = "enemy_missing"
	_assert_issue_fields(_validate(missing_enemy, &"full"), "REF001", "wave_01", "enemy_missing", null, "REF001 must reject a missing enemy reference.", failures)

	var missing_upgrade: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_upgrade, "weapons", "wpn_01")["upgrade_id"] = "upgrade_missing"
	_assert_issue_fields(_validate(missing_upgrade, &"full"), "REF001", "wpn_01", "upgrade_missing", null, "REF001 must reject a missing upgrade reference.", failures)

func _test_wpn001_rejects_each_bounded_weapon_stat(failures: Array[String]) -> void:
	var mutations: Array[Dictionary] = [
		{"field": "damage", "value": 0, "expected": "> 0"},
		{"field": "reload_duration", "value": 0, "expected": "> 0"},
		{"field": "range_pixels", "value": 0, "expected": "> 0"},
		{"field": "pierce_count", "value": -1, "expected": ">= 0"},
		{"field": "pierce_decay", "value": -0.1, "expected": "0..1"},
		{"field": "pierce_decay", "value": 1.1, "expected": "0..1"},
		{"field": "weakpoint_multiplier", "value": 0.9, "expected": ">= 1"},
	]
	for mutation: Dictionary in mutations:
		var snapshot: Dictionary = _full_valid_snapshot(failures)
		_record_by_id(snapshot, "weapons", "wpn_01")[mutation["field"]] = mutation["value"]
		_assert_issue_fields(
			_validate(snapshot, &"full"), "WPN001", "wpn_01",
			mutation["expected"], mutation["value"],
			"WPN001 must reject weapon field %s=%s." % [mutation["field"], str(mutation["value"])],
			failures
		)

func _test_upg001_requires_total_and_category_counts(failures: Array[String]) -> void:
	var short_catalog: Dictionary = _full_valid_snapshot(failures)
	(short_catalog["gameplay"]["upgrades"] as Array).pop_back()
	_assert_issue_fields(_validate(short_catalog, &"full"), "UPG001", "upgrades", 47, 46, "UPG001 must require exactly forty-seven upgrades.", failures)

	var wrong_matrix: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(wrong_matrix, "upgrades", "upgrade_cal_08")["category"] = "engine"
	_assert_issue_fields(
		_validate(wrong_matrix, &"full"), "UPG001", "upgrades",
		{"calibration": 8, "engine": 10, "mutation": 9, "module": 15, "contract": 5},
		{"calibration": 7, "engine": 11, "mutation": 9, "module": 15, "contract": 5},
		"UPG001 must require the exact upgrade category matrix.",
		failures
	)

func _test_upg002_requires_existing_nonself_symmetric_conflicts(failures: Array[String]) -> void:
	var missing: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing, "upgrades", "upgrade_cal_01")["conflicts"] = ["upgrade_missing"]
	_assert_issue_fields(_validate(missing, &"full"), "UPG002", "upgrade_cal_01", "existing upgrade id", "upgrade_missing", "UPG002 must reject a conflict target that does not exist.", failures)

	var self_conflict: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(self_conflict, "upgrades", "upgrade_cal_01")["conflicts"] = ["upgrade_cal_01"]
	_assert_issue_fields(_validate(self_conflict, &"full"), "UPG002", "upgrade_cal_01", "different upgrade id", "upgrade_cal_01", "UPG002 must reject a self conflict.", failures)

	var asymmetric: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(asymmetric, "upgrades", "upgrade_cal_02")["conflicts"] = []
	_assert_issue_fields(_validate(asymmetric, &"full"), "UPG002", "upgrade_cal_01", "upgrade_cal_01", [], "UPG002 must require symmetric conflict declarations.", failures)

func _test_chr001_requires_three_distinct_owned_modules(failures: Array[String]) -> void:
	var two_modules: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(two_modules, "characters", "char_01")["module_ids"] = ["upgrade_module_01", "upgrade_module_02"]
	_assert_issue_fields(_validate(two_modules, &"full"), "CHR001", "char_01", "exactly 3 distinct module ids", ["upgrade_module_01", "upgrade_module_02"], "CHR001 must reject two modules.", failures)

	var four_modules: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(four_modules, "characters", "char_01")["module_ids"] = ["upgrade_module_01", "upgrade_module_02", "upgrade_module_03", "upgrade_module_04"]
	_assert_issue_fields(_validate(four_modules, &"full"), "CHR001", "char_01", "exactly 3 distinct module ids", ["upgrade_module_01", "upgrade_module_02", "upgrade_module_03", "upgrade_module_04"], "CHR001 must reject four modules.", failures)

	var duplicate_module: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(duplicate_module, "characters", "char_01")["module_ids"] = ["upgrade_module_01", "upgrade_module_01", "upgrade_module_03"]
	_assert_issue_fields(_validate(duplicate_module, &"full"), "CHR001", "char_01", "exactly 3 distinct module ids", ["upgrade_module_01", "upgrade_module_01", "upgrade_module_03"], "CHR001 must reject duplicate modules.", failures)

	var wrong_owner: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(wrong_owner, "upgrades", "upgrade_module_01")["character_id"] = "char_02"
	_assert_issue_fields(_validate(wrong_owner, &"full"), "CHR001", "char_01", "char_01", "char_02", "CHR001 must reject a module whose back-reference names another character.", failures)

func _test_mut001_requires_a_mutation_for_every_weapon(failures: Array[String]) -> void:
	var snapshot: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(snapshot, "upgrades", "upgrade_mut_09")["weapon_id"] = "wpn_04"
	_assert_issue_fields(_validate(snapshot, &"full"), "MUT001", "wpn_05", ">= 1 mutation", 0, "MUT001 must reject a weapon without a mutation.", failures)

func _test_wave001_requires_exact_numbers_and_enemy_references(failures: Array[String]) -> void:
	var missing_wave: Dictionary = _full_valid_snapshot(failures)
	(missing_wave["gameplay"]["waves"] as Array).pop_back()
	_assert_issue_fields(_validate(missing_wave, &"full"), "WAVE001", "waves", [1, 20], [20], "WAVE001 must reject a missing wave number.", failures)

	var duplicate_wave: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(duplicate_wave, "waves", "wave_20")["wave"] = 19
	_assert_issue_fields(_validate(duplicate_wave, &"full"), "WAVE001", "wave_20", "unique wave number", 19, "WAVE001 must reject a duplicate wave number.", failures)

	var out_of_range: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(out_of_range, "waves", "wave_20")["wave"] = 21
	_assert_issue_fields(_validate(out_of_range, &"full"), "WAVE001", "wave_20", [1, 20], 21, "WAVE001 must reject an out-of-range wave number.", failures)

	var near_integer: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(near_integer, "waves", "wave_01")["wave"] = 1.000001
	near_integer["config"]["datasets"]["waves"]["state"] = "partial"
	var near_integer_report: Dictionary = _validate(near_integer, &"g0")
	_assert_issue_fields(near_integer_report, "WAVE001", "wave_01", [1, 20], 1.000001, "WAVE001 must reject a near-integer fractional wave number instead of truncating it.", failures)
	_assert_equal((near_integer_report.get("counts", {}) as Dictionary).get("error"), 1, "The isolated near-integer mutation must produce exactly one ERROR issue.", failures)

	var missing_enemy: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_enemy, "waves", "wave_01")["enemy_ids"] = ["enemy_missing"]
	_assert_issue_fields(_validate(missing_enemy, &"full"), "WAVE001", "wave_01", "enemy_missing", null, "WAVE001 must reject an unresolved enemy_ids entry.", failures)

func _test_ulk001_requires_existing_acyclic_dependencies(failures: Array[String]) -> void:
	var diamond_report: Dictionary = _validate(_full_valid_snapshot(failures), &"full")
	_assert_equal(_issue_count(diamond_report, "ULK001"), 0, "ULK001 must accept the valid diamond dependency graph.", failures)

	var missing_dependency: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(missing_dependency, "unlocks", "unlock_left")["requires_unlock_ids"] = ["unlock_missing"]
	_assert_issue_fields(_validate(missing_dependency, &"full"), "ULK001", "unlock_left", "existing unlock id", "unlock_missing", "ULK001 must reject a missing unlock dependency.", failures)

	var cycle: Dictionary = _full_valid_snapshot(failures)
	_record_by_id(cycle, "unlocks", "unlock_root")["requires_unlock_ids"] = ["unlock_top"]
	_assert_issue_fields(_validate(cycle, &"full"), "ULK001", "unlocks", "acyclic", "cycle", "ULK001 must reject a dependency cycle.", failures)

func _test_production_full_profile_remains_not_ready(failures: Array[String]) -> void:
	var report: Dictionary = _validator_script.call("validate_project", &"full", "res://data/content_validation.json")
	_assert_equal(report.get("gate_status"), "fail", "Production must not pass full while future datasets are absent or partial.", failures)
	_assert_equal(report.get("catalog_status"), "not_ready", "Production must honestly report a not_ready catalog.", failures)
	_assert_true(int((report.get("counts", {}) as Dictionary).get("not_ready", 0)) > 0, "Production full validation must retain explicit NOT_READY issues.", failures)

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

func _load_json_fixture(path: String, failures: Array[String]) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("Unable to open JSON fixture: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		failures.append("JSON fixture must contain an object: %s" % path)
		return {}
	return parsed

func _full_valid_snapshot(failures: Array[String]) -> Dictionary:
	return _load_json_fixture(FULL_VALID_FIXTURE, failures)

func _record_by_id(snapshot: Dictionary, dataset_name: String, identifier: String) -> Dictionary:
	for record_value: Variant in snapshot.get("gameplay", {}).get(dataset_name, []):
		if record_value is Dictionary:
			var record: Dictionary = record_value
			if record.get("id") == identifier:
				return record
	return {}

func _upgrade_category_counts(snapshot: Dictionary) -> Dictionary:
	var counts: Dictionary = {"calibration": 0, "engine": 0, "mutation": 0, "module": 0, "contract": 0}
	for record_value: Variant in snapshot.get("gameplay", {}).get("upgrades", []):
		if record_value is Dictionary:
			var category: String = String((record_value as Dictionary).get("category", ""))
			if counts.has(category):
				counts[category] += 1
	return counts

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
		"assets": {
			"header": ASSET_HEADER.duplicate(),
			"rows": [],
			"governance": {"xiaodong": _valid_xiaodong_governance()},
		},
		"gameplay": {
			"weapons": [], "throwables": [], "characters": [], "upgrades": [],
			"enemies": [], "waves": [], "unlocks": [],
		},
	}

func _valid_xiaodong_governance() -> Dictionary:
	return {
		"design_card": {
			"path": "assets/characters/xiaodong/character_xiaodong_design.md",
			"exists": true,
			"machine_block_count": 1,
			"parse_error": "",
			"record": {
				"schema_version": 1,
				"subject": "xiaodong",
				"design_stage": "C0",
				"asset_stage": "A5",
				"artifact_state": "not_generated",
				"decision": "pending_review",
				"candidate_count": 0,
				"reference": {
					"path": XIAODONG_REFERENCE_PATH,
					"bytes": 77554,
					"width": 853,
					"height": 1280,
					"sha256": XIAODONG_REFERENCE_SHA256,
					"rights_policy": "R2",
				},
				"boundary": {
					"c0_changes_a5_status": false,
					"c0_enters_godot": false,
					"a5_status": "planned",
					"a5_gate": "M4",
				},
			},
		},
		"reference": {
			"path": XIAODONG_REFERENCE_PATH,
			"exists": true,
			"bytes": 77554,
			"jpeg_decoded": true,
			"width": 853,
			"height": 1280,
			"sha256": XIAODONG_REFERENCE_SHA256,
		},
	}

func _xiaodong_a5_rows() -> Array[Dictionary]:
	var states: Array[String] = ["idle", "walk", "hit", "death", "skill_breakin", "portrait"]
	var rows: Array[Dictionary] = []
	for state_index: int in range(states.size()):
		var row: Dictionary = _valid_asset_row()
		row["asset_id"] = "xiaodong_%s" % states[state_index]
		row["phase"] = "A5"
		row["category"] = "ui" if states[state_index] == "portrait" else "character"
		row["subject"] = "xiaodong"
		row["state"] = states[state_index]
		row["status"] = "planned"
		row["reference_source"] = XIAODONG_REFERENCE_PATH
		row["reference_sha256"] = XIAODONG_REFERENCE_SHA256
		row["reference_rights_policy"] = "R2"
		row["source_line"] = state_index + 2
		rows.append(row)
	return rows

func _valid_weapon_with_character_reference() -> Dictionary:
	return {
		"id": "wpn_one",
		"character_id": "char_one",
		"upgrade_id": "upgrade_one",
		"damage": 1.0,
		"shots_per_second": 1.0,
		"magazine_size": 1,
		"reload_duration": 1.0,
		"range_pixels": 100.0,
		"source_path": "res://data/weapons/weapon_one.tres",
		"source_line": 0,
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

func _assert_issue_fields(
	report: Dictionary,
	rule: String,
	subject: String,
	expected: Variant,
	actual: Variant,
	message: String,
	failures: Array[String]
) -> void:
	for issue_value: Variant in report.get("issues", []):
		if not issue_value is Dictionary:
			continue
		var issue: Dictionary = issue_value
		if (
			issue.get("severity") == "ERROR"
			and issue.get("rule") == rule
			and issue.get("subject") == subject
			and _variants_equal(issue.get("expected"), expected)
			and _variants_equal(issue.get("actual"), actual)
		):
			return
	failures.append("%s Missing exact issue {%s, %s, expected=%s, actual=%s}." % [message, rule, subject, str(expected), str(actual)])

func _variants_equal(first: Variant, second: Variant) -> bool:
	if (first is int or first is float) and (second is int or second is float):
		return is_equal_approx(float(first), float(second))
	if typeof(first) != typeof(second):
		return false
	if first is Array:
		var first_array: Array = first
		var second_array: Array = second
		if first_array.size() != second_array.size():
			return false
		for index: int in range(first_array.size()):
			if not _variants_equal(first_array[index], second_array[index]):
				return false
		return true
	if first is Dictionary:
		var first_dictionary: Dictionary = first
		var second_dictionary: Dictionary = second
		if first_dictionary.size() != second_dictionary.size():
			return false
		for key: Variant in first_dictionary:
			if not second_dictionary.has(key) or not _variants_equal(first_dictionary[key], second_dictionary[key]):
				return false
		return true
	return first == second

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
