# 小洞大人｜C0 视觉与动作设计卡

- 设计阶段：`C0`
- 资产阶段：`A5`（仅登记正式生产计划）
- artifact state：`generated`
- decision：`accepted_for_concept`
- 当前权威补充：`docs/superpowers/specs/2026-07-31-gogo-xiaodong-eight-direction-grip-design.md`
- 上位历史规格：`docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`

```gogo-governance+json
{
  "schema_version": 1,
  "subject": "xiaodong",
  "design_stage": "C0",
  "asset_stage": "A5",
  "artifact_state": "generated",
  "decision": "accepted_for_concept",
  "candidate_count": 24,
  "reference": {
    "path": "assets/source/references/characters/xiaodong/reference_01.jpg",
    "bytes": 77554,
    "width": 853,
    "height": 1280,
    "sha256": "fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52",
    "rights_policy": "R2"
  },
  "boundary": {
    "c0_changes_a5_status": false,
    "c0_enters_godot": false,
    "a5_status": "planned",
    "a5_gate": "M4"
  }
}
```

## 1. 原始参考登记

| 字段 | 值 |
|---|---|
| 批准规格中的参考文件名 | `照片 1.jpg` |
| 附件源文件名 | `1-照片-1.jpg` |
| 稳定相对路径 | `assets/source/references/characters/xiaodong/reference_01.jpg` |
| 尺寸 | `853×1280` |
| SHA-256 | `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52` |
| 用途 | “小洞大人”职业选手角色的第一视觉依据；用于 C0 视觉母版、头像母版和动作关键姿势的身份一致性约束 |
| 来源策略 | `R2`，仅供内部设计追溯；生成图不得反向标记为原始参考图 |

R2 只适用于有用户指定参考图的职业选手角色。发生视觉冲突时，优先级固定为：用户明确选择和当前角色参考图 > 本卡登记的身份锚点 > GOGO 项目技术规范 > 旧角色文字描述与旧 Prompt。

允许保留可识别的脸部整体关系和气质、发型发色、身形比例、无品牌日常服装的轮廓与主要色块，以及参考图表达的年龄感和站姿气质。必须去除真实战队队标、赞助商/平台/赛事 Logo、官方队服受保护图案、官方赛事 UI、奖杯、舞台、摄影背景、水印，以及未经单独确认的第三方道具或角色资产；参考图没有的职业身份元素不得新增。

R2 不是最终发布所需肖像权或第三方授权的结论。M5 人工门仍须决定该角色是否进入发布包。

## 2. 身份锚点

- 棕色、齐下颌附近的中短发，近似自然中分，发尾形成清晰的两侧轮廓；
- 偏瘦、四肢修长，但在 Q 版转译中保持紧凑；
- 宽松纯黑短袖上衣、黑色长裤、黑色鞋；
- 冷静、克制、略显疏离的表情；
- 自然站立，不采用夸张冲锋、前倾攻击或战术队服姿态。

旧 Prompt 中“凌乱深色短发、红橙点缀、紧凑运动体型、强烈前倾、黑色战术服”的冲突部分全部失效。

项目转译固定为紧凑 Q 版像素游戏角色、俯视 3/4、默认朝向右下、完整全身、双脚清晰、主体占画布约 72%～82%、左上光、深色像素外轮廓和有限色板。角色帧与头像逻辑画布均为 `128×128`。角色身体始终空手，武器为独立节点和独立资产。

> **历史批次边界（2026-07-31 single-direction C0 batch contract）**：本卡中
> “默认朝向右下”、四帧 `walk` 数量及面向右下的 walk QA，记录的是当日
> 单方向 `se` 的全臂 pose guide 合同和历史证据，并非八方向生产完成声明。
> `walk_001–004` 都是 `se` 全臂 pose guide；它们不计入后续 modular
> 八方向工作的 32 个 body layer、48 个 arm layer、24 个 grip group、96 个
> 合成 QA，也不进入之后的视觉门。
>
> 已批准的后续权威为
> `docs/superpowers/specs/2026-07-31-gogo-xiaodong-eight-direction-grip-design.md`。
> 该补充规格在其列明的方向、walk 数量与握持分层范围内优先于本历史合同；
> 新的 modular 八方向 C0 另行生产与验收，不能把本批次的单方向图改写为其
> 交付物。

## 3. 母版优先工作流

```text
参考图与 R2 规则
      ↓
视觉母版
      ↓ 用户/设计 QA 通过
动作关键姿势
      ↓ 一致性 QA 通过
轮廓、色板、透明边缘与锚点清理
      ↓
人工补间和 Sprite Sheet 组装
      ↓
Godot 实机验收
```

第一轮只允许生成视觉母版；母版未通过，不继续生成头像或动作。第二轮以已通过概念审查的母版和原始参考图共同约束头像与动作关键姿势，并让每个动作单独生成。第三轮只针对已识别问题返工，不用无目标反复生成替代问题诊断。

### C0 数量

以下数量是上述 2026-07-31 单方向批次的历史合同，不是后来八方向补充规格
的当前生产计数。尤其 `walk` 的 4 张均为 `se` 全臂 pose guide。

| C0 项目 | 数量 | 验证目标 |
|---|---:|---|
| 视觉母版 | 1 | 参考一致性与项目转译 |
| 头像母版 | 1 | 128×128 小尺寸脸部可识别性 |
| `idle` 关键姿势 | 2 | 呼吸、重心变化与脚底锚点 |
| `walk` 关键姿势 | 4 | 四肢交替、轮廓与身形稳定 |
| `hit` 关键姿势 | 2 | 短促、非血腥的受击语义 |
| `death` 关键姿势 | 3 | 无肢解的连续倒地路径 |
| `skill_breakin` 关键姿势 | 3 | 蓄力—爆发—回稳且无武器/特效 |

### 当前八方向分层目标

2026-07-31 后续书面批准改变当前生产计划，但不改写上表和候选账本的历史
结论。正式 `walk` 覆盖 `n,ne,e,se,s,sw,w,nw` 八方向；C0 每方向四相位
`contact_l,passing_l,contact_r,passing_r`，共 32 张无肩下手臂的
`walk_body` layer。八方向 × pistol/rifle/sniper 三类形成 24 个 grip
group，每组含 `back_arm/front_arm`，共 48 张空手 arm layer；32 个 body
分别与同方向三类握持确定性合成，共 96 个完整全身 QA 结果。

现有四张 cleaned `se` walk 帧均为带完整手臂的历史 full-arm pose guide，
不是 modular body 或 grip 输出。第一视觉门只制作八方向各一个 `contact_l`
body、八个 rifle grip group，以及 `se` 的 pistol/rifle/sniper 对比并形成
“八方向头身 + 三类握持”联系表；联系表交付后必须暂停，等待用户明确批准，
不得提前补齐其余 24 个 body layer 和 14 个握持组。

## 4. 批准 Prompt

### 完整正向 Prompt

```text
Create one standalone R2 game character sprite using the user-designated reference image and registered identity anchors.
The same slim young professional-player character with brown jaw-length medium-short hair, calm restrained expression, loose plain black short-sleeve shirt, black trousers, black shoes, natural standing posture, empty hands.
Top-down three-quarter view, full body, facing lower right, centered.
original compact chibi pixel-art game character, large head, small body, strong silhouette, thick dark pixel outline, limited palette, clean clustered pixels, consistent light from upper left, transparent background, production game asset.
```

### 角色 Prompt 中的批准排除段

```text
No weapon, no grenade, no text, no team logo, no sponsor mark, no platform or tournament logo, no official team-jersey pattern, no official tournament UI, trophy, stage or watermark, no environment, no cast shadow. Do not change hair length, hair color, body type or clothing color.
```

### R2 专用负面约束

```text
no text, no letters, no logo, no team logo, no sponsor mark, no platform or tournament logo, no official team-jersey pattern, no official tournament UI, no trophy, no stage, no watermark, no UI frame, no environment, no floor, no cast shadow, no weapon unless explicitly requested, no extra hands, no extra limbs, no photorealism, no smooth vector art, no 3D render, no anti-aliased blurry edges, no copyrighted character
```

本角色还必须完整执行以下批准排除项：

- 无队标、无赞助商、无赛事 Logo、无水印、无文字；
- 无武器、无手榴弹、无 UI、无场景；
- 无战术背心、无红橙强调色、无夸张冲锋姿态；
- 无额外手脚、无缺失肢体、无模糊抗锯齿边缘；
- 无写实照片、无 3D 渲染、无矢量插画；
- 不改变发长、发色、服装主色或体型。

R2 排除项不得追加 `no real-person portrait`。生成工具若支持负面 Prompt，将上述排除项放入负面框；不支持时追加在主 Prompt 后。

## 5. C0 QA（10 项全部为 1 才可进入 `accepted_for_concept`）

1. 棕色齐下颌中短发可读；
2. 偏瘦身形稳定；
3. 纯黑宽松短袖、黑裤、黑鞋；
4. 冷静克制气质；
5. 俯视 3/4 且朝向右下；
6. 全身完整、无多余或缺失肢体；
7. 无 Logo、文字、赞助商和赛事元素；
8. 空手，身体与武器完全分离；
9. 像素轮廓和有限色板符合项目语言；
10. 双脚和身体底部锚点适合动画。

动作关键姿势还必须通过逐帧叠加检查：发型、脸型、服装长度、身体宽度、脚底锚点不能产生无意漂移。

## 6. 候选记录表

每条候选记录须包含：候选 ID、生成时间、生成工具、源文件相对路径、参考图 ID 与 SHA-256、完整正向 Prompt 与排除项、目标动作、视角、逻辑画布、方向、帧用途、保留的身份锚点、与参考图的差异、技术 QA、设计 QA、决定、决定理由、下一轮只允许修改的项目、清理结果和最终 manifest 条目。

| 候选 ID | 生成时间 | 生成工具 | 源文件相对路径 | 参考图 ID / SHA-256 | 目标动作 / 帧用途 | QA | 决定 / 理由 | 清理结果 / manifest |
|---|---|---|---|---|---|---|---|---|
| `xiaodong_c0_master_001` | `2026-07-31T02:40:53+0800` | Codex built-in `image_gen`（模型名未暴露） | `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_001_source.png` | `reference_01` / `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52` | 视觉母版 / 身份与项目转译 | 独立复核 `9/10`，QA5 失败 | `revise` / 朝向近正面偏左，不是右下 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_master_002` | `2026-07-31T02:54:02+0800` | Codex built-in `image_gen`（模型名未暴露） | `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_002_source.png` | `reference_01` / `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52` | 视觉母版定向修订 / 身份与项目转译 | 代理预检 `10/10`，独立 QA5 通过 | `accepted_for_concept` / 用户明确回复“批准002” | `assets/source/cleaned/c0/xiaodong/master/xiaodong_c0_master_002_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_portrait_001` | `2026-07-31T09:09:59+0800` | Codex built-in `image_gen`（模型名未暴露） | `assets/source/generated/c0/xiaodong/portrait/xiaodong_c0_portrait_001_source.png` | 同上 | 头像母版 / 小尺寸脸部识别 | mapped `10/10`，见 7.1；头像锚点与 128 可读性通过 | `accepted_for_concept` / 发型、脸部关系和气质稳定 | `assets/source/cleaned/c0/xiaodong/portrait/xiaodong_c0_portrait_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_idle_001` | `2026-07-31T09:12:17+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_001_source.png` | 同上 | `idle` / 中性呼吸起点 | `10/10`，动作与锚点通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_idle_002` | `2026-07-31T09:14:20+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_002_source.png` | 同上 | `idle` / 轻微吸气尝试 | 基础 `10/10`，足部叠帧失败 | `revise` / 前脚约漂移 2 个逻辑像素 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_idle_003` | `2026-07-31T09:20:16+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_003_source.png` | 同上 | `idle` / 足部定向修订 | 基础 `10/10`，足部叠帧仍失败 | `revise` / 漂移改善但未锁死 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_idle_004` | `2026-07-31T09:30:56+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_004_source.png` | 同上 | `idle` / 合成姿势引导后的吸气帧 | `10/10`，清理后下半身逐像素锁定 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/idle/xiaodong_c0_idle_004_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_001` | `2026-07-31T09:10:36+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_001_source.png` | 同上 | `walk` / 左脚前接触 | `10/10`，动作与叠帧通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_002_v01` | `2026-07-31T09:13:11+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_002_v01_source.png` | 同上 | `walk` / passing 初次尝试 | 基础 `10/10`，动作相位失败 | `revise` / 仍近似接触帧 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_002` | `2026-07-31T09:15:27+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_002_source.png` | 同上 | `walk` / 左脚承重 passing | `10/10`，动作与叠帧通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_002_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_003_v01` | `2026-07-31T09:17:30+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_v01_source.png` | 同上 | `walk` / 右脚前接触尝试 | 基础 `10/10`，交替失败 | `revise` / 与 001 同相 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_003_v02` | `2026-07-31T09:20:07+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_v02_source.png` | 同上 | `walk` / 反相定向修订 | 基础 `10/10`，交替仍失败 | `revise` / 前后脚侧未改变 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_003_v03` | `2026-07-31T09:23:15+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_v03_source.png` | 同上 | `walk` / 镜像 pose-guide 尝试 | 基础 `10/10`，交替仍失败 | `revise` / 模型忽略姿势指南 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_003_v04` | `2026-07-31T09:25:09+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_v04_source.png` | 同上 | `walk` / pose-guide edit-target 尝试 | 基础 `10/10`，交替仍失败 | `revise` / 模型恢复 001 同相 | `not_cleaned` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_003` | `2026-07-31T09:28:01+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_source.png` | 同上 | `walk` / 合成姿势 edit-target 的右脚前接触 | `10/10`，与 001 反相且右下方向保持 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_003_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_walk_004` | `2026-07-31T09:23:10+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_004_source.png` | 同上 | `walk` / 右脚承重 passing | `10/10`，动作与叠帧通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_004_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_hit_001` | `2026-07-31T09:18:16+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/hit/xiaodong_c0_hit_001_source.png` | 同上 | `hit` / 短促受击 | `10/10`，非血腥受击语义通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/hit/xiaodong_c0_hit_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_hit_002` | `2026-07-31T09:21:16+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/hit/xiaodong_c0_hit_002_source.png` | 同上 | `hit` / 立即回正 | `10/10`，冲击—恢复连续 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/hit/xiaodong_c0_hit_002_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_death_001` | `2026-07-31T09:23:08+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/death/xiaodong_c0_death_001_source.png` | 同上 | `death` / 起倒 | `10/10`，失衡语义通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/death/xiaodong_c0_death_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_death_002` | `2026-07-31T09:25:08+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/death/xiaodong_c0_death_002_source.png` | 同上 | `death` / 倒伏中段 | `10/10`，路径与根部通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/death/xiaodong_c0_death_002_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_death_003` | `2026-07-31T09:26:56+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/death/xiaodong_c0_death_003_source.png` | 同上 | `death` / 完整横躺终态 | `10/10`，无血腥、无肢解 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/death/xiaodong_c0_death_003_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_skill_breakin_001` | `2026-07-31T09:09:01+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_001_source.png` | 同上 | `skill_breakin` / 蓄力 | `10/10`，动作与叠帧通过 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_001_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_skill_breakin_002` | `2026-07-31T09:10:40+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_002_source.png` | 同上 | `skill_breakin` / 爆发 | `10/10`，空手且无特效 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_002_cleaned.png` / 无正式 manifest 条目 |
| `xiaodong_c0_skill_breakin_003` | `2026-07-31T09:13:34+0800` | 同上 | `assets/source/generated/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_003_source.png` | 同上 | `skill_breakin` / 回稳 | `10/10`，三段语义闭合 | `accepted_for_concept` | `assets/source/cleaned/c0/xiaodong/keyposes/skill_breakin/xiaodong_c0_skill_breakin_003_cleaned.png` / 无正式 manifest 条目 |

当前候选记录数：`24`。

### 候选 `xiaodong_c0_master_001`

#### 生成与文件证据

- 生成时间：`2026-07-31T02:40:53+0800`；
- 生成工具：Codex built-in `image_gen`；工具未暴露底层模型名，因此不推定模型；
- 参考输入：`reference_01`，稳定路径
  `assets/source/references/characters/xiaodong/reference_01.jpg`，SHA-256
  `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52`；
- source：
  `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_001_source.png`，
  `1254×1254` RGB，`1,067,707` bytes，SHA-256
  `e81d6be97c3cb8653b7ccf0cc88237fc438679c4b23b3106faeffdcd185ac8b3`；
- review preview：
  `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_001_preview.png`，
  `1024×1024` RGBA，`207,770` bytes，SHA-256
  `77deca370527690e60d3f54ea8970c39a70b4b5694ad083d4e42360915270a8b`；
- source 使用平坦绿色抠像背景。review preview 仅用于本轮透明背景审阅，
  经本地抠像和最近邻缩放把主体高度从约 `90.9%` 规范到约 `80.0%`；
  它不代表正式 `cleaned` 状态。
- preview 派生步骤：`remove_chroma_key.py --auto-key border --soft-matte
  --transparent-threshold 12 --opaque-threshold 220 --despill`，边缘采样键色
  为 `#12f70f`；随后裁取 alpha bbox，以 nearest-neighbor 把主体缩放到
  `287×819`，并放置在 `1024×1024` 透明画布坐标 `(368, 102)`。

#### 实际完整 Prompt

```text
Use case: stylized-concept
Asset type: GOGO C0 game character visual master; one standalone identity-preserving pixel-art character candidate
Input images: Image 1 is the user-designated R2 identity reference only, not an edit target. Preserve the recognizable overall facial relationships and calm restrained presence, the brown jaw-length medium-short naturally center-parted hair with clear side silhouettes, slim long-limbed proportions translated into compact chibi form, and the plain black clothing silhouette. Do not reproduce any background or add professional-team identity elements.
Primary request: Create exactly one standalone R2 game character sprite of the same recognizable young professional-player character from Image 1, translated into the approved GOGO character language.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for local background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, lighting variation, or environment.
Subject: slim young character; brown jaw-length medium-short hair, natural center part, clear hair silhouette; calm restrained slightly distant expression; loose plain pure-black short-sleeve shirt, black trousers, black shoes; natural standing pose; empty hands.
Style/medium: original compact chibi pixel-art production game character; large head, small compact body, strong readable silhouette, crisp hard-edged clustered pixels, 1–2 logical-pixel dark outline, limited palette of brown hair, warm skin, black and dark-gray clothing; consistent upper-left light; no anti-aliased blurry edges.
Composition/framing: square 1024×1024 generation canvas; elevated top-down three-quarter view; full body; character faces lower right; centered; both feet fully visible; body-bottom/feet midpoint suitable as a stable animation anchor; character occupies about 72%–82% of canvas; generous clean padding; no crop.
Constraints: exactly one character and exactly two arms, two hands, two legs, and two feet; preserve recognizable likeness, hair length/color, slim body type, black clothing color, restrained expression, and natural stance from Image 1; no use of #00ff00 anywhere in the subject; no cast shadow, contact shadow, reflection, watermark, or text.
Avoid: weapon, grenade, prop, extra character, extra or missing limbs, fused hands or feet, team logo, sponsor mark, platform logo, tournament logo, official team-jersey pattern, official tournament UI, trophy, stage, photography background, watermark, text, letters, UI frame, environment, floor, tactical vest, red or orange accent, exaggerated charging pose, aggressive forward lean, photorealism, smooth vector art, 3D render, copyrighted character. Do not add “no real-person portrait”; recognizable R2 likeness is required.
```

#### 目标与身份一致性

- 目标：`visual_master`；帧用途：身份母版和后续头像/动作关键姿势约束；
- 视角：俯视 3/4；方向：右下；逻辑画布目标：`128×128`；
- 保留：棕色齐下颌中短发及自然中分、脸部整体关系和冷静气质、
  偏瘦身形、宽松纯黑短袖、黑裤、黑鞋、自然站姿；
- 可见差异：相对参考图进一步放大头部并压缩躯干与四肢，以形成紧凑
  Q 版比例；脸部轮廓略圆、服装褶皱更简化；未增加职业身份元素。

#### 技术 QA

- source 为 `1254×1254` RGB，平坦抠像背景；review preview 为
  `1024×1024` RGBA；
- preview 四角 alpha 为 `0`，透明像素 `897,609 / 1,048,576`，
  部分透明像素 `3,116 / 1,048,576`，非透明主体内未检出强绿色残留；
- source 与 preview 均为完整单人、两手两脚，无裁切、无多余或缺失肢体；
- preview 主体高度约 `80.0%`，双脚完整，身体底部中心可作为后续锚点；
- 像素轮廓、色板和边缘达到概念审阅可读性；尚未完成正式
  `128×128` 逻辑尺寸、逐像素轮廓、固定色板和动作叠帧清理，因此状态保持
  `generated`，不记为 `cleaned`。

#### 设计 QA（代理预检，用户视觉批准仍为待定）

| # | 检查项 | 0/1 | 证据 |
|---:|---|---:|---|
| 1 | 棕色齐下颌中短发可读 | 1 | 中分与两侧发尾轮廓清楚 |
| 2 | 偏瘦身形稳定 | 1 | 四肢修长且 Q 版比例紧凑 |
| 3 | 纯黑宽松短袖、黑裤、黑鞋 | 1 | 三项均完整且无额外主色 |
| 4 | 冷静克制气质 | 1 | 表情自然、无挑衅或攻击姿势 |
| 5 | 俯视 3/4 且朝向右下 | 0 | 头部明显偏左，肩髋近正面，未建立右下轴线 |
| 6 | 全身完整、无多余或缺失肢体 | 1 | 单人、两手、两脚、无裁切 |
| 7 | 无 Logo、文字、赞助商和赛事元素 | 1 | 服装纯色，画面无标记 |
| 8 | 空手，身体与武器完全分离 | 1 | 双手均为空，无道具 |
| 9 | 像素轮廓和有限色板符合项目语言 | 1 | 深色块状轮廓，棕/肤/黑灰有限色板 |
| 10 | 双脚和身体底部锚点适合动画 | 1 | 双脚完整、底部中心清楚 |

独立复核合计：`9/10`。QA5 不能诚实通过，因此本候选不进入
`accepted_for_concept`。

#### 当前决定与下一步

- artifact state：`generated`；
- decision：`revise`；
- 理由：身份、服装、R2 禁止项和像素语言可用，但身体近正面偏左、头与
  视线明显偏左，未满足“俯视 3/4 且朝向右下”；
- 下一轮只允许修改：保持身份、发型、身形、服装、色板、空手姿态和
  R2 禁止项不变，只把头、肩髋和双脚的方向轴修正为明确右下；在母版
  通过前不生成头像或任何动作关键姿势；
- cleaning result：`not_cleaned`；review preview 不是正式清理结果；
- final manifest：无；六项 A5 正式素材继续保持 `planned`，不进入 Godot。

### 候选 `xiaodong_c0_master_002`

#### 生成与文件证据

- 生成时间：`2026-07-31T02:54:02+0800`；
- 生成工具：Codex built-in `image_gen`；工具未暴露底层模型名，因此不推定模型；
- edit target：`xiaodong_c0_master_001` source；本轮只定向修复朝向；
- 身份参考：`reference_01`，稳定路径
  `assets/source/references/characters/xiaodong/reference_01.jpg`，SHA-256
  `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52`；
- source：
  `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_002_source.png`，
  `1254×1254` RGB，`1,075,553` bytes，SHA-256
  `2c8d1f241caf81751df87b2a4959684112debe5b79c159646f7794c639c007a1`；
- review preview：
  `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_002_preview.png`，
  `1024×1024` RGBA，`221,013` bytes，SHA-256
  `0df03821de864e678971d103cfb1d39d79b9ea9ef446d799e0e076469f9e3fe3`；
- source 使用平坦绿色抠像背景。review preview 仅用于本轮透明背景审阅，
  不代表正式 `cleaned` 状态；
- preview 派生步骤：`remove_chroma_key.py --auto-key border --soft-matte
  --transparent-threshold 12 --opaque-threshold 220 --despill`，边缘采样键色
  为 `#11f116`；随后裁取 alpha bbox `(458, 90)–(804, 1104)`，以
  nearest-neighbor 把主体从 `346×1014` 缩放到 `279×819`，并放置在
  `1024×1024` 透明画布坐标 `(372, 102)`。

#### 实际完整 Prompt

```text
Use case: identity-preserve
Asset type: GOGO C0 game character visual master, targeted revision 002
Input images: Image 1 is the current visual-master edit target. Image 2 is the user-designated R2 identity reference. Preserve Image 1's approved pixel-art treatment and preserve the recognizable identity anchors from Image 2.
Primary request: Change only the character's facing direction and three-quarter pose. Make the head, gaze, nose/chin, shoulders, hips, knees, and both feet read unmistakably as facing toward the SCREEN LOWER-RIGHT corner under an elevated top-down three-quarter camera. The direction vector must be diagonally down and right on the image, not frontal, not lower-left, and not ambiguous.
Pose clarification: turn the face so nose, eyes, mouth, and chin point visibly toward image-right and slightly downward; establish a clear three-quarter shoulder and hip axis toward lower-right; align both shoes with that same lower-right travel axis, with one foot naturally leading. Keep an upright calm natural standing pose, not an attack or charging pose.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for local removal; one uniform color, no shadow, gradient, texture, reflection, floor plane, lighting variation, or environment.
Invariants: keep exactly the same recognizable young character identity, brown jaw-length naturally center-parted hair and hair silhouette, facial relationships, calm restrained expression, slim compact chibi body proportions, loose plain pure-black short-sleeve shirt, black trousers, black shoes, empty hands, crisp clustered pixel art, dark pixel outline, limited brown/warm-skin/black-gray palette, and upper-left light. Keep exactly one full-body character with two arms, two hands, two legs, and two fully visible feet. Center the character on a square canvas with generous padding and about 72%–82% subject height.
Constraints: modify only direction/three-quarter orientation; no redesign, no new garment details, no weapon, grenade, prop, text, letters, team logo, sponsor mark, platform or tournament logo, official jersey pattern, official tournament UI, trophy, stage, photography background, watermark, UI frame, floor, cast shadow, tactical vest, red or orange accent, extra or missing limbs, fused hands or feet, aggressive lean, photorealism, smooth vector art, 3D render, blurry anti-aliased edges, or copyrighted character. Do not add “no real-person portrait”; recognizable R2 likeness is required.
```

本轮实际 Prompt 使用平坦抠像背景而非模型原生透明输出，是 built-in
`image_gen` 工作流的工具约束。设计卡继续保留批准 Prompt 中的透明背景
要求，并把 source 与派生 alpha preview 分开记录；在正式清理前不把该
偏差描述为已解决。

#### 目标与身份一致性

- 目标：`visual_master` 定向修订；帧用途：身份母版和后续头像/动作关键姿势约束；
- 视角：俯视 3/4；方向：右下；逻辑画布目标：`128×128`；
- 保留：棕色齐下颌中短发、脸部整体关系和冷静气质、偏瘦身形、宽松
  纯黑短袖、黑裤、黑鞋、自然空手站姿；
- 相对候选 001 的唯一目标变化：头、视线、肩髋、膝盖和双脚共同建立
  明确右下轴线；
- 相对参考图的可见差异：Q 版头身比更紧凑；右下转向使一侧刘海与面部
  遮挡关系更强；服装褶皱进一步简化；未增加职业身份元素。

#### 技术 QA

- source 为 `1254×1254` RGB，平坦抠像背景；review preview 为
  `1024×1024` RGBA；
- preview alpha bbox 为 `(372, 102)–(651, 921)`，主体高度约 `80.0%`；
- preview 四角 alpha 为 `0`，透明像素 `898,062 / 1,048,576`，
  部分透明像素 `3,414 / 1,048,576`，不透明像素
  `147,100 / 1,048,576`；
- 非透明主体内未检出强绿色残留；非零 alpha 只有一个连通主体；
- source 与 preview 均为完整单人、两手两脚，无裁切、无多余或缺失肢体；
- 双脚完整，身体底部中心可作为后续锚点；
- 像素轮廓、色板和边缘达到概念审阅可读性；尚未完成正式
  `128×128` 逻辑尺寸、逐像素轮廓、固定色板和动作叠帧清理，因此状态保持
  `generated`，不记为 `cleaned`。

#### 设计 QA（代理预检，用户视觉批准仍为待定）

| # | 检查项 | 0/1 | 证据 |
|---:|---|---:|---|
| 1 | 棕色齐下颌中短发可读 | 1 | 棕色中分与两侧齐颌轮廓清楚 |
| 2 | 偏瘦身形稳定 | 1 | 四肢修长且 Q 版比例紧凑 |
| 3 | 纯黑宽松短袖、黑裤、黑鞋 | 1 | 三项均完整且无额外主色 |
| 4 | 冷静克制气质 | 1 | 表情自然、无挑衅或攻击姿势 |
| 5 | 俯视 3/4 且朝向右下 | 1 | 独立方向复核通过；头身与双脚建立右下轴线 |
| 6 | 全身完整、无多余或缺失肢体 | 1 | 单人、两手、两脚、无裁切 |
| 7 | 无 Logo、文字、赞助商和赛事元素 | 1 | 服装纯色，画面无标记 |
| 8 | 空手，身体与武器完全分离 | 1 | 双手均为空，无道具 |
| 9 | 像素轮廓和有限色板符合项目语言 | 1 | 深色块状轮廓，棕/肤/黑灰有限色板 |
| 10 | 双脚和身体底部锚点适合动画 | 1 | 双脚完整、底部中心清楚 |

代理预检合计：`10/10`；QA5 另经独立方向复核，以约 `90%` 置信度通过。
该预检在用户决定前只构成审阅入口，不单独构成
`accepted_for_concept`；最终视觉决定见下方用户批准记录。

#### 用户批准记录

- 决定时间：`2026-07-31T08:57:23+0800`；
- 用户原文：`批准002`；
- 决定：`accepted_for_concept`；
- 范围：只批准 `xiaodong_c0_master_002` 作为 C0 视觉母版和后续头像/
  动作关键姿势的一致性依据；
- 不包含：正式 `cleaned`、A5 `approved`/`in_game`、Godot 导入、M5
  发布权利判断或任何第三方授权结论。

#### 当前决定与下一步

- artifact state：`generated`；
- decision：`accepted_for_concept`；
- 理由：候选 002 已通过代理 `10/10` 预检、独立方向复核和独立 checkpoint
  Review，用户随后明确回复“批准002”；
- 下一轮允许内容：只以候选 002 和原始参考共同约束一张头像母版与
  `idle/walk/hit/death/skill_breakin` 的批准数量关键姿势；每个动作独立
  生成，不混入武器、文字、UI、场景或技能特效；
- cleaning result：
  `assets/source/cleaned/c0/xiaodong/master/xiaodong_c0_master_002_cleaned.png`，
  `128×128` RGBA，`5,672` bytes，SHA-256
  `d87c3a64fc69fa19cfe40618a16f4a4cf521645702f83575345755f384f1efd0`；
  review preview 本身仍不是正式清理结果；
- final manifest：无；六项 A5 正式素材继续保持 `planned`，不进入 Godot。

## 7. 批准后 C0 批次、Prompt 与 QA 适用性

完整逐候选 source/preview/cleaned 哈希、可重构实际完整 Prompt、输入顺序、
R2 排除项、技术 QA、动作叠帧、revise 原因和下一步限制统一记录在：

`assets/characters/xiaodong/xiaodong_c0_batch_2026-07-31.md`

本卡第 6 节的 24 行候选表拥有候选 ID、动作、决定和清理结果；批次账本
是这些行的证据附件，不另行拥有决定。两者合起来满足“每次生成后可追溯到
参考图、完整 Prompt、QA、决定和清理结果”的记录契约。

### 7.1 头像候选的 10 项适用性映射

第 5 节的原始 10 项以全身动作帧为默认措辞，而第 3 节同时明确要求一张
head-and-shoulders 头像母版。不能为了满足“全身”字面要求而给头像补出
裤、鞋、手或脚底，也不能把未显示内容描述成直接可见证据。头像按以下
映射评分，结果写为“5 项直接证据 + 5 项批准母版继承证据 = 10/10 mapped”：

| 原 QA | `portrait_001` 证据类型 | 证据 |
|---:|---|---|
| 1 | 直接 | 棕色齐颌中短发、自然中分与两侧轮廓完整 |
| 2 | 继承 + 直接 | master 002 的偏瘦身形已通过；头像颈肩比例未改变身份 |
| 3 | 继承 + 直接 | 黑色短袖在肩胸直接可见；黑裤/黑鞋继承自同一批准母版，不伪造为可见 |
| 4 | 直接 | 冷静克制、略疏离的脸部气质可读 |
| 5 | 直接 | 脸、视线、鼻颏和肩轴均为右下 3/4 |
| 6 | 资产类型映射 | 意图明确的 bust crop 内解剖完整；全身完整性由 master 002 提供 |
| 7 | 直接 | 无 Logo、文字、赞助商和赛事元素 |
| 8 | 继承 + 直接 | crop 内无手、武器或道具；空手身体关系继承自 master 002 |
| 9 | 直接 | 128×128 清晰像素簇、深色轮廓和共享有限色板 |
| 10 | 资产类型映射 | 使用 face center / shoulder midpoint；头像不使用脚底锚点 |

因此头像的用途验收不是把严格全身向量假写为直接 `10/10`，而是明确的
mapped `10/10`。后续若修改第 5 节为结构化 schema，应把 `asset_type`
适用性写入 schema，避免再次依赖文字解释。

### 7.2 横躺 death 的根部契约

`death_002` 与 `death_003` 不再使用站立脚底；两张规范化 preview 的
alpha bbox 中心均为 `(512,600)`，清理后中心约为 `(64,75)`。这就是
横躺中段和终态的躯干/髋部 root。`death_003` 的 bbox bottom 比
`death_002` 高，是横向终态更薄的自然结果，不表示角色上浮；若把终态
强行下移到底边 `y=114`，反而会把 root 从约 `(64,75)` 移走并破坏连续性。

### 7.3 skill_breakin 的统一序列缩放

`skill_breakin` 三帧不再各自拉满 `819px`，而共同使用 frame 003 的原始
主体高度 `948px → 819px` 缩放率。preview 高度为 `746→811→819px`，
清理后 alpha top 为 `22→14→13` 且 bottom 都为 `114`，因此“压低重心—
短距爆发—回稳”在固定脚底基线上可读；不靠武器、火焰、文字或特效表达。

## 8. C0 / A5 / Godot 边界

- C0 输出只是概念候选和动作依据，不登记为 A5 的 `generated`、`cleaned`、`approved` 或 `in_game`。
- C0 的 `accepted_for_concept` 只表示概念审查结果，不替代正式 manifest 生命周期状态。
- 本历史批次发生时，A5 manifest 只有六项，且均为 `planned`；对应旧批次
  ledger 继续作为历史快照，不回写为十二项。
- 2026-07-31 后续批准后的当前 A5 计划为十二项 `planned` 记录：原六项加
  六张握持 layer。当前计划目录的变化不代表历史批次当时已有十二项，也不
  提前改变任何 A5 状态。
- C0 原始生成图不得直接进入 Godot，也不得伪装成正式 A5 Sprite Sheet。
- 只有清理、正式验收、manifest 证据与文件位置一致的 A5 资产，才可按正式状态流继续。
