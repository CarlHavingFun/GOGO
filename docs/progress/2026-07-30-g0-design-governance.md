# G0 设计治理里程碑验收记录

## 记录摘要

- `milestone_id`: `G0`
- `status`: `PASSED`
- `build_version`: `pre-M1 governance build`
- `reviewed_at`: `2026-07-31`（Asia/Shanghai）
- `branch`: `codex_goal`
- `platform`: macOS 26.2（Build 25C56），arm64
- `godot_version`: `4.7.1.stable.official.a13da4feb`
- `reviewer`: `/root/g0_task6_milestone`
- `reviewer_verdict`: `APPROVED`，11/11 G0 退出条件全部 `PASS`
- `next_gate`: `C0 visual master`；生成后必须取得用户明确的视觉批准

本记录只裁决 G0 设计治理。它不把 M0 标记为通过，不生成 C0 图片，
也不授权提前推进 M1、A5 正式素材或未来玩法目录。

## 独立评审边界

- G0 base：
  `8ac2984f03ec21f98f427a5a35e9287824beaa7a`
- 记录提交前 HEAD：
  `1581ba5219ee020d2bbef97cc4d87521a0deb5a7`
- 完整评审范围：
  `8ac2984f03ec21f98f427a5a35e9287824beaa7a..1581ba5219ee020d2bbef97cc4d87521a0deb5a7`
- 范围内提交数：`16`
- 评审包：
  `.superpowers/sdd/2026-07-30-g0-design-governance/review-8ac2984..1581ba5.diff`
- 评审包证据：`13,582` 行、`779,258` bytes、SHA-256
  `00162d6c38c3580948ada28865763fc23c9fa32ff065c030ae91e34b4662a8f1`
- 包完整性：与上述范围的
  `git diff --binary --full-index` 逐字节相同。

评审者没有实现 Tasks 1～5，也没有参与 Task 6 remediation 的实现或
修复循环。本次在阅读完整评审包后，从头复核了权威文档、代码、静态
fixture、生产门、隔离删除反证和用户脏文件边界。

## 完整提交范围

```text
24cbe74e9c1feed6521174b77e86c22a2aa80fbd docs: plan G0 design governance
31b88568b77ec5a0dc26e0d3a569139b936f5c4f docs: establish G0 authority and R2 policy
39d8b670eef1f1ebfbcefba524e366f5dfd468e6 docs: align G0 gameplay and content contracts
934fafe0d046b3087097ee66c89f0c90b4204394 docs: separate R2 negative prompt policy
eb4be1cd620788c9ce50527b8bd651973cea956b refactor: align G0 content ownership
b4a35062dce077e269420aec17d9eeb6d4b8cd26 feat: add G0 content validator
aace514459d41c95fb860d9d7f4079509c84f7d8 fix: harden G0 content validation
6a1908e426ca6bcce76e7a4acce1d0de2553f39e fix: guard malformed reference configs
9fd4bd9853191b7023f5fd284cc801a031bd43f3 feat: enforce future content catalog rules
984d7aad890bd17cfe69065ba9f337d85b913e5e fix: reject fractional wave numbers
4eb79f0fb871dea92b7d205570095633681f4c03 docs: establish Xiaodong R2 asset governance
99d0c7302e9e60c501efc3de2fe735576ba21b31 fix: close G0 governance blockers
7c0ed63d56d52dfd9888f80906abfbd6ca54ef62 fix: harden G0 governance parsing
bc994e3d1b8315ec4d405afec1191b28dbecce33 fix: reject inactive governance HTML blocks
d2958f4f819842f67525883276125c117ae3124d fix: fail closed on governance HTML ordering
1581ba5219ee020d2bbef97cc4d87521a0deb5a7 fix: preserve governance blocks after prose comments
```

其中 Task 6 remediation 提交为：

```text
99d0c7302e9e60c501efc3de2fe735576ba21b31
7c0ed63d56d52dfd9888f80906abfbd6ca54ef62
bc994e3d1b8315ec4d405afec1191b28dbecce33
d2958f4f819842f67525883276125c117ae3124d
1581ba5219ee020d2bbef97cc4d87521a0deb5a7
```

## 自动化证据

所有时间均为 Asia/Shanghai（`+0800`）。

### Godot 版本

- 时间：`2026-07-31T02:31:25+0800`
- 命令：

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot --version
  ```

- 退出码：`0`
- 结果：`4.7.1.stable.official.a13da4feb`

### 完整测试

- 时间：`2026-07-31T02:31:32+0800` 至
  `2026-07-31T02:31:51+0800`
- 命令：

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tests/test_runner.gd
  ```

- 退出码：`0`
- 结果：`TESTS PASSED`

### 600 帧 smoke

- 时间：`2026-07-31T02:31:56+0800` 至
  `2026-07-31T02:32:01+0800`
- 命令：

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . --quit-after 600
  ```

- 退出码：`0`
- 结果：Godot 正常启动并按 600 帧退出，无错误输出。

### 生产 G0 profile

- 时间：`2026-07-31T02:32:08+0800`
- 命令：

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=g0 --format=jsonl
  ```

- 退出码：`0`
- 摘要：

  ```json
  {"catalog_status":"not_ready","counts":{"error":0,"not_ready":7,"warning":0},"gate_status":"pass","profile":"g0","type":"summary"}
  ```

### 生产 full profile

- 时间：`2026-07-31T02:32:13+0800`
- 命令：

  ```bash
  /Users/Carl/Applications/Godot.app/Contents/MacOS/Godot \
    --headless --audio-driver Dummy --path . \
    -s res://tools/validate_content.gd -- \
    --profile=full --format=jsonl
  ```

- 退出码：`1`（预期）
- 摘要：

  ```json
  {"catalog_status":"not_ready","counts":{"error":0,"not_ready":7,"warning":0},"gate_status":"fail","profile":"full","type":"summary"}
  ```

G0 和 full 只包含相同的七项真实未来/部分目录 `NOT_READY`，没有
`ERROR` 或 `WARNING`。

### 稳定参考原件

- 时间：`2026-07-31T02:30:04+0800`
- 命令：

  ```bash
  wc -c assets/source/references/characters/xiaodong/reference_01.jpg
  shasum -a 256 assets/source/references/characters/xiaodong/reference_01.jpg
  sips -g pixelWidth -g pixelHeight \
    assets/source/references/characters/xiaodong/reference_01.jpg
  file assets/source/references/characters/xiaodong/reference_01.jpg
  ```

- 各命令退出码：`0`
- 结果：`77,554` bytes；`853×1280`；有效 baseline JFIF JPEG；
  SHA-256
  `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52`。

## 负向与隔离反证

四个静态 G0 fixture 使用 `--no-header` 捕获 stdout/stderr。每个输出
均为 `9/9` 可解析 JSON 对象、恰好一个 summary、恰好一个 `ERROR`：

| fixture | 时间 | 退出码 | 唯一错误 | 未级联 |
|---|---|---:|---|---|
| missing reference | `2026-07-31T02:32:37+0800` | 1 | `AST006` | 无 `AST007` |
| corrupt reference | `2026-07-31T02:32:37+0800`～`02:32:38+0800` | 1 | `AST006` | 无 `AST007` |
| missing card | `2026-07-31T02:32:38+0800` | 1 | `AST007` | 无 `AST006` |
| invalid card | `2026-07-31T02:32:38+0800` | 1 | `AST007` | 无 `AST006` |

另用两个独立 `mktemp`/`git archive HEAD` 工作副本执行生产路径反证，
没有改动生产文件：

| 隔离变更 | 时间 | 退出码 | 结果 |
|---|---|---:|---|
| 删除生产稳定参考 | `2026-07-31T02:33:21+0800` | 1 | 纯 JSONL；恰好一个 `AST006`，无 `AST007` |
| 删除生产设计卡 | `2026-07-31T02:33:21+0800`～`02:33:22+0800` | 1 | 纯 JSONL；恰好一个 `AST007`，无 `AST006` |

## 人工与静态复核

- 权威文档中没有 M6/M7/M8 或被替换的 M4/M5 里程碑含义；
  G0～M5、M1A/M1B/M1C 和 M5 Beta/RC/1.0 子门一致。
- R2 只覆盖用户指定参考图的职业选手角色；优先级、可保留项、
  禁止项和 M5 人工发布门一致。“小洞大人”六行没有
  `no_real_person_portrait`。
- `RunConfig`、`RunState`、`EconomyState`、`UpgradeState` 的所有权
  唯一；`RunState` 只持有子状态引用。
- `WeaponDef`、AK Resource、`02` 和 `09` 使用同一字段集；没有
  `base_damage`、`reload_sec` 或 `max_range_px` 平行字段。
- `ID001` 独立强制五个批准命名空间：
  `char_`、`wpn_`、`throw_`、`upgrade_`、`enemy_`；仍保留
  snake_case 与跨目录唯一性；没有给 wave 或 unlock 发明前缀规则。
- 素材 manifest 为精确 28 列、61 行；61 行均为 `planned`，
  没有 planned lifecycle evidence，也没有
  `accepted_for_concept` 生命周期值。
- “小洞大人”恰有六项 A5 记录：
  `idle/walk/hit/death/skill_breakin/portrait`。六项均为 `planned`、
  `R2`，参考路径和 SHA 一致，帧数、FPS、画布、pivot、方向和
  Sprite Sheet 布局均匹配批准计划。
- 设计卡恰有一个有效 `gogo-governance+json` block，使用精确 schema；
  当前为 `not_generated/pending_review/0 candidates`，C0 不改变 A5
  状态、不进入 Godot，A5 保持 `planned` 至 M4。卡内有完整 Prompt、
  排除项、10 项 QA、母版优先流程和空候选表。
- 设计 manifest 精确覆盖 `docs/design/*.md` 的 17/17 文件；
  17 个 byte count 与 SHA-256 全部匹配，角色分布为
  15 authoritative、1 auxiliary、1 historical。
- 生产树只有设计卡和稳定参考两个 Xiaodong 文件，没有 C0 图片；
  未来 gameplay 目录仍不存在。

## G0 退出条件

| # | 退出条件 | 结论 |
|---:|---|---|
| 1 | G0～M5 是唯一权威里程碑模型 | `PASS` |
| 2 | R2 范围、优先级和禁止项一致 | `PASS` |
| 3 | 四个运行状态对象保持单一所有权 | `PASS` |
| 4 | WeaponDef 使用唯一 canonical 字段集 | `PASS` |
| 5 | 素材 manifest 为 28 列且生命周期证据诚实 | `PASS` |
| 6 | Xiaodong 六项 A5 保持 planned，C0 分离 | `PASS` |
| 7 | 设计 manifest 17/17 覆盖且 bytes/hash 匹配 | `PASS` |
| 8 | G0 validator 通过并能拒绝缺失/损坏治理输入 | `PASS` |
| 9 | 完整目录诚实保持 NOT_READY | `PASS` |
| 10 | 现有 M0 自动测试与 600 帧 smoke 保持通过 | `PASS` |
| 11 | 用户脏文件被保留且排除于 G0 提交 | `PASS` |

## 用户脏文件与提交边界

记录创建前，index 为空，`git status --short --untracked-files=all`
精确为：

```text
 M project.godot
?? .DS_Store
?? docs/.DS_Store
?? docs/design/.DS_Store
```

完整评审范围未触及这四条路径。本记录提交只允许暂存本文件。

## 已知未来 NOT_READY

以下七项是诚实的后续门，不阻塞 G0：

| 数据集 | 当前状态 | 当前数量 | 目标 | 门 |
|---|---|---:|---|---|
| weapons | `partial` | 1 | 5 | M4 |
| throwables | `not_implemented` | 0 | 4 | M4 |
| characters | `not_implemented` | 0 | 5 | M4 |
| upgrades | `not_implemented` | 0 | 47 | M4 |
| enemies | `not_implemented` | 0 | 14 | M4 |
| waves | `not_implemented` | 0 | 1～20 | M4 |
| unlocks | `not_implemented` | 0 | 完整解锁图 | M5 |

## 最终裁决与下一门

G0 在上述精确评审范围内为 `PASSED`。完整目录仍为
`NOT_READY`，这是预期且诚实的并列结果。

下一门是“小洞大人”C0 visual master。任何 C0 图生成后都必须由用户
进行明确视觉批准；C0 接受不改变六项 A5 的 `planned` 状态，也不允许
直接进入 Godot。M0 在本记录中未被裁决、未被标记为通过。
