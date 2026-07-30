# M0 Top-Down Kit Evaluation Design

## Goal

Initialize a Godot 4.x M0 shooting toy on `foundation/topdown-kit-evaluation` that validates player movement, mouse aiming, AK hitscan fire, recoil/spread, magazine/reload rhythm, a stationary target dummy, readable hit/kill feedback, and deterministic seeded spread.

## Scope

Included:

- One fixed 1280×720 greybox arena.
- WASD movement at 300 px/s and mouse-world aiming.
- One AK with data stored in a `WeaponDefinition` resource.
- Hitscan ray, visible tracer, muzzle flash, crosshair expansion, hit marker, dummy health and respawn.
- 30-round magazine, manual reload, empty-mag auto reload, reload cancellation when ammunition remains.
- Debug overlay for FPS, seed, ammunition, reload state, recoil and current spread.
- Headless unit tests for weapon state and deterministic spread, plus scene smoke loading.
- A GitHub Actions workflow using Godot 4.7.1 stable to parse the project and run the test scene.

Excluded:

- Enemy AI, waves, upgrades, shop, economy, character talents, throwables, formal art, audio assets, pooling and save data.
- Direct import of third-party starter-kit code or assets. This branch evaluates the reusable architecture rather than copying uncertain content.

## Architecture

### Static data

`data/weapons/ak_m0.tres` instantiates `WeaponDefinition`. The AK uses the design baseline: 24 damage, 8.5 shots/second, 30 rounds, 2.2-second reload, 1.4-degree base spread, 1.3-degree movement spread, 9 recoil per shot, 38 recoil recovery per second, and 1400 px range.

### Pure runtime logic

`WeaponRuntime` is a `RefCounted` state object responsible for cooldown, ammunition, recoil, reload progress and cancellation rules. It has no scene-tree or input dependency.

`DeterministicSpread` owns a dedicated `RandomNumberGenerator`. Two instances with the same seed, weapon definition and state sequence must emit the same angular offsets.

### Scene layer

`M0RunRoot` owns one arena lifecycle. `PlayerController` handles movement and aiming. `WeaponController` translates input into runtime operations, performs the hitscan query and emits explicit signals. `TargetDummy` owns health and respawn. `M0Presentation` creates short-lived tracers, muzzle flash, hit markers and status text. A crosshair node reads current spread and never invents a direction different from the actual shot calculation.

### Collision

- Layer 1: player body.
- Layer 2: target dummy hitbox.
- Hitscan queries layer 2 only and excludes the player.
- Arena boundaries clamp the player position rather than introducing additional physics bodies in M0.

## Input and state flow

1. Player movement normalizes the WASD vector and calls `move_and_slide()`.
2. The player and weapon pivot point toward the mouse world position.
3. Holding fire asks `WeaponRuntime` whether a shot is legal.
4. `DeterministicSpread` samples the offset from the dedicated seed stream using current recoil and movement state.
5. `WeaponController` casts the ray, applies 24 damage when the collider exposes `apply_damage`, then consumes the round and increases recoil.
6. Presentation uses the exact ray endpoint for the tracer and hit marker.
7. Every physics tick advances cooldown, reload and recoil recovery.
8. Reload completion refills the magazine. Shooting cancels a non-empty reload without granting ammunition; empty reloads cannot be cancelled by shooting.

## Error handling

- Missing weapon data causes a clear error and disables firing instead of dereferencing null.
- Zero or negative fire rate, magazine size, reload time or range are rejected by `WeaponDefinition.validate()` and covered by tests.
- A ray miss still emits a tracer to maximum range.
- A killed dummy ignores further damage while hidden and automatically resets after 1.0 second.

## Testing

Headless tests cover:

- A full magazine fires exactly 30 shots and rejects the 31st.
- Cooldown prevents firing early and permits firing after `1 / shots_per_sec`.
- Reload completion refills the magazine.
- A reload with rounds remaining can be cancelled by fire without refilling.
- Empty reload cannot be cancelled by fire.
- Equal seeds produce equal 64-shot spread sequences; different seeds differ.
- Recoil and movement increase the calculated spread envelope.
- The main scene loads and exposes the expected player, weapon controller, dummy and HUD nodes.

## Success criteria

- Godot parses the project without script or scene errors.
- All headless tests pass in CI.
- In manual play, WASD movement, mouse aim, held AK fire, recoil recovery, reload, hit feedback and dummy kill/respawn are directly observable.
- The debug panel displays enough state to diagnose a shot without opening the editor.
- The branch remains isolated from `main` and is suitable for evaluation or deletion.
