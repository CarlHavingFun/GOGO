# GOGO

GOGO 是使用 Godot 4.7.1 开发的俯视角单人 PvE 原型。当前主线是固定 Seed、按 Chunk 流式延伸的无尽双尘荒原；固定竞技场只保留为 M0 射击回归场景和未来模式设计参考。

## 默认入口

```text
res://scenes/run/infinite_desert_prototype.tscn
```

M0 回归场景永久保留：

```text
res://scenes/run/m0_ak_lab.tscn
```

默认场景验证 Chunk 加载/卸载、确定性模块布局、屏幕外环形刷怪、对象池回收和 AK 射击契约；M0 场景独立验证弹匣、换弹、后坐力、散布和命中反馈。

## 入口文档

- [CODEX_START.md](CODEX_START.md)：Agent 执行入口和验证命令。
- [设计文档索引](docs/design/README_设计文档索引.md)：唯一权威设计关系。
- [主线整合记录](docs/progress/2026-07-31-mainline-integration.md)：分支来源、冲突决策和验证证据。
- [素材生产管线](docs/design/13_素材生产管线与提示词.md)：Agent Sprite Forge 的 GOGO 生产契约。
- [assets/README.md](assets/README.md)：资产登记、证据和 Godot 交付规则。
- [Agent Sprite Forge wrapper](skills/gogo-agent-sprite-forge/SKILL.md)：GOGO 素材任务的强制执行入口。

文档权威关系：`docs/design/` 是当前设计权威；`docs/superpowers/specs/` 是已批准规格；`docs/superpowers/plans/` 是实施计划；`docs/progress/` 和 `docs/status/` 只记录事实证据与阶段状态；旧合集、兼容性资料和历史分支快照不得覆盖当前路线。

## 运行时结构

```text
src/
├─ actors/       玩家、训练假人、追击敌人
├─ arena/        Chunk 地形和碰撞组件
├─ combat/       WeaponDefinition、WeaponRuntime、SpreadSampler、射击控制
├─ content/      内容快照、ContentValidator 和 CLI
├─ presentation/命中反馈、音效占位、武器视图
├─ run/          无尽世界 RunRoot
├─ spawn/        环形采样、刷怪导演和对象池
├─ ui/           HUD、准星
└─ world/        Chunk 规划、确定性布局、流式管理
```

生产代码只使用 `src/`；旧的 `entities/`、`systems/`、`run/`、`ui/`、`vfx/` 根目录实现已收敛为历史来源，不再与主线并存。

## 验证

```text
Godot 4.7.1 --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
Godot 4.7.1 --headless --audio-driver Dummy --path . --quit-after 600
```

内容门禁保持兼容：

```text
Godot 4.7.1 --headless --path . --script res://tools/validate_content.gd -- --profile=g0
Godot 4.7.1 --headless --path . --script res://tools/validate_content.gd -- --profile=full
```

`--profile=g0` 应得到 `G0 gate: PASS`；`--profile=full` 在完整 catalog 落地前应明确报告 `Full catalog: NOT_READY`。

正式素材不得把生图 raw 文件直接当作运行时 Sprite，必须经过清理、切帧、对齐、严格 QC、确定性 delivery 组装和 Godot 导入证据。
