# GOGO 主线整合记录（2026-07-31）

## 结论

- 当前整合分支从最新 `origin/main` 建立，默认产品路线为无限 Chunk 双尘荒原。
- 默认入口：`res://scenes/run/infinite_desert_prototype.tscn`。
- M0 回归入口永久保留：`res://scenes/run/m0_ak_lab.tscn`。
- 生产代码统一位于 `src/`；旧的 `entities/`、`systems/`、`run/`、`ui/` 重复运行时实现不再并存。
- 远端分支全部保留，不执行删除；本记录是来源、纳入内容和 supersede 关系的审计入口。

## 分支来源与纳入内容

| 来源分支 | 纳入内容 | 决策 |
|---|---|---|
| `origin/main` @ `2b8b64a515026741140b7a600d683d370c945ecf` | 原始主线与 foundation 合并基线 | 作为整合起点 |
| `origin/foundation/topdown-kit-evaluation` @ `b3ab56e16aae70bddc1753061bfd5a9b4fd98ac2` | `WeaponDefinition` 静态契约、纯 `WeaponRuntime`、确定性散布、命中反馈、M0 测试与 CI 契约 | 保留为 M0 回归行为基线，并迁入 `src/combat/`、`src/actors/`、`src/presentation/` |
| `origin/docs/arena-spawn-design` @ `ed7a7fd07f4a755d071da5943b587bb7ab386ecb` | Chunk 流、荒漠模块、环形刷怪、安全距离、地形过滤、对象池和空间设计 | 作为当前无限世界产品和系统来源，代码统一迁入 `src/world/`、`src/spawn/`、`src/arena/`、`src/actors/`、`src/run/` |
| `origin/codex_goal` @ `731b658f0c87f5a4157ce983d51a8025f6b4fc14` | `src/` 基础布局、内容快照、`ContentValidator`、C0/A5 治理、M0 代码与素材登记 | 作为代码治理和验证器基线 |
| `origin/codex/m0-ak-shooting-toy` @ `ce691ce4ac7736da04f7b4021b2dc1ccd944a0da` | 早期 M0 射击玩具实现 | 已被 `codex_goal` 的 `src/` M0 实现覆盖，不保留第二套实现 |
| `origin/docs/m0-xiaodong-animation-goal` @ `b759be680b413b51ad1dc2a20d4f68823ad4a61a` | Xiaodong 参考图治理、A5 资产规划、角色动画约束 | 保留参考图、设计卡、manifest 契约和生产记录 |
| `origin/docs/pixel-style-bible` @ `abc30d3693cc7f0e09fba8a42d9d51e7bfcfe062` | Style Bible、像素规范、图标与图集规划 | 纳入设计权威链和素材流程 |
| `origin/review/gameplay-art-foundation` @ `dc0eccef95c4f9ac0f26e4e78876465b0edf6922` | 删除重复/过时文档和根目录运行时实现的清理结果 | 清理结果已体现在统一 `src/` 结构中；不重复合并删除提交 |
| `origin/verification/m0-godot-ci` @ `de7e04b6cc57cf2c88974d1d5979e9cc1e27590a` | M0 Godot CI 和回归验证增量 | 保留验证要求，并扩展为 M0 + 无限世界双门禁 |

## 结构裁决

荒漠功能的最终路径：

```text
src/world/chunk_stream_planner.gd
src/world/desert_chunk_layout.gd
src/world/infinite_chunk_manager.gd
src/spawn/spawn_ring_sampler.gd
src/spawn/infinite_spawn_director.gd
src/arena/infinite_desert_chunk.gd
src/actors/prototype_chaser.gd
src/run/infinite_desert_run_root.gd
scenes/run/infinite_desert_prototype.tscn
```

M0 射击契约最终路径：

```text
src/combat/weapon_definition.gd
src/combat/weapon_runtime.gd
src/combat/spread_sampler.gd
src/combat/deterministic_spread.gd
src/combat/weapon_controller.gd
scenes/run/m0_ak_lab.tscn
```

foundation 的模块化设计被保留：静态武器数据、纯运行时状态、确定性散布、玩家/武器/目标/表现分层和回归测试仍是稳定契约；仅将旧目录路径统一到 `src/`，并为无限世界增加独立的 world/spawn/arena/run 模块。

## 被 supersede 的重复路径

以下旧路径不再作为生产实现：

- `entities/` 下旧 Player、Enemy、Dummy 实现；
- `systems/combat/` 下重复的 M0 武器运行时和散布实现；
- `systems/world/`、`systems/spawn/` 下已迁移的荒漠实现；
- `run/` 下旧 RunRoot 和默认场景；
- `ui/`、`vfx/` 下旧 M0 表现实现；
- 早期 `docs/m0/README.md` 和重复测试 runner。

历史计划可以保留旧路径作为当时的实施记录，但现行设计、代码、README 和入口必须引用最终 `src/` 与 `scenes/run/` 路径。

## 冲突决策

1. 产品方向以无限 Chunk 文档和已确认的主线裁决为准；固定竞技场只作 M0/未来模式。
2. 代码结构以 `codex_goal` 的 `src/` 治理为准，荒漠分支只提供功能模块和契约，不复制旧目录。
3. M0 行为以 foundation 契约为回归基线；`WeaponRuntime` 和 `SpreadSampler` 各保留一套实现。
4. `sprite_layout` 表示最终交付布局；Agent Sprite Forge 的 raw layout 单独写入 `raw_layout`，不得把原始网格当作运行时图集。
5. 当前两个工作树的 `project.godot` 改动以及 `.import`、`.translation` sidecar 未重置、未纳入本整合提交。

## 验证证据

- 已完成 `git fetch --all --prune`，整合分支从最新 `origin/main` 建立。
- Godot 4.7.1 headless 项目扫描完成。
- `tests/test_runner.gd` 已覆盖 M0、Chunk 负坐标/队列/卸载、环形刷怪、对象池和默认场景集成；当前整合工作树运行结果为 `TESTS PASSED`。
- `gogo-agent-sprite-forge`、固定提交的 `generate2dsprite` 和 `generate2dmap` 均通过 `skill-creator` 的 `quick_validate.py`。
- 临时 `2x2` Pillow fixture 经 `generate2dsprite.py process --strict-qc` 通过，产出 4 个 frame PNG、GIF、透明 sheet、`pipeline-meta.json`、Prompt 证据和 `scale_profile.json`；首次 edge-touch 失败也被 QC 正确拦截。
- `ContentValidator --profile=g0` 通过；`--profile=full` 正确以 `NOT_READY` 退出。
- 后续提交继续记录 Markdown 断链、Godot 600 帧 smoke 和 CI 结果。
