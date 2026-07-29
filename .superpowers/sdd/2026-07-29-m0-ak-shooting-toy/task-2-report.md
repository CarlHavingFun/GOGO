# Task 2 Report — Playable AK Graybox Scene

## Scope

Implemented the playable M0 AK lab at `res://scenes/run/m0_ak_lab.tscn`: a `CharacterBody2D` player, deterministic AK raycast controller, static resettable training dummies, arena collision, camera, and basic muzzle/tracer/hit feedback. HUD, procedural audio, full recoil presentation, AI, progression, shops, characters, and waves remain out of scope for Task 3 or later.

## RED evidence

Added `tests/integration/test_playable_scene.gd` to the native runner before production code. Running:

```text
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tests/test_runner.gd
```

reported the expected feature-missing failures:

```text
PlayerController is required for playable-scene integration tests.
The M0 AK lab scene is required for playable-scene integration tests.
TESTS FAILED: 2
```

The complete RED output is `/tmp/gogo-task2-red.log`.

## Implemented behavior

- `project.godot` now selects the lab as the main scene, configures a 1280×720 viewport/window, and defines `move_left`, `move_right`, `move_up`, `move_down`, `fire`, and `reload`.
- `PlayerController` reads only input actions, normalizes diagonal movement, moves at 300 px/s, and aims at the mouse world position.
- `WeaponController` owns the AK Resource, `WeaponRuntime`, `SpreadSampler`, and fixed seed `24680`; held fire and manual reload drive the existing reviewed runtime.
- Each successful shot samples spread exactly once. One global ray result supplies dummy damage, the shot signal, tracer endpoint, muzzle flash, and hit spark; the player RID is explicitly excluded.
- `TrainingDummy.take_hit(damage: int, hit_position: Vector2)` exposes damage, hit/knockdown visuals, signals/getters, and automatic reset.
- Weapon signals and getters expose shot, hit, ammo, reload transitions, aggregate state, recoil, seed, draw index, and current spread for Task 3 without node-tree spelunking.
- First real Godot import generated stable `.gd.uid` identity metadata for all tracked GDScripts; these are committed. `.godot/` and manifest import/translation caches are precisely ignored.

## Verification

- Each new gameplay script passed a separate Godot headless editor import smoke check.
- Native tests pass after implementation; final output is `/tmp/gogo-task2-final-test.log`.
- Main-scene `--quit-after 30` smoke exits cleanly; final output is `/tmp/gogo-task2-final-main-smoke.log`.
- `/tmp/gogo_task2_behavior_check.gd` instantiated the real scene and verified all six actions, 1280×720 settings, one-round ammo consumption, one RNG draw, 24 damage, shared hit endpoints, dummy knockdown/reset, and equal first-shot endpoints across fresh scenes with seed `24680`. Output is `/tmp/gogo-task2-behavior-check.log`.

## Scope and concerns

The reviewed `WeaponRuntime`, `SpreadSampler`, AK data, design docs, README, `CODEX_START.md`, plan, asset sources, and existing `.DS_Store` files were not modified. Headless checks do not validate pixel appearance or subjective mouse/weapon feel; those remain manual acceptance concerns for the later presentation pass.
