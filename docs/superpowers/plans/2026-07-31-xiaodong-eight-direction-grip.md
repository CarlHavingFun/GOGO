# Xiaodong Eight-Direction Walk and Grip Layers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变 GOGO 里程碑边界的前提下，把“小洞大人”C0 扩展成头身同步转向的八方向四相位走路，以及 pistol/rifle/sniper 三类不显示武器的共用前后手分层，并形成可确定性重建和审计的 96 个完整全身 QA 合成结果。

**Architecture:** 现有右下单方向 C0 批次先作为历史动作依据独立封存；当前权威设计和 A5 planned 目录随后一次性同步。Godot `ContentValidator` 精确拥有十二项 Xiaodong A5 计划合同，独立 Python/Pillow 工具只拥有 C0 元数据、机械图像检查、分层合成和联系表生成；生成源、canonical cleaned layer、派生 QA 和正式 A5 路径保持互不混淆。

**Tech Stack:** Godot `4.7.1.stable.official.a13da4feb`、强类型 GDScript、现有 `SceneTree` 测试运行器、Python 3 标准库、Pillow `11.3.0`、Codex `imagegen` skill、Markdown、JSON、CSV、PNG RGBA。

## Global Constraints

- 当前分支必须始终是 `codex_goal`；本计划不创建工作树、不切换分支。
- 权威基线为 `docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`、`docs/superpowers/specs/2026-07-31-gogo-xiaodong-eight-direction-grip-design.md` 及用户的 `批准002`、`批准八方向方案`、`共用`、`批准三类握持分层方案`、`批准书面规格`。
- 本计划只实现 Xiaodong C0 八方向走路与三类空手握持可行性；不生成其他角色、武器、敌人、平台内容或正式 A5 Sprite Sheet，不修改 M0 战斗行为。
- 方向顺序固定为 `n,ne,e,se,s,sw,w,nw`；C0 相位顺序固定为 `contact_l,passing_l,contact_r,passing_r`。
- A5 八帧顺序固定为 `contact_l,down_l,passing_l,up_l,contact_r,down_r,passing_r,up_r`。
- 每个走路姿势必须让头、脸或后脑、胸腔、骨盆、肩轴法线、髋轴法线、膝和鞋尖同步指向同一个 `direction_id`。
- C0 canonical 数量固定为 32 张 arm-less `walk_body` layer、24 个 grip group / 48 张 arm layer；派生完整全身 QA 固定为 96 个。
- pistol 供 USP/Deagle 共用，rifle 供 AK/M4 共用，sniper 供 AWP 使用；不为单把武器复制角色动画。
- 所有 C0 canonical layer 必须为未裁边 `128×128 RGBA`，左上原点，`+x` 向右、`+y` 向下，`body_root=[64,114]`。
- 角色、握持、generated、preview、cleaned 和正式 sheet 中禁止任何武器像素、半透明武器、轮廓、锚点十字、辅助线、战队 Logo、赞助商、平台/赛事 Logo、官方队服图案、赛事 UI、舞台、奖杯或水印。
- 临时抽象 grip anchor 只允许出现在派生 QA 图；不得进入 generated source、review preview、cleaned layer、A5 sheet 或 Godot。
- R2 必须优先保留可识别神似、棕色齐颌中短发、偏瘦身形、纯黑宽松短袖/黑裤/黑鞋和冷静气质；R2 不等于 M5 发布授权结论。
- 左向可以使用右向作为 pose guide，但不得直接接受未校正身份、解剖左右、固定左上光和遮挡的水平镜像。
- 连续 `aim_angle → grip_direction + residual transform` 明确留到 M4 的独立批准合同；本计划不得把八方向 grip 直接接入运行时。
- A5 武器的 `grip_point → trigger_grip_point` 解释和新增 `support_grip_point` 同样留到 M4 正式武器元数据，不在 C0 伪造。
- `character_xiaodong_walk` 的 A5 目标是 `64` 帧、`10` FPS、`eight_way`、`feet_center`、`grid_8x8`；六个 grip A5 行是 `8` 帧、`0` FPS、`eight_way`、`shoulder_pivot`、`horizontal_8x1`。
- 当前十二项 Xiaodong A5 行在 M4 前必须全部保持 `planned`，四个 evidence 字段保持空；C0 决定不得写成 A5 `generated/cleaned/approved/in_game`。
- 历史文件 `docs/design/GOGO_完整设计文档合集_v0.1.md` 必须保持 `201645` bytes、SHA-256 `50210c784c1d89bbda74d07ee74d842ae90d5fc3012e090449a8cca9b18d3cc6`。
- 固定 R2 参考 `assets/source/references/characters/xiaodong/reference_01.jpg` 必须保持 `77554` bytes、`853×1280`、SHA-256 `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52`。
- Godot 命令统一使用 `/Users/Carl/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path .`。
- 图像生成任务开始前必须读取并使用 `imagegen` skill；机械去绿幕使用 `/Users/Carl/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py`，不得用新写的生成代码替代 image generation。
- 当前用户未提交文件必须始终未暂存且字节不变：`project.godot` SHA-256 `e7db663280b5a03f8df3646c8a7cb0470218436efa8d27d580e080baa0863bc3`、`.DS_Store` SHA-256 `840196eaee5ec2abb7797bc252c91d8b8c4a5f485c173ec27bb1232dfb85153f`、`docs/.DS_Store` SHA-256 `84c98080a6f2add23440330c952d4680563406f0eaadc08ee3656e4d1cce482b`、`docs/design/.DS_Store` SHA-256 `d0bf3ee859568700e440bf6e777b93872a30c1008ab0a856d53a551903eda85b`。
- 每次提交只显式 `git add` 本任务列出的路径；提交前检查 `git diff --cached --name-only`，禁止暂存 `project.godot` 或任一 `.DS_Store`。
- 本计划文件必须在 Task 1 前以独立 `docs: plan Xiaodong eight-direction grip implementation` 提交。
- 完成视觉门联系表后必须暂停；只有用户明确批准该联系表，才可生成剩余 24 个 body layer 和 14 个 grip group。
- 本补充规格完成不等于 M0、M1–M5、Mac 1.0 或整个 `/goal` 完成。

## File and Responsibility Map

- `src/content/content_validator.gd`：精确拥有十二项 Xiaodong A5 planned 记录和静态八方向帧库的 CSV 语义。
- `tests/unit/test_content_validator.gd`：对 AST002、AST005、AST006 的十二项合同做行为测试。
- `tests/fixtures/content_validator/**`：为真实 CSV/JSON 加载、治理失败隔离和 full profile 提供十二项合成输入。
- `tools/xiaodong_c0_direction_grip.py`：只负责 C0 metadata schema、PNG 技术检查、确定性合成、联系表与命令行；不生成美术内容。
- `tests/tools/test_xiaodong_c0_direction_grip.py`：使用临时 PNG 和 JSON 测试 Python 工具，不把测试 fixture 当生产美术。
- `docs/design/00_产品宪法.md`、`04_角色与流派设计.md`、`08_UI美术音频规范.md`、`13_素材生产管线与提示词.md`：拥有当前八方向、三类握持、R2 和 A5 边界。
- `docs/design/manifest.json`：拥有被修改权威 Markdown 的 bytes/SHA，不拥有 C0 图片。
- `assets/asset_manifest.csv`：拥有十二项 A5 planned 目录，不登记 C0 canonical 或 QA。
- `assets/characters/xiaodong/character_xiaodong_design.md`：拥有所有 C0 候选决定、当前 candidate count 和 C0/A5 边界。
- `assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md`：封存已完成的单方向批次证据，不改写成八方向完成。
- `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`：拥有新八方向批次的 Prompt、输入顺序、候选、锚点、决定和 QA。
- `assets/source/generated/c0/xiaodong/direction_grip/`：保存新批次 source/preview 和 revise 证据。
- `assets/source/cleaned/c0/xiaodong/direction_grip/`：保存 80 张 canonical cleaned layer 和唯一机器 metadata。
- `assets/source/qa/c0/xiaodong/direction_grip/`：保存可重建的视觉门、96 个完整合成和联系表；不是 canonical 或 A5。
- `docs/progress/2026-07-31-xiaodong-c0-single-direction.md`：记录现有单方向批次的封存验收。
- `docs/progress/2026-07-31-xiaodong-eight-direction-gate.md`：记录用户对首批联系表的原文决定和批准 SHA。
- `docs/progress/2026-07-31-xiaodong-eight-direction-grip.md`：记录最终自动校验、内容校验、视觉 Review 和范围边界。

---

### Task 1: Preserve the existing single-direction C0 batch as historical pose evidence

**Files:**

- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`
- Create: `assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md`
- Create: `assets/source/generated/c0/xiaodong/keyposes/**/*.png`
- Create: `assets/source/generated/c0/xiaodong/portrait/*.png`
- Create: `assets/source/cleaned/c0/xiaodong/master/xiaodong_c0_master_002_cleaned.png`
- Create: `assets/source/cleaned/c0/xiaodong/keyposes/**/*.png`
- Create: `assets/source/cleaned/c0/xiaodong/portrait/*.png`

**Interfaces:**

- Consumes: 已提交的 `xiaodong_c0_master_002`、用户 `批准002` 和当前未提交的 24 候选 / 16 cleaned 批次。
- Produces: 不可变的右下身份、动作、相位、脚底和色板 pose guide；不产出 modular body/grip。

- [ ] **Step 1: Confirm branch and protected user bytes before staging**

  Run:

  ```bash
  test "$(git branch --show-current)" = "codex_goal"
  shasum -a 256 project.godot .DS_Store docs/.DS_Store docs/design/.DS_Store
  git status --short
  ```

  Expected: 四个 SHA 与 Global Constraints 完全一致；`project.godot` 和三个 `.DS_Store` 都未暂存。

- [ ] **Step 2: Re-run the existing batch's mechanical image checks**

  Run:

  ```bash
  python3 - <<'PY'
  from pathlib import Path
  from PIL import Image

  generated_root = Path("assets/source/generated/c0/xiaodong")
  cleaned_root = Path("assets/source/cleaned/c0/xiaodong")
  generated = sorted(generated_root.rglob("*.png"))
  cleaned = sorted(cleaned_root.rglob("*.png"))
  assert len(generated) == 48, len(generated)
  assert len(cleaned) == 16, len(cleaned)

  for path in generated:
      with Image.open(path) as image:
          if path.name.endswith("_source.png"):
              assert image.size == (1254, 1254), (path, image.size)
              assert image.mode == "RGB", (path, image.mode)
          else:
              assert image.size == (1024, 1024), (path, image.size)
              assert image.mode == "RGBA", (path, image.mode)
              assert all(image.getpixel(point)[3] == 0 for point in ((0, 0), (1023, 0), (0, 1023), (1023, 1023))), path

  for path in cleaned:
      with Image.open(path) as image:
          assert image.size == (128, 128), (path, image.size)
          assert image.mode == "RGBA", (path, image.mode)
          alpha_values = set(image.getchannel("A").getdata())
          assert alpha_values <= {0, 255}, (path, alpha_values)
          assert all(image.getpixel(point)[3] == 0 for point in ((0, 0), (127, 0), (0, 127), (127, 127))), path
          visible = {pixel[:3] for pixel in image.getdata() if pixel[3]}
          assert len(visible) <= 32, (path, len(visible))
          assert not any(g > 240 and r < 32 and b < 32 for r, g, b in visible), path

  print("SINGLE_DIRECTION_GENERATED=48")
  print("SINGLE_DIRECTION_CLEANED=16")
  print("SINGLE_DIRECTION_IMAGE_QA=PASS")
  PY
  ```

  Expected: 三行 PASS 输出；source/preview 为 24 对，cleaned 为 16。

- [ ] **Step 3: Confirm the evidence ledger does not claim eight-direction completion**

  Before the assertions, make these boundary-only edits:

  - in the design card, mark the old “default SE”, four-frame walk and SE QA text as the 2026-07-31 single-direction batch contract;
  - add the approved supplement as the later authority;
  - state that `walk_001–004` are `se` full-arm pose guides and count toward none of 32 body / 48 arm / 24 group / 96 QA;
  - distinguish “six A5 rows at batch time” from the current twelve-item target that will land in Task 4;
  - in the ledger, replace `accepted canonical` wording with historical `accepted_for_concept`;
  - replace the superseded “no more C0 generation until M4” statement with “do not redraw the old candidates; the approved supplement separately authorizes modular eight-direction C0”;
  - explicitly state that this checkpoint is not the user-approved eight-direction contact sheet.

  Run:

  ```bash
  rg -n '24|accepted_for_concept|revise|六项仍为 `planned`|Godot 运行时引用.*0' \
    assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md
  ! rg -n '32 张 canonical|48 张 canonical|96 个.*PASS|八方向.*完成' \
    assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md
  ```

  Expected: 第一条命令命中批次真实结论；第二条命令无命中并退出 0。

- [ ] **Step 4: Confirm no C0 image is referenced by Godot runtime files**

  Run:

  ```bash
  ! rg -n 'assets/source/(generated|cleaned)/c0/xiaodong' \
    --glob '*.gd' --glob '*.tscn' --glob '*.tres' project.godot
  ```

  Expected: 无命中并退出 0。

- [ ] **Step 5: Stage only the historical batch**

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md \
    assets/source/generated/c0/xiaodong/keyposes \
    assets/source/generated/c0/xiaodong/portrait \
    assets/source/cleaned/c0/xiaodong
  git diff --cached --name-only
  test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "62"
  ! git diff --cached --name-only | rg '(^|/)\.DS_Store$|^project\.godot$'
  ```

  Expected: staged 路径只在上述五个资产边界内。

- [ ] **Step 6: Commit the historical concept batch**

  Run:

  ```bash
  git commit -m "art: checkpoint Xiaodong single-direction C0 concepts"
  git status --short
  ```

  Expected: commit 成功；四个用户文件仍留在 unstaged/untracked 状态。

---

### Task 2: Record the single-direction checkpoint and independent review

**Files:**

- Create: `docs/progress/2026-07-31-xiaodong-c0-single-direction.md`

**Interfaces:**

- Consumes: Task 1 commit SHA、24 候选账本、16 cleaned 输出和独立 reviewer 的原始 verdict。
- Produces: 明确写成“历史 pose guide checkpoint”而非八方向完成或里程碑完成的进度记录。

- [ ] **Step 1: Write the checkpoint record with exact evidence**

  Ask a fresh independent reviewer to check only the post-supplement classification boundary: the old `se` four-frame full-arm walk is useful pose evidence, but is not any of the new modular counts or the user visual gate. Record that fresh verdict beside the earlier visual review.

  Create the progress record with these required sections and values:

  ```markdown
  # Xiaodong C0 单方向概念批次进度记录

  - 结论：APPROVED AS HISTORICAL POSE GUIDE
  - 范围：右下方向 master/portrait/idle/walk/hit/death/skill_breakin
  - 候选：24
  - accepted_for_concept：16
  - revise：8
  - cleaned：16 张 128×128 RGBA
  - A5：当时六项仍为 planned
  - Godot 引用：0
  - 后续权威：2026-07-31 八方向/三类握持补充规格

  现有四张右下 walk 图保留为身份、步态、身体宽度、相位和脚底锚点依据。
  因为图中包含完整手臂，它们不能计入新的 32 张 arm-less walk_body，
  也不能计入 48 张 arm layer 或 96 个派生 QA。
  ```

  Append the actual Task 1 commit SHA, the exact commands/output from Task 1, and the independent review verdict. Preserve the reviewer's minor note that Pillow bbox uses half-open `[x0,y0,x1,y1)`.

- [ ] **Step 2: Verify the record's boundary language**

  Run:

  ```bash
  rg -n 'APPROVED AS HISTORICAL POSE GUIDE|候选：24|accepted_for_concept：16|revise：8|cleaned：16|Godot 引用：0' \
    docs/progress/2026-07-31-xiaodong-c0-single-direction.md
  rg -n '不能计入新的 32 张|不能计入 48 张|96 个派生 QA' \
    docs/progress/2026-07-31-xiaodong-c0-single-direction.md
  ! rg -n 'M0.*PASS|八方向.*完成|A5.*approved|A5.*in_game' \
    docs/progress/2026-07-31-xiaodong-c0-single-direction.md
  ```

  Expected: 正向断言命中，负向断言无命中。

- [ ] **Step 3: Commit the checkpoint record independently**

  Run:

  ```bash
  git add docs/progress/2026-07-31-xiaodong-c0-single-direction.md
  git diff --cached --name-only
  git commit -m "docs: record Xiaodong single-direction C0 checkpoint"
  ```

  Expected: 该 commit 只包含一个 progress 文件。

---

### Task 3: Make ContentValidator own the exact twelve-item A5 plan

**Files:**

- Modify: `src/content/content_validator.gd`
- Modify: `tests/unit/test_content_validator.gd`
- Modify: `tests/fixtures/content_validator/full_valid.json`
- Modify: `tests/fixtures/content_validator/g0_valid/assets/asset_manifest.csv`
- Modify: `tests/fixtures/content_validator/governance/corrupt_reference/assets/asset_manifest.csv`
- Modify: `tests/fixtures/content_validator/governance/invalid_card/assets/asset_manifest.csv`
- Modify: `tests/fixtures/content_validator/governance/missing_card/assets/asset_manifest.csv`
- Modify: `tests/fixtures/content_validator/governance/missing_reference/assets/asset_manifest.csv`

**Interfaces:**

- Consumes: approved A5 manifest target and existing AST001–AST007 behavior.
- Produces: `XIAODONG_A5_DELIVERABLES: Dictionary` and `_is_static_directional_bank(row, frames, fps) -> bool`; AST005 validates exact ID and contract, AST006 checks all twelve R2 tuples.

- [ ] **Step 1: Replace the six-state test helper with the exact twelve records**

  In `tests/unit/test_content_validator.gd`, define the expected contract once:

  ```gdscript
  const XIAODONG_A5_DELIVERABLES: Dictionary = {
      "character_xiaodong_idle": {
          "category": "character", "state": "idle",
          "path": "assets/characters/xiaodong/character_xiaodong_idle.png",
          "logical_canvas": "128x128", "pivot": "feet_center",
          "frames": "4", "fps": "5", "direction": "down_right",
          "sprite_layout": "horizontal_4x1",
      },
      "character_xiaodong_walk": {
          "category": "character", "state": "walk",
          "path": "assets/characters/xiaodong/character_xiaodong_walk.png",
          "logical_canvas": "128x128", "pivot": "feet_center",
          "frames": "64", "fps": "10", "direction": "eight_way",
          "sprite_layout": "grid_8x8",
      },
      "character_xiaodong_hit": {
          "category": "character", "state": "hit",
          "path": "assets/characters/xiaodong/character_xiaodong_hit.png",
          "logical_canvas": "128x128", "pivot": "feet_center",
          "frames": "2", "fps": "12", "direction": "down_right",
          "sprite_layout": "horizontal_2x1",
      },
      "character_xiaodong_death": {
          "category": "character", "state": "death",
          "path": "assets/characters/xiaodong/character_xiaodong_death.png",
          "logical_canvas": "128x128", "pivot": "feet_center",
          "frames": "6", "fps": "10", "direction": "down_right",
          "sprite_layout": "horizontal_6x1",
      },
      "character_xiaodong_skill_breakin": {
          "category": "character", "state": "skill_breakin",
          "path": "assets/characters/xiaodong/character_xiaodong_skill_breakin.png",
          "logical_canvas": "128x128", "pivot": "feet_center",
          "frames": "6", "fps": "12", "direction": "down_right",
          "sprite_layout": "horizontal_6x1",
      },
      "portrait_xiaodong": {
          "category": "ui", "state": "portrait",
          "path": "assets/ui/portraits/portrait_xiaodong.png",
          "logical_canvas": "128x128", "pivot": "center",
          "frames": "1", "fps": "0", "direction": "none",
          "sprite_layout": "single",
      },
      "character_xiaodong_grip_pistol_back": {
          "category": "character", "state": "grip_pistol_back",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_back.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
      "character_xiaodong_grip_pistol_front": {
          "category": "character", "state": "grip_pistol_front",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_front.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
      "character_xiaodong_grip_rifle_back": {
          "category": "character", "state": "grip_rifle_back",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_back.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
      "character_xiaodong_grip_rifle_front": {
          "category": "character", "state": "grip_rifle_front",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_front.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
      "character_xiaodong_grip_sniper_back": {
          "category": "character", "state": "grip_sniper_back",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_back.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
      "character_xiaodong_grip_sniper_front": {
          "category": "character", "state": "grip_sniper_front",
          "path": "assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_front.png",
          "logical_canvas": "128x128", "pivot": "shoulder_pivot",
          "frames": "8", "fps": "0", "direction": "eight_way",
          "sprite_layout": "horizontal_8x1",
      },
  }
  const XIAODONG_STATIC_DIRECTIONAL_BANK_IDS: Array[String] = [
      "character_xiaodong_grip_pistol_back",
      "character_xiaodong_grip_pistol_front",
      "character_xiaodong_grip_rifle_back",
      "character_xiaodong_grip_rifle_front",
      "character_xiaodong_grip_sniper_back",
      "character_xiaodong_grip_sniper_front",
  ]
  ```

  Rewrite `_xiaodong_a5_rows()` to iterate sorted dictionary keys, copy the listed fields, then set `phase="A5"`, `subject="xiaodong"`, `status="planned"`, the fixed R2 reference tuple, and sequential `source_line`.

- [ ] **Step 2: Write failing tests for static banks and exact twelve-item identity**

  Add `_test_ast002_allows_only_exact_static_directional_banks()` and call it immediately after the existing AST002 test:

  ```gdscript
  func _test_ast002_allows_only_exact_static_directional_banks(failures: Array[String]) -> void:
      var allowed: Dictionary = _base_snapshot()
      var bank: Dictionary = _valid_asset_row()
      bank["asset_id"] = "character_xiaodong_grip_pistol_back"
      bank["frames"] = "8"
      bank["fps"] = "0"
      bank["direction"] = "eight_way"
      bank["sprite_layout"] = "horizontal_8x1"
      allowed["assets"]["rows"] = [bank]
      _assert_equal(
          _issue_count(_validate(allowed, &"g0"), "AST002"),
          0,
          "An eight-direction static bank must allow eight frames at zero FPS.",
          failures
      )

      for mutation: Dictionary in [
          {"field": "frames", "value": "7"},
          {"field": "direction", "value": "down_right"},
          {"field": "sprite_layout", "value": "grid_8x1"},
          {"field": "asset_id", "value": "unregistered_static_bank"},
      ]:
          var rejected: Dictionary = _base_snapshot()
          var invalid_bank: Dictionary = bank.duplicate(true)
          invalid_bank[mutation["field"]] = mutation["value"]
          rejected["assets"]["rows"] = [invalid_bank]
          _assert_true(
              _has_issue(_validate(rejected, &"g0"), "AST002", String(invalid_bank["asset_id"]), "FPS"),
              "Zero-FPS multi-frame rows must match the exact static directional-bank shape.",
              failures
          )
  ```

  Rewrite `_test_ast005_requires_the_xiaodong_a5_deliverable_set()` so that it asserts:

  ```gdscript
  var complete: Dictionary = _base_snapshot()
  complete["assets"]["rows"] = _xiaodong_a5_rows()
  _assert_equal(_issue_count(_validate(complete, &"g0"), "AST005"), 0, "The exact twelve-item Xiaodong A5 plan must pass.", failures)

  var missing: Dictionary = complete.duplicate(true)
  missing["assets"]["rows"].remove_at(0)
  _assert_true(_has_issue(_validate(missing, &"g0"), "AST005", "xiaodong", "exact"), "One missing asset ID must fail AST005.", failures)

  var wrong_contract: Dictionary = complete.duplicate(true)
  wrong_contract["assets"]["rows"][0]["path"] = "assets/wrong.png"
  _assert_true(_has_issue(_validate(wrong_contract, &"g0"), "AST005", "xiaodong", "contract"), "A matching ID with a wrong field must fail AST005.", failures)
  ```

  Change the real fixture loader assertion from `rows.size() == 6` to `rows.size() == 12` and keep the quoted-comma assertion on its first row.

  Extend AST006 coverage with a grip-row mutation:

  ```gdscript
  var grip_reference_mismatch: Dictionary = _base_snapshot()
  grip_reference_mismatch["assets"]["rows"] = _xiaodong_a5_rows()
  grip_reference_mismatch["assets"]["rows"][11]["reference_rights_policy"] = "original"
  _assert_true(
      _has_issue(_validate(grip_reference_mismatch, &"g0"), "AST006", "xiaodong_reference", "R2"),
      "AST006 must validate the fixed R2 tuple on grip rows too.",
      failures
  )
  ```

- [ ] **Step 3: Run the tests to verify RED**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  ```

  Expected: nonzero exit; new AST002 bank test and exact twelve-item AST005 assertions fail against the six-state validator.

- [ ] **Step 4: Implement the exact production contract**

  In `src/content/content_validator.gd`, replace `XIAODONG_A5_STATES` with the same twelve-entry `XIAODONG_A5_DELIVERABLES` dictionary and six-entry `XIAODONG_STATIC_DIRECTIONAL_BANK_IDS` list from Step 1.

  Add:

  ```gdscript
  static func _is_static_directional_bank(row: Dictionary, frames: int, fps: float) -> bool:
      return (
          row.get("asset_id") in XIAODONG_STATIC_DIRECTIONAL_BANK_IDS
          and
          frames == 8
          and is_zero_approx(fps)
          and row.get("direction") == "eight_way"
          and row.get("sprite_layout") == "horizontal_8x1"
      )
  ```

  Replace the timing condition with:

  ```gdscript
  var valid_single_frame: bool = frames == 1 and is_zero_approx(fps)
  var valid_animation: bool = frames > 1 and fps > 0.0
  var valid_static_bank: bool = _is_static_directional_bank(row, frames, fps)
  if fps < 0.0 or not (valid_single_frame or valid_animation or valid_static_bank):
      issues.append(_issue(
          "ERROR", "AST002", source_path, source_line, asset_id,
          "Asset FPS must describe a single frame, animation, or exact eight-direction static bank.",
          "1 frame/0 FPS, animation/>0 FPS, or 8-frame eight_way horizontal_8x1/0 FPS",
          {"frames": row.get("frames"), "fps": row.get("fps")},
          target_gate
      ))
  ```

  In `_validate_assets()`, collect Xiaodong A5 rows by `asset_id`, reject duplicate/missing/extra IDs, and compare each expected field:

  ```gdscript
  var xiaodong_rows: Dictionary = {}
  for row_value: Variant in rows:
      if not row_value is Dictionary:
          continue
      var row: Dictionary = row_value
      if row.get("phase") == "A5" and row.get("subject") == "xiaodong":
          xiaodong_rows[String(row.get("asset_id", ""))] = row

  var expected_ids: Array[String] = []
  for expected_id: Variant in XIAODONG_A5_DELIVERABLES.keys():
      expected_ids.append(String(expected_id))
  expected_ids.sort()
  var actual_ids: Array[String] = []
  for actual_id: Variant in xiaodong_rows.keys():
      actual_ids.append(String(actual_id))
  actual_ids.sort()

  var contract_reasons: Array[String] = []
  if xiaodong_rows.size() != 12:
      contract_reasons.append("row count differs: expected=12 actual=%d" % xiaodong_rows.size())
  if actual_ids != expected_ids:
      contract_reasons.append("asset IDs differ: expected=%s actual=%s" % [expected_ids, actual_ids])
  for expected_id: String in expected_ids:
      if not xiaodong_rows.has(expected_id):
          continue
      var expected: Dictionary = XIAODONG_A5_DELIVERABLES[expected_id]
      var actual: Dictionary = xiaodong_rows[expected_id]
      for field_value: Variant in expected.keys():
          var field: String = String(field_value)
          if actual.get(field) != expected[field]:
              contract_reasons.append("%s %s differs: expected=%s actual=%s" % [
                  expected_id, field, expected[field], actual.get(field)
              ])
  var has_exact_xiaodong_rows: bool = contract_reasons.is_empty()
  if not has_exact_xiaodong_rows:
      issues.append(_issue(
          "ERROR", "AST005", dataset_config["path"], 0, "xiaodong",
          "A5 Xiaodong must match the exact twelve-item deliverable contract.",
          XIAODONG_A5_DELIVERABLES,
          contract_reasons,
          target_gate
      ))
  ```

  Keep `_validate_xiaodong_governance()` gated by `has_exact_xiaodong_rows`; AST006 will then inspect the fixed reference tuple and `planned` status on all twelve rows.

- [ ] **Step 5: Update every ready-asset fixture to the same twelve records**

  In each of the five CSV files listed under **Files**, replace the six Xiaodong rows with the twelve records from the test dictionary. Keep the fixture-specific corrupt/missing reference and invalid/missing card files unchanged outside the CSV.

  In `tests/fixtures/content_validator/full_valid.json`, replace its six `assets.rows` objects with the same twelve exact IDs and fields, keep `_column_count: 28`, and keep all evidence fields empty.

  Use these exact grip state values:

  ```text
  grip_pistol_back
  grip_pistol_front
  grip_rifle_back
  grip_rifle_front
  grip_sniper_back
  grip_sniper_front
  ```

  All twelve fixture rows must use the fixed `reference_source`, fixed SHA, `reference_rights_policy=R2`, and `status=planned`.

- [ ] **Step 6: Run the focused and complete validator tests to verify GREEN**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  ```

  Expected: exit 0 and `TESTS PASSED`.

- [ ] **Step 7: Commit the validator contract**

  Run:

  ```bash
  git add \
    src/content/content_validator.gd \
    tests/unit/test_content_validator.gd \
    tests/fixtures/content_validator/full_valid.json \
    tests/fixtures/content_validator/g0_valid/assets/asset_manifest.csv \
    tests/fixtures/content_validator/governance/corrupt_reference/assets/asset_manifest.csv \
    tests/fixtures/content_validator/governance/invalid_card/assets/asset_manifest.csv \
    tests/fixtures/content_validator/governance/missing_card/assets/asset_manifest.csv \
    tests/fixtures/content_validator/governance/missing_reference/assets/asset_manifest.csv
  git diff --cached --check
  git diff --cached --name-only
  git commit -m "test: enforce Xiaodong eight-direction asset plan"
  ```

  Expected: only validator and fixture files are committed.

---

### Task 4: Synchronize the authoritative design, production manifest, and design card

**Files:**

- Modify: `docs/design/00_产品宪法.md`
- Modify: `docs/design/04_角色与流派设计.md`
- Modify: `docs/design/08_UI美术音频规范.md`
- Modify: `docs/design/13_素材生产管线与提示词.md`
- Modify: `docs/design/manifest.json`
- Modify: `assets/asset_manifest.csv`
- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`

**Interfaces:**

- Consumes: Task 3 exact twelve-item validator contract and the approved supplement.
- Produces: one independent governance commit that must land before any new direction generation.

- [ ] **Step 1: Capture immutable historical and reference hashes**

  Run:

  ```bash
  wc -c docs/design/GOGO_完整设计文档合集_v0.1.md \
    assets/source/references/characters/xiaodong/reference_01.jpg
  shasum -a 256 docs/design/GOGO_完整设计文档合集_v0.1.md \
    assets/source/references/characters/xiaodong/reference_01.jpg
  ```

  Expected: values match Global Constraints exactly.

- [ ] **Step 2: Update the four authoritative design owners**

  Add the following exact current contract in the document section that already owns Xiaodong or character asset production:

  ```text
  右下只作为 Xiaodong R2 身份种子和历史 pose guide。
  正式 walk 覆盖 n,ne,e,se,s,sw,w,nw 八方向。
  每方向头/后脑、胸腔、骨盆、肩髋轴法线、膝和鞋尖同步转向。
  C0 每方向四相位：contact_l,passing_l,contact_r,passing_r。
  A5 每方向八帧：contact_l,down_l,passing_l,up_l,
  contact_r,down_r,passing_r,up_r。
  pistol(USP/Deagle)、rifle(AK/M4)、sniper(AWP) 各共用一类空手握持。
  body、back_arm、独立 weapon、front_arm 按方向元数据合成。
  角色和握持图始终不显示武器；连续瞄准映射留到 M4 独立批准。
  ```

  Document-specific ownership:

  - `00_产品宪法.md`：替换“默认右下”为“右下身份种子 + walk 八方向”，保留 R2 和 M5 权利门。
  - `04_角色与流派设计.md`：记录 8×4 body、8×3 grip group、两层 arm、pistol/rifle/sniper 适用武器。
  - `08_UI美术音频规范.md`：记录头身同步、固定左上光、左向镜像仅作 guide、角色图不得含武器。
  - `13_素材生产管线与提示词.md`：记录命名、`128×128`、`body_root=(64,114)`、32/48/96、JSON 路径、A5 `grid_8x8` 和 `horizontal_8x1`。

- [ ] **Step 3: Update the production A5 manifest to twelve planned rows**

  Change `character_xiaodong_walk` to:

  ```text
  logical_canvas=128x128
  pivot=feet_center
  frames=64
  fps=10
  status=planned
  notes=body layer; compose with one grip group; no weapon
  direction=eight_way
  sprite_layout=grid_8x8
  source_output=
  cleaned_output=
  qa_record=
  godot_evidence=
  ```

  Add the six exact grip IDs/paths from the approved spec. Each row uses:

  ```text
  phase=A5
  category=character
  subject=xiaodong
  logical_canvas=128x128
  pivot=shoulder_pivot
  frames=8
  fps=0
  prompt_section=6.2
  status=planned
  generation_canvas=1024x1024
  direction=eight_way
  collision_reference=shoulder_pivot
  palette=brown_hair|warm_skin|black_dark_gray_clothing
  reference_source=assets/source/references/characters/xiaodong/reference_01.jpg
  reference_sha256=fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52
  reference_rights_policy=R2
  sprite_layout=horizontal_8x1
  source_output=
  cleaned_output=
  qa_record=
  godot_evidence=
  ```

  Set each `state` to the six exact `grip_*_(back|front)` values from Task 3. Copy the existing Xiaodong R2 negative constraint set and retain `no_weapon`; set notes to `empty-hand <back|front> arm layer; no weapon`.

- [ ] **Step 4: Update the design card without rewriting historical decisions**

  In `character_xiaodong_design.md`:

  - keep `candidate_count=24` until the first new image generation call;
  - keep the 24 existing candidate rows and decisions unchanged;
  - add the approved supplement as current authority;
  - label the four existing `se` walk cleaned frames as full-arm pose guides, not modular outputs;
  - change the current A5 plan from six to twelve `planned` records while explicitly preserving the old batch ledger as a historical snapshot;
  - add the 32 body / 24 groups / 48 arms / 96 QA target and the mandatory post-contact-sheet user pause;
  - keep the machine block boundary as `c0_changes_a5_status=false`, `c0_enters_godot=false`, `a5_status=planned`, `a5_gate=M4`.

- [ ] **Step 5: Recompute design manifest bytes and hashes**

  Run:

  ```bash
  for GOGO_DESIGN_DOC in \
    docs/design/00_产品宪法.md \
    docs/design/04_角色与流派设计.md \
    docs/design/08_UI美术音频规范.md \
    docs/design/13_素材生产管线与提示词.md
  do
    wc -c "$GOGO_DESIGN_DOC"
    shasum -a 256 "$GOGO_DESIGN_DOC"
  done
  ```

  Apply each exact byte count and SHA-256 to its existing record in `docs/design/manifest.json`. Do not change the historical file record.

- [ ] **Step 6: Verify authority and production boundaries**

  Run:

  ```bash
  rg -n 'n,ne,e,se,s,sw,w,nw|contact_l.*passing_l.*contact_r.*passing_r|pistol.*rifle.*sniper|32.*48.*96|不显示武器|M4' \
    docs/design/00_产品宪法.md \
    docs/design/04_角色与流派设计.md \
    docs/design/08_UI美术音频规范.md \
    docs/design/13_素材生产管线与提示词.md \
    assets/characters/xiaodong/character_xiaodong_design.md
  test "$(wc -c < docs/design/GOGO_完整设计文档合集_v0.1.md | tr -d ' ')" = "201645"
  test "$(shasum -a 256 docs/design/GOGO_完整设计文档合集_v0.1.md | awk '{print $1}')" = \
    "50210c784c1d89bbda74d07ee74d842ae90d5fc3012e090449a8cca9b18d3cc6"
  ```

  Expected: current docs contain the approved contract and the historical hash is unchanged.

  Also verify CSV shape and lifecycle:

  ```bash
  python3 - <<'PY'
  import csv

  with open("assets/asset_manifest.csv", newline="", encoding="utf-8") as handle:
      rows = list(csv.DictReader(handle))
  xiaodong = [row for row in rows if row["phase"] == "A5" and row["subject"] == "xiaodong"]
  assert len(rows) == 67, len(rows)
  assert len(xiaodong) == 12, len(xiaodong)
  assert all(row["status"] == "planned" for row in xiaodong)
  assert all(not row[field] for row in xiaodong for field in (
      "source_output", "cleaned_output", "qa_record", "godot_evidence"
  ))
  print("ASSET_ROWS=67")
  print("XIAODONG_A5_ROWS=12")
  print("XIAODONG_A5_LIFECYCLE=PLANNED")
  PY
  ```

- [ ] **Step 7: Run the full Godot and content gates**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    --quit-after 600
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=g0 --format=jsonl
  set +e
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=full --format=jsonl
  GOGO_FULL_STATUS=$?
  set -e
  test "$GOGO_FULL_STATUS" = "1"
  ```

  Expected: tests PASS; smoke exits 0; G0 exits 0 with `gate_status=pass`; full exits 1 only because the future M4/M5 catalogs remain `NOT_READY`.

- [ ] **Step 8: Commit all seven required governance carriers together**

  Run:

  ```bash
  git add \
    docs/design/00_产品宪法.md \
    docs/design/04_角色与流派设计.md \
    docs/design/08_UI美术音频规范.md \
    docs/design/13_素材生产管线与提示词.md \
    docs/design/manifest.json \
    assets/asset_manifest.csv \
    assets/characters/xiaodong/character_xiaodong_design.md
  git diff --cached --check
  git diff --cached --name-only
  git commit -m "docs: govern Xiaodong eight-direction grip production"
  ```

  Expected: one independent governance commit contains exactly the seven approved carriers; no new direction image has been generated before it.

---

### Task 5: Build and test the deterministic C0 QA tool

**Files:**

- Create: `tools/xiaodong_c0_direction_grip.py`
- Create: `tests/tools/test_xiaodong_c0_direction_grip.py`

**Interfaces:**

- Consumes: Pillow images and final metadata path `assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json`.
- Produces:
  - `load_metadata(path: Path) -> dict`
  - `validate_metadata(path: Path, project_root: Path, palette: set[tuple[int,int,int]] = APPROVED_PALETTE_SET) -> list[str]`
  - `expected_composite_keys() -> tuple[str, ...]`
  - `clean_layer(input_path: Path, preview_path: Path, output_path: Path, source_anchor: tuple[int,int], target_anchor: tuple[int,int]) -> Path`
  - `compose_all(metadata_path: Path, project_root: Path, output_dir: Path) -> list[Path]`
  - `build_gate_sheet(cells: dict[str, Path], output_path: Path) -> Path`
  - `build_review_sheet(composites: dict[str, Path], output_path: Path) -> Path`
  - CLI subcommands `clean-layer`, `validate`, `compose-all`, `gate-sheet`, `review-sheet`.

- [ ] **Step 1: Write failing tests for schema, counts, offsets, hashes, PNGs, composition, and gate layout**

  Create a standard-library `unittest` file, not pytest-style free functions, because the repository command uses `unittest discover`. The fixture creates all 80 temporary canonical layers and the exact JSON contract:

  ```python
  import hashlib
  import importlib.util
  import json
  import tempfile
  import unittest
  from pathlib import Path

  from PIL import Image

  REPO_ROOT = Path(__file__).resolve().parents[2]
  MODULE_PATH = REPO_ROOT / "tools/xiaodong_c0_direction_grip.py"
  SPEC = importlib.util.spec_from_file_location("xiaodong_c0_direction_grip", MODULE_PATH)
  if SPEC is None or SPEC.loader is None:
      raise ImportError(f"cannot load {MODULE_PATH}")
  module = importlib.util.module_from_spec(SPEC)
  SPEC.loader.exec_module(module)


  def write_layer(path: Path, color: tuple[int, int, int]) -> str:
      path.parent.mkdir(parents=True, exist_ok=True)
      image = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
      for y in range(40, 88):
          for x in range(48, 80):
              image.putpixel((x, y), (*color, 255))
      image.save(path, optimize=False)
      return hashlib.sha256(path.read_bytes()).hexdigest()


  def build_valid_project(root: Path) -> Path:
      body_layers: dict[str, dict[str, dict]] = {}
      grip_groups: dict[str, dict[str, dict]] = {}
      color = module.APPROVED_PALETTE[0]
      for direction in module.DIRECTIONS:
          body_layers[direction] = {}
          for phase in module.PHASES:
              relative = Path(
                  f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                  f"walk_body/{direction}/body_{direction}_{phase}_cleaned.png"
              )
              digest = write_layer(root / relative, color)
              body_layers[direction][phase] = {
                  "path": relative.as_posix(),
                  "sha256": digest,
                  "root": [64, 114],
              }
          grip_groups[direction] = {}
          for grip in module.GRIPS:
              back = Path(
                  f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                  f"grips/{grip}/{direction}/{grip}_{direction}_back_arm_cleaned.png"
              )
              front = Path(
                  f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                  f"grips/{grip}/{direction}/{grip}_{direction}_front_arm_cleaned.png"
              )
              grip_groups[direction][grip] = {
                  "back_arm_path": back.as_posix(),
                  "back_arm_sha256": write_layer(root / back, color),
                  "front_arm_path": front.as_posix(),
                  "front_arm_sha256": write_layer(root / front, color),
                  "shoulder_pivot": [64, 48],
                  "trigger_hand_anchor": [60, 64],
                  "support_hand_anchor": [72, 64],
                  "weapon_origin": [64, 64],
                  "phase_offsets": {
                      "contact_l": [0, 0],
                      "passing_l": [0, -1],
                      "contact_r": [0, 0],
                      "passing_r": [0, -1],
                  },
                  "occlusion_order": ["back_arm", "body", "weapon", "front_arm"],
              }
      metadata = {
          "schema_version": 1,
          "canvas": {
              "width": 128, "height": 128, "origin": "top_left",
              "x_axis": "right", "y_axis": "down",
          },
          "body_root": [64, 114],
          "direction_order": list(module.DIRECTIONS),
          "c0_phase_order": list(module.PHASES),
          "a5_frame_order": list(module.A5_FRAMES),
          "grip_order": list(module.GRIPS),
          "body_layers": body_layers,
          "grip_groups": grip_groups,
      }
      metadata_path = root / (
          "assets/source/cleaned/c0/xiaodong/"
          "xiaodong_c0_direction_grip_metadata.json"
      )
      metadata_path.parent.mkdir(parents=True, exist_ok=True)
      metadata_path.write_text(
          json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
          encoding="utf-8",
      )
      return metadata_path


  class DirectionGripToolTests(unittest.TestCase):
      def setUp(self) -> None:
          self.temporary = tempfile.TemporaryDirectory()
          self.project_root = Path(self.temporary.name)
          self.metadata_path = build_valid_project(self.project_root)

      def tearDown(self) -> None:
          self.temporary.cleanup()

      def test_expected_composite_keys_are_exact(self) -> None:
          keys = module.expected_composite_keys()
          self.assertEqual(len(keys), 96)
          self.assertEqual(len(set(keys)), 96)
          self.assertEqual(keys[0], "xiaodong_c0_walk_n_contact_l_pistol_qa")
          self.assertEqual(keys[-1], "xiaodong_c0_walk_nw_passing_r_sniper_qa")

      def test_valid_metadata_and_layers_pass(self) -> None:
          self.assertEqual(
              module.validate_metadata(self.metadata_path, self.project_root),
              [],
          )

      def test_metadata_rejects_wrong_top_level_keys(self) -> None:
          data = json.loads(self.metadata_path.read_text(encoding="utf-8"))
          data["unexpected"] = True
          self.metadata_path.write_text(json.dumps(data), encoding="utf-8")
          errors = module.validate_metadata(self.metadata_path, self.project_root)
          self.assertTrue(any("top-level keys" in error for error in errors))

      def test_metadata_rejects_offset_hash_and_occlusion_errors(self) -> None:
          data = json.loads(self.metadata_path.read_text(encoding="utf-8"))
          group = data["grip_groups"]["se"]["rifle"]
          group["phase_offsets"]["passing_l"] = [3, 0]
          group["back_arm_sha256"] = "00"
          group["occlusion_order"] = ["body", "back_arm", "front_arm", "front_arm"]
          self.metadata_path.write_text(json.dumps(data), encoding="utf-8")
          errors = module.validate_metadata(self.metadata_path, self.project_root)
          self.assertTrue(any("phase offset" in error for error in errors))
          self.assertTrue(any("SHA-256" in error for error in errors))
          self.assertTrue(any("occlusion_order" in error for error in errors))

      def test_compose_all_writes_exactly_96_rgba_images(self) -> None:
          output_dir = self.project_root / "qa"
          outputs = module.compose_all(self.metadata_path, self.project_root, output_dir)
          self.assertEqual(len(outputs), 96)
          self.assertEqual(len(list(output_dir.glob("*_qa.png"))), 96)
          with Image.open(outputs[0]) as image:
              self.assertEqual(image.mode, "RGBA")
              self.assertEqual(image.size, (128, 128))

      def test_gate_sheet_has_eleven_review_cells(self) -> None:
          sample = next(self.project_root.rglob("*_cleaned.png"))
          cells = {
              "rifle_n": sample, "rifle_ne": sample,
              "rifle_e": sample, "rifle_se": sample,
              "rifle_s": sample, "rifle_sw": sample,
              "rifle_w": sample, "rifle_nw": sample,
              "se_pistol": sample, "se_rifle": sample, "se_sniper": sample,
          }
          output = module.build_gate_sheet(cells, self.project_root / "gate.png")
          with Image.open(output) as image:
              self.assertEqual(image.mode, "RGBA")
              self.assertEqual(image.size, (1024, 768))

      def test_clean_layer_aligns_anchor_and_uses_shared_palette(self) -> None:
          source = Image.new("RGBA", (1254, 1254), (0, 0, 0, 0))
          for y in range(900, 1000):
              for x in range(580, 680):
                  source.putpixel((x, y), (250, 210, 175, 255))
          source_path = self.project_root / "source.png"
          preview_path = self.project_root / "preview.png"
          output_path = self.project_root / "cleaned.png"
          source.save(source_path)
          module.clean_layer(
              source_path, preview_path, output_path,
              source_anchor=(512, 816), target_anchor=(512, 912),
          )
          with Image.open(preview_path) as preview:
              self.assertEqual(preview.size, (1024, 1024))
          with Image.open(output_path) as cleaned:
              self.assertEqual(cleaned.mode, "RGBA")
              self.assertEqual(cleaned.size, (128, 128))
              self.assertLessEqual(set(cleaned.getchannel("A").getdata()), {0, 255})

      def test_review_sheet_is_direction_by_phase_grip_matrix(self) -> None:
          sample = next(self.project_root.rglob("*_cleaned.png"))
          composites = {key: sample for key in module.expected_composite_keys()}
          output = module.build_review_sheet(composites, self.project_root / "review.png")
          with Image.open(output) as image:
              self.assertEqual(image.mode, "RGBA")
              self.assertEqual(image.size, (1536, 1024))


  if __name__ == "__main__":
      unittest.main()
  ```

- [ ] **Step 2: Run the Python tests to verify RED**

  Run:

  ```bash
  python3 -m unittest discover -s tests/tools -p 'test_*.py' -v
  ```

  Expected: import/file-not-found failure because `tools/xiaodong_c0_direction_grip.py` does not exist.

- [ ] **Step 3: Implement constants, exact enumeration, and metadata loading**

  Start `tools/xiaodong_c0_direction_grip.py` with:

  ```python
  from __future__ import annotations

  import argparse
  import hashlib
  import json
  import sys
  from pathlib import Path
  from typing import Iterable

  from PIL import Image, ImageDraw

  DIRECTIONS = ("n", "ne", "e", "se", "s", "sw", "w", "nw")
  PHASES = ("contact_l", "passing_l", "contact_r", "passing_r")
  A5_FRAMES = (
      "contact_l", "down_l", "passing_l", "up_l",
      "contact_r", "down_r", "passing_r", "up_r",
  )
  GRIPS = ("pistol", "rifle", "sniper")
  TOP_LEVEL_KEYS = {
      "schema_version", "canvas", "body_root", "direction_order",
      "c0_phase_order", "a5_frame_order", "grip_order",
      "body_layers", "grip_groups",
  }
  BODY_RECORD_KEYS = {"path", "sha256", "root"}
  GRIP_RECORD_KEYS = {
      "back_arm_path", "back_arm_sha256",
      "front_arm_path", "front_arm_sha256",
      "shoulder_pivot", "trigger_hand_anchor",
      "support_hand_anchor", "weapon_origin",
      "phase_offsets", "occlusion_order",
  }
  OCCLUSION_TOKENS = {"body", "back_arm", "weapon", "front_arm"}
  APPROVED_PALETTE = (
      (0xfd, 0xd3, 0xb2), (0xfd, 0xcd, 0xab), (0xf8, 0xb7, 0x8e),
      (0xe6, 0x8b, 0x59), (0xc9, 0x6b, 0x3d), (0xb3, 0x55, 0x2e),
      (0x9b, 0x4b, 0x27), (0x7a, 0x44, 0x2e), (0x80, 0x35, 0x1c),
      (0x64, 0x2b, 0x17), (0x3d, 0x31, 0x35), (0x3b, 0x2b, 0x2e),
      (0x35, 0x2b, 0x2f), (0x33, 0x29, 0x2d), (0x30, 0x26, 0x2b),
      (0x2a, 0x23, 0x26), (0x4e, 0x18, 0x0b), (0x30, 0x14, 0x0f),
      (0x26, 0x20, 0x23), (0x26, 0x18, 0x1a), (0x21, 0x1c, 0x1e),
      (0x20, 0x18, 0x1c), (0x1d, 0x16, 0x1a), (0x1d, 0x0e, 0x0e),
      (0x16, 0x12, 0x13), (0x12, 0x0e, 0x0f), (0x10, 0x0b, 0x0d),
      (0x09, 0x09, 0x06), (0x0e, 0x04, 0x05), (0x06, 0x03, 0x04),
      (0x02, 0x03, 0x01), (0x01, 0x00, 0x00),
  )
  APPROVED_PALETTE_SET = set(APPROVED_PALETTE)


  def load_metadata(path: Path) -> dict:
      value = json.loads(path.read_text(encoding="utf-8"))
      if not isinstance(value, dict):
          raise ValueError("metadata root must be an object")
      return value


  def sha256(path: Path) -> str:
      return hashlib.sha256(path.read_bytes()).hexdigest()


  def expected_composite_keys() -> tuple[str, ...]:
      return tuple(
          f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
          for direction in DIRECTIONS
          for phase in PHASES
          for grip in GRIPS
      )
  ```

- [ ] **Step 4: Implement fail-closed metadata and layer validation**

  `validate_metadata()` must append human-readable errors instead of stopping on the first problem. It must enforce:

  ```python
  def is_int_pair(value: object, minimum: int | None = None, maximum: int | None = None) -> bool:
      if not isinstance(value, list) or len(value) != 2:
          return False
      if any(type(component) is not int for component in value):
          return False
      if minimum is not None and any(component < minimum for component in value):
          return False
      if maximum is not None and any(component > maximum for component in value):
          return False
      return True


  def inspect_layer(path: Path, palette: set[tuple[int, int, int]]) -> list[str]:
      errors: list[str] = []
      if not path.is_file():
          return [f"{path}: missing layer"]
      with Image.open(path) as image:
          if image.mode != "RGBA":
              errors.append(f"{path}: mode must be RGBA")
          if image.size != (128, 128):
              errors.append(f"{path}: size must be 128x128")
          rgba = image.convert("RGBA")
          alpha_values = set(rgba.getchannel("A").getdata())
          if not alpha_values <= {0, 255}:
              errors.append(f"{path}: alpha must be binary")
          corners = ((0, 0), (127, 0), (0, 127), (127, 127))
          if any(rgba.getpixel(point)[3] != 0 for point in corners):
              errors.append(f"{path}: all corners must be transparent")
          visible = {pixel[:3] for pixel in rgba.getdata() if pixel[3]}
          if any(g > 240 and r < 32 and b < 32 for r, g, b in visible):
              errors.append(f"{path}: strong green residue is forbidden")
          if not visible <= palette:
              errors.append(f"{path}: visible colors exceed the approved shared palette")
      return errors
  ```

  Implement the fail-closed path and main validators:

  ```python
  def project_file(project_root: Path, value: object) -> Path | None:
      if not isinstance(value, str) or not value:
          return None
      relative = Path(value)
      if relative.is_absolute() or ".." in relative.parts:
          return None
      root = project_root.resolve()
      resolved = (root / relative).resolve()
      if resolved != root and root not in resolved.parents:
          return None
      return resolved


  def validate_metadata(
      path: Path,
      project_root: Path,
      palette: set[tuple[int, int, int]] = APPROVED_PALETTE_SET,
  ) -> list[str]:
      errors: list[str] = []
      try:
          data = load_metadata(path)
      except (OSError, ValueError, json.JSONDecodeError) as error:
          return [f"metadata load failed: {error}"]
      if set(data) != TOP_LEVEL_KEYS:
          errors.append("metadata top-level keys must match the exact schema")
      if data.get("schema_version") != 1:
          errors.append("schema_version must be integer 1")
      expected_canvas = {
          "width": 128, "height": 128, "origin": "top_left",
          "x_axis": "right", "y_axis": "down",
      }
      if data.get("canvas") != expected_canvas:
          errors.append("canvas must match the exact 128x128 top-left screen-coordinate contract")
      if data.get("body_root") != [64, 114]:
          errors.append("body_root must equal [64, 114]")
      for field, expected in (
          ("direction_order", list(DIRECTIONS)),
          ("c0_phase_order", list(PHASES)),
          ("a5_frame_order", list(A5_FRAMES)),
          ("grip_order", list(GRIPS)),
      ):
          if data.get(field) != expected:
              errors.append(f"{field} differs from the fixed order")

      body_layers = data.get("body_layers")
      if not isinstance(body_layers, dict) or set(body_layers) != set(DIRECTIONS):
          errors.append("body_layers must contain the exact eight directions")
          body_layers = {}
      for direction in DIRECTIONS:
          phases = body_layers.get(direction)
          if not isinstance(phases, dict) or set(phases) != set(PHASES):
              errors.append(f"body_layers.{direction} must contain the exact four phases")
              continue
          for phase in PHASES:
              record = phases[phase]
              label = f"body_layers.{direction}.{phase}"
              if not isinstance(record, dict) or set(record) != BODY_RECORD_KEYS:
                  errors.append(f"{label} must use the exact body record keys")
                  continue
              if record.get("root") != [64, 114]:
                  errors.append(f"{label} root must equal [64, 114]")
              layer_path = project_file(project_root, record.get("path"))
              if layer_path is None:
                  errors.append(f"{label} path must be safe and project-relative")
                  continue
              if not layer_path.is_file():
                  errors.append(f"{label} layer is missing")
                  continue
              if record.get("sha256") != sha256(layer_path):
                  errors.append(f"{label} SHA-256 differs from file bytes")
              errors.extend(inspect_layer(layer_path, palette))

      grip_groups = data.get("grip_groups")
      if not isinstance(grip_groups, dict) or set(grip_groups) != set(DIRECTIONS):
          errors.append("grip_groups must contain the exact eight directions")
          grip_groups = {}
      for direction in DIRECTIONS:
          groups = grip_groups.get(direction)
          if not isinstance(groups, dict) or set(groups) != set(GRIPS):
              errors.append(f"grip_groups.{direction} must contain pistol/rifle/sniper")
              continue
          for grip in GRIPS:
              record = groups[grip]
              label = f"grip_groups.{direction}.{grip}"
              if not isinstance(record, dict) or set(record) != GRIP_RECORD_KEYS:
                  errors.append(f"{label} must use the exact grip record keys")
                  continue
              for path_field, digest_field in (
                  ("back_arm_path", "back_arm_sha256"),
                  ("front_arm_path", "front_arm_sha256"),
              ):
                  layer_path = project_file(project_root, record.get(path_field))
                  if layer_path is None:
                      errors.append(f"{label}.{path_field} must be safe and project-relative")
                      continue
                  if not layer_path.is_file():
                      errors.append(f"{label}.{path_field} is missing")
                      continue
                  if record.get(digest_field) != sha256(layer_path):
                      errors.append(f"{label}.{digest_field} SHA-256 differs from file bytes")
                  errors.extend(inspect_layer(layer_path, palette))
              for anchor_field in (
                  "shoulder_pivot", "trigger_hand_anchor",
                  "support_hand_anchor", "weapon_origin",
              ):
                  if not is_int_pair(record.get(anchor_field), 0, 127):
                      errors.append(f"{label}.{anchor_field} must be an integer pair in 0..127")
              offsets = record.get("phase_offsets")
              if not isinstance(offsets, dict) or set(offsets) != set(PHASES):
                  errors.append(f"{label}.phase_offsets must contain the exact four phases")
              else:
                  if offsets.get("contact_l") != [0, 0]:
                      errors.append(f"{label} contact_l phase offset must equal [0, 0]")
                  for phase in PHASES:
                      if not is_int_pair(offsets.get(phase), -2, 2):
                          errors.append(f"{label}.{phase} phase offset must be integer -2..2")
              order = record.get("occlusion_order")
              if (
                  not isinstance(order, list)
                  or len(order) != 4
                  or set(order) != OCCLUSION_TOKENS
              ):
                  errors.append(f"{label}.occlusion_order must contain each token once")
      return errors
  ```

  These loops enforce 32 exact body records, 24 exact grip records, 80 canonical PNGs, safe paths, actual hashes, exact anchors/offsets/orders, RGBA/binary-alpha/transparent-corner/green/palette checks.

- [ ] **Step 5: Implement deterministic layer composition**

  Before composition, implement deterministic mechanical cleaning. It is not allowed to invent or repaint pixels; it only rescales the returned canvas to `1024×1024`, translates a measured source anchor onto the declared target anchor, downsamples with nearest-neighbor, hardens alpha at `128`, retains the largest 8-connected component, and maps each visible RGB value to the nearest `APPROVED_PALETTE` color by squared Euclidean distance.

  ```python
  def nearest_palette_color(rgb: tuple[int, int, int]) -> tuple[int, int, int]:
      return min(
          APPROVED_PALETTE,
          key=lambda color: sum((rgb[index] - color[index]) ** 2 for index in range(3)),
      )


  def retain_largest_eight_connected_component(image: Image.Image) -> Image.Image:
      rgba = image.convert("RGBA")
      visible = {
          (x, y)
          for y in range(rgba.height)
          for x in range(rgba.width)
          if rgba.getpixel((x, y))[3] > 0
      }
      components: list[set[tuple[int, int]]] = []
      while visible:
          seed = visible.pop()
          component = {seed}
          stack = [seed]
          while stack:
              x, y = stack.pop()
              for dy in (-1, 0, 1):
                  for dx in (-1, 0, 1):
                      if dx == 0 and dy == 0:
                          continue
                      neighbor = (x + dx, y + dy)
                      if neighbor in visible:
                          visible.remove(neighbor)
                          component.add(neighbor)
                          stack.append(neighbor)
          components.append(component)
      keep = max(components, key=len) if components else set()
      result = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
      for point in keep:
          result.putpixel(point, rgba.getpixel(point))
      return result


  def clean_layer(
      input_path: Path,
      preview_path: Path,
      output_path: Path,
      source_anchor: tuple[int, int],
      target_anchor: tuple[int, int],
  ) -> Path:
      with Image.open(input_path) as source:
          normalized = source.convert("RGBA").resize((1024, 1024), Image.Resampling.NEAREST)
      dx = target_anchor[0] - source_anchor[0]
      dy = target_anchor[1] - source_anchor[1]
      preview = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
      preview.alpha_composite(normalized, dest=(dx, dy))
      preview_path.parent.mkdir(parents=True, exist_ok=True)
      preview.save(preview_path, optimize=False)
      logical = preview.resize((128, 128), Image.Resampling.NEAREST)
      pixels = []
      for red, green, blue, alpha in logical.getdata():
          if alpha < 128:
              pixels.append((0, 0, 0, 0))
          else:
              mapped = nearest_palette_color((red, green, blue))
              pixels.append((*mapped, 255))
      logical.putdata(pixels)
      logical = retain_largest_eight_connected_component(logical)
      output_path.parent.mkdir(parents=True, exist_ok=True)
      logical.save(output_path, optimize=False)
      return output_path
  ```

  For a body layer, `source_anchor` is the measured feet midpoint/body bottom after the initial `1024×1024` resize and `target_anchor=(512,912)`. For an arm layer, `source_anchor` is the measured shoulder connection and `target_anchor` is the corresponding cleaned body shoulder coordinate multiplied by eight. Record every measured source and target anchor in the batch ledger.

  Use this exact offset and order behavior:

  ```python
  def shifted(layer: Image.Image, offset: list[int]) -> Image.Image:
      result = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
      result.alpha_composite(layer, dest=(offset[0], offset[1]))
      return result


  def compose_one(
      body_path: Path,
      back_arm_path: Path,
      front_arm_path: Path,
      offset: list[int],
      occlusion_order: list[str],
      output_path: Path,
  ) -> Path:
      with Image.open(body_path) as body_image, \
           Image.open(back_arm_path) as back_image, \
           Image.open(front_arm_path) as front_image:
          layers = {
              "body": body_image.convert("RGBA"),
              "back_arm": shifted(back_image.convert("RGBA"), offset),
              "front_arm": shifted(front_image.convert("RGBA"), offset),
          }
          canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
          for token in occlusion_order:
              if token == "weapon":
                  continue
              canvas.alpha_composite(layers[token])
          output_path.parent.mkdir(parents=True, exist_ok=True)
          canvas.save(output_path, optimize=False)
      return output_path
  ```

  Implement the exact direction → phase → grip loop:

  ```python
  def compose_all(
      metadata_path: Path,
      project_root: Path,
      output_dir: Path,
  ) -> list[Path]:
      errors = validate_metadata(metadata_path, project_root)
      if errors:
          raise ValueError("\n".join(errors))
      data = load_metadata(metadata_path)
      outputs: list[Path] = []
      for direction in DIRECTIONS:
          for phase in PHASES:
              body = data["body_layers"][direction][phase]
              for grip in GRIPS:
                  group = data["grip_groups"][direction][grip]
                  key = f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
                  output = output_dir / f"{key}.png"
                  compose_one(
                      project_file(project_root, body["path"]),
                      project_file(project_root, group["back_arm_path"]),
                      project_file(project_root, group["front_arm_path"]),
                      group["phase_offsets"][phase],
                      group["occlusion_order"],
                      output,
                  )
                  outputs.append(output)
      if tuple(path.stem for path in outputs) != expected_composite_keys():
          raise ValueError("composite output order differs from the fixed contract")
      return outputs
  ```

- [ ] **Step 6: Implement the exact visual-gate and full-review contact sheets**

  `build_gate_sheet()` must require exactly these eleven keys:

  ```python
  GATE_LAYOUT = (
      ("rifle_n", "rifle_ne", "rifle_e", "rifle_se"),
      ("rifle_s", "rifle_sw", "rifle_w", "rifle_nw"),
      ("se_pistol", "se_rifle", "se_sniper", "legend"),
  )
  ```

  Create a `1024×768 RGBA` sheet with `256×256` cells. Scale each `128×128` composite to `256×256` using `Image.Resampling.NEAREST`; draw the key on a black rectangle in the top-left. The `legend` cell must contain:

  ```text
  Eight directions: head + torso + hips + feet
  SE comparison: pistol / rifle / sniper
  Empty hands only; weapon node omitted
  ```

  The repeated `se_rifle` review cell points to the same unique composite already used by `rifle_se`; the sheet has eleven review cells but ten unique composites.

  `build_review_sheet()` must require exactly the 96 `expected_composite_keys()`. It creates a `1536×1024 RGBA` matrix with eight `128px` rows in `DIRECTIONS` order and twelve `128px` columns in `PHASES × GRIPS` order. It pastes pixels at 1:1 scale and draws a small semi-opaque label containing `<direction> <phase> <grip>` inside each cell. This sheet is derived QA only.

  Implement both functions:

  ```python
  def build_gate_sheet(cells: dict[str, Path], output_path: Path) -> Path:
      required = {key for row in GATE_LAYOUT for key in row if key != "legend"}
      if set(cells) != required:
          raise ValueError(f"gate cells must equal {sorted(required)}")
      sheet = Image.new("RGBA", (1024, 768), (26, 26, 30, 255))
      draw = ImageDraw.Draw(sheet, "RGBA")
      for row_index, row in enumerate(GATE_LAYOUT):
          for column_index, key in enumerate(row):
              x = column_index * 256
              y = row_index * 256
              if key == "legend":
                  draw.multiline_text(
                      (x + 12, y + 20),
                      "Eight directions: head + torso + hips + feet\n"
                      "SE comparison: pistol / rifle / sniper\n"
                      "Empty hands only; weapon node omitted",
                      fill=(255, 255, 255, 255),
                      spacing=8,
                  )
                  continue
              with Image.open(cells[key]) as image:
                  cell = image.convert("RGBA").resize((256, 256), Image.Resampling.NEAREST)
              sheet.alpha_composite(cell, dest=(x, y))
              draw.rectangle((x, y, x + 150, y + 18), fill=(0, 0, 0, 210))
              draw.text((x + 4, y + 3), key, fill=(255, 255, 255, 255))
      output_path.parent.mkdir(parents=True, exist_ok=True)
      sheet.save(output_path, optimize=False)
      return output_path


  def build_review_sheet(composites: dict[str, Path], output_path: Path) -> Path:
      if set(composites) != set(expected_composite_keys()):
          raise ValueError("review sheet requires the exact 96 composite keys")
      sheet = Image.new("RGBA", (1536, 1024), (26, 26, 30, 255))
      draw = ImageDraw.Draw(sheet, "RGBA")
      for row, direction in enumerate(DIRECTIONS):
          for phase_index, phase in enumerate(PHASES):
              for grip_index, grip in enumerate(GRIPS):
                  column = phase_index * len(GRIPS) + grip_index
                  key = f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
                  with Image.open(composites[key]) as image:
                      cell = image.convert("RGBA")
                  x = column * 128
                  y = row * 128
                  sheet.alpha_composite(cell, dest=(x, y))
                  draw.rectangle((x, y, x + 126, y + 12), fill=(0, 0, 0, 180))
                  draw.text(
                      (x + 2, y + 1),
                      f"{direction} {phase} {grip}",
                      fill=(255, 255, 255, 255),
                  )
      output_path.parent.mkdir(parents=True, exist_ok=True)
      sheet.save(output_path, optimize=False)
      return output_path
  ```

- [ ] **Step 7: Implement CLI exit behavior**

  Support:

  ```text
  python3 tools/xiaodong_c0_direction_grip.py validate --metadata PATH --project-root .
  python3 tools/xiaodong_c0_direction_grip.py clean-layer --input PATH --preview PATH --output PATH --source-anchor X,Y --target-anchor X,Y
  python3 tools/xiaodong_c0_direction_grip.py compose-all --metadata PATH --project-root . --output-dir DIR
  python3 tools/xiaodong_c0_direction_grip.py gate-sheet --cells-json PATH --output PATH
  python3 tools/xiaodong_c0_direction_grip.py review-sheet --input-dir DIR --output PATH
  ```

  `validate` prints each error and exits 1, or prints `C0_DIRECTION_GRIP_QA=PASS` and exits 0. `compose-all` prints `COMPOSITE_COUNT=96`. `gate-sheet` prints its output path and SHA-256.

  Use this parser/dispatcher:

  ```python
  def parse_anchor(value: str) -> tuple[int, int]:
      parts = value.split(",")
      if len(parts) != 2 or not all(part.strip().lstrip("-").isdigit() for part in parts):
          raise argparse.ArgumentTypeError("anchor must be X,Y integers")
      return int(parts[0]), int(parts[1])


  def main(argv: list[str] | None = None) -> int:
      parser = argparse.ArgumentParser()
      commands = parser.add_subparsers(dest="command", required=True)

      validate_parser = commands.add_parser("validate")
      validate_parser.add_argument("--metadata", type=Path, required=True)
      validate_parser.add_argument("--project-root", type=Path, required=True)

      clean_parser = commands.add_parser("clean-layer")
      clean_parser.add_argument("--input", type=Path, required=True)
      clean_parser.add_argument("--preview", type=Path, required=True)
      clean_parser.add_argument("--output", type=Path, required=True)
      clean_parser.add_argument("--source-anchor", type=parse_anchor, required=True)
      clean_parser.add_argument("--target-anchor", type=parse_anchor, required=True)

      compose_parser = commands.add_parser("compose-all")
      compose_parser.add_argument("--metadata", type=Path, required=True)
      compose_parser.add_argument("--project-root", type=Path, required=True)
      compose_parser.add_argument("--output-dir", type=Path, required=True)

      gate_parser = commands.add_parser("gate-sheet")
      gate_parser.add_argument("--cells-json", type=Path, required=True)
      gate_parser.add_argument("--output", type=Path, required=True)
      gate_parser.add_argument("--project-root", type=Path, default=Path("."))

      review_parser = commands.add_parser("review-sheet")
      review_parser.add_argument("--input-dir", type=Path, required=True)
      review_parser.add_argument("--output", type=Path, required=True)

      arguments = parser.parse_args(argv)
      try:
          if arguments.command == "validate":
              errors = validate_metadata(arguments.metadata, arguments.project_root)
              if errors:
                  print("\n".join(errors), file=sys.stderr)
                  return 1
              print("C0_DIRECTION_GRIP_QA=PASS")
          elif arguments.command == "clean-layer":
              clean_layer(
                  arguments.input, arguments.preview, arguments.output,
                  arguments.source_anchor, arguments.target_anchor,
              )
              print(arguments.output.as_posix())
          elif arguments.command == "compose-all":
              outputs = compose_all(
                  arguments.metadata, arguments.project_root, arguments.output_dir,
              )
              print(f"COMPOSITE_COUNT={len(outputs)}")
          elif arguments.command == "gate-sheet":
              raw = json.loads(arguments.cells_json.read_text(encoding="utf-8"))
              cells = {
                  key: project_file(arguments.project_root, value)
                  for key, value in raw.items()
              }
              if any(path is None for path in cells.values()):
                  raise ValueError("gate cell path must be safe and project-relative")
              output = build_gate_sheet(cells, arguments.output)
              print(f"GATE_SHEET={output.as_posix()}")
              print(f"GATE_SHEET_SHA256={sha256(output)}")
          elif arguments.command == "review-sheet":
              composites = {
                  key: arguments.input_dir / f"{key}.png"
                  for key in expected_composite_keys()
              }
              output = build_review_sheet(composites, arguments.output)
              print(f"REVIEW_SHEET={output.as_posix()}")
              print(f"REVIEW_SHEET_SHA256={sha256(output)}")
      except (OSError, ValueError, json.JSONDecodeError) as error:
          print(str(error), file=sys.stderr)
          return 1
      return 0


  if __name__ == "__main__":
      raise SystemExit(main())
  ```

- [ ] **Step 8: Run Python and Godot regressions**

  Run:

  ```bash
  python3 -m unittest discover -s tests/tools -p 'test_*.py' -v
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  ```

  Expected: all Python tests pass and Godot prints `TESTS PASSED`.

- [ ] **Step 9: Commit the deterministic tool**

  Run:

  ```bash
  git add \
    tools/xiaodong_c0_direction_grip.py \
    tests/tools/test_xiaodong_c0_direction_grip.py
  git diff --cached --check
  git commit -m "test: add Xiaodong direction grip QA tooling"
  ```

  Expected: one focused tooling commit with no production images.

---

### Task 6: Produce the eight-direction and three-grip visual gate

**Files:**

- Create: `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`
- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`
- Create: `assets/source/generated/c0/xiaodong/direction_grip/walk_body/{n,ne,e,se,s,sw,w,nw}/*.png`
- Create: `assets/source/generated/c0/xiaodong/direction_grip/grips/rifle/{n,ne,e,se,s,sw,w,nw}/*.png`
- Create: `assets/source/generated/c0/xiaodong/direction_grip/grips/{pistol,sniper}/se/*.png`
- Create: `assets/source/cleaned/c0/xiaodong/direction_grip/walk_body/{n,ne,e,se,s,sw,w,nw}/xiaodong_c0_walk_body_*_contact_l_cleaned.png`
- Create: `assets/source/cleaned/c0/xiaodong/direction_grip/grips/rifle/{n,ne,e,se,s,sw,w,nw}/*.png`
- Create: `assets/source/cleaned/c0/xiaodong/direction_grip/grips/{pistol,sniper}/se/*.png`
- Create: `assets/source/qa/c0/xiaodong/direction_grip/gate/*.png`
- Create: `assets/source/qa/c0/xiaodong/direction_grip/gate/gate_cells.json`

**Interfaces:**

- Consumes: Task 4 approved governance, Task 5 mechanical tool, master 002, stable R2 reference, old `se` walk pose guides.
- Produces: eight `contact_l` body layers, ten grip groups / twenty arm layers, ten unique full-body composites, and an eleven-cell visual-gate sheet.

- [ ] **Step 1: Read the image-generation skill and establish the gate ledger before any call**

  Read `/Users/Carl/.codex/skills/.system/imagegen/SKILL.md` completely. Create the batch ledger with:

  ```text
  authority specs and commit SHAs
  reference path/bytes/dimensions/SHA/R2
  approved master 002 paths and SHA
  direction and phase order
  candidate naming contract
  prompt common block
  per-candidate input order
  generated timestamp/tool
  source/preview/cleaned paths and SHA
  measured source/target anchor
  QA1–QA10 and grip QA
  decision/reason/next-change permission
  canonical and derived counts
  ```

  Start the new-batch candidate count at zero. The design card's global `candidate_count` remains 24 until the first successful image generation call is recorded.

- [ ] **Step 2: Fix the direction language and proposed occlusion order**

  Use these exact visual meanings:

  | ID | Camera-relative body reading |
  |---|---|
  | `n` | screen-up; rear view; back of jaw-length hair and back centered |
  | `ne` | screen-upper-right; rear three-quarter |
  | `e` | screen-right; clean right profile |
  | `se` | screen-lower-right; approved identity three-quarter seed |
  | `s` | screen-down; front-facing top-down |
  | `sw` | screen-lower-left; front three-quarter |
  | `w` | screen-left; clean left profile |
  | `nw` | screen-upper-left; rear three-quarter |

  Use the following proposed occlusion order for all grip classes:

  ```json
  {
    "n":  ["front_arm", "weapon", "body", "back_arm"],
    "ne": ["front_arm", "weapon", "body", "back_arm"],
    "e":  ["back_arm", "body", "weapon", "front_arm"],
    "se": ["back_arm", "body", "weapon", "front_arm"],
    "s":  ["back_arm", "body", "weapon", "front_arm"],
    "sw": ["front_arm", "body", "weapon", "back_arm"],
    "w":  ["front_arm", "body", "weapon", "back_arm"],
    "nw": ["front_arm", "weapon", "body", "back_arm"]
  }
  ```

  `weapon` is an empty slot during C0 composition. The user approves or rejects the visible result in the gate sheet; after approval these orders become the metadata values unless the approval message names a correction.

- [ ] **Step 3: Generate one arm-less `contact_l` body candidate for each direction**

  Make eight separate `imagegen` calls. Each output is one standalone layer candidate, never a sheet. Use master 002 and the stable reference for all calls; additionally use the corresponding old `se` walk frame only for the `se` phase guide.

  Common prompt:

  ```text
  Create one Xiaodong C0 pixel-art WALK BODY LAYER on a perfectly uniform #00ff00
  chroma background. This is an internal modular layer, not a complete character:
  include one complete head and hair, neck, torso, pelvis, two complete legs and two
  complete separate feet; end both shoulders at clean transparent connection edges
  and include no arm, forearm, hand, weapon, prop, guide, marker, shadow, text or effect.
  Preserve the approved master 002 identity and R2 reference: recognizable facial
  relationships when visible, brown jaw-length center-parted medium-short hair, slim
  body, loose plain pure-black short-sleeve shirt, black trousers, black shoes, calm
  restrained presence, compact top-down chibi proportions, fixed upper-left light,
  hard clustered pixels and the approved shared dark/brown/warm-skin palette.
  Pose is anatomical contact_l: the character's anatomical LEFT foot contacts forward
  along the declared screen direction and the anatomical RIGHT foot trails. Keep the
  same body scale and body-root target. The head/face or back-of-head, chest, pelvis,
  shoulder-axis normal, hip-axis normal, both knees and both shoe tips all point to
  the same declared direction. Do not mirror the light. No team logo, sponsor,
  platform/tournament logo, official jersey pattern, tournament UI, trophy, stage,
  watermark, red/orange accent, extra/missing/fused limb, photorealism, vector art,
  3D render or blurry antialiasing.
  ```

  Append exactly one direction sentence from Step 2. Name accepted attempts:

  ```text
  xiaodong_c0_walk_body_<direction>_contact_l_<candidate>_source.png
  xiaodong_c0_walk_body_<direction>_contact_l_<candidate>_preview.png
  ```

  Candidate numbers start at `001` per direction and increment for each retry. Every returned image, including revise, is retained and entered in the ledger.

- [ ] **Step 4: Generate the initial ten grip groups as separate back/front arm candidates**

  Required groups are rifle for all eight directions plus pistol/sniper for `se`. Each group uses two separate calls:

  - candidate `001`: trigger-side `back_arm`, behind the absent weapon;
  - candidate `002`: support-side `front_arm`, in front of the absent weapon.

  Common prompt:

  ```text
  Create one Xiaodong C0 pixel-art ARM LAYER on a perfectly uniform #00ff00 chroma
  background, aligned to the supplied arm-less body reference on the same square
  canvas. Output only ONE anatomically complete shoulder-to-hand arm named by the
  role sentence; all other pixels remain green. Preserve the approved skin, black
  short-sleeve cuff, pixel clusters, upper-left light and scale. The shoulder end must
  connect to the supplied body without a gap or duplicate shoulder. The hand assumes
  an empty-handed invisible-weapon grip: fingers may curl naturally, but there is no
  weapon, transparent weapon, weapon silhouette, prop, guide, anchor cross, line,
  text, shadow or effect. Do not output torso, head, pelvis, legs, the other arm,
  team/sponsor/tournament material, extra fingers, fused anatomy or antialiasing.
  ```

  Append one class sentence:

  ```text
  pistol: compact two-hand spacing; trigger hand close to chest, support hand close enough to cup it.
  rifle: medium two-hand spacing; trigger hand near chest, support hand extended a moderate distance.
  sniper: longest support reach; trigger hand close to shoulder, rear elbow slightly raised but restrained.
  ```

  Append one role sentence:

  ```text
  back_arm: output only the trigger-side arm and trigger hand that belongs behind the absent weapon.
  front_arm: output only the support-side arm and support hand that belongs in front of the absent weapon.
  ```

  Append the direction sentence from Step 2. Name every attempt:

  ```text
  xiaodong_c0_grip_<grip>_<direction>_<candidate>_source.png
  xiaodong_c0_grip_<grip>_<direction>_<candidate>_preview.png
  ```

  In the ledger, the candidate row's role field disambiguates back/front. If a retry is required, use `003`, `004`, and continue monotonically; never overwrite a prior attempt.

- [ ] **Step 5: Remove chroma and mechanically align each accepted gate layer**

  For every returned source, run:

  ```bash
  python3 /Users/Carl/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
    --input INPUT_SOURCE.png \
    --out INPUT_RGBA.png \
    --auto-key border \
    --soft-matte \
    --transparent-threshold 12 \
    --opaque-threshold 220 \
    --despill
  ```

  Inspect `INPUT_RGBA.png`, measure the body feet-midpoint/bottom or arm shoulder connection after a whole-canvas `1024×1024` resize, and record the integer coordinate in the ledger.

  Clean a body with target `(512,912)`:

  ```bash
  python3 tools/xiaodong_c0_direction_grip.py clean-layer \
    --input INPUT_RGBA.png \
    --preview assets/source/generated/c0/xiaodong/direction_grip/walk_body/DIRECTION/xiaodong_c0_walk_body_DIRECTION_contact_l_CANDIDATE_preview.png \
    --output assets/source/cleaned/c0/xiaodong/direction_grip/walk_body/DIRECTION/xiaodong_c0_walk_body_DIRECTION_contact_l_cleaned.png \
    --source-anchor SOURCE_X,SOURCE_Y \
    --target-anchor 512,912
  ```

  For an arm, measure the intended shoulder connection on the accepted cleaned body, multiply that logical coordinate by eight, and use it as `--target-anchor`. Reject and regenerate rather than rescale if the cleaned body visible height is outside `100..104` pixels or the arm proportion no longer matches master 002.

- [ ] **Step 6: Record anchors, phase offsets, and proposed orders for the ten gate groups**

  For every gate group, record integer `shoulder_pivot`, `trigger_hand_anchor`, `support_hand_anchor`, and `weapon_origin`. The trigger/support anchor is the center pixel of the corresponding palm cluster. `weapon_origin` equals `trigger_hand_anchor`, matching the later `trigger_grip_point` alignment. `shoulder_pivot` is the component-wise midpoint of the two measured shoulder connections, with an odd coordinate rounded toward the trigger-side shoulder by `trigger + int((support - trigger) / 2)`.

  Use this exact phase offset map for every group:

  ```json
  {
    "contact_l": [0, 0],
    "passing_l": [0, -1],
    "contact_r": [0, 0],
    "passing_r": [0, -1]
  }
  ```

  The hand-to-abstract-grip error in the gate composite must be at most one logical pixel. Abstract anchor marks are rendered only into temporary QA copies and are absent from all source/preview/cleaned files.

- [ ] **Step 7: Compose ten unique gate results and build the eleven-cell sheet**

  Compose each accepted contact body with its same-direction rifle back/front arms using Task 5's `compose_one()`. Also compose `se` pistol and `se` sniper. Save:

  ```text
  assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_walk_<direction>_contact_l_rifle_qa.png
  assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_walk_se_contact_l_pistol_qa.png
  assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_walk_se_contact_l_sniper_qa.png
  ```

  Write `gate_cells.json` as a JSON object mapping the eleven required gate keys to project-relative paths; `se_rifle` and `rifle_se` intentionally map to the same composite.

  Run:

  ```bash
  python3 tools/xiaodong_c0_direction_grip.py gate-sheet \
    --cells-json assets/source/qa/c0/xiaodong/direction_grip/gate/gate_cells.json \
    --output assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_eight_direction_three_grip_gate.png
  shasum -a 256 \
    assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_eight_direction_three_grip_gate.png
  ```

  Expected: `1024×768 RGBA`; eight rifle direction cells and the `se` pistol/rifle/sniper comparison are readable.

- [ ] **Step 8: Run gate technical and visual pre-review**

  Machine checks:

  ```bash
  python3 - <<'PY'
  from pathlib import Path
  from PIL import Image

  root = Path("assets/source/cleaned/c0/xiaodong/direction_grip")
  bodies = sorted(root.glob("walk_body/*/*_contact_l_cleaned.png"))
  arms = sorted(root.glob("grips/*/*/*_arm_cleaned.png"))
  assert len(bodies) == 8, len(bodies)
  assert len(arms) == 20, len(arms)
  for path in bodies + arms:
      with Image.open(path) as image:
          assert image.mode == "RGBA", (path, image.mode)
          assert image.size == (128, 128), (path, image.size)
          assert set(image.getchannel("A").getdata()) <= {0, 255}, path
          assert all(image.getpixel(point)[3] == 0 for point in ((0, 0), (127, 0), (0, 127), (127, 127))), path
  print("GATE_BODY_COUNT=8")
  print("GATE_ARM_COUNT=20")
  print("GATE_TECH_QA=PASS")
  PY
  ```

  A fresh independent visual reviewer must inspect the gate sheet and individual `128×128` composites for:

  - head/body/hip/knee/shoe direction agreement;
  - anatomical `contact_l`;
  - same identity across front/profile/rear views;
  - complete two arms/two hands/two legs/two feet in composites;
  - distinct pistol/rifle/sniper spacing;
  - no weapon pixels or prohibited R2 material;
  - fixed upper-left light and corrected left directions;
  - acceptable proposed occlusion.

  Fix only findings within this gate subset and retain all revise evidence. Do not generate the other 24 body layers or 14 grip groups.

- [ ] **Step 9: Update candidate counts and commit the visual-gate evidence**

  Set the design card's global `candidate_count` to the exact number of candidate rows across the old and new ledgers. The minimum with no retries is `52` (`24 + 8 body + 20 arm calls`); never write `52` if retries increased the real count.

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md \
    assets/source/generated/c0/xiaodong/direction_grip \
    assets/source/cleaned/c0/xiaodong/direction_grip \
    assets/source/qa/c0/xiaodong/direction_grip/gate
  git diff --cached --check
  ! git diff --cached --name-only | rg '(^|/)\.DS_Store$|^project\.godot$'
  git commit -m "art: add Xiaodong eight-direction visual gate"
  ```

  Expected: the commit contains only gate candidates/layers/QA and their ledgers; no bulk phase or non-SE pistol/sniper files exist.

- [ ] **Step 10: Pause and present the gate sheet to the user**

  Present the exact committed sheet, its SHA-256, the independent pre-review verdict, and a concise note that:

  ```text
  这一步只批准八方向头身母版、contact_l 和三类握持间距/遮挡。
  批准前不会生成剩余 24 个 body layer 或 14 个 grip group。
  ```

  Stop execution here. A response that only approves the written specification does not satisfy this visual gate.

---

### Task 7: Record the user's visual-gate decision

**Files:**

- Create: `docs/progress/2026-07-31-xiaodong-eight-direction-gate.md`
- Modify when revisions are requested: gate-only paths from Task 6

**Interfaces:**

- Consumes: user's explicit reaction to the committed contact sheet.
- Produces: an auditable approval commit that authorizes Tasks 8–12, or a gate-only revision loop that remains paused.

- [ ] **Step 1: Classify the user's response without inference**

  Proceed only if the user explicitly approves the displayed eight-direction + three-grip gate. If the user names visual changes, generate and review only the affected gate candidates, commit the revised gate, show the new sheet, and pause again. Do not interpret silence, written-spec approval, or approval of master 002 as gate approval.

- [ ] **Step 2: Write the exact approval record**

  Record:

  ```text
  gate commit SHA
  gate sheet project-relative path
  gate sheet SHA-256
  displayed dimensions 1024×768
  eight direction IDs
  three grip classes
  proposed occlusion-order map
  independent pre-review verdict
  user's exact approval text and timestamp
  authorization: remaining 24 body layers and 14 grip groups
  exclusions: no A5, no Godot runtime, no M0 verdict, no M5 rights decision
  ```

- [ ] **Step 3: Verify and commit the gate decision**

  Run:

  ```bash
  rg -n '1024×768|n,ne,e,se,s,sw,w,nw|pistol.*rifle.*sniper|24.*body|14.*grip|用户原文|SHA-256' \
    docs/progress/2026-07-31-xiaodong-eight-direction-gate.md
  git add docs/progress/2026-07-31-xiaodong-eight-direction-gate.md
  git diff --cached --name-only
  git commit -m "docs: record Xiaodong direction grip gate approval"
  ```

  Expected: a single progress-record commit. Tasks 8–12 remain unauthorized unless this commit cites a real explicit user approval.

---

### Task 8: Complete the remaining twenty-four walk-body layers

**Files:**

- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`
- Modify: `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`
- Create: `assets/source/generated/c0/xiaodong/direction_grip/walk_body/{n,ne,e,se,s,sw,w,nw}/*_{passing_l,contact_r,passing_r}_*.png`
- Create: `assets/source/cleaned/c0/xiaodong/direction_grip/walk_body/{n,ne,e,se,s,sw,w,nw}/*_{passing_l,contact_r,passing_r}_cleaned.png`

**Interfaces:**

- Consumes: Task 7 approved `contact_l` identities and direction silhouettes.
- Produces: exact 32 canonical arm-less body layers, four phases per direction.

- [ ] **Step 1: Dispatch only disjoint image directories**

  With subagents, partition directions without shared writes:

  ```text
  worker A: n, ne, e
  worker B: se, s, sw
  worker C: w, nw
  root: ledger merge, design-card count, review and commits
  ```

  Workers write only their assigned generated/cleaned direction directories and return a structured candidate report. Only root edits the design card or batch ledger.

- [ ] **Step 2: Generate the three missing phases for every direction**

  Use the accepted same-direction `contact_l` body as first reference, master 002 as identity reference, and the stable R2 reference. Reuse Task 6's arm-less body common prompt, replacing the phase paragraph with exactly one:

  ```text
  passing_l: anatomical LEFT foot bears weight under the pelvis; anatomical RIGHT knee bends and the RIGHT foot lifts past the support leg; no contact-stride duplication.
  contact_r: anatomical RIGHT foot contacts forward; anatomical LEFT leg trails; reverse the leg phase without mirroring head, torso, camera or upper-left light.
  passing_r: anatomical RIGHT foot bears weight under the pelvis; anatomical LEFT knee bends and the LEFT foot lifts past the support leg; no contact-stride duplication.
  ```

  Keep direction fixed. Name source/preview/cleaned files exactly per the approved naming contract. Retain every retry and record why it is `revise`.

- [ ] **Step 3: Mechanically clean and align to the same root**

  Use Task 5 `clean-layer` with `target-anchor=512,912` for every accepted body. Do not crop the logical canvas. Reject a candidate if:

  - visible height is outside `100..104` logical pixels;
  - feet midpoint/body bottom does not resolve to `[64,114]`;
  - shoulder connection moves without a documented phase reason;
  - head/torso direction changes from the approved contact seed;
  - anatomical left/right phase is ambiguous;
  - any arm below the shoulder, weapon or forbidden material remains.

- [ ] **Step 4: Verify the exact 8×4 body matrix**

  Run:

  ```bash
  python3 - <<'PY'
  from pathlib import Path
  from PIL import Image

  directions = ("n", "ne", "e", "se", "s", "sw", "w", "nw")
  phases = ("contact_l", "passing_l", "contact_r", "passing_r")
  root = Path("assets/source/cleaned/c0/xiaodong/direction_grip/walk_body")
  paths = []
  for direction in directions:
      for phase in phases:
          matches = list((root / direction).glob(f"xiaodong_c0_walk_body_{direction}_{phase}_cleaned.png"))
          assert len(matches) == 1, (direction, phase, matches)
          paths.extend(matches)
  assert len(paths) == 32
  for path in paths:
      with Image.open(path) as image:
          assert image.mode == "RGBA"
          assert image.size == (128, 128)
          assert set(image.getchannel("A").getdata()) <= {0, 255}
  print("BODY_MATRIX=8x4")
  print("BODY_COUNT=32")
  print("BODY_TECH_QA=PASS")
  PY
  ```

  A fresh visual reviewer checks each four-frame row as `contact_l → passing_l → contact_r → passing_r`, with special attention to anatomical left/right on rear views.

- [ ] **Step 5: Merge records, recompute candidate count, and commit bodies**

  Root appends every body attempt to the new ledger, recomputes the design card's global candidate count from both ledgers, and records the body reviewer verdict.

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md \
    assets/source/generated/c0/xiaodong/direction_grip/walk_body \
    assets/source/cleaned/c0/xiaodong/direction_grip/walk_body
  git diff --cached --check
  git commit -m "art: complete Xiaodong eight-direction walk bodies"
  ```

  Expected: exactly 32 canonical cleaned body layers are present after the commit.

---

### Task 9: Complete the remaining fourteen grip groups

**Files:**

- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`
- Modify: `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`
- Create: `assets/source/generated/c0/xiaodong/direction_grip/grips/{pistol,sniper}/{n,ne,e,s,sw,w,nw}/*.png`
- Create: `assets/source/cleaned/c0/xiaodong/direction_grip/grips/{pistol,sniper}/{n,ne,e,s,sw,w,nw}/*.png`

**Interfaces:**

- Consumes: Task 7 approved `se` grip spacing and all eight approved body directions.
- Produces: exact 24 grip groups and 48 canonical arm-layer PNGs.

- [ ] **Step 1: Enumerate the only missing groups**

  The gate already contains all eight rifle groups and `se` pistol/sniper. Generate only:

  ```text
  pistol: n, ne, e, s, sw, w, nw
  sniper: n, ne, e, s, sw, w, nw
  ```

  This is 14 groups and 28 accepted back/front arm layers. Do not regenerate rifle or `se` unless an approved gate correction explicitly requires it.

- [ ] **Step 2: Generate back/front arms from approved class and direction references**

  For each missing group, use:

  1. same-direction accepted `contact_l` body;
  2. approved `se` candidate for the same grip and arm role;
  3. approved same-direction rifle arm for direction/occlusion only;
  4. master 002 and stable R2 reference.

  Use Task 6's exact arm prompt, grip descriptor, role sentence and naming. The same-direction rifle reference must not collapse pistol/sniper spacing into rifle spacing.

- [ ] **Step 3: Align, anchor, and validate each group**

  Clean with Task 5 `clean-layer`, targeting the same-direction body shoulder coordinate. Record all four anchors, the uniform phase offset map, and the approved direction occlusion order.

  Reject if:

  - either arm/hand is incomplete or has extra/fused fingers;
  - pistol does not remain the most compact spacing;
  - sniper does not have the longest support reach;
  - a shoulder join exceeds one logical pixel gap/overlap;
  - an anchor is non-integer/outside `0..127`;
  - abstract trigger/support grip error exceeds one pixel;
  - any weapon pixel, guide, marker or prohibited R2 material remains.

- [ ] **Step 4: Verify the exact 8×3×2 arm matrix**

  Run:

  ```bash
  python3 - <<'PY'
  from pathlib import Path
  from PIL import Image

  directions = ("n", "ne", "e", "se", "s", "sw", "w", "nw")
  grips = ("pistol", "rifle", "sniper")
  roles = ("back_arm", "front_arm")
  root = Path("assets/source/cleaned/c0/xiaodong/direction_grip/grips")
  paths = []
  for direction in directions:
      for grip in grips:
          for role in roles:
              pattern = f"xiaodong_c0_grip_{grip}_{direction}_{role}_cleaned.png"
              matches = list((root / grip / direction).glob(pattern))
              assert len(matches) == 1, (direction, grip, role, matches)
              paths.extend(matches)
  assert len(paths) == 48
  for path in paths:
      with Image.open(path) as image:
          assert image.mode == "RGBA"
          assert image.size == (128, 128)
          assert set(image.getchannel("A").getdata()) <= {0, 255}
  print("GRIP_GROUP_COUNT=24")
  print("ARM_LAYER_COUNT=48")
  print("ARM_TECH_QA=PASS")
  PY
  ```

  A fresh visual reviewer compares all three classes per direction and verifies that the approved class hierarchy survives rear/profile/front views.

- [ ] **Step 5: Merge records, recompute candidate count, and commit grips**

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md \
    assets/source/generated/c0/xiaodong/direction_grip/grips \
    assets/source/cleaned/c0/xiaodong/direction_grip/grips
  git diff --cached --check
  git commit -m "art: complete Xiaodong three-class grip layers"
  ```

  Expected: exactly 24 groups / 48 accepted canonical arm layers exist after the commit.

---

### Task 10: Build final metadata and all ninety-six deterministic composites

**Files:**

- Create: `assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json`
- Create: `assets/source/qa/c0/xiaodong/direction_grip/composites/*.png`
- Create: `assets/source/qa/c0/xiaodong/direction_grip/xiaodong_c0_direction_grip_review_sheet.png`
- Modify: `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`

**Interfaces:**

- Consumes: 32 body layers, 48 arm layers, recorded anchors/offsets/orders and Task 5 tool.
- Produces: schema-version-1 metadata, exact 96 named QA composites, one `1536×1024` review sheet, deterministic rebuild evidence.

- [ ] **Step 1: Write the exact metadata object**

  The JSON top level must contain only:

  ```json
  {
    "schema_version": 1,
    "canvas": {
      "width": 128,
      "height": 128,
      "origin": "top_left",
      "x_axis": "right",
      "y_axis": "down"
    },
    "body_root": [64, 114],
    "direction_order": ["n", "ne", "e", "se", "s", "sw", "w", "nw"],
    "c0_phase_order": ["contact_l", "passing_l", "contact_r", "passing_r"],
    "a5_frame_order": [
      "contact_l", "down_l", "passing_l", "up_l",
      "contact_r", "down_r", "passing_r", "up_r"
    ],
    "grip_order": ["pistol", "rifle", "sniper"],
    "body_layers": {},
    "grip_groups": {}
  }
  ```

  Populate `body_layers[direction][phase]` with exact project-relative path, actual SHA-256 and `root:[64,114]`. Populate `grip_groups[direction][grip]` with the exact record fields defined by the specification and Task 5. Do not include timestamps, review prose, candidate IDs or derived QA paths in this machine JSON.

- [ ] **Step 2: Validate metadata before composition**

  Run:

  ```bash
  python3 tools/xiaodong_c0_direction_grip.py validate \
    --metadata assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json \
    --project-root .
  ```

  Expected: exit 0 and `C0_DIRECTION_GRIP_QA=PASS`. Fix the metadata or canonical layer; do not weaken the validator.

- [ ] **Step 3: Generate all 96 full-body empty-hand QA composites**

  Run:

  ```bash
  python3 tools/xiaodong_c0_direction_grip.py compose-all \
    --metadata assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json \
    --project-root . \
    --output-dir assets/source/qa/c0/xiaodong/direction_grip/composites
  python3 tools/xiaodong_c0_direction_grip.py review-sheet \
    --input-dir assets/source/qa/c0/xiaodong/direction_grip/composites \
    --output assets/source/qa/c0/xiaodong/direction_grip/xiaodong_c0_direction_grip_review_sheet.png
  ```

  Expected: `COMPOSITE_COUNT=96`; sheet is `1536×1024 RGBA`.

- [ ] **Step 4: Prove deterministic reconstruction**

  Run:

  ```bash
  GOGO_REBUILD_DIR="$(mktemp -d)"
  python3 tools/xiaodong_c0_direction_grip.py compose-all \
    --metadata assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json \
    --project-root . \
    --output-dir "$GOGO_REBUILD_DIR"
  diff \
    <(cd assets/source/qa/c0/xiaodong/direction_grip/composites && shasum -a 256 *.png | sort) \
    <(cd "$GOGO_REBUILD_DIR" && shasum -a 256 *.png | sort)
  ```

  Expected: `diff` has no output. Leave the temporary directory outside the repository; no cleanup is required for repository correctness.

- [ ] **Step 5: Run per-composite technical QA**

  Run:

  ```bash
  python3 - <<'PY'
  from pathlib import Path
  from PIL import Image

  root = Path("assets/source/qa/c0/xiaodong/direction_grip/composites")
  paths = sorted(root.glob("*_qa.png"))
  assert len(paths) == 96, len(paths)
  assert len({path.name for path in paths}) == 96
  for path in paths:
      with Image.open(path) as image:
          assert image.mode == "RGBA", (path, image.mode)
          assert image.size == (128, 128), (path, image.size)
          assert set(image.getchannel("A").getdata()) <= {0, 255}, path
          assert all(image.getpixel(point)[3] == 0 for point in ((0, 0), (127, 0), (0, 127), (127, 127))), path
  print("FULL_BODY_QA_COUNT=96")
  print("FULL_BODY_TECH_QA=PASS")
  PY
  ```

- [ ] **Step 6: Record hashes and commit metadata plus derived QA**

  Record the metadata SHA, review-sheet SHA, composite hash-list SHA and rebuild command in the batch ledger.

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md \
    assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json \
    assets/source/qa/c0/xiaodong/direction_grip/composites \
    assets/source/qa/c0/xiaodong/direction_grip/xiaodong_c0_direction_grip_review_sheet.png
  git diff --cached --check
  git commit -m "art: add Xiaodong grip metadata and composite QA"
  ```

  Expected: canonical counts remain 32 body + 48 arms; the 96 committed QA images remain explicitly derived, not canonical or A5.

---

### Task 11: Perform final visual, content, and boundary reviews

**Files:**

- Modify: `assets/characters/xiaodong/character_xiaodong_design.md`
- Modify: `assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md`

**Interfaces:**

- Consumes: complete metadata, layers, 96 composites, user gate approval and all prior commits.
- Produces: final reviewed design-card/ledger state with no unreviewed candidate or contract mismatch.

- [ ] **Step 1: Reconcile candidate and artifact counts**

  Count candidate rows in both ledgers and set the machine block's `candidate_count` to the exact total. The new ledger must separately report:

  ```text
  generated calls = all source candidates, including revise
  accepted body layers = 32
  accepted grip groups = 24
  accepted arm layers = 48
  derived composites = 96
  derived gate cells = 11 review cells / 10 unique composites
  A5 current plan = 12 planned
  Godot runtime references = 0
  ```

  Do not count previews, cleaned derivatives or QA composites as generation calls.

- [ ] **Step 2: Run a fresh independent visual review of all 96 composites**

  Provide the reviewer with the approved spec, metadata, full review sheet and permission to inspect individual files. Require a verdict for:

  1. all eight direction IDs match head/body/hips/knees/shoes;
  2. all four anatomical gait phases are correct in every direction;
  3. every composite is complete full-body anatomy;
  4. pistol/rifle/sniper spacing remains distinct;
  5. arm/body/empty weapon slot/front-arm occlusion is coherent;
  6. identity, scale, left-up light and shared palette are stable;
  7. no direct mirrored-light/identity artifact;
  8. no weapon pixel, anchor mark or prohibited R2 material;
  9. `128×128` direction and phase remain readable;
  10. every finding names exact direction/phase/grip and severity.

  Critical or Important findings must be corrected and all affected 96 composites regenerated. Minor findings must be recorded with a disposition; do not silently omit them.

- [ ] **Step 3: Run an independent code/content review**

  A separate reviewer checks:

  - validator exception is restricted to the six registered grip bank IDs;
  - AST005 owns exact IDs and fields;
  - all five CSV fixtures and `full_valid.json` use twelve records;
  - metadata schema/path/SHA/count validation fails closed;
  - composite order and offsets are deterministic;
  - A5 rows remain planned with evidence empty;
  - C0 has no Godot runtime references;
  - historical design file and user dirty hashes are unchanged;
  - scope did not expand to A5, continuous aim or M0.

  Resolve all Critical/Important code findings under the `receiving-code-review` workflow and rerun the affected tests.

- [ ] **Step 4: Run the complete fresh verification matrix**

  Run:

  ```bash
  python3 -m unittest discover -s tests/tools -p 'test_*.py' -v
  python3 tools/xiaodong_c0_direction_grip.py validate \
    --metadata assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json \
    --project-root .
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    --quit-after 600
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=g0 --format=jsonl
  set +e
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=full --format=jsonl
  GOGO_FULL_STATUS=$?
  set -e
  test "$GOGO_FULL_STATUS" = "1"
  ! rg -n 'assets/source/(generated|cleaned|qa)/c0/xiaodong/direction_grip' \
    --glob '*.gd' --glob '*.tscn' --glob '*.tres' project.godot
  test "$(wc -c < docs/design/GOGO_完整设计文档合集_v0.1.md | tr -d ' ')" = "201645"
  test "$(shasum -a 256 docs/design/GOGO_完整设计文档合集_v0.1.md | awk '{print $1}')" = \
    "50210c784c1d89bbda74d07ee74d842ae90d5fc3012e090449a8cca9b18d3cc6"
  shasum -a 256 project.godot .DS_Store docs/.DS_Store docs/design/.DS_Store
  ```

  Expected:

  - Python tests PASS;
  - C0 tool PASS;
  - Godot tests PASS;
  - smoke exits 0;
  - G0 exits 0 with no ERROR;
  - full exits 1 only with expected future `NOT_READY`, no ERROR;
  - runtime reference search is empty;
  - protected hashes match Global Constraints.

- [ ] **Step 5: Commit the reconciled design card and ledger**

  Run:

  ```bash
  git add \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/characters/xiaodong/xiaodong_c0_direction_grip_batch_2026-07-31.md
  git diff --cached --check
  git commit -m "docs: reconcile Xiaodong direction grip evidence"
  ```

  Expected: this commit contains only the final evidence owners and review dispositions.

---

### Task 12: Record completion of the C0 supplement without closing the project goal

**Files:**

- Create: `docs/progress/2026-07-31-xiaodong-eight-direction-grip.md`

**Interfaces:**

- Consumes: all committed asset/tool/governance SHAs, user visual approval, verification outputs and two independent reviews.
- Produces: one final progress record for this C0 supplement; hands control back to M0 Windows evidence work.

- [ ] **Step 1: Write the final progress record**

  Include:

  ```text
  authority spec SHAs
  plan SHA
  historical pose-guide commit and record SHA
  validator contract SHA
  governance sync SHA
  tooling SHA
  visual gate asset SHA
  user's exact visual approval and gate-record SHA
  body/grip/metadata/evidence SHAs
  32 body / 24 groups / 48 arms / 96 composites
  candidate accepted/revise counts
  metadata and review-sheet SHA
  exact commands, exit codes and summary lines
  visual review verdict and findings/dispositions
  code/content review verdict and findings/dispositions
  A5 twelve rows all planned
  Godot references zero
  protected user/historical hashes
  known deferrals: A5 interpolation/sheets, continuous aim, Godot import, M5 rights
  explicit statement: this is not M0/M1–M5/Mac 1.0 or /goal completion
  ```

- [ ] **Step 2: Verify the record against repository facts**

  Run:

  ```bash
  rg -n '32.*body|24.*grip|48.*arm|96.*QA|十二.*planned|Godot.*0|用户原文|APPROVED' \
    docs/progress/2026-07-31-xiaodong-eight-direction-grip.md
  rg -n 'A5.*defer|continuous aim|M4|M5|不代表.*M0|不代表.*/goal' \
    docs/progress/2026-07-31-xiaodong-eight-direction-grip.md
  ! rg -n 'A5.*in_game|M0.*PASSED|/goal.*完成|Mac 1\\.0.*完成' \
    docs/progress/2026-07-31-xiaodong-eight-direction-grip.md
  ```

  Expected: all positive facts are present and no forbidden completion claim appears.

- [ ] **Step 3: Commit the progress record independently**

  Run:

  ```bash
  git add docs/progress/2026-07-31-xiaodong-eight-direction-grip.md
  git diff --cached --name-only
  git commit -m "docs: record Xiaodong direction grip C0 acceptance"
  ```

  Expected: exactly one progress file is committed.

- [ ] **Step 4: Hand back to the milestone sequence**

  Report this supplement as complete only if Task 12's record cites all evidence. Keep `/goal` active. The next milestone action is to obtain or rerun the missing Windows M0 raw evidence for at least three testers and an independent M0 review; do not mark M0 passed from the prior summary alone.
