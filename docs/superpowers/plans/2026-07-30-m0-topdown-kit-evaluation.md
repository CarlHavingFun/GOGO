# M0 Top-Down Kit Evaluation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a runnable and headlessly tested Godot 4.x M0 shooting toy on `foundation/topdown-kit-evaluation`.

**Architecture:** Keep weapon data in a Resource, deterministic weapon state in pure RefCounted classes, and input/physics/presentation in small scene nodes. The main scene is a single greybox arena and all visual feedback is generated from primitives, so there are no asset-license dependencies.

**Tech Stack:** Godot 4.7.1 stable, typed GDScript, Godot Resource files, built-in physics, GitHub Actions.

## Global Constraints

- Engine: Godot 4.x stable; CI pins 4.7.1 stable.
- Windows is the first target; the implementation remains compatible with later Web/mobile ports.
- WASD movement, mouse aim, held left-button fire and R reload.
- One primary weapon, infinite reserve ammunition, retained magazine/reload rhythm.
- Hitscan judgement with a visible tracer matching the actual ray.
- Dedicated injectable random stream for spread.
- No third-party game plugin, enemy AI, upgrades, shop, character system or formal art.
- All GDScript uses static typing where Godot APIs permit it.

---

### Task 1: Initialize the Godot project and failing test harness

**Files:**
- Create: `project.godot`
- Create: `tests/test_runner.gd`
- Create: `tests/test_runner.tscn`
- Create: `tests/unit/test_weapon_runtime.gd`
- Create: `tests/unit/test_deterministic_spread.gd`
- Create: `tests/integration/test_m0_scene.gd`

**Interfaces:**
- Consumes: Godot built-in `SceneTree`, `ResourceLoader` and assertions implemented by the test runner.
- Produces: test scripts exposing `run() -> Array[String]`; an exit code of 0 when no failure strings are returned.

- [x] Write tests that preload the planned production scripts and describe magazine, cooldown, reload, deterministic spread and scene-smoke behavior.
- [ ] Run the headless test command and confirm it fails because production scripts and the M0 scene do not exist.
- [x] Commit the red tests and project input configuration.

### Task 2: Implement weapon data, runtime and deterministic spread

**Files:**
- Create: `systems/combat/weapon_definition.gd`
- Create: `systems/combat/weapon_runtime.gd`
- Create: `systems/combat/deterministic_spread.gd`
- Create: `data/weapons/ak_m0.tres`

**Interfaces:**
- Produces: `WeaponDefinition.validate() -> PackedStringArray`; `WeaponRuntime.configure(definition)`, `tick(delta)`, `can_fire()`, `fire()`, `start_reload()`, `cancel_reload_for_shot()`; `DeterministicSpread.configure(seed)` and `sample_offset_deg(definition, recoil, moving)`.

- [ ] Implement the smallest typed classes that satisfy the unit tests.
- [ ] Run the headless unit suite and confirm all weapon-runtime and spread tests pass.
- [ ] Commit the pure combat core and AK resource.

### Task 3: Implement the playable greybox scene

**Files:**
- Create: `entities/player/player_controller.gd`
- Create: `entities/player/weapon_controller.gd`
- Create: `entities/enemies/target_dummy.gd`
- Create: `ui/hud/m0_hud.gd`
- Create: `vfx/m0_presentation.gd`
- Create: `run/m0_run_root.gd`
- Create: `run/m0_shooting_toy.tscn`

**Interfaces:**
- `WeaponController` emits `shot_resolved(origin, end, hit)`, `weapon_state_changed(snapshot)` and `dry_fired()`.
- `TargetDummy.apply_damage(amount, hit_position) -> Dictionary` returns hit, killed and remaining-health fields.
- `M0Presentation` consumes shot and hit results and draws transient feedback.
- `M0HUD` consumes the weapon snapshot and displays FPS, seed, ammo, reload, recoil and spread.

- [ ] Build the player, weapon, dummy and arena with primitive draw calls and collision shapes.
- [ ] Use the exact sampled ray for damage, tracer and crosshair spread.
- [ ] Run the scene smoke test and full headless test suite.
- [ ] Open the project parser headlessly and fail on any script/scene parse error.
- [ ] Commit the playable M0 scene.

### Task 4: Add CI and operator documentation

**Files:**
- Create: `.github/workflows/godot-m0.yml`
- Create: `docs/m0/README.md`

**Interfaces:**
- GitHub Actions downloads Godot 4.7.1 stable, runs an editor parse/import pass, then executes `res://tests/test_runner.tscn` headlessly.

- [ ] Document controls, run command, test command, manual acceptance checklist and known limitations.
- [x] Add pull-request, evaluation-branch push and workflow-dispatch CI.
- [ ] Run local structural checks for every referenced `res://` path and every required input action.
- [ ] Commit CI and documentation.

### Task 5: Publish and verify the evaluation branch

**Files:**
- Modify only files listed in Tasks 1–4.

- [ ] Compare the branch against `main` and confirm no existing design document changed.
- [x] Push `foundation/topdown-kit-evaluation`.
- [x] Open a draft PR against `main` to trigger CI without merging.
- [ ] Inspect the workflow result and logs; fix any parse, scene or test failure and rerun.
- [ ] Report branch, commit, PR, validation evidence and any unverified manual-play criteria.
