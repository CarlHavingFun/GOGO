# GOGO 素材资产与 Agent Sprite Forge 交付

本目录保存正式运行时素材、原始生成物的登记信息，以及每个资产从规划到 Godot 接入的可审计证据。素材生产以 [docs/design/13_素材生产管线与提示词.md](../docs/design/13_素材生产管线与提示词.md) 为权威流程，以 `assets/asset_manifest.csv` 为唯一生产清单。

## 固定工具链

- Agent Sprite Forge 上游仓库：<https://github.com/0x0funky/agent-sprite-forge>
- 固定快照：`64fd0b57d3f2ae117ef0a95e4c2decc25b4c9dd2`
- 仓库授权：MIT；本项目只纳入 `generate2dsprite` 与 `generate2dmap`，不把 `video2dsprite` 作为 Codex 默认流程。
- 项目入口：`skills/gogo-agent-sprite-forge/SKILL.md`
- 上游快照：`skills/generate2dsprite/SKILL.md`、`skills/generate2dmap/SKILL.md`

GOGO wrapper 负责把上游参数映射到 A0–A5、C0、原创/IP 边界和 Godot 运行时契约。处理 GOGO 角色、武器、特效、地图或动画前，必须先阅读 wrapper、本文档、素材生产规范和当前 manifest。

## Manifest 字段

生产清单保留 `sprite_layout`，它只表示最终运行时交付布局；生成阶段布局单独记录在 `raw_layout`。当前 33 列中的 Forge 相关字段如下：

| 字段 | 约束 |
|---|---|
| `forge_mode` | `generate2dsprite`、`generate2dmap`、`runtime_native` 或 `procedural_placeholder` |
| `raw_layout` | 原始生成网格，例如 `2x2`、`2x3`、`2x4`、`4x4`；不得直接当作交付布局 |
| `prompt_path` | 手写 Prompt 和排除项的证据文件 |
| `pipeline_meta` | 清理、切帧、对齐、QC 和交付组装的机器可读记录 |
| `scale_profile` | 多动作高价值角色共享的尺寸、锚点和安全区域配置 |
| `sprite_layout` | 最终横向条带、最终图集、单帧或地图元数据布局 |

旧的 28 列 fixture 仍可被 validator 读取，正式 `assets/asset_manifest.csv` 使用 33 列 canonical header。

## 生命周期

```text
planned -> generated -> cleaned -> approved -> in_game
                    \-> rejected
```

- `planned`：先登记用途、路径、尺寸、动作、Prompt 章节和运行时契约；生成证据字段可为空。
- `generated`：必须有 Forge 模式、原始布局、Prompt、原始输出；上游多行网格仍是 raw layout。
- `cleaned`：完成透明背景、轮廓、色板、锚点、切帧和严格 QC，并保存 `pipeline_meta` 与清理输出。
- `approved`：有 QA、reviewer 和 Godot evidence 后，才允许确定性组装交付布局。
- `in_game`：通过 Godot 导入和实际场景验证，补齐 `godot_import` 与运行时证据。
- `rejected`：保留失败原因和 QA 记录，不得拥有稳定运行时路径。

raw sprite、raw map 和未经 QC 的透明处理结果永远不能直接填入最终 `path` 或直接被场景引用。

## 目录与证据建议

```text
assets/
├─ asset_manifest.csv
├─ source/references/       # 参考图原件及 hash/rights 记录
├─ raw/                     # Agent Sprite Forge 原始网格或地图输出
├─ cleaned/                 # 清理、切帧、对齐、QC 中间物
├─ prompts/                 # prompt-used.txt 或等价 Prompt 证据
├─ pipeline/                # pipeline-meta.json、QA 和 Godot evidence
└─ <runtime category>/      # 仅存最终可交付运行时资产
```

每次生成必须能从 manifest 追溯到 Prompt、pipeline metadata、清理结果、QA 记录和 Godot 导入证据。连续两轮出现同类错误时，先改 Prompt、参考图或资产拆分，再开始下一轮。

## 当前门禁

```text
G0 gate: PASS
Full catalog: NOT_READY
```

`--profile=g0` 只证明 G0 所需文档、固定参考和 manifest 契约满足门禁；`--profile=full` 在完整角色、武器、波次和解锁内容落地前必须保持 `NOT_READY`。

## Godot 导入基线

- Filter：Off
- Compression：Lossless
- Mipmaps：战斗 Sprite 默认 Off
- Repeat：仅无缝 Tile 开启
- 使用整数倍最近邻缩放
- 角色锚点落在脚底或身体底部中心；武器单独记录握持点、枪口点和弹壳点
- 每个交付条带或图集的帧尺寸一致，动画帧不得发生锚点漂移
