# M0 Xiaodong Production Assets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce and integrate the approved M0 Xiaodong asset pack: 40 eight-direction character frames, one standalone AK, seven shooting feedback sprites, three metadata files, and a Godot presentation layer that replaces the current graybox player without changing combat rules.

**Architecture:** Keep character, weapon, effects, metadata, and runtime integration separate. Character direction comes from `aim_dir`; idle/move comes from velocity. A single right-facing AK is aligned to each character frame through `hand_socket_stand` and the existing weapon `grip_point`, while muzzle effects and hitscan feedback originate from the weapon `muzzle_point`.

**Tech Stack:** Godot 4.7.1, GDScript, PNG with hard alpha edges, JSON metadata, Python 3 validation scripts using Pillow, Git/GitHub.

## Global Constraints

- Source of truth: `docs/design/16_M0小洞大人素材规范.md`.
- Style authority: `docs/design/14_像素美术Style_Bible.md`.
- Production pipeline: `docs/design/13_素材生产管线与提示词.md`.
- Character canvas: exactly `128×128` logical pixels, transparent background.
- Weapon canvas: exactly `160×96` logical pixels, transparent background.
- Character files are complete-body frames with empty hands; AK is never baked into character PNGs.
- Directions are exactly `n`, `ne`, `e`, `se`, `s`, `sw`, `w`, `nw`.
- Idle has exactly one frame per direction; move has exactly four frames per direction.
- `idle_se_f00` is the approval gate and visual master for all subsequent frames.
- Character identity anchors: black longer hair reaching near the jaw/covering ears, partly exposed forehead, no thick straight fringe, narrow youthful face, slim compact build, aggressive forward-ready energy.
- No real team jersey, logo, sponsor, event badge, watermark, readable text, cast shadow, floor, weapon, or grenade in character PNGs.
- Final PNGs must have hard integer-pixel edges and no semi-transparent fringe pixels except fully transparent background.
- Character frame anchor drift must not exceed two logical pixels inside one animation.
- AK attachment coordinates must continue to reference `assets/weapons/weapon_attachment_spec.json` key `weapons.ak`.
- Do not change weapon damage, fire rate, recoil, spread, reload, collision, or hitscan behavior while integrating presentation assets.
- Commit after every independently reviewable task.

---

## Planned File Structure

```text
assets/
├── characters/xiaodong/m0/
│   ├── idle/
│   │   ├── character_xiaodong_idle_n_f00.png
│   │   ├── character_xiaodong_idle_ne_f00.png
│   │   └── ... eight directions
│   ├── move/
│   │   ├── character_xiaodong_move_n_f00.png
│   │   ├── character_xiaodong_move_n_f01.png
│   │   └── ... thirty-two frames
│   └── data/
│       ├── xiaodong_m0_manifest.json
│       └── xiaodong_m0_anchor_map.json
├── weapons/ak/m0/
│   ├── weapon_ak_base_v01.png
│   └── ak_m0_meta.json
├── effects/m0/
│   ├── muzzle_flash/ak/
│   │   ├── fx_muzzle_ak_f00.png
│   │   ├── fx_muzzle_ak_f01.png
│   │   └── fx_muzzle_ak_f02.png
│   ├── tracer/fx_tracer_rifle_v01.png
│   └── hit/
│       ├── fx_hit_spark_small_f00.png
│       ├── fx_hit_spark_small_f01.png
│       └── fx_hit_spark_small_f02.png
├── source/
│   ├── generated/xiaodong_m0/
│   ├── cleaned/xiaodong_m0/
│   └── rejected/xiaodong_m0/
tools/assets/
├── validate_m0_xiaodong_assets.py
└── build_xiaodong_spriteframes.gd
systems/presentation/
├── direction_8.gd
└── xiaodong_m0_presentation.gd
scenes/m0/
└── xiaodong_m0_sprite_frames.tres
tests/
├── test_direction_8.gd
└── test_xiaodong_m0_assets.py
```

---

### Task 1: Create the asset contract and failing validator tests

**Files:**
- Create: `tests/test_xiaodong_m0_assets.py`
- Create: `tools/assets/validate_m0_xiaodong_assets.py`
- Create: `assets/characters/xiaodong/m0/data/xiaodong_m0_manifest.json`
- Create: `assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json`
- Create: `assets/weapons/ak/m0/ak_m0_meta.json`

**Interfaces:**
- Consumes: `assets/weapons/weapon_attachment_spec.json` and the approved filenames from the spec.
- Produces: `validate_pack(repo_root: Path) -> list[str]`, returning an empty list only when every required asset and metadata rule passes.

- [ ] **Step 1: Write the failing Python tests**

Create tests that assert:

```python
from pathlib import Path
from tools.assets.validate_m0_xiaodong_assets import validate_pack


def test_missing_pack_reports_all_required_groups(tmp_path: Path) -> None:
    errors = validate_pack(tmp_path)
    assert any("idle frames: expected 8" in error for error in errors)
    assert any("move frames: expected 32" in error for error in errors)
    assert any("AK base sprite" in error for error in errors)
    assert any("muzzle frames: expected 3" in error for error in errors)
    assert any("hit frames: expected 3" in error for error in errors)


def test_manifest_declares_exact_m0_counts(repo_root: Path) -> None:
    errors = validate_pack(repo_root)
    assert not [e for e in errors if e.startswith("manifest:")]
```

- [ ] **Step 2: Run the tests and verify failure**

Run:

```bash
python -m pytest tests/test_xiaodong_m0_assets.py -v
```

Expected: import or assertion failure because the validator and metadata do not exist.

- [ ] **Step 3: Implement the validator skeleton**

Implement `validate_pack()` to check:

- exact file counts;
- exact direction names;
- exact filenames;
- PNG dimensions;
- RGBA mode;
- no non-zero RGB values in pixels with alpha `0`;
- no alpha values between `1` and `254`;
- manifest paths exist;
- every frame has `body_center`, `feet_center`, and `hand_socket_stand` integer coordinate pairs;
- AK metadata references `../weapon_attachment_spec.json#weapons.ak`;
- duplicate manifest paths are rejected.

The CLI must print one error per line and exit `1` on failure, `0` on success:

```bash
python tools/assets/validate_m0_xiaodong_assets.py --repo-root .
```

- [ ] **Step 4: Create initial metadata with all 48 expected paths**

`xiaodong_m0_manifest.json` must include:

```json
{
  "version": "1.0",
  "character": "xiaodong",
  "milestone": "m0",
  "directions": ["n", "ne", "e", "se", "s", "sw", "w", "nw"],
  "animations": {
    "idle": {"frames_per_direction": 1, "fps": 0, "loop": false},
    "move": {"frames_per_direction": 4, "fps": 8, "loop": true}
  },
  "character_canvas": [128, 128],
  "weapon_canvas": [160, 96],
  "approval_gate": "assets/characters/xiaodong/m0/idle/character_xiaodong_idle_se_f00.png"
}
```

`xiaodong_m0_anchor_map.json` must have one entry for every character frame. Use provisional integer coordinates until final cleanup; mark each entry with `"status": "provisional"`.

`ak_m0_meta.json` must include:

```json
{
  "version": "1.0",
  "image": "assets/weapons/ak/m0/weapon_ak_base_v01.png",
  "attachment_spec": "assets/weapons/weapon_attachment_spec.json#weapons.ak",
  "base_direction": "right"
}
```

- [ ] **Step 5: Run the tests**

Expected: metadata tests pass; image-presence tests still fail with explicit missing-file errors.

- [ ] **Step 6: Commit**

```bash
git add tests/test_xiaodong_m0_assets.py tools/assets/validate_m0_xiaodong_assets.py \
  assets/characters/xiaodong/m0/data assets/weapons/ak/m0/ak_m0_meta.json
git commit -m "test: define M0 Xiaodong asset contract"
```

---

### Task 2: Produce and approve the southeast idle master frame

**Files:**
- Create: `assets/source/generated/xiaodong_m0/character_xiaodong_idle_se_f00_source.png`
- Create: `assets/characters/xiaodong/m0/idle/character_xiaodong_idle_se_f00.png`
- Modify: `assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json`

**Interfaces:**
- Consumes: Style Bible and approved Xiaodong identity anchors.
- Produces: the visual master used to derive all remaining character frames.

- [ ] **Step 1: Generate one source image only**

Use this production prompt:

```text
Create one standalone original GOGO game-character sprite for the approved M0 southeast idle master frame.
Use a young elite entry-fragger only as broad appearance reference: black longer hair with side mass reaching near the jaw and covering the ears, forehead partly visible, only a few naturally falling front strands, narrow youthful face, slim compact build, intense forward-ready energy.
Do not draw thick straight bangs, bowl-cut hair, two heavy curtain-bang panels, or a muscular bulky body.
Translate these broad cues into an original compact chibi pixel-art design, recognizable in spirit but not an exact portrait or photoreal likeness.
Original dark charcoal training clothes with a small red-orange accent under ten percent of the body area. Empty hands held in a compact universal rifle-ready pose; no weapon.
Top-down three-quarter view, full body, facing lower right / southeast, centered on a transparent background. Large readable head, small compact body, narrow silhouette, clear top of hair and face direction, consistent upper-left light, strong clean one-to-two logical-pixel dark outline, limited GOGO palette, clustered pixel shading, hard pixel edges.
No floor, no cast shadow, no environment, no UI, no text, no logo, no watermark, no real team jersey, no sponsor, no gun, no grenade, no extra limbs, no photorealism, no 3D render, no smooth vector edges, no antialiasing.
```

Do not generate a sprite sheet or any second direction in this step.

- [ ] **Step 2: Clean the source into the final 128×128 PNG**

Required cleanup:

- nearest-neighbor only;
- remove all semi-transparent edge pixels;
- reduce to 8–14 local colors;
- keep subject height between 92 and 105 pixels;
- set feet baseline consistently;
- ensure hair remains readable at 1× display;
- preserve empty hands and compact rifle-ready arm pose.

- [ ] **Step 3: Run visual approval checks**

Review at:

- 1× logical size;
- 2× nearest-neighbor;
- on light checkerboard;
- on dark checkerboard;
- in a screenshot at the current M0 camera zoom.

Reject the frame if the hair reads as short, bowl-cut, thick-fringe, or two heavy curtain panels.

- [ ] **Step 4: Record final anchors**

Update the matching anchor entry with measured integer pixels:

```json
{
  "body_center": [64, 72],
  "feet_center": [64, 111],
  "hand_socket_stand": [78, 72],
  "status": "approved"
}
```

The values above are examples; record the actual measured coordinates.

- [ ] **Step 5: Run the validator**

Expected: the southeast master passes format checks; missing assets remain listed.

- [ ] **Step 6: Commit**

```bash
git add assets/source/generated/xiaodong_m0 \
  assets/characters/xiaodong/m0/idle/character_xiaodong_idle_se_f00.png \
  assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json
git commit -m "art: approve Xiaodong southeast idle master"
```

---

### Task 3: Produce the remaining seven idle directions

**Files:**
- Create: seven remaining files under `assets/characters/xiaodong/m0/idle/`
- Modify: `assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json`

**Interfaces:**
- Consumes: approved `idle_se_f00` master.
- Produces: a complete eight-direction idle set with consistent identity and baseline.

- [ ] **Step 1: Produce one direction at a time in this order**

```text
e → ne → n → nw → w → sw → s
```

For each direction, reuse the master’s exact:

- hair length and front-hair rule;
- face width;
- head/body ratio;
- outfit colors;
- outline thickness;
- feet baseline;
- hand posture.

Only turn the body and face. Do not redesign the character per direction.

- [ ] **Step 2: Clean each frame to 128×128 RGBA**

Apply the same cleanup criteria as Task 2.

- [ ] **Step 3: Measure and record anchors immediately after each frame**

Set each entry to `"status": "approved"` only after overlay comparison against the master.

- [ ] **Step 4: Build an eight-direction review contact sheet locally**

The contact sheet is a review artifact only and must not be committed as a game asset. Arrange directions clockwise starting with `n`.

Verify:

- head size differs by no more than two pixels;
- feet baseline differs by no more than two pixels;
- hand socket transition is smooth;
- no direction silently changes hairstyle or body mass.

- [ ] **Step 5: Run validator and commit**

```bash
python tools/assets/validate_m0_xiaodong_assets.py --repo-root .
git add assets/characters/xiaodong/m0/idle \
  assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json
git commit -m "art: add Xiaodong eight-direction idle set"
```

Expected validator state: idle group passes; move/weapon/effects still fail as missing.

---

### Task 4: Produce the four-frame southeast move cycle

**Files:**
- Create: `assets/characters/xiaodong/m0/move/character_xiaodong_move_se_f00.png`
- Create: `assets/characters/xiaodong/m0/move/character_xiaodong_move_se_f01.png`
- Create: `assets/characters/xiaodong/m0/move/character_xiaodong_move_se_f02.png`
- Create: `assets/characters/xiaodong/m0/move/character_xiaodong_move_se_f03.png`
- Modify: `assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json`

**Interfaces:**
- Consumes: approved southeast idle frame.
- Produces: the master move cycle used as timing and displacement reference for other directions.

- [ ] **Step 1: Define the four poses**

```text
f00: left leg forward, body down 1 px
f01: passing pose, body neutral
f02: right leg forward, body down 1 px
f03: passing pose, body neutral
```

Keep head bob at zero or one pixel. Keep `hand_socket_stand` within two pixels across all four frames.

- [ ] **Step 2: Produce and clean the four complete-body PNGs**

Do not generate a sprite sheet. Review the loop at 8 fps and at half speed.

- [ ] **Step 3: Measure anchors and verify loop closure**

The transition `f03 → f00` must not jump more than two pixels at feet, body center, or hand socket.

- [ ] **Step 4: Run validator and commit**

```bash
git add assets/characters/xiaodong/m0/move/*_se_f*.png \
  assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json
git commit -m "art: add Xiaodong southeast move master"
```

---

### Task 5: Produce the remaining twenty-eight move frames

**Files:**
- Create: four frames for each of `e`, `ne`, `n`, `nw`, `w`, `sw`, `s`
- Modify: `assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json`

**Interfaces:**
- Consumes: eight idle directions and southeast move timing.
- Produces: complete thirty-two-frame move set.

- [ ] **Step 1: Complete one direction per review cycle**

For every direction:

1. create four frames;
2. clean to final pixels;
3. play at 8 fps;
4. overlay with its idle frame;
5. record anchors;
6. mark approved;
7. commit or checkpoint before starting the next direction.

- [ ] **Step 2: Enforce directional consistency**

The same animation phase must mean the same foot phase in all directions. Do not mirror asymmetrical hair blindly; redraw hair volume where needed so the silhouette remains plausible.

- [ ] **Step 3: Run the complete character validator**

Expected: all 40 character frames pass dimensions, names, alpha, metadata, and counts.

- [ ] **Step 4: Commit**

```bash
git add assets/characters/xiaodong/m0/move \
  assets/characters/xiaodong/m0/data/xiaodong_m0_anchor_map.json
git commit -m "art: complete Xiaodong eight-direction move set"
```

---

### Task 6: Produce the standalone AK sprite

**Files:**
- Create: `assets/source/generated/xiaodong_m0/weapon_ak_base_v01_source.png`
- Create: `assets/weapons/ak/m0/weapon_ak_base_v01.png`
- Modify: `assets/weapons/ak/m0/ak_m0_meta.json`

**Interfaces:**
- Consumes: existing `weapons.ak` attachment coordinates.
- Produces: one right-facing AK sprite aligned to `grip_point [68,58]` and `muzzle_point [151,40]` on a 160×96 canvas.

- [ ] **Step 1: Generate one standalone fictional rifle sprite**

Prompt requirements:

```text
One standalone original fictional pixel-art assault-rifle sprite for GOGO M0, inspired only by the broad silhouette language of a curved-magazine rifle. Pointing right, side view with slight top visibility, front-heavy readable silhouette, dark metal receiver, muted warm wooden handguard and stock, limited GOGO palette, upper-left light, one-to-two logical-pixel outline, hard pixel edges, transparent background. No hands, no character, no muzzle flash, no bullet, no logo, no manufacturer mark, no readable text, no floor, no cast shadow, no photorealism, no 3D render.
```

- [ ] **Step 2: Clean and place on the exact 160×96 canvas**

The rear grip must cover the configured `grip_point`; the barrel endpoint must land exactly at `muzzle_point`. Do not change global attachment coordinates to compensate for a poorly placed drawing.

- [ ] **Step 3: Verify attachment overlay in all eight idle directions**

Use the current anchor map to render an offline overlay. Verify:

- hands plausibly cover the grip/handguard;
- muzzle does not intersect the face;
- stock does not float excessively;
- horizontal flip preserves attachment positions.

- [ ] **Step 4: Update metadata status and run validator**

Add `"status": "approved"` and the final SHA-256 checksum to `ak_m0_meta.json`.

- [ ] **Step 5: Commit**

```bash
git add assets/source/generated/xiaodong_m0/weapon_ak_base_v01_source.png \
  assets/weapons/ak/m0/weapon_ak_base_v01.png assets/weapons/ak/m0/ak_m0_meta.json
git commit -m "art: add M0 standalone AK sprite"
```

---

### Task 7: Produce muzzle flash, tracer, and hit sprites

**Files:**
- Create: three muzzle flash PNGs
- Create: one tracer PNG
- Create: three hit spark PNGs

**Interfaces:**
- Consumes: AK muzzle point and current hitscan presentation.
- Produces: seven reusable feedback sprites, independent from character and weapon images.

- [ ] **Step 1: Produce the three-frame muzzle flash**

Canvas: 64×64. Origin: center-left attachment point. Sequence:

```text
f00: compact bright core
f01: widest star/diamond burst
f02: narrow fading ember shape
```

Use four to eight colors from warm attack palette. No smoke cloud in M0.

- [ ] **Step 2: Produce one tracer sprite**

Canvas: 64×16 or 128×16, with the logical origin at the left center. The runtime may scale its X length; preserve hard vertical edges and a bright center with one darker outer band.

- [ ] **Step 3: Produce the three-frame hit spark**

Canvas: 64×64. Keep the effect compact enough not to hide a target. Sequence: contact core, radial fragments, fade fragments.

- [ ] **Step 4: Run alpha and size validation**

Expected: all seven effect files pass.

- [ ] **Step 5: Commit**

```bash
git add assets/effects/m0
git commit -m "art: add M0 rifle shooting effects"
```

---

### Task 8: Implement and test stable eight-direction selection

**Files:**
- Create: `systems/presentation/direction_8.gd`
- Create: `tests/test_direction_8.gd`
- Modify: `tests/test_runner.tscn` or the existing test registry

**Interfaces:**
- Produces: `Direction8.from_vector(direction: Vector2, previous: StringName = &"se", hysteresis_deg: float = 4.0) -> StringName`.

- [ ] **Step 1: Write failing direction tests**

Cover cardinal directions, diagonals, zero vector fallback, and hysteresis near `22.5°`.

Example:

```gdscript
assert_eq(Direction8.from_vector(Vector2.RIGHT), &"e")
assert_eq(Direction8.from_vector(Vector2.DOWN), &"s")
assert_eq(Direction8.from_vector(Vector2(-1, -1)), &"nw")
assert_eq(Direction8.from_vector(Vector2.ZERO, &"sw"), &"sw")
```

- [ ] **Step 2: Run tests and verify failure**

```bash
godot --headless --path . res://tests/test_runner.tscn
```

- [ ] **Step 3: Implement the single shared quantizer**

Normalize angle to `[-180,180)`. Apply the exact sectors from the approved spec. Retain `previous` while the angle stays within `hysteresis_deg` beyond the previous sector boundary.

- [ ] **Step 4: Run tests and commit**

```bash
git add systems/presentation/direction_8.gd tests/test_direction_8.gd tests/test_runner.tscn
git commit -m "feat: add stable eight-direction selector"
```

---

### Task 9: Build SpriteFrames and presentation controller

**Files:**
- Create: `tools/assets/build_xiaodong_spriteframes.gd`
- Create: `scenes/m0/xiaodong_m0_sprite_frames.tres`
- Create: `systems/presentation/xiaodong_m0_presentation.gd`
- Modify: current M0 player scene to add `AnimatedSprite2D`, `WeaponPivot`, `WeaponSprite`, `MuzzleSocket`, and effect nodes

**Interfaces:**
- Consumes: manifest, anchor map, Direction8, AK metadata.
- Produces: runtime animation names `idle_n`…`idle_nw` and `move_n`…`move_nw`.

- [ ] **Step 1: Write a failing scene-load test**

The test must instantiate the M0 scene and assert:

```gdscript
assert_not_null(player.get_node("BodySprite"))
assert_not_null(player.get_node("WeaponPivot/WeaponSprite"))
assert_eq(body_sprite.sprite_frames.get_animation_names().size(), 16)
```

- [ ] **Step 2: Build the SpriteFrames resource from manifest paths**

The builder must fail on missing paths or unexpected frame counts. Set move animations to 8 fps and loop; idle animations contain one frame and do not loop.

- [ ] **Step 3: Implement `XiaodongM0Presentation`**

Responsibilities only:

- choose direction from player `aim_direction`;
- choose idle/move from player movement state;
- play the matching body animation;
- read current frame’s `hand_socket_stand`;
- align `WeaponPivot` so AK `grip_point` lands on that socket;
- flip/rotate the weapon without altering combat aim;
- set weapon z-index from the existing front/behind rule;
- place `MuzzleSocket` from transformed `muzzle_point`;
- play muzzle flash on shot;
- display tracer from shot origin to actual end point;
- play hit spark only when `did_hit` is true.

Do not calculate damage, spread, recoil, ammo, reload, or raycasts in this script.

- [ ] **Step 4: Remove or disable graybox drawing only after sprites load successfully**

Keep a development fallback that draws the original shape when the presentation resource fails to load and prints a clear error.

- [ ] **Step 5: Run all Godot tests and commit**

```bash
godot --headless --path . --editor --quit
godot --headless --path . res://tests/test_runner.tscn
git add tools/assets/build_xiaodong_spriteframes.gd scenes/m0 \
  systems/presentation current/player/scene/path tests
git commit -m "feat: integrate M0 Xiaodong presentation assets"
```

Replace `current/player/scene/path` with the exact existing player scene path discovered before implementation; do not create a parallel unused player scene.

---

### Task 10: Complete automated validation and manifest checksums

**Files:**
- Modify: `tools/assets/validate_m0_xiaodong_assets.py`
- Modify: `tests/test_xiaodong_m0_assets.py`
- Modify: all three metadata JSON files
- Modify: `assets/asset_manifest.csv`

**Interfaces:**
- Produces: reproducible command proving the committed pack is structurally complete.

- [ ] **Step 1: Add tests for final checksums and approved statuses**

Require every final PNG to have a SHA-256 entry and every anchor entry to have `"status": "approved"`.

- [ ] **Step 2: Add actual asset rows to `assets/asset_manifest.csv`**

Each row must include stable ID, path, category, milestone `M0`, state `approved`, canvas size, and source/ownership note `original GOGO production asset`.

- [ ] **Step 3: Run complete validation**

```bash
python -m pytest tests/test_xiaodong_m0_assets.py -v
python tools/assets/validate_m0_xiaodong_assets.py --repo-root .
godot --headless --path . --editor --quit
godot --headless --path . res://tests/test_runner.tscn
```

Expected: all commands exit `0`; validator prints `M0 Xiaodong asset pack: PASS`.

- [ ] **Step 4: Commit**

```bash
git add assets/asset_manifest.csv assets/characters/xiaodong/m0/data \
  assets/weapons/ak/m0/ak_m0_meta.json tools/assets tests/test_xiaodong_m0_assets.py
git commit -m "test: verify complete M0 Xiaodong asset pack"
```

---

### Task 11: Perform manual M0 playtest and document acceptance

**Files:**
- Create: `docs/acceptance/M0_Xiaodong_Asset_Acceptance.md`
- Modify: `docs/design/16_M0小洞大人素材规范.md` status line

**Interfaces:**
- Consumes: complete integrated pack.
- Produces: final acceptance evidence and known-issue list.

- [ ] **Step 1: Run the game for ten continuous minutes on Windows**

Test:

- idle in every direction;
- move while aiming in every direction;
- circle-strafe and backpedal;
- hold fire through a full magazine;
- reload and resume fire;
- repeatedly cross all direction boundaries;
- shoot targets at close and long range.

- [ ] **Step 2: Record acceptance results**

The document must include a checkbox and evidence note for:

- hair reads correctly at gameplay size;
- no thick fringe/bowl-cut regression;
- all direction changes are readable;
- no boundary flicker under ordinary mouse movement;
- hand socket drift is not visible;
- AK does not float or clip severely;
- muzzle flash starts at barrel;
- tracer and hit point agree with actual hitscan;
- weapon front/behind ordering is correct;
- no gameplay values changed;
- no error appears in Godot output;
- ten-minute run completed.

- [ ] **Step 3: Resolve blockers only**

Fix only acceptance failures that block M0. Record non-blocking polish requests under `Deferred to M1`; do not add new actions or animation states.

- [ ] **Step 4: Mark the spec complete and commit**

Change status to `M0 成品素材已验收` only after all blocker checks pass.

```bash
git add docs/acceptance/M0_Xiaodong_Asset_Acceptance.md \
  docs/design/16_M0小洞大人素材规范.md
git commit -m "docs: accept M0 Xiaodong production assets"
```

---

## Final Verification

Run from repository root:

```bash
python -m pytest tests/test_xiaodong_m0_assets.py -v
python tools/assets/validate_m0_xiaodong_assets.py --repo-root .
godot --headless --path . --editor --quit
godot --headless --path . res://tests/test_runner.tscn
git status --short
```

Expected:

- Python tests pass;
- asset validator reports PASS;
- Godot imports without parse/resource errors;
- Godot test runner passes;
- working tree contains no accidental `.DS_Store`, generated contact sheets, rejected source images, or untracked temporary files.
