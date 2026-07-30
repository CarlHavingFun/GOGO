# G0 Design Governance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地 GOGO 的 G0 设计治理，使 G0–M5、R2、内容 ID、运行状态所有权、素材状态、设计文档 manifest 和 ContentValidator 形成一套可自动验证的权威基线。

**Architecture:** `docs/design/` 继续作为唯一权威 GDD，`manifest.json` 枚举并校验其中全部 Markdown；`assets/asset_manifest.csv` 管理 A0–A5 正式素材，C0 候选只由“小洞大人”设计卡管理。Godot 原生 `ContentSnapshotLoader` 负责把 JSON/CSV/Resource 规范化为 snapshot，`ContentValidator` 以 `g0` 与 `full` 两种 profile 分别报告当前门禁和完整内容目录状态，避免把尚不存在的 47 升级、20 波数据假报为通过。

**Tech Stack:** Godot `4.7.1.stable.official.a13da4feb`、强类型 GDScript、Godot `FileAccess`/`JSON`/`DirAccess`、现有 `SceneTree` 测试运行器、Markdown、JSON、CSV。

## Global Constraints

- 当前工作必须留在 `codex_goal`，不得切换或新建其他分支。
- 权威基线是 `docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md` 和用户在 2026-07-30 的 `/goal` 批准指令。
- R2 只适用于用户指定参考图的职业选手角色；参考图优先保留可识别神似，但必须去除战队 Logo、赞助商、平台/赛事 Logo、官方队服图案、官方赛事 UI/舞台/水印。
- 本计划只完成 G0 治理和 C0 生产准备；不生成 C0 图、不把 C0 导入 Godot、不实现 M1 敌人/波次/升级/商店。
- C0 的 `accepted_for_concept` 只属于设计卡决定；正式 manifest 的 `state` 列只表示动作/变体（如 `idle`、`walk`），`status` 列才表示生命周期且只能是 `planned|generated|cleaned|approved|in_game|rejected`。
- A5 的“小洞大人”六项正式资产保持 `planned`，直到 M4 入口门通过。
- 不修改用户现有未提交的 `project.godot` 空 `[autoload]` 区段，不删除或暂存三个现有 `.DS_Store`。
- 每次提交只显式暂存本任务列出的文件；提交前后都运行 `git status --short` 核对用户改动仍在。
- 本计划文件必须在 Task 1 开始前以独立 `docs: plan G0 design governance` 提交，不得作为未跟踪文件遗留到 G0 Review。
- Godot 命令统一使用 `/Users/Carl/Applications/Godot.app/Contents/MacOS/Godot`，测试时使用 `--headless --audio-driver Dummy --path .`。
- `g0` profile 必须退出 0 并输出 `gate_status=pass`；`full` profile 在完整玩法数据尚未落地时必须退出 1 并输出 `catalog_status=not_ready`，不得笼统输出“全部内容通过”。
- `docs/design/GOGO_完整设计文档合集_v0.1.md` 标记为 `historical`，`docs/design/兼容性要求规范.md` 标记为 `auxiliary`；两者都必须由设计 manifest 枚举，但历史合集中的旧口径不再具有权威性。
- 所有新增路径使用项目相对路径或 `res://`；不得写入 Windows/macOS 绝对路径作为运行时资源引用。

---

### Task 1: Unify the authoritative design baseline

**Files:**

- Modify: `docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`
- Modify: `CODEX_START.md`
- Modify: `docs/design/README_设计文档索引.md`
- Modify: `docs/design/00_产品宪法.md`
- Modify: `docs/design/01_核心循环与20波流程.md`
- Modify: `docs/design/03_投掷物与状态系统.md`
- Modify: `docs/design/04_角色与流派设计.md`
- Modify: `docs/design/05_技能与奖励池.md`
- Modify: `docs/design/06_怪物与波次设计.md`
- Modify: `docs/design/07_经济与局外成长.md`
- Modify: `docs/design/08_UI美术音频规范.md`
- Modify: `docs/design/10_平衡测试规范.md`
- Modify: `docs/design/11_开发里程碑.md`
- Modify: `docs/design/12_游戏性与素材Review.md`
- Modify: `docs/design/13_素材生产管线与提示词.md`
- Modify: `assets/README.md`

**Interfaces:**

- Consumes: 已批准规格中的 G0–M5 表、R2 §2、玩法修订 §10、状态所有权与 ID §11、验证门槛 §12。
- Produces: 后续代码、manifest 和验收记录引用的唯一术语、状态与门禁定义。

- [ ] **Step 1: Record approval and current evidence without inventing facts**

  把规格头部状态改为“已由用户 `/goal` 书面批准（2026-07-30）”。保留规格中“M0 手工清单尚未勾选”的历史快照，并追加实施注记：用户随后报告 Windows 验收完成，但 G0 不把缺失的三名测试者报告、硬件、build 和 Review 元数据推定为已存在。

  同一注记明确允许以下 TDD 顺序细化，而不改变规格交付顺序：Validator kernel 可以先针对合成 fixture 开发；只有步骤 1–5 的文档、正式 manifest、稳定参考和设计卡全部落地后才运行生产 G0 门；C0 生成仍严格在生产 G0 门通过之后。

- [ ] **Step 2: Replace every authoritative milestone definition with the exact G0–M5 model**

  在 `CODEX_START.md`、索引、宪法、Review 和里程碑文档中统一使用：

  ```text
  G0 设计治理
  M0 射击玩具
  M1 五波闭环（M1A 三敌三波；M1B 赏金/升级/商店五波；M1C 重开/遥测/复现）
  M2 角色与战术
  M3 十波垂直切片
  M4 二十波 Alpha
  M5 平衡与 Windows 发布（Beta/RC/1.0 为子门）
  1.0 后才评估 Web、Android、iOS 与扩展内容
  ```

  重写 `docs/design/11_开发里程碑.md` 的总览、各阶段标题、依赖图、版本表、风险表、`MilestoneRecord.milestone_id` 和完成标准，删除权威部分中的 M6/M7/M8 含义；历史合集不改正文，只在索引与 manifest 中明确降级为历史快照。

- [ ] **Step 3: Land R2 as a narrow, auditable exception**

  在宪法中建立 R2 权威条款，并在入口、角色、美术、素材管线和素材 README 引用它。统一写清：

  ```text
  默认角色外观原创。
  仅用户指定参考图的职业选手角色适用 R2。
  冲突优先级：用户选择/参考图 > 身份锚点 > 项目技术规范 > 旧 Prompt。
  可保留脸部整体关系、气质、发型发色、身形和无品牌服装色块。
  必须去除队标、赞助商、平台/赛事 Logo、官方队服图案、官方赛事 UI/奖杯/舞台/水印。
  R2 不构成最终发布肖像权或第三方授权结论；该发布选择留到 M5 人工门。
  ```

  把“小洞大人”的旧“凌乱深色短发、红橙点缀、战术服、强烈前倾”描述和 Prompt 替换为棕色齐下颌中短发、偏瘦、宽松纯黑短袖/黑裤/黑鞋、冷静克制、右下 3/4、自然站立、空手和武器分离。

- [ ] **Step 4: Commit the authority, milestone and R2 policy**

  ```bash
  git add CODEX_START.md assets/README.md \
    docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md \
    docs/design/README_设计文档索引.md \
    docs/design/00_产品宪法.md \
    docs/design/04_角色与流派设计.md \
    docs/design/08_UI美术音频规范.md \
    docs/design/11_开发里程碑.md \
    docs/design/12_游戏性与素材Review.md \
    docs/design/13_素材生产管线与提示词.md
  git commit -m "docs: establish G0 authority and R2 policy"
  ```

- [ ] **Step 5: Apply all ten approved gameplay corrections to their owning documents**

  使用以下精确值，不改写成新数值：

  1. 单局中位数暂定 30–35 分钟，P90 不超过 40 分钟；
  2. 完整局免费升级 20–24 次；
  3. 波末顺序为资源 → 波末事件 → 利息 → 固定奖励节点 → 清空待选升级 → 生成并打开商店；
  4. `char_xiaodong` 解锁条件为任意角色“4 秒内击杀 8 名敌人”，开发期五角色全开；
  5. 烟雾在测试期默认可用，大表哥正式解锁不得依赖自身烟雾能力；
  6. 第 3 波开始低频通用背身/诱饵机会，第 8/13 波强化专属职责；
  7. 小洞焦躁只在存在可达有效目标时计时，开波 3 秒宽限；
  8. 设备在非 AWP 时获得通用稳定性/后坐控制收益，并有非 AWP 收集来源；
  9. 火焰降低维修治疗效率但不无限打断，对护盾部分穿透或折减，HE 仍是主破盾；
  10. 同时可见 P0 危险上限普通战 6、Boss 战 7；同类边缘箭头合并，小伤害数字默认聚合。

- [ ] **Step 6: Define canonical gameplay IDs without creating duplicate runtime ownership**

  规定运行时 ID 为小写命名空间，显示名独立。至少在所有权威示例中使用：

  ```text
  char_nini, char_xiaodong, char_device, char_shangdi, char_dabiaoge
  wpn_usp, wpn_deagle, wpn_ak, wpn_m4, wpn_awp
  throw_he, throw_smoke, throw_flash, throw_fire
  upgrade_cal_01, upgrade_eng_01, upgrade_wpn_ak_01, upgrade_nin_01, upgrade_don_01
  enemy_chaser, enemy_swarm, enemy_ranged, enemy_backturn, enemy_smokehound
  ```

  将 `CAL_*|ENG_*|WPN_*|NIN_*|DON_*|DEV_*|JAM_*|KAR_*|CON_*` 明确标为 v0.1 设计代号并给出一一对应的 canonical 规则；不要创建一份新的生产玩法目录来重复拥有未来 Resource 数据。

- [ ] **Step 7: Define the two-profile validator contract**

  在入口、技术相关说明、素材管线和规格完成定义中澄清：

  ```text
  G0 gate: PASS
  Full catalog: NOT_READY
  ```

  “ContentValidator 全部通过”在 G0 只表示 `--profile=g0` 的必需数据通过；47 升级、五角色、五武器、1–20 波和解锁图在 `--profile=full` 下必须继续返回 NOT_READY，直到真实生产数据落地。

- [ ] **Step 8: Verify the document contract**

  Run:

  ```bash
  GOGO_AUTH_DOCS=(
    CODEX_START.md assets/README.md
    docs/design/README_设计文档索引.md
    docs/design/00_产品宪法.md docs/design/01_核心循环与20波流程.md
    docs/design/02_战斗与枪械系统.md docs/design/03_投掷物与状态系统.md
    docs/design/04_角色与流派设计.md docs/design/05_技能与奖励池.md
    docs/design/06_怪物与波次设计.md docs/design/07_经济与局外成长.md
    docs/design/08_UI美术音频规范.md docs/design/09_Godot技术架构.md
    docs/design/10_平衡测试规范.md docs/design/11_开发里程碑.md
    docs/design/12_游戏性与素材Review.md docs/design/13_素材生产管线与提示词.md
  )
  ! rg -n '(^|[^A-Za-z])(M6|M7|M8)([^A-Za-z]|$)' "${GOGO_AUTH_DOCS[@]}"
  ! rg -n '25[～-]30 分钟|凌乱深色短发|红橙点缀|黑色战术服|强烈前倾|小洞大人.*专属.*解锁|第一版同时维护 Windows、Web 和手机' "${GOGO_AUTH_DOCS[@]}"
  rg -n 'G0 设计治理|M1A|M1B|M1C|M5 平衡与 Windows 发布' "${GOGO_AUTH_DOCS[@]}"
  rg -n 'R2|棕色.*齐下颌|宽松纯黑短袖|无.*队标|无.*赞助商' "${GOGO_AUTH_DOCS[@]}"
  rg -n '30[～-]35 分钟|P90.*40' "${GOGO_AUTH_DOCS[@]}"
  rg -n '20[～-]24 次' "${GOGO_AUTH_DOCS[@]}"
  rg -n '资源.*波末事件.*利息.*固定奖励.*待选升级.*商店' "${GOGO_AUTH_DOCS[@]}"
  rg -n '4 秒内击杀 8' "${GOGO_AUTH_DOCS[@]}"
  rg -n '烟雾.*默认可用|解锁.*不得依赖.*自身' "${GOGO_AUTH_DOCS[@]}"
  rg -n '第 3 波.*背身|第 8/13 波' "${GOGO_AUTH_DOCS[@]}"
  rg -n '可达有效目标|3 秒宽限' "${GOGO_AUTH_DOCS[@]}"
  rg -n '非 AWP.*稳定|非 AWP.*后坐|非 AWP.*收集' "${GOGO_AUTH_DOCS[@]}"
  rg -n '火焰.*维修.*治疗|火焰.*护盾|HE.*破盾' "${GOGO_AUTH_DOCS[@]}"
  rg -n '普通战 6|Boss 战 7|边缘箭头.*合并|小伤害数字.*聚合' "${GOGO_AUTH_DOCS[@]}"
  ```

  Expected: 两条负向断言退出 0；十项正向断言各至少命中一个拥有该规则的权威文件。历史合集未加入数组，因此不掩盖现行文档冲突。

- [ ] **Step 9: Commit the gameplay, ID and validator contracts**

  ```bash
  git add CODEX_START.md assets/README.md \
    docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md \
    docs/design/README_设计文档索引.md \
    docs/design/00_产品宪法.md \
    docs/design/01_核心循环与20波流程.md \
    docs/design/03_投掷物与状态系统.md \
    docs/design/04_角色与流派设计.md \
    docs/design/05_技能与奖励池.md \
    docs/design/06_怪物与波次设计.md \
    docs/design/07_经济与局外成长.md \
    docs/design/08_UI美术音频规范.md \
    docs/design/10_平衡测试规范.md \
    docs/design/11_开发里程碑.md \
    docs/design/12_游戏性与素材Review.md \
    docs/design/13_素材生产管线与提示词.md
  git commit -m "docs: align G0 gameplay and content contracts"
  ```

---

### Task 2: Align runtime state ownership and WeaponDef

**Files:**

- Modify: `docs/design/01_核心循环与20波流程.md`
- Modify: `docs/design/02_战斗与枪械系统.md`
- Modify: `docs/design/09_Godot技术架构.md`
- Modify: `data/weapons/weapon_def.gd`
- Modify: `data/weapons/ak.tres`
- Modify: `tests/unit/test_weapon_runtime.gd`

**Interfaces:**

- Consumes: Task 1 canonical `wpn_ak` ID and state ownership definitions.
- Produces: `WeaponDef.id/tags/damage/reload_duration/range_pixels/pierce_count/pierce_decay/weakpoint_multiplier` for Validator rule `WPN001`.

- [ ] **Step 1: Write the failing WeaponDef schema assertions**

  Add assertions to `tests/unit/test_weapon_runtime.gd`:

  ```gdscript
  _assert_equal(ak_definition.get(&"id"), &"wpn_ak", "AK must use the canonical gameplay ID.", failures)
  _assert_equal(ak_definition.get(&"tags"), Array[StringName]([&"rifle", &"automatic", &"recoil"]), "AK tags must be stable.", failures)
  _assert_equal(ak_definition.get(&"pierce_count"), 0, "M0 AK must preserve zero base pierce.", failures)
  _assert_equal(ak_definition.get(&"pierce_decay"), 1.0, "Zero-pierce AK must use a neutral decay.", failures)
  _assert_equal(ak_definition.get(&"weakpoint_multiplier"), 1.0, "M0 behavior must remain unchanged.", failures)
  _assert_true(not _has_property(ak_definition, &"base_damage"), "WeaponDef must not expose base_damage beside damage.", failures)
  _assert_true(not _has_property(ak_definition, &"reload_sec"), "WeaponDef must not expose reload_sec beside reload_duration.", failures)
  _assert_true(not _has_property(ak_definition, &"max_range_px"), "WeaponDef must not expose max_range_px beside range_pixels.", failures)

  func _has_property(object: Object, property_name: StringName) -> bool:
      for property: Dictionary in object.get_property_list():
          if StringName(property.get("name", "")) == property_name:
              return true
      return false
  ```

- [ ] **Step 2: Run the red test**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
  ```

  Expected: FAIL because `id`, `tags`, `pierce_count`, `pierce_decay`, and `weakpoint_multiplier` do not exist.

- [ ] **Step 3: Add the minimal neutral schema**

  Add to `WeaponDef`:

  ```gdscript
  @export var id: StringName = &""
  @export var tags: Array[StringName] = []
  @export var pierce_count: int = 0
  @export_range(0.0, 1.0, 0.01) var pierce_decay: float = 1.0
  @export_range(1.0, 10.0, 0.01) var weakpoint_multiplier: float = 1.0
  ```

  Set `ak.tres` to `wpn_ak`, tags `rifle/automatic/recoil`, zero pierce, neutral decay and neutral weakpoint multiplier. Do not change the existing M0 damage, cadence, magazine, reload, spread, recoil or range values.

- [ ] **Step 4: Correct the authoritative schemas**

  In `01` and `09`, define:

  ```text
  RunConfig: read-only seed/difficulty/character/weapon/starting throwables.
  RunState: phase/wave/time/RNG streams/event sequence and references to child state.
  EconomyState: wallet/experience/level/pending upgrade count.
  UpgradeState: acquired upgrades/contracts/stacks.
  ```

  In `02` and `09`, use only the existing code names `damage`, `reload_duration`, `range_pixels` and the new `id/tags/pierce_count/pierce_decay/weakpoint_multiplier`; remove unconverted `base_damage/reload_sec/max_range_px` schema examples.

- [ ] **Step 5: Run regression and smoke tests**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . --quit-after 600
  ```

  Expected: `TESTS PASSED`; smoke exits 0; M0 shot behavior remains unchanged.

- [ ] **Step 6: Commit the schema alignment**

  ```bash
  git add docs/design/01_核心循环与20波流程.md \
    docs/design/02_战斗与枪械系统.md \
    docs/design/09_Godot技术架构.md \
    data/weapons/weapon_def.gd data/weapons/ak.tres \
    tests/unit/test_weapon_runtime.gd
  git commit -m "refactor: align G0 content ownership"
  ```

---

### Task 3: Build the G0 validator and CLI with TDD

**Files:**

- Create: `src/content/content_snapshot_loader.gd`
- Create: `src/content/content_validator.gd`
- Create: `src/content/content_validator_cli.gd`
- Create: `tools/validate_content.gd`
- Create: `data/content_validation.json`
- Create: `tests/unit/test_content_validator.gd`
- Create: `tests/integration/test_content_validator_cli.gd`
- Create: `tests/fixtures/content_validator/g0_valid/data/content_validation.json`
- Create: `tests/fixtures/content_validator/g0_valid/design/manifest.json`
- Create: `tests/fixtures/content_validator/g0_valid/design/00.md`
- Create: `tests/fixtures/content_validator/g0_valid/assets/asset_manifest.csv`
- Create: `tests/fixtures/content_validator/g0_invalid/data/content_validation.json`
- Create: `tests/fixtures/content_validator/g0_invalid/asset_duplicate.csv`
- Create: `tests/fixtures/content_validator/g0_invalid/asset_missing_evidence.csv`
- Create: `tests/fixtures/content_validator/g0_invalid/design_bad_hash.json`
- Modify: `tests/test_runner.gd`

**Interfaces:**

- Consumes: raw project-relative JSON/CSV/Resource files.
- Produces:

  ```gdscript
  ContentSnapshotLoader.load_project(
      project_root: String = "res://",
      config_path: String = "res://data/content_validation.json"
  ) -> Dictionary

  ContentValidator.validate_project(
      profile: StringName = &"g0",
      config_path: String = "res://data/content_validation.json"
  ) -> Dictionary

  ContentValidator.validate_snapshot(snapshot: Dictionary, profile: StringName) -> Dictionary
  ContentValidator.format_jsonl(report: Dictionary) -> PackedStringArray
  ContentValidator.exit_code(report: Dictionary) -> int

  ContentValidatorCLI.parse_args(args: PackedStringArray) -> Dictionary
  ContentValidatorCLI.run(args: PackedStringArray) -> Dictionary
  ```

  `data/content_validation.json` must use this exact schema and may not gain implicit defaults:

  ```json
  {
    "schema_version": 1,
    "current_gate": "G0",
    "datasets": {
      "assets": {
        "state": "legacy",
        "path": "res://assets/asset_manifest.csv",
        "target_gate": "G0"
      },
      "design_documents": {
        "state": "legacy",
        "path": "res://docs/design/manifest.json",
        "target_gate": "G0"
      },
      "weapons": {
        "state": "partial",
        "path": "res://data/weapons",
        "target_gate": "M4",
        "expected_count": 5
      },
      "throwables": {
        "state": "not_implemented",
        "path": "res://data/throwables",
        "target_gate": "M4",
        "expected_count": 4
      },
      "characters": {
        "state": "not_implemented",
        "path": "res://data/characters",
        "target_gate": "M4",
        "expected_count": 5
      },
      "upgrades": {
        "state": "not_implemented",
        "path": "res://data/upgrades",
        "target_gate": "M4",
        "expected_count": 47,
        "expected_categories": {
          "calibration": 8,
          "engine": 10,
          "mutation": 9,
          "module": 15,
          "contract": 5
        }
      },
      "enemies": {
        "state": "not_implemented",
        "path": "res://data/enemies",
        "target_gate": "M4",
        "expected_count": 14
      },
      "waves": {
        "state": "not_implemented",
        "path": "res://data/waves",
        "target_gate": "M4",
        "expected_range": [1, 20]
      },
      "unlocks": {
        "state": "not_implemented",
        "path": "res://data/unlocks",
        "target_gate": "M5"
      }
    }
  }
  ```

  `ContentSnapshotLoader` normalizes project files to this exact top-level shape:

  ```gdscript
  {
      "config": {
          "schema_version": 1,
          "current_gate": "G0",
          "datasets": Dictionary
      },
      "design_documents": {
          "manifest": Dictionary,
          "actual_markdown_files": Array[String],
          "records": Array[Dictionary]
      },
      "assets": {
          "header": PackedStringArray,
          "rows": Array[Dictionary]
      },
      "gameplay": {
          "weapons": Array[Dictionary],
          "throwables": Array[Dictionary],
          "characters": Array[Dictionary],
          "upgrades": Array[Dictionary],
          "enemies": Array[Dictionary],
          "waves": Array[Dictionary],
          "unlocks": Array[Dictionary]
      }
  }
  ```

  Every loaded record includes `source_path` and `source_line`; missing datasets are represented by empty arrays plus config readiness, never by invented rows.

  Readiness semantics and rule ownership are mandatory:

  | dataset state | Existing records | Completeness | G0 result |
  |---|---|---|---|
  | `not_implemented` | Path must be absent or empty; otherwise `CFG001 ERROR` | Emit one `NOT_READY` | Future target gates do not fail G0 |
  | `legacy` | Only safe-path/readability checks run | Emit one `NOT_READY` | Fails G0 when `target_gate=G0` |
  | `partial` | Run ID, schema, numeric range and all resolvable present-record references | Missing count/unknown future refs emit `NOT_READY` | Any existing-record error fails G0 |
  | `ready` | Run every rule owned by that dataset | Count/range/reference completeness required | Any error fails G0 |

  | Rule | `g0` profile | `full` profile |
  |---|---|---|
  | `CFG001` | Always | Always |
  | `DOC001–003` | When design documents are `ready`; `legacy` is G0-NOT_READY | Required and complete |
  | `AST001–005` | When assets are `ready`; `legacy` is G0-NOT_READY | Required and complete |
  | `ID001`, `WPN001` | Run ID rules for every present gameplay record and weapon schema rules for every present weapon in `partial|ready` | Run for all ready gameplay datasets |
  | `REF001` | Validate references whose target dataset is present; missing future dataset is NOT_READY | Every reference must resolve |
  | `UPG001–002`, `CHR001`, `MUT001`, `WAVE001`, `ULK001` | Run only for present `partial|ready` records; missing completeness is NOT_READY | All required, complete and error-free |

  Gate order is `G0 < M0 < M1 < M2 < M3 < M4 < M5`. In `g0`, `ERROR` always exits 1; `NOT_READY` exits 1 only when its `target_gate` is G0 or earlier. In `full`, any `ERROR` or `NOT_READY` exits 1.

- [ ] **Step 1: Write red loader and validator tests**

  `tests/unit/test_content_validator.gd` must cover:

  ```text
  CFG001 unknown dataset state and dishonest not_implemented directory
  DOC001 unsafe/duplicate/missing manifest paths
  DOC002 unregistered or nonexistent Markdown
  DOC003 byte count or SHA-256 mismatch
  AST001 exact 28-column header, quoted comma, and short row
  AST002 unique snake_case ID, enums, canvas, frames/FPS, safe paths
  AST003 lifecycle evidence matrix
  AST004 generated-or-later Prompt and negative constraints
  AST005 exactly idle/walk/hit/death/skill_breakin/portrait for A5 xiaodong
  ```

  Pure rule tests call `validate_snapshot`. Loader tests call `load_project("res://tests/fixtures/content_validator/g0_valid/", fixture_config)` and assert quoted commas, exact CSV line numbers, safe paths, Markdown enumeration, bytes and hashes in the returned snapshot/load issues.

- [ ] **Step 2: Run the red test**

  Run the existing test runner. Expected: FAIL because loader and validator classes do not exist.

- [ ] **Step 3: Implement deterministic loading**

  `ContentSnapshotLoader` must:

  - use `FileAccess.get_csv_line(",")`, never `load()` for the CSV;
  - preserve CSV line numbers;
  - reject absolute paths and `..`;
  - enumerate every `docs/design/*.md`;
  - compute `FileAccess.get_sha256(path)` and `FileAccess.get_file_as_bytes(path).size()`;
  - return `{"snapshot": ..., "load_issues": Array[Dictionary]}` without throwing for content errors.

- [ ] **Step 4: Implement G0 validation and stable reports**

  Report shape:

  ```gdscript
  {
      "profile": "g0",
      "gate_status": "pass",
      "catalog_status": "not_ready",
      "counts": {"error": 0, "warning": 0, "not_ready": 1},
      "issues": [{
          "severity": "NOT_READY",
          "rule": "UPG001",
          "path": "data/content_validation.json",
          "line": 0,
          "subject": "upgrades",
          "message": "47-upgrade catalog is declared not_implemented",
          "expected": 47,
          "actual": 0,
          "target_gate": "M4"
      }]
  }
  ```

  Sort issues by `severity,rule,path,line,subject`. Use severities `ERROR|WARNING|NOT_READY`. Derive all three counts exclusively from `issues` and test count consistency. Apply the readiness/profile exit matrix above; CLI argument errors exit 2.

- [ ] **Step 5: Implement the exact 28-column asset schema**

  ```csv
  asset_id,phase,category,subject,state,path,logical_canvas,pivot,frames,fps,prompt_section,status,notes,generation_canvas,direction,collision_reference,palette,negative_constraints,godot_import,reviewer,reference_source,reference_sha256,reference_rights_policy,sprite_layout,source_output,cleaned_output,qa_record,godot_evidence
  ```

  `state` is the preserved v0.1 action/variant column; it is never a lifecycle field. Every evidence rule below keys only on `status`:

  ```text
  status=planned: stable path may be absent; four evidence paths empty.
  status=generated: source_output exists; prompt_section and negative_constraints nonempty.
  status=cleaned: generated + cleaned_output and stable path exist.
  status=approved: cleaned + qa_record exists + reviewer nonempty.
  status=in_game: approved + godot_evidence exists + godot_import nonempty.
  status=rejected: source_output and rejection qa_record exist; stable path absent.
  ```

  `accepted_for_concept` is invalid in both `state` and `status`.

- [ ] **Step 6: Implement and integration-test the CLI**

  Put argument parsing and report rendering in `ContentValidatorCLI`; keep `tools/validate_content.gd` as a thin `SceneTree` wrapper. Accept `--profile=g0|full`, `--format=jsonl` and `--config=<res:// path>`, print one JSON object per issue plus one summary, and call `quit(ContentValidator.exit_code(report))`.

  `tests/integration/test_content_validator_cli.gd` uses `OS.execute(OS.get_executable_path(), args, output, true)` against fixture configs and asserts:

  ```text
  valid g0 fixture -> exit 0 and JSONL summary gate_status=pass
  valid g0 fixture under full -> exit 1 and catalog_status=not_ready
  --profile=unknown -> exit 2
  issue lines precede exactly one summary line
  every JSONL line parses and summary counts equal emitted issue severities
  ```

  Append both unit and CLI integration test paths to `TEST_PATHS`.

- [ ] **Step 7: Run the green fixture tests**

  Run the complete test runner. Expected: `TESTS PASSED`. Do not require the production CSV/manifest to pass yet; that migration is Task 5.

- [ ] **Step 8: Commit the G0 validator core**

  ```bash
  git add src/content/content_snapshot_loader.gd \
    src/content/content_validator.gd src/content/content_validator_cli.gd \
    tools/validate_content.gd \
    data/content_validation.json tests/test_runner.gd \
    tests/unit/test_content_validator.gd tests/integration/test_content_validator_cli.gd \
    tests/fixtures/content_validator
  git commit -m "feat: add G0 content validator"
  ```

---

### Task 4: Implement the full-catalog validation rules without fake production data

**Files:**

- Modify: `src/content/content_validator.gd`
- Modify: `tests/unit/test_content_validator.gd`
- Create: `tests/fixtures/content_validator/full_valid.json`
- Create: `tests/fixtures/content_validator/full_invalid.json`

**Interfaces:**

- Consumes: the normalized snapshot from Task 3.
- Produces stable rules `ID001`, `REF001`, `WPN001`, `UPG001`, `UPG002`, `CHR001`, `MUT001`, `WAVE001`, `ULK001`.

- [ ] **Step 1: Create a valid synthetic full catalog**

  The test-only fixture must contain:

  ```text
  5 unique characters, each with exactly 3 distinct module IDs
  5 unique weapons, each with at least 1 mutation
  4 throwables
  14 enemies
  exactly 47 upgrades classified 8 calibration / 10 engine / 9 mutation / 15 module / 5 contract
  waves exactly 1 through 20
  an acyclic unlock graph
  ```

  Use lower-case canonical IDs. The fixture is validation input only and must not be loaded by the game or presented as implemented content.

- [ ] **Step 2: Write red tests for each future rule**

  Tests must prove:

  - duplicate/cross-domain or malformed IDs fail `ID001`;
  - missing character/weapon/enemy/upgrade references fail `REF001`;
  - nonpositive damage/reload/range, negative pierce, decay outside 0–1, weakpoint below 1 fail `WPN001`;
  - 46 upgrades or wrong 8/10/9/15/5 counts fail `UPG001`;
  - missing/self/asymmetric conflicts fail `UPG002`;
  - 2/4/duplicate/wrong-owner modules fail `CHR001`;
  - a weapon without mutation fails `MUT001`;
  - missing/duplicate/out-of-range waves or missing enemy refs fail `WAVE001`;
  - missing unlock dependency or cycle fails `ULK001`, while a diamond graph passes.

- [ ] **Step 3: Run the red tests**

  Expected: the new tests fail because the future rule IDs are absent.

- [ ] **Step 4: Implement the rules against the snapshot**

  Keep validation pure and deterministic. Do not scan Markdown tables as production gameplay data and do not create `data/upgrades`, `data/waves`, `data/characters`, `data/enemies` or `data/unlocks` merely to make `full` pass.

- [ ] **Step 5: Prove both honest outcomes**

  The valid synthetic fixture must pass `full`. The real project config must still report its absent/partial datasets as NOT_READY. Run the full test runner and expect `TESTS PASSED`.

- [ ] **Step 6: Commit the future validation kernel**

  ```bash
  git add src/content/content_validator.gd \
    tests/unit/test_content_validator.gd \
    tests/fixtures/content_validator/full_valid.json \
    tests/fixtures/content_validator/full_invalid.json
  git commit -m "feat: enforce future content catalog rules"
  ```

---

### Task 5: Migrate production manifests and establish Xiaodong C0 traceability

**Files:**

- Modify: `assets/asset_manifest.csv`
- Modify: `docs/design/manifest.json`
- Modify: `data/content_validation.json`
- Create: `assets/characters/xiaodong/character_xiaodong_design.md`
- Create: `assets/source/references/characters/xiaodong/reference_01.jpg`

**Interfaces:**

- Consumes: Task 3 exact CSV/JSON schemas and Task 1 R2 rules.
- Produces: production input that passes `--profile=g0`; six A5 `planned` Xiaodong entries; stable C0 reference/design record.

- [ ] **Step 1: Verify and copy the exact reference**

  Source:

  ```text
  /tmp/codex-remote-attachments/019fb31c-072f-7d53-88ee-db1428e52873/50462BE6-335F-4804-ACFF-1E697518CE1A/1-照片-1.jpg
  ```

  Required evidence:

  ```text
  width=853
  height=1280
  sha256=fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52
  destination=assets/source/references/characters/xiaodong/reference_01.jpg
  ```

  Abort this task if the source hash differs. Copy the verified binary without re-encoding.

- [ ] **Step 2: Create the authoritative design card before generating images**

  `character_xiaodong_design.md` must contain:

  - reference filename, stable relative path, 853×1280, SHA-256, use and R2 policy;
  - identity anchors and the exact 10-item C0 QA checklist;
  - the master-first workflow and action counts;
  - the complete positive Prompt and exclusions from the approved spec;
  - artifact state `not_generated` and decision `pending_review`;
  - an empty candidate ledger schema with no fabricated candidate IDs or decisions;
  - an explicit boundary: C0 never changes A5 manifest status or enters Godot.

- [ ] **Step 3: Migrate all existing asset rows to the exact 28 columns**

  Preserve every existing value. Preserve `state` as the action/variant value and preserve `status=planned` as lifecycle. For all `status=planned` rows, keep evidence paths empty and fill deterministic production metadata (`generation_canvas`, `direction`, `collision_reference`, `palette`, `negative_constraints`, `godot_import`, `reference_rights_policy`, `sprite_layout`) appropriate to the asset category. Leave `reviewer` empty until approval.

- [ ] **Step 4: Complete the six A5 Xiaodong records**

  Ensure these exact records exist and remain `planned`:

  | asset_id | state (action/variant) | status | path | frames | fps | sprite_layout |
  |---|---|---|---|---:|---:|---|
  | `character_xiaodong_idle` | idle | planned | `assets/characters/xiaodong/character_xiaodong_idle.png` | 4 | 5 | `horizontal_4x1` |
  | `character_xiaodong_walk` | walk | planned | `assets/characters/xiaodong/character_xiaodong_walk.png` | 8 | 10 | `horizontal_8x1` |
  | `character_xiaodong_hit` | hit | planned | `assets/characters/xiaodong/character_xiaodong_hit.png` | 2 | 12 | `horizontal_2x1` |
  | `character_xiaodong_death` | death | planned | `assets/characters/xiaodong/character_xiaodong_death.png` | 6 | 10 | `horizontal_6x1` |
  | `character_xiaodong_skill_breakin` | skill_breakin | planned | `assets/characters/xiaodong/character_xiaodong_skill_breakin.png` | 6 | 12 | `horizontal_6x1` |
  | `portrait_xiaodong` | portrait | planned | `assets/ui/portraits/portrait_xiaodong.png` | 1 | 0 | `single` |

  All six use `phase=A5`, `generation_canvas=1024x1024`, `logical_canvas=128x128`, `reference_source=assets/source/references/characters/xiaodong/reference_01.jpg`, the approved SHA, and `reference_rights_policy=R2`. Body animations use `direction=down_right` and `pivot=feet_center`; portrait uses `direction=none` and `pivot=center`.

- [ ] **Step 5: Upgrade the design manifest to schema 2**

  Use:

  ```json
  {
    "schema_version": 2,
    "project": "GOGO",
    "design_version": "0.3",
    "date": "2026-07-30",
    "coverage": {"root": "docs/design", "include": ["*.md"], "exclude": []},
    "documents": [],
    "catalog_targets": {"upgrade_count": 47, "wave_range": [1, 20]}
  }
  ```

  Enumerate every `docs/design/*.md`: README and 00–13 as `authoritative`, compatibility as `auxiliary`, v0.1 combined document as `historical`. Record exact UTF-8 bytes and lowercase SHA-256 after all Task 1/2 document edits.

- [ ] **Step 6: Mark only G0 datasets ready**

  In `data/content_validation.json`, set design documents and assets to `ready`; set weapons to `partial`; set throwables/characters/upgrades/enemies/waves/unlocks to `not_implemented` with their expected counts/ranges and target gates. The config is readiness evidence, not gameplay data.

- [ ] **Step 7: Run production gates**

  Run:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- --profile=g0 --format=jsonl
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- --profile=full --format=jsonl
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
  ```

  Expected: G0 exits 0 with zero errors; full exits 1 only because real future catalogs are NOT_READY; tests print `TESTS PASSED`.

- [ ] **Step 8: Commit manifest and C0 traceability**

  ```bash
  git add assets/asset_manifest.csv \
    assets/characters/xiaodong/character_xiaodong_design.md \
    assets/source/references/characters/xiaodong/reference_01.jpg \
    docs/design/manifest.json data/content_validation.json
  git commit -m "docs: establish Xiaodong R2 asset governance"
  ```

---

### Task 6: Perform and record the G0 milestone review

**Files:**

- Create: `docs/progress/2026-07-30-g0-design-governance.md`

**Interfaces:**

- Consumes: all commits from Tasks 1–5 and their task review reports.
- Produces: the independent G0 milestone progress/review record required before M0 closure work.

- [ ] **Step 1: Assign an independent milestone reviewer**

  Task 6 must be dispatched to a fresh reviewer agent that did not implement Tasks 1–5 and has not participated in their fix loops. Give it the G0 base SHA, current head SHA, the generated full diff/review package, the task review verdicts and this Task 6 brief. Record its canonical reviewer identity and exact reviewed commit range in the progress record.

- [ ] **Step 2: Independently audit scope and dirty-file preservation**

  Record the G0 base commit, implementation commit range, current branch and exact `git status --short`. Confirm `project.godot` plus the three `.DS_Store` remain unstaged and unchanged; no other unrelated file may be staged.

- [ ] **Step 3: Run all required G0 evidence**

  Run and record command, exit code, concise output and timestamp for:

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot --version
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . --quit-after 600
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- --profile=g0 --format=jsonl
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- --profile=full --format=jsonl
  shasum -a 256 assets/source/references/characters/xiaodong/reference_01.jpg
  ```

- [ ] **Step 4: Review every G0 exit criterion**

  The record must verdict each item `PASS|FAIL|NOT_READY`:

  ```text
  G0–M5 is the only authoritative milestone model.
  R2 scope/priority/prohibitions are consistent.
  RunConfig/RunState/EconomyState/UpgradeState have single ownership.
  WeaponDef uses one canonical field set.
  Asset manifest has 28 columns and honest lifecycle evidence.
  Xiaodong has six A5 planned records; C0 is separate.
  Design manifest covers every docs/design Markdown with matching bytes/hash.
  G0 validator passes.
  Full catalog correctly remains NOT_READY.
  Existing M0 tests and 600-frame smoke still pass.
  User dirty files are preserved and excluded.
  ```

- [ ] **Step 5: Write the milestone record**

  Include:

  ```text
  milestone_id: G0
  status: PASSED only if every G0 item is PASS
  build_version: pre-M1 governance build
  Godot version and platform
  implementation commits
  automated test evidence
  content validation evidence
  manual inspection evidence
  reviewer identity and verdict
  known NOT_READY future datasets
  next gate: C0 visual master, requiring user visual approval
  ```

  Do not mark M0 passed in this record.

- [ ] **Step 6: Commit the independent milestone record**

  ```bash
  git add docs/progress/2026-07-30-g0-design-governance.md
  git commit -m "docs: record G0 milestone acceptance"
  ```

- [ ] **Step 7: Re-run G0 validation after the record commit**

  The progress record is outside `docs/design`, so design hashes must remain valid. Expected: G0 exits 0; full remains NOT_READY for future gameplay data only.
