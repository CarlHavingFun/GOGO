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

The initial Task 2 commit did not modify the reviewed `WeaponRuntime`, `SpreadSampler`, AK data, design docs, README, `CODEX_START.md`, plan, asset sources, or existing `.DS_Store` files. Headless checks do not validate pixel appearance or subjective mouse/weapon feel; those remain manual acceptance concerns for the later presentation pass. Fix round 1 makes the narrowly tested `WeaponRuntime` cooldown change documented below.

## Fix round 1 — cadence, persistent integration, and applied damage

### Cadence and real-scene integration RED

The native runner was extended with an async branch so the integration test can add the real lab scene to `SceneTree`, advance physics at the project-default 60 Hz, and drive `fire`/`reload` through `Input.action_press()` and `Input.action_release()`.

Command:

```text
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tests/test_runner.gd
```

Output from the original controller:

```text
ERROR: Held fire at 60 Hz should produce about nine shots in the first second. Expected 9, got 8.
ERROR: Held fire should preserve the 8.5 shots/sec cadence over two seconds. Expected 17, got 15.
ERROR: Successful real-scene shots must consume matching ammo. Expected 13, got 15.
ERROR: Each successful real-scene shot must consume exactly one spread draw. Expected 17, got 15.
TESTS FAILED: 4
```

The complete RED output is `/tmp/gogo-task2-fix1-cadence-red.log`.

Root cause: `WeaponRuntime.tick()` clamped the cooldown to zero before the controller made its one-per-frame fire attempt, discarding the approximately 15.7 ms by which a 60 Hz frame crossed an 8.5 shots/sec deadline.

### Cadence GREEN

`WeaponRuntime` remains the single cadence authority. While fire is held and the weapon is able to fire, `tick()` preserves the sub-frame cooldown overflow and `try_fire()` adds the next interval to that remainder. While fire is released, empty, or reloading, cooldown clamps to zero so idle time cannot bank a compensating burst. `WeaponController` consumes all currently due successful shots but owns no parallel cadence timer.

The persistent integration test now verifies:

- 9 shots after 60 physics frames and 17 after 120 frames.
- Ammo and seeded RNG draw index both equal the successful shot count.
- A real ray damages the center dummy and `shot_fired`/`hit_confirmed` share the same endpoint.
- One idle second followed by a new press produces exactly one shot, not a catch-up burst.
- `reload` starts a partial-magazine reload and a cadence-eligible fire press cancels it and shoots.

GREEN output:

```text
TESTS PASSED
```

The runtime-authority GREEN output is `/tmp/gogo-task2-fix1-runtime-authority-green.log`.

### Knockdown damage semantics RED

After the cadence fix, the same runner exposed the original downed-target behavior:

```text
ERROR: Only the three shots that apply 24 damage may emit hit_confirmed before knockdown. Expected 3, got 17.
ERROR: take_hit must report zero actual damage while the dummy is knocked down. Expected 0, got <null>.
TESTS FAILED: 2
```

The complete RED output is `/tmp/gogo-task2-fix1-knockdown-red.log`.

### Knockdown damage semantics GREEN

`TrainingDummy.take_hit(damage: int, hit_position: Vector2) -> int` now returns the actual clamped damage, including `0` while knocked down. `WeaponController` emits `hit_confirmed` only when that return value is greater than zero, and reports the actual value rather than requested damage.

GREEN output:

```text
TESTS PASSED
```

The complete GREEN output is `/tmp/gogo-task2-fix1-knockdown-green.log`.

### Final verification

- Headless editor import: exit 0, no parser errors or warnings (`/tmp/gogo-task2-fix1-final-import.log`).
- Full native runner: `TESTS PASSED` (`/tmp/gogo-task2-fix1-final-test.log`).
- Main scene 30-frame smoke: exit 0 with no runtime errors or warnings (`/tmp/gogo-task2-fix1-final-main-smoke.log`).
- Scene and input are cleaned up by releasing actions, queue-freeing the instance, and awaiting a process frame.
