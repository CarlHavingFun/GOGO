# Weapon, Throwable, and Upgrade Icon Asset Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a coherent four-tier rarity UI, modular weapon attachment metadata, and first-pass image atlases for weapons, throwables, universal upgrades, and Xiaodong-exclusive upgrades.

**Architecture:** Keep runtime combat sprites, UI icons, rarity decoration, and metadata in separate files. Godot composes character and weapon sprites through registered sockets, while reward cards compose a neutral item icon with rarity and timing overlays.

**Tech Stack:** Godot 4.x, SVG concept atlases, PNG runtime exports, JSON attachment metadata, CSV asset manifests.

## Global Constraints

- Character sprites never contain weapons.
- Weapon sprites never contain hands, muzzle flashes, shells, lasers, text, logos, or cast shadows.
- Runtime UI icons use a 64×64 logical canvas and transparent background.
- Rarity colors are common white, rare blue, epic purple, and legendary gold.
- Rarity must also be identifiable by circle, diamond, hexagon, and four-point-star shape codes.
- Timer badges appear only on effects that depend on seconds, duration, cooldown, refresh, windows, or wave start.
- Final PNGs use hard pixel edges, lossless compression, Filter Off, and no mipmaps.

---

### Task 1: Lock the rarity and card composition contract

**Files:**
- Create: `docs/design/15_武器道具与升级图标资产设计.md`
- Create: `assets/ui/icons/rarity_ui_atlas.svg`
- Create: `assets/ui/icons/atlas_map.json`

**Interfaces:**
- Consumes: project palette and UI icon size from `14_像素美术Style_Bible.md`
- Produces: rarity IDs `common`, `rare`, `epic`, `legendary`; overlay cells for reward-card UI

- [ ] Review all four border cells at 64×64 and 32×32 nearest-neighbor preview.
- [ ] Verify each tier remains distinguishable in grayscale by shape code.
- [ ] Verify the timer badge does not overlap a 48×48 central safe area.
- [ ] Commit the approved rarity contract.

### Task 2: Register modular weapon attachment data

**Files:**
- Create: `assets/weapons/weapon_attachment_spec.json`
- Modify: player weapon rendering code that owns `WeaponPivot`
- Test: add or extend the project weapon attachment test scene

**Interfaces:**
- Consumes: `hand_socket_stand`, `hand_socket_crouch`
- Produces: `grip_point`, `muzzle_point`, `shell_eject_point`, `shoulder_point`, `laser_origin`, `rotation_center`

- [ ] Load the JSON by weapon ID.
- [ ] Align each `grip_point` to the active character hand socket.
- [ ] Mirror every registered point when the weapon flips horizontally.
- [ ] Switch weapon z-order behind the torso when `aim_dir.y < -0.20`.
- [ ] Validate all five weapons at 0°, 90°, 180°, and 270°.
- [ ] Commit attachment loading and tests.

### Task 3: Export the weapon and throwable UI icon atlas

**Files:**
- Create: `assets/ui/icons/weapon_throwable_atlas.svg`
- Create: nine independent 64×64 PNG exports under `assets/ui/icons/weapons/` and `assets/ui/icons/throwables/`
- Update: `assets/upgrade_icon_manifest.csv`

**Interfaces:**
- Consumes: atlas rects in `assets/ui/icons/atlas_map.json`
- Produces: `ui_weapon_usp`, `ui_weapon_deagle`, `ui_weapon_ak`, `ui_weapon_m4`, `ui_weapon_awp`, `ui_throwable_he`, `ui_throwable_smoke`, `ui_throwable_flash`, `ui_throwable_fire`

- [ ] Export each atlas cell without scaling.
- [ ] Remove anti-aliased or semi-transparent edge pixels.
- [ ] Confirm each weapon is recognizable at 32×32.
- [ ] Import into Godot with Filter Off and Lossless compression.
- [ ] Commit the nine PNGs and import metadata.

### Task 4: Export the universal upgrade icon pack

**Files:**
- Create: `assets/ui/icons/common_upgrade_atlas.svg`
- Create: twelve independent PNGs under `assets/ui/icons/upgrades/common/`
- Update: `assets/upgrade_icon_manifest.csv`

**Interfaces:**
- Produces icon IDs `CAL_01` through `CAL_08`, `ENG_01`, `ENG_02`, `ENG_04`, and `ENG_06`

- [ ] Export all twelve cells to 64×64 PNG.
- [ ] Confirm no rarity color is baked into the item subject.
- [ ] Confirm time-based items are marked in metadata, not permanently baked with a timer badge.
- [ ] Test icons on white, dark, and smoke-gray card backgrounds.
- [ ] Commit the universal icon pack.

### Task 5: Export the Xiaodong-exclusive upgrade icon pack

**Files:**
- Create: `assets/ui/icons/xiaodong_upgrade_atlas.svg`
- Create: eight independent PNGs under `assets/ui/icons/upgrades/xiaodong/`
- Update: `assets/upgrade_icon_manifest.csv`

**Interfaces:**
- Produces icon IDs `DON_01` through `DON_08`
- Runtime pool initially consumes only `DON_01`, `DON_02`, and `DON_03`

- [ ] Export eight cells to 64×64 PNG.
- [ ] Verify the red-orange character theme does not replace the rarity border.
- [ ] Keep `DON_04` through `DON_08` disabled in the current reward pool.
- [ ] Verify `DON_02` and `DON_08` show their downside on the reward card.
- [ ] Commit the Xiaodong icon pack.

### Task 6: Integrate rarity and timer overlays in Godot

**Files:**
- Modify: reward-card scene and script
- Modify: inventory icon scene and script
- Test: add UI snapshot or deterministic scene checks for all four rarities

**Interfaces:**
- Consumes: `rarity`, `category`, `has_timer_badge`, `stack_count`, `max_stack`
- Produces: composed card with neutral icon, rarity frame, category badge, optional timer badge, text, and stack state

- [ ] Render the neutral icon below all overlays.
- [ ] Select the rarity frame by exact ID.
- [ ] Select the shape code independently from color.
- [ ] Show the timer badge only when `has_timer_badge=true`.
- [ ] Show contract category stripes without changing rarity.
- [ ] Verify all combinations at 100%, 150%, and 200% UI scale.
- [ ] Commit the composed reward-card UI.

### Task 7: Validate gameplay readability and balance semantics

**Files:**
- Update: reward data definitions with new rarity values
- Update: automated data validation for rarity and icon IDs
- Test: reward-pool deterministic tests

**Interfaces:**
- Consumes: migration `普通→common`, `少见→rare`, `稀有→epic`, `合同→category`
- Produces: four-tier visual rarity without changing current reward effects

- [ ] Reject any item with a missing icon ID.
- [ ] Reject any item with a rarity outside the four allowed IDs.
- [ ] Reject any contract missing an explicit downside field.
- [ ] Reject any legendary item whose effect is only a scalar duplicate of a lower-tier item.
- [ ] Verify the current 47-item pool still satisfies candidate filtering and pity rules.
- [ ] Commit validation and data migration.
