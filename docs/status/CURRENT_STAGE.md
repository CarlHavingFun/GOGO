# CURRENT_STAGE｜GOGO 当前执行状态

- **更新时间**：2026-07-30
- **权威玩法阶段**：M1｜灰盒战斗玩具
- **状态**：`ACTIVE_VALIDATION`
- **下一阶段**：M2｜五波核心闭环
- **单次 /goal 最大晋级数**：1
- **仓库旧称映射**：`docs/m0/` 与部分代码中的 “M0 AK 射击玩具” 对应权威 M1

## 玩法证据

| 项目 | 状态 | 证据要求 |
|---|---|---|
| Godot 项目可解析 | 待重新验证 | `godot --headless --path . --editor --quit` |
| 自动测试 | 待重新验证 | `godot --headless --path . res://tests/test_runner.tscn` |
| Windows 连续运行 10 分钟 | `PENDING_MANUAL` | 无脚本错误、无明显卡顿 |
| 目标机器稳定 60 FPS | `PENDING_MANUAL` | 记录测试机器和最低 FPS |
| 点射与长扫差异 | `PENDING_MANUAL` | 人工手感记录 |
| 固定种子散布重现 | 待重新验证 | 自动测试与按 T 手动对照 |

全部强制门槛通过前，不得把本文件改为 M2。

## 美术轨道

- **当前资产**：`character_xiaodong_standard_pose`
- **当前状态**：`REFERENCE_APPROVED`
- **参考图**：`assets/characters/xiaodong/reference/xiaodong_approved_pixel_anchor_v01.jpeg`
- **下一动作**：根据 Style Bible 生产小洞大人 128×128 标准立姿；每轮只处理一张图并等待人工“通过/拒绝”
- **动画门槛**：五名角色标准立姿全部通过 `CharacterLineupReview` 后，才开始小洞大人动作帧

## M1 通过后的第一个 M2 工作包

只实现 `RunState` 与五波流程的状态转换测试：

```text
PREPARE → ACTIVE → CLEANUP → SETTLEMENT
```

本工作包不包含商店、升级、正式敌人、正式 UI 或角色天赋。

## 状态更新格式

Codex 修改本文件时必须追加：

```text
验证提交：<commit sha>
Godot 版本：<version>
Godot MCP：<server / connected / unavailable>
执行命令：<commands>
自动测试：<pass/fail>
人工验收：<pass/fail/pending>
阶段结论：<remain / advance>
未验证项：<none or exact list>
```
