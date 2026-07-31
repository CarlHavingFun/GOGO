---
name: gogo-agent-sprite-forge
description: "Use for GOGO character, weapon, projectile, muzzle-flash, impact, effect, map, prop, or animation asset work. It wraps the pinned Agent Sprite Forge sprite and map skills with GOGO's A0-A5/C0 governance, original/IP boundaries, raw-versus-delivery layout contract, manifest evidence, deterministic QC, and Godot import gates."
---

# GOGO Agent Sprite Forge

This is the GOGO project wrapper around the pinned Agent Sprite Forge snapshot
`64fd0b57d3f2ae117ef0a95e4c2decc25b4c9dd2`. Use it whenever a task creates,
edits, reviews, or integrates GOGO visual assets. The upstream skills provide
agent planning, built-in image generation, and deterministic post-processing;
this wrapper supplies the project contract and evidence gates.

## Mandatory preflight

Before planning or generating anything, read all three current project sources:

1. `docs/design/13_素材生产管线与提示词.md`
2. `assets/README.md`
3. `assets/asset_manifest.csv`

Also inspect the target scene/runtime contract and the relevant current design
document. If a local reference image is involved, make it visible with
`view_image` before using it as an image-generation reference. Never rely on a
path string alone as visual context.

Use the vendored upstream skill that matches the asset:

- `skills/generate2dsprite/SKILL.md` for characters, weapons, projectiles,
  muzzle flashes, impacts, props, effects, and animation sheets.
- `skills/generate2dmap/SKILL.md` for maps, chunks, terrain, props, collision,
  zones, placement metadata, and scene previews.

The upstream snapshot is MIT licensed. Do not add `video2dsprite`: its workflow
depends on Grok-specific video generation and is not part of the Codex path.

## GOGO contract

### 1. Register before generating

Create or update the manifest row first with `status=planned`. Decide and record
asset category, subject/action, phase A0-A5, canvas, pivot/anchor, frame count,
direction, collision reference, runtime path, and Godot import contract.

The canonical manifest keeps `sprite_layout` for the final runtime delivery
layout and adds:

- `forge_mode`: `generate2dsprite`, `generate2dmap`, `runtime_native`, or
  `procedural_placeholder`;
- `raw_layout`: the raw generation grid, such as `2x2`, `2x3`, `2x4`, or `4x4`;
- `prompt_path`: the hand-written prompt and negative constraints evidence;
- `pipeline_meta`: deterministic cleanup, slicing, alignment, QC, and assembly
  metadata;
- `scale_profile`: the shared scale/anchor profile for a multi-action
  high-value character.

Do not use `sprite_layout` to describe the raw generated grid. A raw grid and a
Godot delivery strip/atlas are separate artifacts and separate decisions.

### 2. Map GOGO governance before image generation

- A0 is the greybox/reference stage; A1-A5 follow the approved milestone.
- C0 design approval and A5 asset readiness are separate gates. A concept or
  reference decision never silently changes A5 status.
- Original characters and game identity are the default. User-supplied
  references may guide style or identity only under the project's stated rights
  policy; remove logos, team marks, sponsor marks, watermarks, and recognizable
  third-party branding.
- Keep body, weapon, muzzle flash, projectile, impact, smoke, dust, and other
  detached effects in separate layers unless the runtime contract explicitly
  requires a tightly attached silhouette.

### 3. Write a manual prompt

The prompt must state the subject, action, camera/view, exact grid, frame count,
cell dimensions, palette/style, safe area, anchor line, consistent scale, and
explicit exclusions. For sprite generation use a pure `#FF00FF` raw background.
Require the complete subject inside the central safe area with no edge touch,
cropping, labels, text, borders, separators, UI, or unintended background.

For body animation, use one action family per raw sheet:

- 4 frames: `2x2`
- 6 frames: `2x3`
- 8 frames: `2x4`
- four-direction walk: `4x4`

Do not ask the model for unrelated action rows in one raw atlas. Do not use a
single-row raw body sheet merely because Godot eventually needs a horizontal
strip. Generate and QC each action grid first, then assemble the delivery strip
or final atlas deterministically. Create a shared `scale_profile` from an
accepted idle/run master for high-value multi-action characters.

### 4. Generate and preserve the raw output

Use the built-in image generation path required by the upstream skill. Keep the
original raw output under an evidence directory such as
`assets/raw/<asset_id>/`. Set the manifest row to `generated` only after
`forge_mode`, `raw_layout`, `prompt_path`, and `source_output` are present.

Raw sprites, raw maps, layout guides, and stage references are evidence or
planning artifacts. They must never be used directly as the final runtime
asset.

### 5. Process deterministically and run strict QC

Use the vendored upstream scripts only for deterministic operations such as
chroma-key cleanup, frame extraction, alpha cleanup, component selection,
alignment, shared scaling, GIF export, metadata, and QC. Do not use code to
invent the raw creative image.

For maps, use `generate2dmap` and separate the foundation/base, props,
collision, zones, spawn markers, scene hooks, and runtime metadata. A playable
map must not infer collision from a baked preview or ship a stage-reference
image as the runtime map.

For every asset, check dimensions, frame count, alpha, pure-magenta removal,
edge touch, anchor drift, scale consistency, palette, unintended text/logo,
and the real gameplay camera. For characters, also check body occupancy and
shared feet/root alignment. For maps, check seam, collision, spawn, safe-area,
and preview consistency.

After cleanup set `status=cleaned` only when `pipeline_meta` and the cleaned
output exist. Only then assemble `sprite_layout` delivery output and run the
Godot import/scene check.

### 6. Save evidence and close the lifecycle

Every generation stores:

```text
manifest row
prompt_path
source_output
raw_layout
pipeline_meta
cleaned_output
qa_record
godot_evidence
```

`approved` and `in_game` require QA, reviewer, and Godot evidence. `in_game`
also requires the Godot import settings and a real scene check. `rejected` must
retain the failure QA record and must not have a stable runtime `path`.

Run the project validator after every lifecycle transition:

```text
godot --headless --path . --script res://tools/validate_content.gd -- --profile=g0
godot --headless --path . --script res://tools/validate_content.gd -- --profile=full
```

The accepted project baseline remains:

```text
G0 gate: PASS
Full catalog: NOT_READY
```

### 7. Correct repeated failures

If the same class of error appears in two consecutive rounds, stop blind
regeneration. Change the prompt, visible reference, layout guide, scale profile,
or asset split, record that decision in the QA/pipeline metadata, and rerun the
smallest relevant processor fixture before generating again.

## Delivery checklist

Before calling a GOGO asset complete, verify:

- the manifest was planned before generation;
- raw and delivery layouts are explicitly different or explicitly identical by
  contract, never implicitly conflated;
- the raw source is preserved and the final `path` points only to cleaned,
  deterministic delivery output;
- the Prompt, pipeline metadata, QA record, reviewer, and Godot evidence paths
  exist for the row's status;
- character layers and detached effects remain composable at runtime;
- map gameplay data is separate from visual references and previews;
- original/IP and A0-A5/C0 decisions are recorded;
- `ContentValidator --profile=g0` passes and `--profile=full` still reports
  `NOT_READY` until the complete catalog is actually delivered.
