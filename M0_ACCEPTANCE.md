# M0 Acceptance

Validated with Godot `4.7.1.stable.official.a13da4feb`.

## Start and test

From the repository root:

```bash
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --editor --path .
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy -s res://tests/test_runner.gd
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --quit-after 600
```

Directly start the playable scene with:

```bash
/tmp/gogo-godot-4.7.1/Godot.app/Contents/MacOS/Godot --path . scenes/run/m0_ak_lab.tscn
```

Controls: `WASD` moves, left mouse fires, and `R` reloads.

## Automated acceptance coverage

`tests/integration/test_m0_acceptance.gd` runs against real `SceneTree` input and the assembled lab scene. It verifies:

- Holding fire consumes all 30 rounds, immediately shows `0 / ∞` and `AUTO RELOAD`, then refills after 2.2 seconds with `RELOAD COMPLETE`.
- `R` begins `MANUAL RELOAD`; firing with a non-empty magazine cancels it, commits a shot, and shows `RELOAD CANCELED`.
- Real ray hits report the applied damage in HUD feedback and the final 24-damage hit reports target knockdown.
- Two fresh scenes with the same combat seed, aim, and input reproduce the first six endpoints and last-shot bias/spread snapshots, with six RNG draws each.

## Manual checklist

- [ ] Movement: test cardinal and diagonal WASD movement at arena boundaries.
- [ ] Aim: sweep the cursor around the player and confirm the weapon/crosshair follows it.
- [ ] Short burst: make a brief burst and observe ammo, recoil, and spread change.
- [ ] Long sweep: hold fire while sweeping aim and inspect cadence and endpoint feedback.
- [ ] Empty magazine: expend all 30 rounds and confirm the visible empty state.
- [ ] Automatic reload: confirm empty-magazine reload begins without pressing `R` and completes after its visible progress.
- [ ] Manual reload: press `R` with rounds remaining and verify the manual label/progress.
- [ ] Reload cancel: fire during a non-empty manual reload and verify cancellation plus a shot.
- [ ] Hit: strike a standing target and confirm actual damage feedback.
- [ ] Knockdown: land enough hits to knock a target down and confirm the target-down feedback.
- [ ] Muzzle fire: inspect muzzle flash timing during single shots and sustained fire.
- [ ] Tracers: inspect tracer origin, endpoint, and cleanup for hits and misses.
- [ ] Audio: listen for shot, hit, empty, reload-start, reload-complete, and knockdown cues.
- [ ] HUD: check ammo, status, reload progress, feedback, crosshair, and debug readout remain legible.
- [ ] FPS: inspect the on-screen FPS readout under sustained fire.
- [ ] Seed/RNG: restart twice and compare the seed and RNG draw progression under matching input.
- [ ] Magazine: verify all ammo transitions use the visible `current / ∞` format.
- [ ] Recoil: confirm recoil builds while held and recovers after release or during reload.
- [ ] Spread: compare stationary, moving, short-burst, and sustained-fire spread.
- [ ] Stability: leave the scene running and interact intermittently for 10 minutes without errors or stale feedback.
- [ ] 60 FPS observation: at a stable 60 FPS, inspect cadence, reload boundary, recoil recovery, and tracer continuity.

## Scope and remaining human checks

M0 does not include new weapons, AI, progression, networking, save/load, menus, accessibility tuning, localization, or production asset polish. Human confirmation is still required for subjective feel: movement and recoil weight, readability at target display sizes, visual/audio comfort, tracer/muzzle-fire taste, and sustained 60-FPS perception on the intended hardware.
