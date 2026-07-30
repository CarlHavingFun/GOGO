# 小洞大人｜C0 视觉与动作设计卡

- 设计阶段：`C0`
- 资产阶段：`A5`（仅登记正式生产计划）
- artifact state：`not_generated`
- decision：`pending_review`
- 权威规格：`docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`

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

| C0 项目 | 数量 | 验证目标 |
|---|---:|---|
| 视觉母版 | 1 | 参考一致性与项目转译 |
| 头像母版 | 1 | 128×128 小尺寸脸部可识别性 |
| `idle` 关键姿势 | 2 | 呼吸、重心变化与脚底锚点 |
| `walk` 关键姿势 | 4 | 四肢交替、轮廓与身形稳定 |
| `hit` 关键姿势 | 2 | 短促、非血腥的受击语义 |
| `death` 关键姿势 | 3 | 无肢解的连续倒地路径 |
| `skill_breakin` 关键姿势 | 3 | 蓄力—爆发—回稳且无武器/特效 |

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

当前候选记录数：`0`。

## 7. C0 / A5 / Godot 边界

- C0 输出只是概念候选和动作依据，不登记为 A5 的 `generated`、`cleaned`、`approved` 或 `in_game`。
- C0 的 `accepted_for_concept` 只表示概念审查结果，不替代正式 manifest 生命周期状态。
- C0 决定永远不改变六项 A5 正式资产的 manifest 状态；在 M4 入口条件满足前，六项 A5 资产保持 `planned`。
- C0 原始生成图不得直接进入 Godot，也不得伪装成正式 A5 Sprite Sheet。
- 只有清理、正式验收、manifest 证据与文件位置一致的 A5 资产，才可按正式状态流继续。
