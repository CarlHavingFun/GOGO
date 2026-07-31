# Infinite Desert World Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a runnable Godot 4.7.1 infinite-desert prototype with deterministic Chunk modules, sparse POIs, ring-based enemy spawning, and bounded recycling while preserving the M0 shooting toy.

**Architecture:** Keep deterministic decisions in pure `RefCounted` classes that can be tested headlessly. Use one `InfiniteChunkManager` to stream `InfiniteDesertChunk` nodes around the player, one separate `InfiniteSpawnDirector` to own spawn filtering and pooling, and one new run scene that reuses the existing player, weapon, presentation, and HUD layers.

**Tech Stack:** Godot 4.7.1 stable, typed GDScript, built-in 2D physics, existing lightweight headless test runner, GitHub Actions.

## Global Constraints

- Chunk size is `1024×1024 px`.
- Active radius is `2`, producing a `5×5` desired set.
- Build at most one Chunk per frame.
- Default world Seed is `424242`.
- Terrain uses 2D physics layer 3 (`mask value 4`).
- Infinite-scene weapon rays use mask `6` so enemies and Terrain block shots.
- First implementation uses six ordinary greybox modules and one sparse supply-outpost POI.
- Enemy spawning uses an `850～1250 px` ring and a `2100 px` recycle distance.
- Maximum active prototype enemies is `24`; prewarm `8` pooled enemies.
- No external runtime plugin, WFC, TileSet, save system, full wave loop, player health, or formal pixel asset is added.
- Original `run/m0_shooting_toy.tscn` and its tests remain valid.

---

### Task 1: Add failing deterministic-world tests and CI coverage

**Files:**
- Create: `tests/unit/test_desert_chunk_layout.gd`
- Create: `tests/unit/test_chunk_stream_planner.gd`
- Create: `tests/unit/test_spawn_ring_sampler.gd`
- Create: `tests/integration/test_infinite_desert_scene.gd`
- Modify: `tests/test_runner.gd`
- Modify: `.github/workflows/godot-m0.yml`

**Interfaces:**
- Consumes: planned scripts and scene paths.
- Produces: red tests proving the new feature is absent and a branch-triggered Godot CI run.

- [ ] Add layout tests for repeatability, negative coordinates, module variety, and sparse POIs.
- [ ] Add stream-planner tests for 25 desired coordinates, negative world mapping, forward priority, and unloading.
- [ ] Add ring-sampler tests for repeatability, distance bounds, and sample variation.
- [ ] Add a scene test requiring Player, Camera2D, ChunkManager, SpawnDirector, WeaponController, HUD, and disabled arena clamping.
- [ ] Add all suites to the existing test runner.
- [ ] Make GitHub Actions run on pushes to `docs/arena-spawn-design`.
- [ ] Confirm CI fails because the planned production scripts and scene do not exist.

### Task 2: Implement deterministic layout and stream planning

**Files:**
- Create: `systems/world/desert_chunk_layout.gd`
- Create: `systems/world/chunk_stream_planner.gd`

**Interfaces:**
- Produces: `DesertChunkLayout.configure(seed_value)`, `describe(coord)`, `chunk_seed(coord)`; `ChunkStreamPlanner.world_to_chunk(position, size)`, `desired_coords(center, radius)`, `build_load_queue(active, center, radius, heading)`, and `coords_to_unload(active, center, radius)`.

- [ ] Implement a bounded integer mixer independent of the global random stream.
- [ ] Return `module_id`, `rotation_quarters`, `poi_id`, `chunk_seed`, and `decoration_seed` from each layout description.
- [ ] Override ordinary module selection with `supply_outpost` only on a sparse deterministic roll.
- [ ] Implement negative-coordinate-safe world-to-Chunk conversion.
- [ ] Sort missing coordinates by Manhattan distance, movement-direction score, then stable coordinates.
- [ ] Run the unit suites and confirm they pass.

### Task 3: Implement greybox Chunk streaming

**Files:**
- Create: `arenas/infinite_desert/infinite_desert_chunk.gd`
- Create: `systems/world/infinite_chunk_manager.gd`

**Interfaces:**
- Consumes: `DesertChunkLayout` and `ChunkStreamPlanner`.
- Produces: configurable greybox chunks with Terrain collision and `InfiniteChunkManager` signals `chunk_loaded(coord, module_id)` and `chunk_unloaded(coord)`.

- [ ] Draw deterministic sand patches from `decoration_seed`.
- [ ] Build obstacle rectangles and matching `StaticBody2D` collision shapes for all six ordinary modules and the supply outpost.
- [ ] Apply quarter-turn rotation around the Chunk center without changing Chunk boundaries.
- [ ] Maintain an active-coordinate dictionary and a duplicate-free load queue.
- [ ] Build the center Chunk immediately and at most one queued Chunk per frame thereafter.
- [ ] Unload coordinates outside the desired radius and cancel stale queued items.

### Task 4: Add infinite run scene without breaking M0

**Files:**
- Modify: `entities/player/player_controller.gd`
- Create: `run/infinite_desert_run_root.gd`
- Create: `run/infinite_desert_prototype.tscn`
- Modify: `project.godot`

**Interfaces:**
- Consumes: existing `PlayerController`, `WeaponController`, AK resource, presentation, and HUD.
- Produces: a main scene with camera-follow movement, Terrain collision, streamed chunks, and weapon feedback.

- [ ] Add exported `clamp_to_arena` to `PlayerController`, defaulting to `true` for M0 compatibility.
- [ ] Disable clamping only in the infinite scene.
- [ ] Add a Camera2D under Player.
- [ ] Set Player collision mask to Terrain and weapon ray mask to enemy plus Terrain.
- [ ] Reuse M0 HUD and presentation signal contracts.
- [ ] Set the project main scene to the infinite prototype while retaining the M0 scene file.

### Task 5: Implement ring spawning and pooled prototype enemies

**Files:**
- Create: `systems/spawn/spawn_ring_sampler.gd`
- Create: `entities/enemies/prototype_chaser.gd`
- Create: `systems/spawn/infinite_spawn_director.gd`

**Interfaces:**
- Produces: deterministic `SpawnRingSampler.sample(center, sample_index, min_distance, max_distance)`; pooled enemies exposing `activate(position, target)`, `deactivate()`, `apply_damage(amount, hit_position)`; a director exposing `active_enemy_count()` and `pooled_enemy_count()`.

- [ ] Sample uniformly by area inside the ring using an isolated per-index Seed.
- [ ] Create enemies with Target collision, Terrain mask, chase movement, health, drawing, and compatible damage dictionaries.
- [ ] Prewarm eight inactive enemies.
- [ ] Reject candidates in unloaded chunks or Terrain.
- [ ] Delay instead of spawning when no legal point is found.
- [ ] Return killed or over-distance enemies to the pool.
- [ ] Enforce the maximum active count.

### Task 6: Verify, update PR documentation, and report limits

**Files:**
- Modify: PR #6 description or discussion comment.

**Interfaces:**
- Consumes: completed branch and GitHub Actions evidence.
- Produces: exact verification status and documented remaining manual checks.

- [ ] Run GitHub Actions parser/import and the complete headless suite.
- [ ] Inspect failed job logs and fix every parse, scene, or assertion failure.
- [ ] Compare the branch before and after implementation and list changed files.
- [ ] Update PR #6 to state that it now includes runtime prototype code rather than documentation only.
- [ ] Record CI run status and explicitly leave the ten-minute interactive movement/performance check as a Windows manual gate if it cannot be performed remotely.
