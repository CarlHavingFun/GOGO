# Arena Design Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate the GOGO arena, spawn-buffer, and three-map design package into the repository’s single authoritative GDD without changing runtime game code.

**Architecture:** Add one authoritative arena/spawn spatial-system document plus three arena appendices under `docs/design/`. Align the design index, developer entrypoint, and milestone numbering so M0 remains the AK shooting toy and M1 becomes the first arena/spawn implementation stage. Keep wave composition in `WaveSpawnProfile`, map geometry in `ArenaDefinition` and `SpawnPortal`, and runtime selection in a shared `SpawnDirector`.

**Tech Stack:** Markdown, GitHub branches and pull requests, Godot 4.x repository conventions.

## Global Constraints

- `docs/design/` remains the only authoritative GDD.
- Do not create a parallel `docs/maps/` or root-level map-document package.
- First release implements only `arena_double_dust`; `arena_redtile_town` and `arena_freight_hub` remain design reserves.
- This change is documentation-only: do not modify `.gd`, `.tscn`, `.tres`, `project.godot`, assets, or tests.
- Preserve the open pixel Style Bible work by basing this branch on `docs/pixel-style-bible`.
- Use M0 shooting toy, M1 five-wave loop, M2 character/tactical validation, M3 ten-wave vertical slice, M4 twenty-wave Alpha, M5 balance, M6 Windows Beta, M7 Windows 1.0, and M8 ports.
- Do not introduce a second map-owned spawn-profile resource; use `ArenaDefinition`, `SpawnPortal`, `WaveSpawnProfile`, and shared `SpawnDirector` responsibilities.
- Do not claim Godot runtime verification for a documentation-only change.

---

### Task 1: Add the authoritative arena and spawn spatial-system design

**Files:**
- Create: `docs/design/15_竞技场与刷怪空间系统.md`

**Interfaces:**
- Consumes: `00_产品宪法.md`, `06_怪物与波次设计.md`, `09_Godot技术架构.md`, `13_素材生产管线与提示词.md`, `14_像素美术Style_Bible.md`.
- Produces: design contracts for `ArenaDefinition`, `ArenaRoot`, `SpawnPortal`, `WaveSpawnProfile`, `SpawnDirector`, and `SpawnCandidateSelector`.

- [ ] Define the three spatial layers: spawn buffer, transition channel, and playable arena.
- [ ] Define the required regular, special, and Boss portal contract.
- [ ] Define filtering, scoring, fixed-seed selection, congestion handling, anti-camping, logging, telemetry, and validation.
- [ ] State that no legal portal means deferred spawning rather than face spawning.
- [ ] State that first release implements only Double Dust.
- [ ] Scan for ambiguous or overlapping map-owned spawn-profile terminology.

### Task 2: Add the arena index and three map appendices

**Files:**
- Create: `docs/design/arenas/README_竞技场索引.md`
- Create: `docs/design/arenas/15A_双尘旧城.md`
- Create: `docs/design/arenas/15B_赤瓦小镇.md`
- Create: `docs/design/arenas/15C_货运枢纽.md`

**Interfaces:**
- Consumes: the contract in `../15_竞技场与刷怪空间系统.md`.
- Produces: one first-release map specification and two post-1.0 content-reserve specifications.

- [ ] Give every map a stable `arena_id` and a clear release status.
- [ ] Require 8 regular portals, 2 special portal placeholders, and 1 Boss portal per appendix.
- [ ] Describe buffer-zone fiction, combat regions, loops, anti-camping behavior, and validation criteria.
- [ ] Keep Double Dust as the only first-release implementation target.
- [ ] Keep Redtile Town and Freight Hub free of current milestone implementation commitments.
- [ ] Remove direct copies of real-map markings, logos, textures, and exact object layouts from the specification.

### Task 3: Align repository navigation and milestone numbering

**Files:**
- Modify: `README.md`
- Modify: `CODEX_START.md`
- Modify: `docs/design/README_设计文档索引.md`
- Modify: `docs/design/11_开发里程碑.md`

**Interfaces:**
- Consumes: the new document paths and canonical M0–M8 sequence.
- Produces: one unambiguous developer entrypoint and one milestone source of truth.

- [ ] Add links to the arena/spawn document and arena appendix index.
- [ ] Add `14_像素美术Style_Bible.md` and `15_竞技场与刷怪空间系统.md` to the authoritative reading order.
- [ ] Make M0 the AK shooting toy throughout the changed files.
- [ ] Put Arena extraction between M0 and M1 as an engineering work package, not a new milestone ID.
- [ ] Put Double Dust greybox and safe spawning in M1.
- [ ] Put Double Dust pixel art in M3, after greybox and smoke validation.
- [ ] State that additional arenas are post-1.0 projects.

### Task 4: Validate the documentation set

**Files:**
- Test: all Markdown files changed by this plan.

**Interfaces:**
- Consumes: the completed Markdown set.
- Produces: static verification evidence and an exact changed-file list.

- [ ] Scan for unfinished markers, obsolete milestone labels, old map IDs, and overlapping map-owned spawn-profile terminology.
- [ ] Check relative Markdown links introduced by the change.
- [ ] Confirm every arena appendix references the authoritative spatial-system document.
- [ ] Confirm only documentation files changed compared with `docs/pixel-style-bible`.
- [ ] Fetch the remote branch versions after upload and compare them with the intended file set.

### Task 5: Publish a stacked draft pull request

**Files:**
- Modify only files listed in Tasks 1–3.

**Interfaces:**
- Consumes: verified branch `docs/arena-spawn-design`.
- Produces: a draft PR targeting `docs/pixel-style-bible` until the Style Bible PR merges.

- [ ] Create the branch from the latest `docs/pixel-style-bible` head.
- [ ] Upload the new and replacement Markdown files with focused commit messages.
- [ ] Compare base and head and record the exact changed files.
- [ ] Open a draft PR with scope, dependency, validation, and explicit “no runtime code changed” notes.
- [ ] After the Style Bible PR merges, retarget this PR to `main` and resolve any documentation conflict before merge.
