# CODEX_GOAL｜当前 `/goal` 执行入口

把下面整段交给 Codex `/goal`。该目标会先验证当前阶段；只有门槛全部通过时，才推进到下一阶段，并且一次最多跨一个里程碑。

```text
/goal
在当前 GOGO 仓库中执行“阶段门槛驱动的自动推进”。

开始前必须阅读：
1. CODEX_START.md
2. docs/design/00_产品宪法.md
3. docs/design/09_Godot技术架构.md
4. docs/design/11_开发里程碑.md
5. docs/design/11A_M0小洞大人动画与阶段推进.md
6. docs/design/13_素材生产管线与提示词.md
7. docs/design/14_像素美术Style_Bible.md
8. docs/status/CURRENT_STAGE.md

执行规则：
- 以 docs/status/CURRENT_STAGE.md 的权威阶段为准；
- 先检查已配置的 Godot MCP，并优先使用它完成项目、场景树、资源绑定、运行错误和可观察验收；
- 同时必须运行 CLI 解析与无头测试，Godot MCP 不能替代 CI；
- 当前阶段任何自动或人工强制门槛未通过时，只修复当前阶段，不得修改阶段编号；
- 自动测试通过但 Windows 10 分钟运行、60 FPS 或手感验收仍 pending 时，保持 ACTIVE_VALIDATION；
- 全部门槛通过后，更新 docs/status/CURRENT_STAGE.md，记录提交、Godot 版本、MCP 状态、命令和证据；
- 然后把下一阶段设为 ACTIVE，并只实现下一阶段的第一个单闭环工作包；
- 一次 /goal 最多跨越一个阶段，不得连续跳级；
- 每个工作包先写失败测试，再实现最小代码，再运行测试；
- 不顺手实现未列入当前工作包的商店、升级、敌人、角色或正式 UI；
- 不生成或修改正式角色图片。小洞大人的生图由人工审批流程完成；Codex 只登记、整理、导入和验收已批准文件。

当前预期：
1. 重新验证权威 M1 灰盒战斗玩具；
2. 使用 Godot MCP 打开并运行当前主场景，读取错误和节点/资源状态；
3. 运行：
   godot --headless --path . --editor --quit
   godot --headless --path . res://tests/test_runner.tscn
4. 汇报仍需人工完成的 Windows 10 分钟、FPS 和手感验收；
5. 仅当全部 M1 门槛已有真实证据时，进入 M2；
6. 进入 M2 后，只实现 RunState 的 PREPARE → ACTIVE → CLEANUP → SETTLEMENT 状态转换与测试，不实现商店、升级和正式敌人。

完成前必须汇报：
- 修改文件；
- Godot MCP 实际调用与结果；
- 实际执行命令和输出摘要；
- 自动测试结果；
- 人工验收结果或 pending 项；
- 是否晋级及理由；
- 未完成项和已知风险。
```
