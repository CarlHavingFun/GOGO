# 09｜Godot 技术架构

- **版本**：v0.1
- **依赖**：全部玩法设计文档
- **目标引擎**：Godot 4.x 稳定版
- **首发平台**：Windows
- **后续平台**：Web、Android、iOS

---

## 1. 目标

本文件定义可维护、可测试、可扩展的技术结构，使项目能够：

- 先快速完成灰盒；
- 用数据扩充角色、武器、升级、怪物和波次；
- 固定种子重现生成与奖励；
- 在大量敌人与特效下保持性能；
- 避免角色和升级逻辑散落在巨大脚本中；
- 后续适配手柄、Web 和手机；
- 为平衡测试提供完整遥测。

---


## 明确规则摘要

- 静态内容使用 Resource，运行状态由 RunRoot 持有；
- 当前一局的玩家、钱包、波次和升级不得放入全局单例；
- 高频战斗事件使用局部接口，跨域流程才使用全局事件；
- 角色、敌人和升级不得通过具体内容 ID 互相硬编码；
- 生成、奖励、商店、精英和诱饵使用独立随机子流；
- 敌人、赏金、曳光、投掷物和特效必须池化；
- 启动和构建时运行内容验证，关键引用错误阻止进入游戏。

## 2. 架构原则

### 2.1 数据与运行逻辑分离

静态设计数据使用 Godot `Resource`：

- `CharacterDef`
- `WeaponDef`
- `ThrowableDef`
- `StatusDef`
- `UpgradeDef`
- `EnemyDef`
- `WaveDef`
- `DifficultyDef`
- `VFXProfile`
- `AudioEventDef`

运行时状态使用普通对象或节点：

- `CharacterRuntime`
- `WeaponRuntime`
- `StatusRuntime`
- `UpgradeRuntime`
- `EnemyRuntime`
- `RunState`

禁止在角色脚本中写死：

```text
if current_character == "nini":
    enemy.turn_back()
```

正确方式：

- 敌人产生通用 `back_facing` 标签；
- 尼尼监听该标签；
- 奖励系统监听角色标签；
- 角色与怪物不直接依赖具体实现。

### 2.2 单一职责

每个模块回答一个问题：

- `WaveDirector`：现在是哪一波、何时结束；
- `SpawnDirector`：生成什么、在哪里生成；
- `CombatResolver`：这次攻击造成什么结果；
- `StatusSystem`：状态如何叠加和移除；
- `RewardDirector`：候选如何过滤和抽取；
- `EconomySystem`：钱和经验如何变化；
- `RunController`：整个流程如何转换。

### 2.3 局部直接调用，跨域事件通信

- 同一实体内部组件可直接持有引用；
- 跨系统使用明确事件或信号；
- 不把所有消息都丢进全局 EventBus；
- 全局总线只承载少量跨域事件，例如波开始、波结束、局结束；
- 高频命中事件使用局部接口，避免全局信号风暴。

### 2.4 设计可重现，不承诺物理逐帧完全确定

必须固定：

- 波次生成序列；
- 奖励候选；
- 商店候选；
- 诱饵真假；
- 精英词缀。

不承诺：

- 不同设备、不同帧率下所有物理位置逐帧完全一致。

Bug 报告保存：

- 种子；
- 内容版本；
- 平台；
- 输入摘要；
- 波次；
- 最近事件日志。

---

## 3. 推荐目录

```text
res://
├─ app/
│  ├─ app_config.gd
│  ├─ scene_router.gd
│  └─ build_info.gd
├─ autoload/
│  ├─ content_db.gd
│  ├─ save_service.gd
│  ├─ audio_service.gd
│  ├─ input_service.gd
│  └─ telemetry_service.gd
├─ data/
│  ├─ characters/
│  ├─ weapons/
│  ├─ throwables/
│  ├─ statuses/
│  ├─ upgrades/
│  ├─ enemies/
│  ├─ waves/
│  ├─ difficulties/
│  └─ profiles/
├─ run/
│  ├─ run_root.tscn
│  ├─ run_controller.gd
│  ├─ run_state.gd
│  └─ rng_streams.gd
├─ systems/
│  ├─ wave/
│  ├─ spawn/
│  ├─ combat/
│  ├─ status/
│  ├─ rewards/
│  ├─ economy/
│  ├─ area_effects/
│  ├─ pooling/
│  └─ performance/
├─ entities/
│  ├─ player/
│  ├─ enemies/
│  ├─ projectiles/
│  ├─ pickups/
│  └─ shared_components/
├─ ui/
│  ├─ hud/
│  ├─ upgrade_screen/
│  ├─ shop/
│  ├─ pause/
│  └─ results/
├─ audio/
├─ vfx/
├─ arenas/
├─ debug/
│  ├─ balance_lab/
│  ├─ wave_preview/
│  ├─ seed_replay/
│  └─ content_validator/
└─ tests/
   ├─ unit/
   ├─ integration/
   ├─ golden_seeds/
   └─ performance/
```

---

## 4. 运行场景树

推荐 `RunRoot`：

```text
RunRoot
├─ RunController
├─ Arena
│  ├─ Navigation
│  ├─ SpawnPoints
│  ├─ DynamicSlots
│  └─ Boundary
├─ Player
├─ EntityWorld
│  ├─ Enemies
│  ├─ Pickups
│  ├─ Throwables
│  ├─ AreaEffects
│  └─ VFX
├─ Systems
│  ├─ WaveDirector
│  ├─ SpawnDirector
│  ├─ CombatResolver
│  ├─ StatusSystem
│  ├─ AreaEffectSystem
│  ├─ RewardDirector
│  ├─ EconomySystem
│  └─ PoolManager
├─ CameraRig
├─ HUD
└─ DebugOverlay
```

`RunRoot` 离开时应能够释放整局状态，避免 Autoload 残留下一局数据。

---

## 5. Autoload 边界

适合 Autoload：

- 内容数据库；
- 存档；
- 音频总线；
- 输入映射；
- 场景切换；
- 版本信息；
- 遥测写入服务。

不适合 Autoload：

- 当前玩家；
- 当前波次；
- 当前敌人；
- 当前升级；
- 当前钱包；
- 战斗状态。

这些属于 `RunRoot` 生命周期。

---

## 6. 玩家组件

推荐拆分：

```text
Player
├─ MovementComponent
├─ AimComponent
├─ HealthComponent
├─ ArmorComponent
├─ WeaponController
├─ ThrowableController
├─ ActiveAbilityController
├─ StatusReceiver
├─ UpgradeReceiver
├─ Hurtbox
├─ PickupMagnet
└─ CharacterPresenter
```

职责：

- `MovementComponent` 不知道角色名字；
- `WeaponController` 不决定伤害最终值；
- `HealthComponent` 不处理 UI；
- `StatusReceiver` 通过 `StatusDef` 管理状态；
- `CharacterPresenter` 只处理动画与外观；
- `UpgradeReceiver` 向统一 Modifier 容器注册效果。

---

## 7. 敌人组件

```text
Enemy
├─ EnemyRuntime
├─ AIController
├─ MovementComponent
├─ HealthComponent
├─ ArmorComponent
├─ StatusReceiver
├─ Hitbox
├─ Hurtbox
├─ WeakpointComponent
├─ AttackController
├─ BountyDropComponent
├─ EliteModifierComponent
└─ EnemyPresenter
```

复杂敌人通过行为组件组合：

- `ChaseBehavior`
- `KeepDistanceBehavior`
- `ChargeAttack`
- `ProjectileAttack`
- `ShieldFacing`
- `SupportHeal`
- `DeployLure`
- `DeployHazard`
- `PullBeam`

避免为每个敌人复制完整 AI 脚本。

---

## 8. 内容数据库

`ContentDB` 在启动时：

1. 扫描或加载显式内容清单；
2. 验证 ID 唯一；
3. 验证引用存在；
4. 验证升级数量和分类；
5. 验证波次引用敌人；
6. 验证音频/VFX 配置；
7. 输出内容版本和错误。

发布版遇到非关键内容错误：

- 禁用错误内容；
- 记录日志；
- 不让整个游戏崩溃。

关键内容错误，例如默认角色或第 1 波缺失：

- 阻止进入游戏；
- 显示可理解错误页；
- 提供日志路径。

---

## 9. 数据资源示例

### 9.1 `WeaponDef`

```gdscript
class_name WeaponDef
extends Resource

@export var id: StringName
@export var tags: Array[StringName]
@export var display_name: String
@export var damage: int
@export var shots_per_second: float
@export var magazine_size: int
@export var reload_duration: float
@export var base_spread_degrees: float
@export var moving_spread_addition_degrees: float
@export var recoil_per_shot: float
@export var recoil_recovery_per_second: float
@export var recoil_spread_coefficient: float
@export var maximum_recoil_bias_degrees: float
@export var maximum_visual_kick_pixels: float
@export var weakpoint_multiplier: float
@export var pierce_count: int
@export var pierce_decay: float
@export var range_pixels: float
```

### 9.2 `UpgradeDef`

```gdscript
class_name UpgradeDef
extends Resource

@export var id: StringName
@export var category: UpgradeCategory
@export var rarity: UpgradeRarity
@export var tags: Array[StringName]
@export var required_weapon_ids: Array[StringName]
@export var required_character_ids: Array[StringName]
@export var min_wave: int
@export var max_stacks: int
@export var conflict_ids: Array[StringName]
@export var effect_defs: Array[UpgradeEffectDef]
@export var base_weight: float
```

数据资源中不直接保存运行节点引用。

---

## 10. Modifier 系统

### 10.1 属性层

统一属性容器建议支持：

- 基础值；
- 加法；
- 百分比加法；
- 乘法；
- 最终限制；
- 来源追踪。

计算顺序：

```text
final = clamp(
    (base + flat_add)
    × (1 + percent_add)
    × product(multipliers),
    min_value,
    max_value
)
```

每个 Modifier 包含：

- 来源 ID；
- 目标属性；
- 运算类型；
- 数值；
- 条件；
- 生命周期；
- 堆叠组；
- 调试描述。

### 10.2 事件效果

不是所有升级都能靠属性完成。使用 `EffectExecutor`：

- `OnShotFiredEffect`
- `OnHitEffect`
- `OnKillEffect`
- `OnReloadCompleteEffect`
- `OnWaveStartEffect`
- `OnWaveEndEffect`
- `OnAreaExpiredEffect`
- `OnBountyCollectedEffect`
- `OnWalletChangedEffect`

注册表通过效果类型创建执行器，避免在升级 ID 上写巨大 `match`。

---

## 11. 战斗管线

建议顺序：

```text
Input
→ WeaponController 请求射击
→ AimComponent 提供方向
→ RecoilModel 计算散布
→ HitscanQuery 收集目标
→ CombatResolver 计算每个目标
→ HealthComponent 应用伤害
→ EventContext 生成命中/击杀/过量伤害
→ 局部效果执行器处理
→ TelemetryService 记录摘要
→ Presenter 播放反馈
```

`DamageContext` 至少包含：

- 来源实体；
- 武器/投掷物 ID；
- 基础伤害；
- 标签；
- 弱点；
- 暴击；
- 穿透序号；
- 过量伤害；
- 状态；
- 随机索引；
- 波次和时间戳。

---

## 12. 状态系统

`StatusSystem` 不应每个状态创建独立节点。

推荐：

- 每个实体一个 `StatusReceiver`；
- 使用字典保存活跃状态；
- DOT 按统一调度器批量更新；
- 区域状态由 `AreaEffectSystem` 发送进入/离开；
- 高频区域查询降频到 10～20 Hz；
- 状态视觉通过事件更新，不每帧重建。

Boss 控制转换由 `StatusDef.boss_conversion_id` 处理，不在 Boss 脚本中逐个判断闪光 ID。

---

## 13. AI 与导航

### 13.1 基础方式

- 简单追踪怪使用直接 steering；
- 需要绕障碍的单位使用导航代理；
- 不让全部 110 个敌人每帧重新寻路；
- 寻路请求分批；
- 近距离避让使用轻量分离力；
- 大群小怪允许局部重叠，但命中与攻击并发受限。

### 13.2 AI 更新频率

| 类型 | 建议频率 |
|---|---:|
| 屏幕内高威胁敌人 | 60 Hz 移动，20 Hz 决策 |
| 普通追踪怪 | 60 Hz 移动，10 Hz 决策 |
| 屏幕外普通怪 | 30 Hz 移动，5 Hz 决策 |
| 支援与部署类 | 10 Hz 决策 |
| 纯视觉对象 | 低于 30 Hz 或动画系统 |

---

## 14. 生成系统

`SpawnDirector` 使用：

- 波次威胁预算；
- 活跃上限；
- 职责配额；
- 生成扇区；
- 安全矩形；
- 最小距离；
- 并发危险锁。

生成流程必须输出可调试原因：

```text
spawn_attempt
candidate_sector
rejected_too_close
rejected_visible_center
rejected_navigation
spawn_deferred
spawn_success
```

提供调试覆盖层显示合法/非法生成区域。

---

## 15. 随机数架构

从主种子派生独立子流：

```text
run_seed
├─ spawn_rng
├─ reward_rng
├─ shop_rng
├─ elite_rng
├─ lure_rng
├─ cosmetic_rng
└─ combat_rng
```

要求：

- 刷新商店只消耗 `shop_rng`；
- 玩家多开一枪不会改变下一次商店；
- 诱饵真假只消耗 `lure_rng`；
- 纯视觉随机不消耗玩法随机；
- 调试日志记录每个重要抽取的索引。

不要使用全局随机函数处理核心玩法。

---

## 16. 对象池

必须池化：

- 敌人；
- 枪械曳光；
- 赏金实体；
- 投掷物；
- 爆炸和命中特效；
- 地面危险区；
- 临时伤害数字。

池化对象重用时必须重置：

- 信号连接；
- 状态；
- Modifier；
- 动画；
- 碰撞；
- 计时器；
- 所有者；
- 遥测 ID。

提供 `reset_for_pool()` 接口和自动泄漏检查。

---

## 17. 空间查询

高频“寻找附近目标”不能每次遍历全场节点。

可选实现：

- Godot 物理空间查询；
- 分区网格/空间哈希；
- 按敌人列表维护屏幕内集合。

建议：

- 过量弹跳、燃烧扩散和手雷使用统一 `TargetQueryService`；
- 查询支持半径、标签、数量、排序；
- 单帧大批查询有预算；
- 同一爆炸共享查询结果；
- 最近目标排序稳定，固定种子回归更可靠。

---

## 18. UI 架构

- UI 订阅 ViewModel，不直接读取深层节点树；
- `HUDViewModel` 汇总生命、弹匣、波次和角色计量；
- 升级卡从 `UpgradeDef` 和动态数值生成；
- 商店预览使用纯计算，不先修改真实钱包；
- UI 动画不能控制玩法状态；
- 场景切换时解除订阅；
- 支持键鼠、手柄焦点和未来触屏。

---

## 19. 输入抽象

定义动作：

```text
move_left
move_right
move_up
move_down
aim
fire
reload
active_ability
throwable_1
throwable_2
build_panel
pause
confirm
cancel
```

玩法代码只读取动作，不读取具体键值。

未来移动端：

- 虚拟移动摇杆；
- 右侧瞄准摇杆；
- 自动射击可选；
- 投掷物按钮；
- 辅助瞄准；
- UI 安全区。

不在玩法代码中判断 `OS == mobile`，由输入与质量配置提供差异。

---

## 20. 存档与版本迁移

### 20.1 保存内容

局外：

- 解锁；
- 设置；
- 成就；
- 统计；
- 最高难度；
- 教程状态；
- 文档版本。

标准模式 v0.1 不要求中途存档续局。

### 20.2 存档结构

```json
{
  "schema_version": 1,
  "content_manifest_version": 1,
  "profile": {},
  "settings": {},
  "unlocks": {},
  "statistics": {}
}
```

### 20.3 迁移

- 每次 schema 变化提供逐版本迁移；
- 迁移前备份；
- 未知字段保留或安全忽略；
- 内容 ID 删除时使用映射表；
- 迁移失败不覆盖原存档；
- 提供“导出诊断信息”，不导出隐私数据。

---

## 21. 遥测

开发版默认写入本地 JSON Lines：

事件包括：

- `run_started`
- `wave_started`
- `shot_fired`
- `hit_summary`
- `reload_completed`
- `damage_taken`
- `enemy_killed`
- `bounty_collected`
- `upgrade_offered`
- `upgrade_selected`
- `shop_offer_generated`
- `shop_purchase`
- `negative_trait_triggered`
- `ability_used`
- `run_ended`
- `performance_sample`

高频命中事件应聚合，避免每颗子弹写磁盘。

正式版外部分析若启用，需要：

- 明确告知；
- 默认只收集玩法数据；
- 不收集聊天、文件和个人内容；
- 支持关闭；
- 使用 schema 版本。

---

## 22. 性能目标

### 22.1 Windows 基线

目标场景：

- 1080p；
- 60 FPS；
- 110 活跃敌人；
- 每秒 150 次枪械射线；
- 12 个区域效果；
- 200 个可见赏金实体；
- 6 个高质量爆炸并发。

性能预算建议：

| 模块 | 单帧预算方向 |
|---|---|
| AI 与移动 | 30% |
| 物理与空间查询 | 20% |
| 渲染与 VFX | 25% |
| UI | 10% |
| 玩法系统 | 10% |
| 余量 | 5% |

### 22.2 后续平台质量档

| 平台 | 活跃敌人目标 | 特效策略 |
|---|---:|---|
| Windows | 110 | 完整 |
| Web | 80 | 合并赏金、降低烟雾 |
| 高端移动 | 70 | 降低粒子和尸体 |
| 低档移动 | 50 | 更积极合并、简化阴影 |

移植时应调整生成预算和表现，而不是让逻辑帧率失控。

---

## 23. 调试工具

必须尽早提供：

- 武器实验室：固定靶、移动靶、护甲靶；
- 波次预览：跳到指定波；
- 敌人生成面板；
- 状态添加/清除；
- 升级强制授予；
- 商店候选查看；
- 随机子流索引；
- 伤害公式分解；
- 生成安全覆盖层；
- 性能 HUD；
- 固定种子回放入口；
- 内容验证器；
- 一键导出本局诊断包。

调试工具不是最后才做的附加项，而是平衡和 Codex 开发的基础设施。

---

## 24. 错误处理

### 24.1 可恢复错误

例如：

- 某个非关键升级引用缺失；
- 某个 VFX 缺失；
- 音频事件不存在。

处理：

- 禁用该内容或使用占位；
- 记录错误；
- 游戏继续；
- 调试 HUD 显示一次。

### 24.2 不可恢复错误

例如：

- 默认角色不存在；
- 第 1 波配置不存在；
- 主武器定义无效；
- 存档迁移会覆盖原数据。

处理：

- 阻止开始；
- 显示错误代码与日志路径；
- 不伪装成正常运行。

---

## 25. 不包含的范围

- 一个脚本管理全部玩法；
- 全局变量保存当前一局状态；
- 每个升级手写 ID 分支；
- 核心玩法使用全局随机数；
- 为每个状态创建独立常驻节点；
- 所有敌人每帧寻路；
- 发布前才做对象池和性能测试；
- 首发联网账号和云存档；
- 标准模式中途随时保存并精确恢复；
- 依赖外部服务才能开始一局。

---

## 26. 数据字段

### 26.1 `RunConfig`

`RunConfig` is read-only and owns seed, difficulty, character, weapon, and starting throwables.

| 字段 | 类型 | 说明 |
|---|---|---|
| `run_seed` | int | 本局主随机种子 |
| `difficulty_id` | StringName | 难度 |
| `character_id` | StringName | 角色 |
| `weapon_id` | StringName | 主武器 |
| `starting_throwable_ids` | Array[StringName] | 开局投掷物，不随运行时槽位变化 |

### 26.2 `RunState`

`RunState` owns phase, wave, time, RNG streams, event sequence, and references to child state.

| 字段 | 类型 | 说明 |
|---|---|---|
| `phase` | enum | 当前流程 |
| `wave_index` | int | 波次 |
| `elapsed_combat_time` | float | 战斗时间 |
| `elapsed_total_time` | float | 含商店总时间 |
| `rng_streams` | Dictionary | 子流状态 |
| `event_sequence` | int | 事件序号 |
| `player_state` | Resource | 玩家运行状态 |
| `economy_state` | Resource | 经济 |
| `upgrade_state` | Resource | 升级 |
| `throwable_state` | Resource | 运行时投掷物槽位与充能 |

### 26.3 `EconomyState`

`EconomyState` owns wallet, experience, level, and pending upgrade count.

### 26.4 `UpgradeState`

`UpgradeState` owns acquired upgrades, contracts, and stacks.

### 26.5 `GameplayEventContext`

| 字段 | 类型 | 说明 |
|---|---|---|
| `event_id` | int | 唯一序号 |
| `event_type` | StringName | 类型 |
| `source_entity_id` | int | 来源 |
| `target_entity_ids` | Array[int] | 目标 |
| `source_content_id` | StringName | 武器/技能 |
| `tags` | Array[StringName] | 标签 |
| `value` | float | 主值 |
| `wave_index` | int | 波次 |
| `run_time` | float | 时间 |
| `rng_index` | int | 随机索引 |
| `metadata` | Dictionary | 附加信息 |

---

## 27. 与其他系统的接口

本文件是所有系统的实现边界。具体接口应遵循：

- 设计数据从 `ContentDB` 获取；
- 一局状态由 `RunRoot` 持有；
- 高频战斗使用局部调用；
- 跨域流程使用明确事件；
- UI 读取 ViewModel；
- 存档只接触局外数据；
- 遥测只记录副本，不反向控制玩法；
- 性能管理只降低表现质量，不删除危险信息；
- 内容验证器在启动和构建时运行。

---

## 28. 可验证的完成标准

- 项目可从数据新增一把武器而不修改玩家核心脚本；
- 可从数据新增一个普通升级并由注册效果执行；
- 角色和怪物代码不存在彼此具体 ID 的硬依赖；
- 固定种子可重现生成、奖励和商店；
- 一局结束后重新开始无残留状态；
- 对象池复用不保留旧状态；
- 内容引用错误能在启动时发现；
- 目标压力场景达到帧率；
- 调试工具可跳波、授予升级和查看伤害分解；
- 存档迁移失败不损坏原文件；
- 输入动作可重新映射；
- Windows 构建无需外部服务即可完整游玩。

---

## 29. 尚未验证的假设

1. Godot 4.x 的 2D 与物理查询可满足目标敌人数量；
2. 射线判定和空间查询服务能够支撑所有弹跳、穿透和扩散；
3. Resource 数据量在首发规模下管理方便；
4. GDScript 性能足以完成 Windows 首发，热点可后续优化；
5. 不做标准模式中途续局不会影响目标玩家；
6. 独立随机子流足以重现大多数平衡问题；
7. 局部事件与少量全局事件的边界团队能够长期遵守；
8. Web 和移动端主要需要表现降级，而不需要重写核心玩法。
