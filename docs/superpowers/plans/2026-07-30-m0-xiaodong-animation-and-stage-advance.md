# M0 Xiaodong Animation and Stage Advance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the approved Xiaodong character reference and animation pipeline, validate the current Godot combat milestone with Godot MCP plus CLI evidence, and advance at most one canonical milestone when every gate passes.

**Architecture:** Keep gameplay and art as parallel tracks. Codex manages files, manifests, Godot resources, tests and evidence; human approval controls image generation. Godot MCP is the default interactive editor path, while headless Godot commands remain mandatory for deterministic verification and CI parity.

**Tech Stack:** Godot 4.7.1 stable, typed GDScript, Godot MCP, Godot CLI/headless tests, Markdown status records, independent PNG frames, GitHub pull requests.

## Global Constraints

- Canonical milestones come from `docs/design/11_开发里程碑.md`; legacy “M0 AK shooting toy” maps to canonical M1.
- One `/goal` may advance at most one milestone boundary.
- Formal character images remain human-approved; Codex does not invent or regenerate sprites.
- All character frames use 128×128 logical canvas, `feet_center`, top-down three-quarter view, lower-right facing and upper-left light.
- Characters, weapons, throwables, VFX and UI remain separate assets and nodes.
- Five standard poses must pass `CharacterLineupReview` before any Xiaodong animation frames are produced.
- Godot MCP is required for scene/resource/visual verification; CLI parse and tests are also mandatory.
- No third-party MCP implementation becomes a runtime game dependency.

---

### Task 1: Register the approved Xiaodong reference

**Files:**
- Create: `assets/characters/xiaodong/reference/xiaodong_approved_pixel_anchor_v01.jpeg`
- Create: `assets/characters/xiaodong/reference/README.md`
- Modify: `assets/asset_manifest.csv`

**Interfaces:**
- Consumes: the user-approved pixel anchor image.
- Produces: a repository-stable reference path and manifest entry with `REFERENCE_APPROVED` status.

- [ ] Confirm the JPEG opens and is 1024×1536.
- [ ] Confirm the README states that it is reference-only and cannot be imported as a runtime sprite.
- [ ] Add the reference, standard pose and animation records to `assets/asset_manifest.csv`.
- [ ] Verify every manifest path is unique and every animation uses `feet_center`.
- [ ] Commit the reference and manifest changes.

### Task 2: Produce and approve the standard pose

**Files:**
- Create after human approval: `assets/characters/xiaodong/standard/character_xiaodong_standard_pose_v01.png`
- Modify: `assets/asset_manifest.csv`
- Create when the gallery exists: `assets/characters/xiaodong/standard/approval.md`

**Interfaces:**
- Consumes: approved reference JPEG plus Style Bible.
- Produces: one transparent 128×128 mother frame used by every later animation.

- [ ] Generate exactly one empty-handed standard pose outside Codex.
- [ ] Wait for explicit human `通过` or `拒绝`; do not create another asset while pending.
- [ ] On approval, verify dimensions, alpha, hard edges and absence of logos/weapons.
- [ ] Mark the standard pose `approved`, not `in_game`.
- [ ] Stop animation production until all five character standard poses pass lineup review.

### Task 3: Validate the five-character lineup gate

**Files:**
- Create: `scenes/dev/character_lineup_review.tscn`
- Create: `src/dev/character_lineup_review.gd`
- Test: `tests/integration/test_character_lineup_review.gd`

**Interfaces:**
- Consumes: five approved standard-pose PNGs.
- Produces: a fixed-scale comparison scene with no gameplay dependency.

- [ ] Write a failing test that loads all five expected standard-pose paths and reports missing resources.
- [ ] Run the test and confirm failure until all five assets exist.
- [ ] Implement the smallest lineup scene with identical scale, anchor guides and neutral background.
- [ ] Use Godot MCP to open the scene, inspect resource bindings and capture the approval record.
- [ ] Mark `CharacterLineupReview` passed only after explicit human approval.

### Task 4: Build the Xiaodong M0 animation resources

**Files:**
- Create: `assets/characters/xiaodong/idle/*.png`
- Create: `assets/characters/xiaodong/walk/*.png`
- Create: `assets/characters/xiaodong/crouch_idle/*.png`
- Create: `assets/characters/xiaodong/crouch_walk/*.png`
- Create: `assets/characters/xiaodong/hit/*.png`
- Create: `assets/characters/xiaodong/death/*.png`
- Create: `assets/characters/xiaodong/xiaodong_sprite_frames.tres`
- Test: `tests/integration/test_xiaodong_sprite_frames.gd`

**Interfaces:**
- Produces animations named `idle`, `walk`, `crouch_idle`, `crouch_walk`, `hit`, and `death` with exact frame counts 4/8/4/8/2/6 and FPS 6/10/6/8/12/10.

- [ ] Produce one frame per human approval cycle; never generate a sprite sheet.
- [ ] Write a failing integration test that checks animation names, frame counts, FPS and loop flags.
- [ ] Create the SpriteFrames resource only from approved PNGs.
- [ ] Run the test and fix missing/duplicate/wrong-order frames.
- [ ] Use Godot MCP to inspect the resource, play every animation and check `flip_h`.
- [ ] Record visual findings; mark `in_game` only after both MCP and CLI checks pass.

### Task 5: Revalidate canonical M1

**Files:**
- Modify: `docs/status/CURRENT_STAGE.md`
- Modify only when failures require fixes: existing M1 code/tests.

**Interfaces:**
- Consumes: current M1 scene, test suite and manual acceptance criteria.
- Produces: evidence-backed `ACTIVE_VALIDATION`, `BLOCKED`, or `PASSED` result.

- [ ] Connect Godot MCP and record server/connection status.
- [ ] Use MCP to open and run the main scene; inspect errors, nodes and resource references.
- [ ] Run `godot --headless --path . --editor --quit` and require exit code 0.
- [ ] Run `godot --headless --path . res://tests/test_runner.tscn` and require exit code 0.
- [ ] Complete the Windows 10-minute, 60 FPS and shooting-feel checklist; keep these pending when no human evidence exists.
- [ ] Update `CURRENT_STAGE.md` with exact commands, commit, Godot version, results and remaining gates.

### Task 6: Advance once and start M2 Task 1

**Files:**
- Modify: `docs/status/CURRENT_STAGE.md`
- Create: `systems/run/run_state.gd`
- Create: `tests/unit/test_run_state.gd`

**Interfaces:**
- Produces: deterministic transitions `PREPARE → ACTIVE → CLEANUP → SETTLEMENT` and rejects illegal transitions.

- [ ] Confirm every M1 gate is `PASSED`; otherwise stop without changing the stage.
- [ ] Change current stage to M2 `ACTIVE` and record the M1 evidence.
- [ ] Write failing tests for the four-state sequence and at least one illegal transition.
- [ ] Run the tests and confirm failure because `RunState` does not exist.
- [ ] Implement the minimal typed state machine with explicit transition validation.
- [ ] Run unit tests and the full headless suite.
- [ ] Use Godot MCP to load a minimal test scene and confirm no runtime errors.
- [ ] Stop. Do not implement shop, upgrades, enemies or formal UI in the same `/goal`.
