# M0 AK 射击玩具实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 交付一个可直接运行和回归验证的 Godot 4.x AK 灰盒射击场景。

**Architecture:** `WeaponDef` Resource 保存 AK 静态参数；纯逻辑 `WeaponRuntime` 与 `SpreadSampler` 管理弹匣、换弹、后坐力和独立战斗随机子流；玩家、武器、假人、反馈层和 HUD 使用职责单一的 Godot 节点脚本组装。射击使用 2D 射线，曳光方向与真实判定共享同一结果。

**Tech Stack:** Godot 4.7.1 stable、强类型 GDScript、Godot 原生 `SceneTree` 测试运行器；不使用第三方插件或正式美术。

## 全局约束

- 仅实现本次 M0 范围，不进入敌人 AI、升级、商店、角色和波次。
- 输入只读取 `move_*`、`fire`、`reload` 动作。
- 相同固定种子必须生成相同散布序列，战斗随机不得使用全局 RNG。
- 无限备弹保留弹匣节奏；空仓自动换弹；非空仓换弹可由射击取消。
- GDScript 变量、参数和返回值使用显式类型。
- 现有 `docs/design/` 文件与用户的 `.DS_Store` 不修改、不覆盖、不删除。

## 文件边界

- `project.godot`：窗口、主场景和输入映射。
- `data/weapons/weapon_def.gd`、`data/weapons/ak.tres`：武器静态数据。
- `src/combat/weapon_runtime.gd`：弹匣、射速、换弹和后坐力状态机。
- `src/combat/spread_sampler.gd`：可注入种子的独立散布抽样。
- `src/combat/weapon_controller.gd`：输入到射线、伤害和反馈的数据流。
- `src/actors/player_controller.gd`、`src/actors/training_dummy.gd`：移动/瞄准与静止靶。
- `src/presentation/arena_view.gd`、`combat_feedback.gd`、`audio_feedback.gd`：灰盒场地与音画反馈。
- `src/ui/crosshair.gd`、`combat_hud.gd`：准星、弹药和调试面板。
- `scenes/run/m0_ak_lab.tscn`：M0 场景组装。
- `tests/unit/test_weapon_runtime.gd`、`tests/unit/test_spread_sampler.gd`、`tests/test_runner.gd`：无第三方自动回归。

### Task 1：核心逻辑 RED → GREEN

- [ ] 初始化只包含项目元数据的最小 `project.godot` 与原生 `SceneTree` 测试运行器。
- [ ] 先写弹匣扣减、手动换弹、空仓自动换弹、非空仓换弹取消和固定种子散布测试。
- [ ] 用 Godot headless 执行测试，确认因类/行为尚不存在而按预期失败。
- [ ] 实现最小 `WeaponRuntime`、`SpreadSampler` 和 AK Resource，使上述测试通过。
- [ ] 再运行完整测试，确保输出无解析错误或警告。

### Task 2：可玩灰盒场景

- [ ] 补齐项目输入映射与 `m0_ak_lab.tscn`。
- [ ] 实现 WASD、鼠标瞄准、按住左键按 8.5 发/秒连续射击和 R 换弹。
- [ ] 将同一弹道结果用于射线、曳光、命中反馈和假人伤害。
- [ ] 每完成一个脚本后用 headless 导入/启动检查解析与运行错误。

### Task 3：手感与可读反馈

- [ ] 实现 0～100 后坐力、停火恢复、移动散布、可见枪身后坐与准星开合。
- [ ] 实现枪口火焰、曳光、命中火花/命中标记、击倒重置、空仓和换弹状态提示。
- [ ] 实现弹匣/无限备弹、换弹进度、FPS、固定种子、随机索引、散布和后坐力调试 HUD。

### Task 4：真实验证

- [ ] 运行导入、自动测试、主场景冒烟和固定帧数场景验收。
- [ ] 运行自动化输入验收脚本覆盖连射、空仓、换弹、命中与可复现散布。
- [ ] 修复所有解析错误、运行错误和新增警告后重跑。
- [ ] 检查 `git diff` 与未跟踪文件，确认没有无关改动并记录剩余人工手感验收风险。
