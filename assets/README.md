# GOGO 素材目录

本目录保存进入项目的正式素材、源文件记录和生产清单。

权威规范：

- `docs/design/08_UI美术音频规范.md`
- `docs/design/12_游戏性与素材Review.md`
- `docs/design/13_素材生产管线与提示词.md`
- `assets/asset_manifest.csv`

## 基本原则

- 角色、武器、投掷物、子弹、特效、UI、场景独立；
- 不把武器画在角色手里作为最终战斗资产；
- 不把枪口火焰、子弹和弹壳画进武器底图；
- 不把烟雾、爆炸或火焰画进投掷物底图；
- 不把带文字的 AI 图作为正式 UI；
- 角色外观默认原创；仅用户指定参考图的职业选手角色适用 R2；
- R2 可保留脸部整体关系、气质、发型发色、身形和无品牌服装色块，但必须无队标、无赞助商、无平台/赛事 Logo、无官方队服图案、无官方赛事 UI/奖杯/舞台/水印；
- R2 不构成发布授权结论，对应角色是否进入发布包留到 M5 人工门；
- 所有新素材先登记 manifest，再生成和清理。

## 状态流转

```text
planned -> generated -> cleaned -> approved -> in_game
                    \-> rejected
```

- `planned`：有明确用途、路径、尺寸和 Prompt；
- `generated`：保存了原始输出和 Prompt；
- `cleaned`：完成透明背景、轮廓、色板和锚点处理；
- `approved`：通过美术规范检查；
- `in_game`：通过 Godot 实机场景验证；
- `rejected`：不进入正式项目，保留原因。

## Godot 导入基线

- Filter：Off；
- Compression：Lossless；
- Mipmaps：战斗 Sprite 默认 Off；
- Repeat：仅无缝 Tile 开启；
- 采用整数倍最近邻缩放；
- 角色以脚底或身体底部中心为锚点；
- 武器登记握持点、枪口点和弹壳点；
- Sprite Sheet 每帧尺寸完全一致；
- 动画帧不得出现锚点漂移。

## 当前生产顺序

1. A0：灰盒；
2. A1：M0 的 AK 与基础命中反馈；
3. A2：M1 的三种敌人、赏金、竞技场和核心 UI；
4. A3：M2 的尼尼、大表哥、Deagle、烟雾、背身敌人与烟幕猎犬；
5. A4：M3 十波垂直切片；
6. A5：M4 的小洞大人、设备、上帝、其余敌人、Boss 与完整 UI。

在对应玩法里程碑通过前，不提前批量制作后续阶段资产。
