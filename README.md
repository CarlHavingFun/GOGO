# GOGO

一款使用 Godot 4.x 开发的俯视角手动瞄准动作肉鸽。

核心组合：

- 固定 Seed 可复现、按 Chunk 流式延伸的无尽黄沙旧城战场；
- 手动瞄准、后坐力、弹匣和换弹；
- 单主武器 + 两个投掷物槽；
- 五名拥有正负天赋的原创电竞角色；
- 受控随机升级、商店、经济与角色专属构筑；
- 模块化像素素材与 AI 辅助生产管线。

## 从这里开始

开发者与 Codex：阅读 [`CODEX_START.md`](CODEX_START.md)。

完整设计索引：阅读 [`docs/design/README_设计文档索引.md`](docs/design/README_设计文档索引.md)。

地图与刷怪空间：

- [`docs/design/15_竞技场与刷怪空间系统.md`](docs/design/15_竞技场与刷怪空间系统.md)
- [`docs/design/16_无尽双尘荒原与程序化模块系统.md`](docs/design/16_无尽双尘荒原与程序化模块系统.md)
- [`docs/design/arenas/README_竞技场索引.md`](docs/design/arenas/README_竞技场索引.md)

素材生产：

- [`docs/design/13_素材生产管线与提示词.md`](docs/design/13_素材生产管线与提示词.md)
- [`docs/design/14_像素美术Style_Bible.md`](docs/design/14_像素美术Style_Bible.md)
- [`assets/asset_manifest.csv`](assets/asset_manifest.csv)
- [`assets/README.md`](assets/README.md)

## 当前状态

M0「AK 射击玩具」仍作为射击回归场景保留。当前分支已经增加可运行的“无尽双尘荒原”灰盒原型：

- 玩家附近 `5×5` Chunk 流式加载，远处 Chunk 回收；
- 相同世界 Seed 与 Chunk 坐标生成相同模块；
- 六种人工设计的战斗模块和一个稀疏废弃补给站 POI；
- 玩家屏幕外环形刷怪；
- 追击灰盒敌人、活动数量上限和对象池回收；
- Godot 4.7.1 无头解析、自动测试和 600 帧运行时 smoke。

下一步是在 Windows 上完成十分钟连续移动、射击和性能人工验收，再把无限地图底座接入五波成长闭环。

## 产品边界

第一版：

- Windows 单人 PvE；
- Godot 4.x；
- 2D 俯视角；
- 一个正式世界主题：无尽双尘荒原；
- 固定 Seed、Chunk 流送、人工战斗模块与稀疏 POI；
- 五把原型枪械；
- 四种投掷物；
- 五名原创角色；
- 20 波与最终 Boss。

赤瓦小镇和货运枢纽当前只保留设计，不进入第一版开发承诺。固定竞技场文档继续作为空间、安全生成与未来模式的设计参考，但不再是当前默认启动玩法。

暂不包含多人、PvP、随机迷宫、复杂背包、皮肤交易、完整城镇、地下迷宫、永久世界存档和真实职业选手肖像或队伍素材。
