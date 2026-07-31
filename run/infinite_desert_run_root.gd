extends Node2D
class_name InfiniteDesertRunRoot

@onready var player: PlayerController = $Player
@onready var weapon_controller: WeaponController = $Player/WeaponController
@onready var chunk_manager: InfiniteChunkManager = $ChunkManager
@onready var spawn_director: InfiniteSpawnDirector = $SpawnDirector
@onready var presentation: M0Presentation = $Presentation
@onready var hud: M0HUD = $HUD

func _ready() -> void:
	weapon_controller.shot_resolved.connect(_on_shot_resolved)
	weapon_controller.weapon_state_changed.connect(hud.update_weapon_state)
	weapon_controller.dry_fired.connect(_on_dry_fired)
	weapon_controller.reload_started.connect(_on_reload_started)
	weapon_controller.feedback_requested.connect(hud.show_feedback)
	spawn_director.enemy_recycled.connect(_on_enemy_recycled)
	hud.update_weapon_state(weapon_controller.get_snapshot())
	hud.show_feedback("INFINITE DESERT — SEED %d" % chunk_manager.world_seed)

func _on_shot_resolved(origin: Vector2, end_point: Vector2, hit: bool, result: Dictionary) -> void:
	presentation.show_shot(origin, end_point, hit, result)
	if bool(result.get("hit", false)) and not bool(result.get("killed", false)):
		hud.show_feedback("HIT %d  |  HP %d" % [
			int(result.get("damage", 0.0)),
			int(result.get("remaining_health", 0.0)),
		])

func _on_dry_fired() -> void:
	presentation.show_dry_fire(player.global_position)
	hud.show_feedback("EMPTY — AUTO RELOAD")

func _on_reload_started() -> void:
	presentation.show_reload(player.global_position)

func _on_enemy_recycled(_enemy: Node, reason: StringName) -> void:
	if reason == &"defeated":
		hud.show_feedback("TARGET DOWN — RECYCLED")
