class_name InfiniteDesertRunRoot
extends Node2D

@onready var chunk_manager: InfiniteChunkManager = $ChunkManager
@onready var spawn_director: InfiniteSpawnDirector = $SpawnDirector
@onready var hud: CombatHUD = $Interface/CombatHUD

func _ready() -> void:
	spawn_director.enemy_recycled.connect(_on_enemy_recycled)
	hud.present_feedback("INFINITE DESERT - SEED %d" % chunk_manager.world_seed)

func _on_enemy_recycled(_enemy: Node, reason: StringName) -> void:
	if reason == &"defeated":
		hud.present_feedback("TARGET DOWN - RECYCLED")
