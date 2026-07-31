# 14｜像素美术 Style Bible

- **版本**：v0.1
- **日期**：2026-07-30
- **依赖**：`00_产品宪法.md`、`08_UI美术音频规范.md`、`12_游戏性与素材Review.md`
- **适用范围**：角色、武器、投掷物、敌人、特效、竞技场、UI 图标与动画
- **目标**：把“像素风”拆成可执行、可比较、可拒收的硬约束，保证所有素材看起来来自同一款游戏

---

## 1. 权威性与核心原则

本文件是 GOGO 像素视觉的最高优先级规范。与其他素材文档发生冲突时，以本文件为准。

视觉优先级固定为：

> 信息清晰 > 操作反馈 > 角色识别 > 氛围 > 写实细节

所有素材必须同时满足：

1. **统一**：使用相同视角、像素密度、轮廓、光照、明暗层级和色板家族；
2. **可读**：缩小到实际游戏尺寸后仍能快速辨认主体、朝向和状态；
3. **模块化**：角色、武器、特效、UI、地块分别生产和组合；
4. **原创转译**：允许真实人物作为宽泛参照，但最终必须成为 GOGO 的原创 chibi 像素角色；
5. **先批准再扩展**：标准立姿未通过前，不制作该角色的动画、头像或换装。

---

## 2. 一句话风格定义

> **2D 俯视 3/4 视角、高对比卡通战术训练场像素风；大头小身体块、强轮廓、低频细节、有限色板、统一左上光。**

必须具备：

- top-down three-quarter view；
- compact chibi proportions；
- large readable head；
- small compact body；
- strong silhouette；
- clustered pixel shading；
- limited palette；
- hard pixel edges；
- upper-left key light；
- transparent background（独立资产）。

禁止混入：

- 纯正面或纯侧面角色立绘；
- 等距 45° 视角；
- 透视插画或海报构图；
- 手绘厚涂、油画笔触；
- 3D 渲染截图感；
- AI 平滑抗锯齿；
- 不同素材之间明显不同的逻辑像素大小。

---

## 3. 统一逻辑尺寸与像素密度

| 类别 | 生成参考画布 | 最终逻辑画布 | 默认锚点 |
|---|---:|---:|---|
| 玩家标准立姿/动画帧 | 1024×1024 | 128×128 | 双脚中点或身体底部中心 |
| 玩家头像 | 1024×1024 | 128×128 | 中心 |
| 普通敌人 | 1024×1024 | 96×96 或 128×128 | 身体底部中心 |
| Boss | 1536×1536 | 256×256 | 身体底部中心 |
| 枪械 | 1024×1024 | 160×96 | `grip_point` |
| 投掷物 | 1024×1024 | 64×64 | 中心 |
| 子弹/弹壳 | 512×512 | 16×16 或 32×32 | 中心 |
| 小型特效 | 1024×1024 | 64×64 | 中心 |
| 大型特效 | 1024×1024 | 128×128 | 中心 |
| 技能/状态图标 | 1024×1024 | 64×64 | 中心 |
| 场景地块 | 1024×1024 | 64×64 | 左上角或中心 |

规则：

- 最终素材只允许 2× 或 4× 最近邻放大；
- 禁止线性、双三次或 AI 平滑放大；
- 同类别素材必须使用同一逻辑像素密度；
- 动画每帧画布、身体基准线与锚点必须完全一致；
- 锚点漂移超过 2 个逻辑像素即拒收。

---

## 4. 视角与朝向

### 4.1 角色与敌人

统一俯视 3/4，必须同时看见：

- 头顶面积；
- 面部朝向；
- 肩部与胸前轮廓；
- 身体底部或脚部接地点。

标准立姿统一：

- 全身；
- 朝右下；
- 居中；
- 空手；
- 不带地面和投影；
- 角色主体高度占 128×128 画布的 72%～82%。

### 4.2 武器

- 默认枪口朝右；
- 侧视为主，略带顶部信息；
- 只生产一套基础方向；
- 旋转、左右翻转和射击后坐由 Godot `WeaponPivot` 完成；
- 不生成八方向基础枪械图。

### 4.3 投掷物与场景道具

- 俯视 3/4；
- 中心构图；
- 不混入动作特效；
- 场景模块的透视角度必须一致。

### 4.4 UI

- 使用正视图；
- 不使用场景透视；
- 正式 UI 文字由 Godot 字体渲染，不使用 AI 图中的伪文字。

---

## 5. 造型比例与识别锚点

### 5.1 玩家比例

- 头部占总高度约 34%～42%；
- 身体紧凑；
- 四肢短而清晰；
- 不追求真实人体比例；
- 手部只保留能表达动作的最小像素块。

### 5.2 识别锚点

每名角色只能使用 2～3 个高优先级锚点：

- 发型与发色；
- 脸型/眉眼气质；
- 体态或眼镜；
- 一种小面积角色强调色。

不得用大量装备、徽章、文字和真实队服堆砌识别度。

### 5.3 敌人轮廓

每种敌人只保留：

- 一个主轮廓特征；
- 一个危险机制特征；
- 一个方向或弱点提示。

---

## 6. 轮廓、像素簇与边缘

### 6.1 外轮廓

- 固定为 1～2 个逻辑像素；
- 默认轮廓色：`#1C1E24`；
- 极暗区域可使用 `#121419`，但不能整圈纯黑；
- 外轮廓必须连续、干净且优先于内部线。

### 6.2 内部结构线

- 内线比外轮廓低一个明度层级；
- 内部细节不能比脸、武器和危险提示更抢眼；
- 不使用随机黑线模拟材质。

### 6.3 像素簇

必须使用有意图的 clustered pixel shading：

- 用大色块表达体积；
- 阴影形成连续像素簇；
- 禁止噪点式随机抖色；
- 禁止用高频小点铺满衣服、地面或武器。

### 6.4 透明边缘

- 正式 PNG 边缘必须是硬像素；
- 不保留半透明脏边；
- 不保留 AI 模糊光晕；
- 发丝、枪管和眼镜仍需保持清晰的整数像素轮廓。

---

## 7. 项目基础色板

以下为项目基础色板。角色可以选取子集，但不得脱离同一明暗与饱和体系。

### 7.1 中性色

| 名称 | HEX | 用途 |
|---|---|---|
| Outline Deep | `#1C1E24` | 默认外轮廓 |
| Shadow Deep | `#2B2F38` | 深阴影 |
| Neutral Mid | `#3D4450` | 金属/服装中间色 |
| Neutral Light | `#596273` | 亮面 |
| Metal Highlight | `#8993A3` | 小面积金属高光 |

### 7.2 暖色与玩家攻击

| 名称 | HEX |
|---|---|
| Red Orange | `#C84832` |
| Warm Orange | `#E06A3B` |
| Amber | `#F2A32A` |
| Warm Highlight | `#FFD36A` |

### 7.3 冷色与技术感

| 名称 | HEX |
|---|---|
| Tactical Blue | `#3F7EA6` |
| Bright Blue | `#57A6D8` |
| Cyan Light | `#79C7D9` |

### 7.4 安全与治疗

- `#3FAF5A`
- `#76D36B`

### 7.5 敌方危险

- `#C53A47`
- `#E55C4A`
- `#F08A3E`
- `#B04BC7`

### 7.6 色数限制

- 玩家单角色：8～14 个局部颜色；
- 单把武器：6～10 色；
- 普通敌人：6～12 色；
- 小型特效：4～8 色；
- 单个地块：不超过 10～12 色；
- 强调色面积原则上不超过角色主体的 12%。

---

## 8. 光照与明暗层级

全项目统一主光方向：

> **左上方主光。**

每种材质建议使用：

1. 一个小面积高光；
2. 一个基色；
3. 一个主阴影；
4. 可选一个深阴影。

禁止：

- 不同资产使用相反光源；
- 大面积柔和渐变；
- 插画式空气透视；
- 无来源的多处镜面高光。

材质简化：

- 皮肤：基色 + 暖高光 + 一层阴影；
- 布料：大色块表达折面，不画密集针脚；
- 金属：高对比小面积高光；
- 木制件：只保留 1～2 道大纹理；
- 塑料/橡胶：低光泽；
- 能量部件：小面积高亮，不铺满主体。

---

## 9. 真实参照转译规则

五名主角允许以真实职业选手作为外形参照。真实参照只用于提高角色识别度，不等于制作真人肖像。

允许保留：

- 发型、发色和发缝；
- 脸型倾向与眉眼气质；
- 体态、胖瘦与是否戴眼镜；
- 年轻、冷静、强势、指挥型等宽泛气质。

禁止复制：

- 照片级面部结构；
- 真实队服、队标、赞助商和赛事图案；
- 真实人物照片中的完整姿势、光照和构图；
- 任何会被误认为官方职业选手肖像或授权皮肤的表达。

执行方法：

1. Prompt 中先写真实参照与 2～3 个宽泛特征；
2. 随后明确“translate into the GOGO compact chibi pixel-art design”；
3. 必须写“not an exact portrait or photo-real likeness”；
4. 最终角色必须服从本文件的比例、色板、轮廓和左上光；
5. 美术验收看“角色是否容易联想到参照”，而不是“脸是否一比一相同”。

---

## 10. 模块化资产边界

### 10.1 角色主体不得包含

- 武器；
- 投掷物；
- 枪口火焰；
- 子弹或弹壳；
- UI；
- 场景；
- 大片投影。

### 10.2 武器不得包含

- 手或人物；
- 枪口火焰；
- 子弹或弹壳；
- 地面；
- 文字；
- 固定阴影底盘。

### 10.3 特效不得包含

- 人物本体；
- 武器本体；
- 完整地面；
- 文字和 UI 框。

### 10.4 场景不得整体烘焙

- 地面 Tile、边界墙、障碍、Decal、生成口与装饰分别生产；
- 完整竞技场概念图只能作为布局参考；
- 不把一张带伪文字和不可编辑障碍的 AI 大图直接作为最终关卡。

---

## 11. 角色标准立姿审批门

每个角色首先只生产一张标准立姿：

- 128×128 最终逻辑画布；
- 俯视 3/4；
- 朝右下；
- 全身；
- 空手；
- 透明背景；
- 左上光；
- 中性但能表达角色气质的站姿。

标准立姿必须完成以下流程：

```text
planned -> generated -> cleaned -> style_review -> approved
                                           \-> rejected
```

审批内容：

- 五名角色放在同一画布中比例是否一致；
- 头身比和逻辑像素是否一致；
- 外轮廓粗细是否一致；
- 左上光和阴影级数是否一致；
- 各自 2～3 个识别锚点是否清楚；
- 是否没有武器、文字、Logo 与真实队服。

标准立姿未全部通过前：

- 不生成动画；
- 不生成头像；
- 不生成角色换装；
- 不生成整张 AI Sprite Sheet。

---

## 12. 动画基线

AI 不得一次生成整张最终角色 Sprite Sheet。动画必须基于批准的标准立姿逐动作制作。

| 动作 | 帧数 | FPS | 要点 |
|---|---:|---:|---|
| idle | 4 | 5 | 轻微呼吸，头部漂移小 |
| walk | 8 | 10 | 步态清楚，体积不变化 |
| crouch_idle | 4 | 5 | 重心降低、明显更稳 |
| crouch_walk | 6 或 8 | 8 | 低姿态短步移动 |
| hit | 2 | 12 | 短促，不改变碰撞体 |
| death | 6 | 10 | 清晰结束姿态，不血腥 |
| skill | 4～8 | 8～12 | 仅角色专属动作需要 |

### 12.1 下蹲动作规范

下蹲用于 `Ctrl` 稳定射击，必须一眼可读：

- 身体重心降低约 10%～15%；
- 头部和肩部压低，但头身比不变化；
- 手臂与躯干更收紧；
- 脚步更短；
- 不得变成趴下或跪地；
- 武器仍由独立 `WeaponPivot` 控制；
- 下蹲握持点相对站立姿态只允许预先登记的固定偏移。

### 12.2 动画一致性检查

- 头部中心漂移不超过 2 个逻辑像素；
- 身体宽度和发型体积保持一致；
- 颜色不得在帧间自动漂移；
- 动画按动作分别输出，不混入文字标签；
- 射击表现主要由武器后坐、枪口火焰、准星与少量身体反冲共同完成。

---

## 13. Godot 导入基线

- Filter：Off；
- Compression：Lossless；
- Mipmaps：战斗 Sprite 默认 Off；
- Repeat：仅无缝 Tile 开启；
- 缩放：整数倍最近邻；
- Sprite Sheet：每帧尺寸完全一致；
- Pixel Snap：项目统一设置；
- 角色锚点：脚底或身体底部中心；
- 武器必须记录：`grip_point`、`muzzle_point`、`shell_eject_point`、旋转中心和逻辑长度。

---

## 14. 标准 Prompt 骨架

### 14.1 角色标准立姿

```text
Create one standalone original game character standard-pose sprite.
[真实参照与 2～3 个宽泛识别特征]
Translate those broad reference cues into the original GOGO compact chibi pixel-art design; recognizable in spirit, not an exact portrait or photo-real likeness.
Top-down three-quarter view, full body, facing lower right, centered, empty hands.
Large readable head, small compact body, strong clean silhouette, 1-to-2 logical-pixel dark outline, limited project palette, clustered pixel shading, consistent upper-left light, hard pixel edges, transparent background, production game asset.
No weapon, no grenade, no text, no letters, no logo, no watermark, no UI, no environment, no floor, no cast shadow, no real team jersey, no sponsor mark, no extra limbs, no photorealism, no 3D render, no smooth vector art, no blurry anti-aliased edges.
```

### 14.2 武器基础图

```text
Create one standalone original fictional weapon sprite.
[武器轮廓与材质描述]
Pointing to the right, side view with slight top visibility, centered.
Strong readable silhouette, 1-to-2 logical-pixel dark outline, limited project palette, clustered pixel shading, consistent upper-left light, hard pixel edges, transparent background, production game asset.
No hand, no character, no muzzle flash, no bullet, no shell, no text, no logo, no floor, no cast shadow, no manufacturer marks.
```

### 14.3 场景模块

```text
Create one standalone modular top-down pixel-art environment tile or prop.
[地块或障碍描述]
Top-down three-quarter view, consistent GOGO perspective and upper-left light, aligned for modular assembly.
Strong silhouette, low-frequency detail, limited project palette, clustered pixel shading, hard pixel edges, transparent background.
No text, no logo, no character, no weapon, no dramatic poster background.
```

---

## 15. 拒收条件

任一条件成立即拒收：

- 与其他资产视角、像素密度或光源不一致；
- 带不可清理文字、Logo、真实队服或赞助商；
- 过度接近照片级真人肖像；
- 角色和武器画死；
- 角色手脚数量错误；
- 武器带手、火焰或弹壳；
- 缩小后轮廓不可读；
- 半透明抗锯齿形成脏边；
- 色数明显超过限制；
- 动画锚点漂移超过 2 个逻辑像素；
- AI 一次输出的整张动画表没有经过逐帧重绘和校正；
- 具体复制参考游戏角色、色板、UI 或素材。

---

## 16. 生产顺序

1. 生成并清理小洞大人标准立姿；
2. 以小洞大人为首个风格锚点，生成尼尼、设备、上帝、大表哥标准立姿；
3. 将五名角色放入统一 `CharacterLineupReview` 画布完成比例、轮廓、光照和色板审核；
4. 五名标准立姿全部批准后，才允许制作动作；
5. 动作优先顺序：当前可玩角色的 `idle`、`walk`、`crouch_idle`、`crouch_walk`、`hit`、`death`；
6. 武器、特效、竞技场和 UI 按可玩里程碑接入，不一次性生成全部内容。
