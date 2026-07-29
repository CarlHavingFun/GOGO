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
- 不使用真实人物肖像、队标、赞助商、赛事素材和平台 Logo；
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

1. A1：AK 与基础命中反馈；
2. A2：尼尼、Deagle、三种敌人、赏金、竞技场基础 UI；
3. A3：大表哥、烟雾、背身诱导怪、烟幕猎犬；
4. A4：设备、AWP、四种投掷物与十波切片素材；
5. A5：剩余角色、枪械、敌人、Boss 和完整 UI。

在对应玩法里程碑通过前，不提前批量制作后续阶段资产。