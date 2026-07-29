# Task 1 Report — Core Logic RED → GREEN

## Scope

Implemented only the M0 deterministic AK core: project metadata, native `SceneTree` tests, `WeaponDef`/AK data, `WeaponRuntime`, and `SpreadSampler`. No scene, player, HUD, or feedback code was added.

## RED evidence

Ran `Godot --headless --path . -s res://tests/test_runner.gd` before production scripts existed. The runner reported `TESTS FAILED: 4` for the missing `WeaponDef`, `WeaponRuntime`, AK Resource, and `SpreadSampler` resources. This is the expected feature-missing failure and was captured in `/tmp/gogo-task1-red.log`.

## GREEN verification

Ran the same headless command after implementation. Godot 4.7.1 reported `TESTS PASSED` with no parse errors or warnings; the final command output is captured in `/tmp/gogo-task1-final-test.log`.

## Covered behavior

- AK design values match the specified damage, fire rate, magazine, reload, spread, recoil, and range.
- Firing consumes one round; manual and automatic reloads refill the magazine.
- A non-empty reload is cancelled by a permitted fire request; an empty reload is not.
- Recoil is clamped to `0..100` and recovers through `tick`.
- Spread uses a per-instance seeded `RandomNumberGenerator`, preserves `draw_index`, and is deterministic for equal seed and input sequences.

## Scope checks

Only the task files are staged for the task commit. Existing untracked `.DS_Store` files and all protected documents remain untouched.

## Fix round 1 — immediate automatic reload

### RED

Command:

```text
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tests/test_runner.gd
```

Output:

```text
ERROR: The final successful shot should immediately start automatic reload.
ERROR: Automatic reload must refill the magazine. Expected 30, got 0.
TESTS FAILED: 2
```

The regression test now observes `is_reloading` immediately after the 30th successful shot, without issuing an additional fire request. The complete RED output is `/tmp/gogo-task1-fix-round1-red.log`.

### GREEN

Command:

```text
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tests/test_runner.gd
```

Output:

```text
TESTS PASSED
```

`WeaponRuntime.try_fire()` now starts reload immediately when its successful shot empties the magazine. The complete GREEN output is `/tmp/gogo-task1-fix-round1-green.log`.
