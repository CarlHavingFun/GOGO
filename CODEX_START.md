# CODEX_START｜GOGO 开发执行入口

这是 Codex 或新开发者进入仓库后的第一份文件。当前主线已经确定为“按 Chunk 流式延伸的无尽双尘荒原”，不要把固定竞技场重新设为默认入口。

## 先读什么

1. [设计文档索引](docs/design/README_设计文档索引.md)
2. [产品宪法](docs/design/00_产品宪法.md)
3. [无尽世界规格](docs/design/16_无尽双尘荒原与程序化模块系统.md)
4. [Godot 技术架构](docs/design/09_Godot技术架构.md)
5. [素材生产管线](docs/design/13_素材生产管线与提示词.md)
6. [资产登记规则](assets/README.md)
7. [主线整合记录](docs/progress/2026-07-31-mainline-integration.md)

如果任务涉及角色、武器、特效、地图或动画素材，还必须读取：

```text
skills/gogo-agent-sprite-forge/SKILL.md
skills/generate2dsprite/SKILL.md
skills/generate2dmap/SKILL.md
```

## 作者确认的执行约束

- 开发必须使用 Godot MCP skill。
- 生图必须使用 Agent Sprite Forge，并使用 Codex 规划资产生产。
- 原始图使用内置 imagegen 生成，再自动去背景、处理透明通道、切分帧、统一缩放和底部锚点。
- 交付透明 PNG、GIF 和元数据；地图任务同时支持 Godot 场景、TileMap、碰撞体和分离式道具。
- `good_practice/` 保存作者认可的 demo 图片；当前示例为 `good_practice/donk.png`。

## 权威关系

- `docs/design/` 是唯一当前设计权威；`00_产品宪法.md` 优先级最高。
- `docs/superpowers/specs/` 是已批准专项规格；`docs/superpowers/plans/` 是实施计划。
- `docs/progress/` 只记录事实证据、阶段状态和整合决策。
- `docs/design/GOGO_完整设计文档合集_v0.1.md`、兼容性资料和旧分支记录是 historical/auxiliary，不覆盖当前专项规格。
- `assets/asset_manifest.csv` 是资产源数据；`data/content_validation.json` 是内容门禁配置。

## 当前运行时契约

默认入口：`res://scenes/run/infinite_desert_prototype.tscn`。

M0 回归入口：`res://scenes/run/m0_ak_lab.tscn`。

```text
src/world/       ChunkStreamPlanner、DesertChunkLayout、InfiniteChunkManager
src/spawn/       SpawnRingSampler、InfiniteSpawnDirector
src/arena/       InfiniteDesertChunk 及地形碰撞
src/actors/      PlayerController、TrainingDummy、PrototypeChaser
src/combat/      WeaponDefinition、WeaponRuntime、SpreadSampler、WeaponController
src/run/         InfiniteDesertRunRoot
src/ui/          CombatHUD、CombatCrosshair
src/presentation CombatFeedback、AudioFeedback、PlayerWeaponView
```

Chunk 契约必须保持：

- `ChunkStreamPlanner.world_to_chunk()`、`desired_coords()`、`build_load_queue()`、`coords_to_unload()`；
- `DesertChunkLayout.configure()`、`chunk_seed()`、`describe()`；
- `InfiniteChunkManager.force_refresh()`、`get_active_chunk_count()`、`get_active_coords()`；
- `SpawnRingSampler.configure()`、`sample()`；
- `InfiniteSpawnDirector.active_enemy_count()`、`pooled_enemy_count()`。

M0 契约必须保持：

- `WeaponDefinition` 保存静态数据并可 `validate()`；
- `WeaponRuntime` 是无场景/无输入的纯运行时状态；
- `SpreadSampler` 使用可注入 Seed 的独立随机流；
- 玩家、武器控制、目标、反馈和 HUD 分层；
- 命中、命中反馈、换弹和固定 Seed 散布有自动测试。

## 验证命令

```powershell
& $godot --headless --audio-driver Dummy --path . -s res://tests/test_runner.gd
& $godot --headless --audio-driver Dummy --path . --quit-after 600
& $godot --headless --audio-driver Dummy --path . --script res://tools/validate_content.gd -- --profile=g0
& $godot --headless --audio-driver Dummy --path . --script res://tools/validate_content.gd -- --profile=full
```

完成声明必须附带真实命令输出。`g0` 通过不代表完整内容目录 ready；`full` 当前必须诚实报告 `NOT_READY`。
