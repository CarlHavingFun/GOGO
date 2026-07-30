class_name ContentSnapshotLoader
extends RefCounted

const GAMEPLAY_DATASETS: Array[String] = [
	"weapons", "throwables", "characters", "upgrades", "enemies", "waves", "unlocks",
]
const ASSET_EVIDENCE_FIELDS: Array[String] = [
	"path", "source_output", "cleaned_output", "qa_record", "godot_evidence",
]

static func load_project(
	project_root: String = "res://",
	config_path: String = "res://data/content_validation.json"
) -> Dictionary:
	var snapshot: Dictionary = _empty_snapshot()
	var load_issues: Array[Dictionary] = []
	var normalized_root: String = _normalize_root(project_root)
	if not _is_safe_res_path(config_path):
		load_issues.append(_issue("CFG001", config_path, 0, "config", "Config path must be a safe res:// path."))
		return {"snapshot": snapshot, "load_issues": load_issues}
	if not FileAccess.file_exists(config_path):
		load_issues.append(_issue("CFG001", config_path, 0, "config", "Config file does not exist."))
		return {"snapshot": snapshot, "load_issues": load_issues}
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(config_path))
	if not config_value is Dictionary:
		load_issues.append(_issue("CFG001", config_path, 0, "config", "Config file is not valid JSON object content."))
		return {"snapshot": snapshot, "load_issues": load_issues}
	var config: Dictionary = config_value
	snapshot["config"] = config
	var datasets_value: Variant = config.get("datasets", null)
	if not datasets_value is Dictionary:
		load_issues.append(_issue("CFG001", config_path, 0, "datasets", "Config datasets must be an object."))
		return {"snapshot": snapshot, "load_issues": load_issues}
	var datasets: Dictionary = datasets_value
	var design_config: Dictionary = _dataset_config_for_loading(datasets, "design_documents", config_path, load_issues)
	if not design_config.is_empty():
		_load_design_documents(snapshot, load_issues, normalized_root, design_config)
	var asset_config: Dictionary = _dataset_config_for_loading(datasets, "assets", config_path, load_issues)
	if not asset_config.is_empty():
		_load_assets(snapshot, load_issues, normalized_root, asset_config)
	for dataset_name: String in GAMEPLAY_DATASETS:
		var dataset_config: Dictionary = _dataset_config_for_loading(datasets, dataset_name, config_path, load_issues)
		if not dataset_config.is_empty():
			_load_gameplay_dataset(snapshot, load_issues, normalized_root, dataset_name, dataset_config)
	return {"snapshot": snapshot, "load_issues": load_issues}

static func _empty_snapshot() -> Dictionary:
	return {
		"config": {"schema_version": 0, "current_gate": "", "datasets": {}},
		"design_documents": {"manifest": {}, "actual_markdown_files": [], "records": []},
		"assets": {"header": PackedStringArray(), "rows": []},
		"gameplay": {
			"weapons": [], "throwables": [], "characters": [], "upgrades": [],
			"enemies": [], "waves": [], "unlocks": [],
		},
	}

static func _dataset_config_for_loading(
	datasets: Dictionary,
	dataset_name: String,
	config_path: String,
	load_issues: Array[Dictionary]
) -> Dictionary:
	var dataset_config_value: Variant = datasets.get(dataset_name, null)
	if not dataset_config_value is Dictionary:
		load_issues.append(_issue("CFG001", config_path, 0, dataset_name, "Dataset config must be an object."))
		return {}
	var dataset_config: Dictionary = dataset_config_value
	if not dataset_config.get("state", null) is String:
		load_issues.append(_issue("CFG001", config_path, 0, dataset_name, "Dataset state must be a string."))
		return {}
	if not dataset_config.get("path", null) is String:
		load_issues.append(_issue("CFG001", config_path, 0, dataset_name, "Dataset path must be a string."))
		return {}
	return dataset_config

static func _load_design_documents(
	snapshot: Dictionary,
	load_issues: Array[Dictionary],
	project_root: String,
	dataset_config: Dictionary
) -> void:
	var declared_path: String = dataset_config["path"]
	if not _is_safe_res_path(declared_path):
		if not declared_path.is_empty():
			load_issues.append(_issue("CFG001", declared_path, 0, "design_documents", "Dataset path must be a safe res:// path."))
		return
	var manifest_path: String = _resolve_dataset_path(project_root, declared_path)
	if manifest_path.is_empty():
		return
	if dataset_config["state"] == "not_implemented":
		if _path_is_nonempty(manifest_path):
			load_issues.append(_issue("CFG001", manifest_path, 0, "design_documents", "Dataset declared not_implemented must be absent or empty."))
		return
	var design_directory: String = manifest_path.get_base_dir()
	var actual_markdown_files: Array[String] = []
	var directory: DirAccess = DirAccess.open(design_directory)
	if directory != null:
		for file_name: String in directory.get_files():
			if file_name.get_extension().to_lower() == "md":
				actual_markdown_files.append(design_directory.path_join(file_name))
	actual_markdown_files.sort()
	snapshot["design_documents"]["actual_markdown_files"] = actual_markdown_files
	if not FileAccess.file_exists(manifest_path):
		load_issues.append(_issue("DOC001", manifest_path, 0, "manifest", "Design manifest does not exist."))
		return
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not manifest_value is Dictionary:
		load_issues.append(_issue("DOC001", manifest_path, 0, "manifest", "Design manifest is not valid JSON object content."))
		return
	var manifest: Dictionary = manifest_value
	snapshot["design_documents"]["manifest"] = manifest
	var records: Array[Dictionary] = []
	var documents_value: Variant = manifest.get("documents", [])
	if not documents_value is Array:
		load_issues.append(_issue("DOC001", manifest_path, 0, "manifest", "Design manifest documents must be an array."))
		snapshot["design_documents"]["records"] = records
		return
	for document_value: Variant in documents_value:
		if not document_value is Dictionary:
			load_issues.append(_issue("DOC001", manifest_path, 0, "manifest", "Every design manifest record must be an object."))
			continue
		var record: Dictionary = (document_value as Dictionary).duplicate(true)
		record["source_path"] = manifest_path
		record["source_line"] = 0
		var file_name: String = record.get("file", "")
		record["exists"] = false
		record["actual_bytes"] = 0
		record["actual_sha256"] = ""
		var document_path: String = ""
		if _is_safe_relative_path(file_name):
			document_path = design_directory.path_join(file_name)
			record["_document_path"] = document_path
			record["exists"] = FileAccess.file_exists(document_path)
			if record["exists"]:
				record["actual_bytes"] = FileAccess.get_file_as_bytes(document_path).size()
				record["actual_sha256"] = FileAccess.get_sha256(document_path)
			else:
				load_issues.append(_issue("DOC002", document_path, 0, file_name, "Registered Markdown file does not exist."))
		else:
			load_issues.append(_issue("DOC001", manifest_path, 0, "manifest", "Manifest file path is missing or unsafe."))
		records.append(record)
	snapshot["design_documents"]["records"] = records

static func _load_assets(
	snapshot: Dictionary,
	load_issues: Array[Dictionary],
	project_root: String,
	dataset_config: Dictionary
) -> void:
	var declared_path: String = dataset_config["path"]
	if not _is_safe_res_path(declared_path):
		if not declared_path.is_empty():
			load_issues.append(_issue("CFG001", declared_path, 0, "assets", "Dataset path must be a safe res:// path."))
		return
	var csv_path: String = _resolve_dataset_path(project_root, declared_path)
	if csv_path.is_empty():
		return
	if dataset_config["state"] == "not_implemented":
		if _path_is_nonempty(csv_path):
			load_issues.append(_issue("CFG001", csv_path, 0, "assets", "Dataset declared not_implemented must be absent or empty."))
		return
	if not FileAccess.file_exists(csv_path):
		load_issues.append(_issue("AST001", csv_path, 0, "asset_manifest", "Asset manifest does not exist."))
		return
	var csv_file: FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	if csv_file == null:
		load_issues.append(_issue("AST001", csv_path, 0, "asset_manifest", "Asset manifest is not readable."))
		return
	var header: PackedStringArray = csv_file.get_csv_line(",")
	snapshot["assets"]["header"] = header
	var rows: Array[Dictionary] = []
	var source_line: int = 1
	while not csv_file.eof_reached():
		var values: PackedStringArray = csv_file.get_csv_line(",")
		source_line += 1
		if values.size() == 1 and values[0].is_empty() and csv_file.eof_reached():
			break
		var row: Dictionary = {
			"source_path": csv_path,
			"source_line": source_line,
			"_column_count": values.size(),
		}
		for column_index: int in range(header.size()):
			row[header[column_index]] = values[column_index] if column_index < values.size() else ""
		for evidence_field: String in ASSET_EVIDENCE_FIELDS:
			var evidence_path: String = row.get(evidence_field, "")
			if not evidence_path.is_empty() and not _is_safe_relative_path(evidence_path):
				load_issues.append(_issue(
					"AST002",
					csv_path,
					source_line,
					row.get("asset_id", ""),
					"%s must be a safe project-relative path." % evidence_field
				))
			var resolved_path: String = _resolve_record_path(project_root, evidence_path)
			row["_%s_exists" % evidence_field] = not resolved_path.is_empty() and FileAccess.file_exists(resolved_path)
		rows.append(row)
	snapshot["assets"]["rows"] = rows

static func _load_gameplay_dataset(
	snapshot: Dictionary,
	load_issues: Array[Dictionary],
	project_root: String,
	dataset_name: String,
	dataset_config: Dictionary
) -> void:
	var declared_path: String = dataset_config["path"]
	if not _is_safe_res_path(declared_path):
		if not declared_path.is_empty():
			load_issues.append(_issue("CFG001", declared_path, 0, dataset_name, "Dataset path must be a safe res:// path."))
		return
	var dataset_path: String = _resolve_dataset_path(project_root, declared_path)
	if dataset_path.is_empty():
		return
	var state: String = dataset_config["state"]
	if state == "not_implemented" and _path_is_nonempty(dataset_path):
		load_issues.append(_issue("CFG001", dataset_path, 0, dataset_name, "Dataset declared not_implemented must be absent or empty."))
		return
	var records: Array[Dictionary] = []
	var directory: DirAccess = DirAccess.open(dataset_path)
	if directory == null:
		snapshot["gameplay"][dataset_name] = records
		return
	var resource_files: Array[String] = []
	for file_name: String in directory.get_files():
		if file_name.get_extension().to_lower() in ["tres", "res"]:
			resource_files.append(file_name)
	resource_files.sort()
	for file_name: String in resource_files:
		var resource_path: String = dataset_path.path_join(file_name)
		var resource: Resource = ResourceLoader.load(resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Resource
		if resource == null:
			load_issues.append(_issue("CFG001", resource_path, 0, dataset_name, "Gameplay Resource is not readable."))
			continue
		var record: Dictionary = _resource_to_dictionary(resource)
		record["source_path"] = resource_path
		record["source_line"] = 0
		records.append(record)
	snapshot["gameplay"][dataset_name] = records

static func _resource_to_dictionary(resource: Resource) -> Dictionary:
	var record: Dictionary = {}
	for property: Dictionary in resource.get_property_list():
		var property_name: String = property.get("name", "")
		var usage: int = property.get("usage", 0)
		if property_name.is_empty() or property_name == "script":
			continue
		if usage & PROPERTY_USAGE_STORAGE == 0:
			continue
		record[property_name] = _normalize_value(resource.get(property_name))
	return record

static func _normalize_value(value: Variant) -> Variant:
	if value is StringName:
		return String(value)
	if value is Array:
		var normalized_array: Array = []
		for item: Variant in value:
			normalized_array.append(_normalize_value(item))
		return normalized_array
	if value is Dictionary:
		var normalized_dictionary: Dictionary = {}
		for key: Variant in value:
			normalized_dictionary[String(key)] = _normalize_value(value[key])
		return normalized_dictionary
	if value is Resource:
		return _resource_to_dictionary(value)
	return value

static func _normalize_root(project_root: String) -> String:
	var normalized: String = project_root
	if not normalized.ends_with("/"):
		normalized += "/"
	return normalized

static func _resolve_dataset_path(project_root: String, declared_path: String) -> String:
	if declared_path.is_empty():
		return ""
	if project_root == "res://":
		return declared_path
	return project_root.path_join(declared_path.trim_prefix("res://"))

static func _resolve_record_path(project_root: String, record_path: String) -> String:
	if record_path.is_empty() or not _is_safe_relative_path(record_path):
		return ""
	if record_path.begins_with("res://"):
		return _resolve_dataset_path(project_root, record_path)
	return project_root.path_join(record_path)

static func _path_is_nonempty(path: String) -> bool:
	if FileAccess.file_exists(path):
		return true
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		return false
	return not directory.get_files().is_empty() or not directory.get_directories().is_empty()

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

static func _issue(rule: String, path: String, line: int, subject: String, message: String) -> Dictionary:
	return {
		"severity": "ERROR",
		"rule": rule,
		"path": path.trim_prefix("res://"),
		"line": line,
		"subject": subject,
		"message": message,
		"expected": null,
		"actual": null,
		"target_gate": "G0",
	}
