# GOGO

一款使用 Godot 4.x 开发的俯视角手动瞄准动作肉鸽。

核心组合：

- 固定竞技场 20 波生存；
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
- [`docs/design/arenas/README_竞技场索引.md`](docs/design/arenas/README_竞技场索引.md)

素材生产：

- [`docs/design/13_素材生产管线与提示词.md`](docs/design/13_素材生产管线与提示词.md)
- [`docs/design/14_像素美术Style_Bible.md`](docs/design/14_像素美术Style_Bible.md)
- [`assets/asset_manifest.csv`](assets/asset_manifest.csv)
- [`assets/README.md`](assets/README.md)

## 当前状态

M0「AK 射击玩具」已经建立可运行和可测试的射击底座。下一步先把灰盒竞技场抽成可替换 Arena，再进入 M1 的双尘旧城灰盒、三种敌人和五波闭环。

## 产品边界

第一版：

- Windows 单人 PvE；
- Godot 4.x；
- 2D 俯视角；
- 一个正式竞技场：双尘旧城；
- 五把原型枪械；
- 四种投掷物；
- 五名原创角色；
- 20 波与最终 Boss。

赤瓦小镇和货运枢纽当前只保留设计，不进入第一版开发承诺。

暂不包含多人、PvP、随机迷宫、复杂背包、皮肤交易和真实职业选手肖像或队伍素材。
