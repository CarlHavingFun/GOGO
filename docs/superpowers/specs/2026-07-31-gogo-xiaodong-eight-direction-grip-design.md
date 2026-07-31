# GOGO“小洞大人”八方向走路与三类空手握持分层补充规格

- 日期：2026-07-31
- 状态：方向与握持方案已获用户批准；书面规格待用户复核
- 决策基线：R2
- 适用范围：“小洞大人”C0 八方向走路、空手握持分层及对应 A5 边界
- 上位规格：`docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`
- 用户决定：
  - `批准八方向方案`
  - `批准三类握持分层方案`

## 1. 决策目的

原规格先以右下朝向验证身份和单方向步态，并允许水平翻转覆盖左下。该范围
不足以支撑最终八方向角色：若只切换腿部方向或只旋转武器，人物头部、肩轴、
髋部和鞋尖会与移动读向冲突；若把一种握持姿势用于全部枪械，手枪、步枪和
重型狙击枪的双手间距也会明显错位。

本补充规格将 C0 走路验证扩展为八方向，并把握持姿势从走路主体中拆成三类
空手握持层。武器仍是独立节点和独立资产，任何角色或握持 PNG 都不得包含
武器像素。

## 2. 权威关系与替代范围

本规格只替代上位规格中的以下内容：

1. §3.2“先制作右下、水平翻转覆盖左下”的方向策略；
2. §4.1 单方向 `walk` 四个关键姿势的数量解释；
3. 设计卡中把所有 C0 动作统一写成“朝向右下”的 `walk` QA；
4. §4.2 将 `walk` 的“8 帧”理解为整张正式资产总共只有 8 帧的做法。

替代后的规则是：

- C0 `walk` 为八方向，每方向四个关键姿势，共 32 张 canonical
  `walk_body` layer；与三类握持合成 96 个完整全身 QA 结果；
- A5 正式 `walk` 为八方向，每方向八帧，共 64 帧；
- 头像仍为一张 UI 资产，不扩成八方向头像；
- `idle`、`hit`、`death`、`skill_breakin` 本轮不扩大方向数量；
- R2、身份锚点、128×128 逻辑画布、左上光、有限色板、武器独立、C0/A5
  生命周期边界及 G0–M5 里程碑定义全部继续有效。

若本规格未明确替代某项要求，以上位规格和后续批准的权威文档为准。

### 2.1 必须同步的权威载体

本规格提交后、任何新方向资产生成前，实施计划必须在一个独立治理提交中同步：

- `docs/design/00_产品宪法.md`：把“默认右下”改为“右下是身份种子，
  `walk` 正式覆盖八方向”；
- `docs/design/04_角色与流派设计.md`：同步 Xiaodong 八方向和武器分层；
- `docs/design/08_UI美术音频规范.md`：同步角色朝向、握持和武器独立规则；
- `docs/design/13_素材生产管线与提示词.md`：同步方向、帧数、布局、命名和
  双手锚点；
- `docs/design/manifest.json`：更新被修改权威 Markdown 的字节数和哈希；
- `assets/asset_manifest.csv`：更新 walk 行并增加六个握持层计划行；
- `assets/characters/xiaodong/character_xiaodong_design.md`：同步 C0 数量、
  候选合同和方向 QA。

`docs/design/GOGO_完整设计文档合集_v0.1.md` 的 manifest role 是
`historical`，只供追溯；不得改写，其字节数和哈希必须保持不变。
历史 G0 计划与进度记录继续如实保留“当时六项 A5 planned”的结论，不回写
历史。新治理提交必须注明：用户 2026-07-31 的后续批准改变了当前计划目录，
但所有新增/修改 A5 行仍保持 `planned`，不能借规格同步提前进入
`generated/cleaned/approved/in_game`。

### 2.2 A5 manifest 目标

现有 `character_xiaodong_walk` 行保持 asset ID 和路径，改为：

| 字段 | 目标值 |
|---|---|
| `frames` | `64` |
| `fps` | `10` |
| `direction` | `eight_way` |
| `pivot` | `feet_center` |
| `sprite_layout` | `grid_8x8` |
| `status` | `planned` |
| `notes` | body layer；必须与一个 grip group 合成；no weapon |

新增六个 A5 `planned` 行及精确路径：

| asset_id | path |
|---|---|
| `character_xiaodong_grip_pistol_back` | `assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_back.png` |
| `character_xiaodong_grip_pistol_front` | `assets/characters/xiaodong/grips/character_xiaodong_grip_pistol_front.png` |
| `character_xiaodong_grip_rifle_back` | `assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_back.png` |
| `character_xiaodong_grip_rifle_front` | `assets/characters/xiaodong/grips/character_xiaodong_grip_rifle_front.png` |
| `character_xiaodong_grip_sniper_back` | `assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_back.png` |
| `character_xiaodong_grip_sniper_front` | `assets/characters/xiaodong/grips/character_xiaodong_grip_sniper_front.png` |

六行均为 `128x128`、`frames=8`、`fps=0`、`direction=eight_way`、
`pivot=shoulder_pivot`、`sprite_layout=horizontal_8x1`、`status=planned`。
因此当前计划目录由历史六项变为十二项：原六项仍在，新增六项只负责三类
握持的前后手层。

## 3. 八方向与四相位

### 3.1 方向 ID

方向使用屏幕坐标，不使用人物主观左右：

| direction_id | 中文 | 屏幕向量 |
|---|---|---:|
| `n` | 上 | `(0,-1)` |
| `ne` | 右上 | `(1,-1)` |
| `e` | 右 | `(1,0)` |
| `se` | 右下 | `(1,1)` |
| `s` | 下 | `(0,1)` |
| `sw` | 左下 | `(-1,1)` |
| `w` | 左 | `(-1,0)` |
| `nw` | 左上 | `(-1,-1)` |

所有方向保持同一俯视相机和同一角色比例。`n` 可以主要显示后脑与背部，
`s` 可以更接近正面；这属于同一俯视相机下的身体转向，不是改变相机。身份
神似在正面/侧面依赖脸部关系，在背面依赖棕色齐颌发型、头肩比例、偏瘦身形
和纯黑服装轮廓，不强行在背面画出脸。

### 3.2 四个 C0 关键姿势

每个方向都必须包含同一套解剖相位：

| phase_id | 定义 |
|---|---|
| `contact_l` | 人物解剖左脚向目标方向接触，右脚拖后 |
| `passing_l` | 左脚承重，右脚抬起经过支撑腿 |
| `contact_r` | 人物解剖右脚向目标方向接触，左脚拖后 |
| `passing_r` | 右脚承重，左脚抬起经过支撑腿 |

方向改变不能改变人物的解剖左右。四帧必须组成
`contact_l → passing_l → contact_r → passing_r` 的闭环，禁止用镜像后
交换 ID 来伪造交替。

### 3.3 头身同步

每个走路姿势中以下轴线必须共同指向 `direction_id`：

- 后脑/脸部与视线；
- 鼻颏或背头中心；
- 胸腔中心线和骨盆朝向；
- 肩轴、髋轴的法线；肩线和髋线本身随身体方向一致旋转；
- 双膝；
- 双鞋鞋尖与步进方向。

禁止仅转头、仅转腿、仅翻转鞋或让头身分别指向相反方向。C0 先验证移动方向
与持枪朝向一致的 canonical 组合；移动与鼠标瞄准不一致的 strafing 组合不在
本轮新增资产范围内，仍由后续 M4 运行时组合与实机可读性验收负责。

## 4. 三类空手握持分层

### 4.1 握持类别

| grip_id | 适用武器 | 空手姿势 |
|---|---|---|
| `pistol` | USP、Deagle | 紧凑双手握持；扳机手靠近胸前，支撑手贴近 |
| `rifle` | AK、M4 | 中等双手间距；后手靠近扳机位，前手前伸支撑 |
| `sniper` | AWP | 前手伸得更远，后手靠近肩部，后肘略抬但不夸张 |

同类武器共用角色手臂姿势，通过独立武器资产的握持点和原点差异完成对齐，
不为 USP/Deagle 或 AK/M4 分别复制整套角色动画。

### 4.2 图层结构

每个 `direction_id × grip_id` 是一个握持组，共 24 组。每组至少包含：

1. `back_arm`：位于武器之后的手臂/手；
2. `front_arm`：位于武器之前的手臂/手；
3. `shoulder_pivot`：肩部旋转/贴合基准；
4. `trigger_hand_anchor`：后手/扳机手锚点；
5. `support_hand_anchor`：前手/支撑手锚点；
6. `weapon_origin`：武器独立节点的角色侧原点；
7. `occlusion_profile`：该方向的身体、后手、武器和前手遮挡顺序。

握持组跨同方向的四个 C0 步态相位复用，只允许跟随身体根部和肩部做记录明确
的 1～2 个逻辑像素起伏；不为每个步态相位重新画一套握持姿势。

32 个 canonical `walk_body` 是不重复绘制手臂的身体层：包含完整头部、
躯干、骨盆、双腿和双脚，肩关节处留出透明连接边界，不包含肩以下手臂。
24 个 canonical grip group 各有 `back_arm/front_arm` 两张图，因此共有
48 张 canonical arm-layer PNG。两类 canonical 都是分层生产单元，不单独
宣称“完整全身”。

每个 `walk_body` 必须分别和同方向的 pistol/rifle/sniper 三组手臂合成，
产生 `32 × 3 = 96` 个完整全身 QA 结果。96 个结果是由 canonical 图层和
元数据确定性派生的 Review 证据，不重复计为生成候选或 canonical。每个合成
结果都必须接受完整解剖、方向、遮挡和空手 QA；不能用单独身体层或手臂层
替代完整全身验收。

### 4.3 坐标、锚点与机器元数据

所有 C0 body/arm layer 使用同一未裁边 `128×128 RGBA` 逻辑画布：

- 原点 `(0,0)` 在左上；
- `+x` 向屏幕右，`+y` 向屏幕下；
- 所有锚点和偏移都是整数逻辑像素；
- `body_root` 固定为 `(64,114)`；
- 图层 PNG 不因 alpha bbox 改变尺寸、原点或 pivot。

机器元数据固定写入：

```text
assets/source/cleaned/c0/xiaodong/xiaodong_c0_direction_grip_metadata.json
```

JSON 顶层必须精确包含：

| key | 类型与约束 |
|---|---|
| `schema_version` | integer，固定 `1` |
| `canvas` | `{width:128,height:128,origin:"top_left",x_axis:"right",y_axis:"down"}` |
| `body_root` | `[64,114]` |
| `direction_order` | `["n","ne","e","se","s","sw","w","nw"]` |
| `c0_phase_order` | `["contact_l","passing_l","contact_r","passing_r"]` |
| `a5_frame_order` | 见 §4.4 的八帧顺序 |
| `grip_order` | `["pistol","rifle","sniper"]` |
| `body_layers` | direction → phase → body layer record |
| `grip_groups` | direction → grip → grip group record |

每个 body layer record 必须精确包含 `path`、`sha256` 和
`root:[64,114]`。每个 grip group record 必须精确包含：

- `back_arm_path/back_arm_sha256`；
- `front_arm_path/front_arm_sha256`；
- `shoulder_pivot`、`trigger_hand_anchor`、`support_hand_anchor`、
  `weapon_origin`；
- `phase_offsets`：四个 C0 phase 到 `[dx,dy]` 的完整映射；
- `occlusion_order`：`body/back_arm/weapon/front_arm` 四个 token
  各出现一次的数组。

`phase_offsets.contact_l` 固定为 `[0,0]`；其余三个偏移的 `dx/dy`
都必须是 `-2..2` 的整数。该偏移同时应用于 `back_arm`、`front_arm`
和武器节点，禁止让武器与双手分离。`occlusion_order` 的具体排列由方向
母版视觉门批准后写入，但 schema、token 集合和唯一性在批准前已经固定。

### 4.4 A5 八帧复用与布局

A5 每方向八帧顺序固定为：

```text
contact_l, down_l, passing_l, up_l,
contact_r, down_r, passing_r, up_r
```

`character_xiaodong_walk.png` 是 `grid_8x8`：

- 行顺序：`n,ne,e,se,s,sw,w,nw`；
- 列顺序：上述八帧；
- 单格 `128×128`，整图 `1024×1024`。

六张 grip layer sheet 均为 `horizontal_8x1`，列顺序同
`direction_order`，单格 `128×128`，整图 `1024×128`。同方向的一组
前后手跨八个 walk 帧复用；M4 A5 元数据必须提供完整 `a5_frame_offsets`，
其八个键与 `a5_frame_order` 一致，每个 `[dx,dy]` 仍限制在 `-2..2`。

### 4.5 武器资产契约

武器图片继续遵守：

- 图片中没有手、人物、火焰、弹壳、Logo、文字或阴影；
- 默认枪口朝右；
- Godot 节点负责旋转、后坐和左右方向规则；
- 武器资产与角色资产分别进入 manifest 生命周期。

正式 A5 武器元数据除现有 `grip_point`、`muzzle_point`、旋转中心外，还必须
提供 `support_grip_point`。现有 `grip_point` 解释为
`trigger_grip_point`。角色 `trigger_hand_anchor` 对齐
`trigger_grip_point`，角色 `support_hand_anchor` 对齐
`support_grip_point`。

C0 可以用临时抽象线段或锚点十字复核双手间距，但这些辅助标记只存在于
临时 QA 图，不进入 generated source、review preview、cleaned PNG、正式
Sprite Sheet 或 Godot 运行资产。

24 个 C0 grip group 只是八个离散方向的手位和遮挡样本，不授权把连续鼠标
角度直接吸附到八方向。进入 A5 生产前，M4 必须批准独立运行时映射契约，
明确 `aim_angle → grip_direction + residual transform` 或等价算法，并用
自动测试证明枪口方向仍与射击判定完全一致、双手锚点误差不超过 1 个逻辑
像素、扇区边界不发生明显跳手。该契约未批准时，六个 grip manifest 行继续
保持 `planned`。

### 4.6 不显示武器

“考虑持枪手位”不等于在角色图里画透明武器、半透明武器、武器轮廓或道具。
紧凑手枪握持允许双手接触，但双手区域不得包含武器像素、辅助线或锚点标记；
最终画面只有 Godot 独立武器节点能填入握持区域。C0 source、preview、
cleaned 和 A5 Sprite Sheet 中一旦出现任何武器像素，该候选直接判
`revise`。

## 5. C0 产出矩阵

### 5.1 Canonical 数量

| 产出 | 组合 | canonical 数量 |
|---|---:|---:|
| 八方向 `walk_body` layer | 8 方向 × 4 相位 | 32 张 |
| 空手握持组 | 8 方向 × 3 类 | 24 组 / 48 张 arm layer |
| 完整全身 QA 合成 | 32 body × 3 grip | 96 个派生结果，不计 canonical |
| UI 头像 | 保持现有单张 | 不新增 |
| 其他动作 | 保持现有 C0 结论 | 不新增方向 |

一组握持包含 `back_arm/front_arm` 两个可合成图层和对应锚点记录；“24 组”
不是 24 张完整 Sprite Sheet。32 张 body layer 加 48 张 arm layer，
构成 80 张 canonical cleaned layer。失败重试和 `revise` 证据不计入
canonical，但必须保留并进入设计卡候选总数。

### 5.2 现有右下资产

现有 `se` 的四个 approved 走路关键姿势继续作为身份、步态、身体宽度、
相位和脚底锚点依据，不删除、不改写历史决定。它们目前把完整手臂画在人物
主体中，因此只能作为新分层生产的 pose guide 和证据，不能直接冒充已经
完成的 modular body/grip 输出。

### 5.3 命名

走路 body 候选使用：

```text
xiaodong_c0_walk_body_<direction_id>_<phase_id>_<candidate>_{source,preview}.png
xiaodong_c0_walk_body_<direction_id>_<phase_id>_cleaned.png
```

握持候选和通过清理的前后手层使用：

```text
xiaodong_c0_grip_<grip_id>_<direction_id>_<candidate>_{source,preview}.png
xiaodong_c0_grip_<grip_id>_<direction_id>_<back_arm|front_arm>_cleaned.png
```

确定性合成 QA 预览使用：

```text
xiaodong_c0_walk_<direction_id>_<phase_id>_<grip_id>_qa.png
```

96 个 QA 预览可由 committed layers 和 JSON 确定性重建，不登记为 generated
候选或 A5 资产；Review 包必须记录重建命令、总数和联系表 SHA-256。

候选编号、生成时间、输入顺序、完整 Prompt、源/预览/清理 SHA-256、QA、
决定、失败原因和下一轮允许修改项继续记录在“小洞大人”设计卡及批次账本。

## 6. 生产顺序与用户视觉门

实施必须按以下顺序：

1. 先用独立治理提交同步 §2.1 的权威载体和 planned manifest；
2. 保留现有 `se` 四帧作为步态依据；
3. 制作八方向各一个 `contact_l` body layer 和八个 rifle grip group；
4. 再制作 `se` 的 pistol/sniper grip group；
5. 合成八个 rifle `contact_l` 方向母版以及 `se` 的三类握持对比，生成一张
   “八方向头身 + 三类握持”联系表供用户审阅；
6. 用户明确批准联系表后，才补齐其余 24 个 body layer 和 14 个握持组；
7. 完成透明边缘、共享色板、锚点、JSON 和图层清理；
8. 确定性生成全部 96 个合成 QA 结果；
9. 运行机器 QA、内容校验、合成 Review 和独立视觉 Review；
10. 形成独立 C0 扩展提交与进度记录。

完成第 5 步后必须暂停并把联系表交给用户；第 6 步是批准门。未获得用户明确
批准，不得执行第 6 步所述后续批量生成，也不得把本补充规格标记完成。

镜像只允许作为左向姿势引导。`ne/e/se` 可以为 `nw/w/sw` 提供构图和步态
guide，但左向最终候选必须重新校正：

- 发型与脸部神似；
- 解剖左右和步态 phase ID；
- 固定左上光，不能把光源一起翻到右上；
- 衣服明暗簇和轮廓；
- 手部前后遮挡。

未经上述复核的原始水平翻转图不能进入 `accepted_for_concept`。

## 7. QA 与自动校验

### 7.1 八方向 QA

每个 canonical body layer 必须通过第 1～3、5～10 项；每个对应的三类
完整全身合成结果还必须通过第 4 项和手臂遮挡检查：

1. `direction_id` 与头、肩、髋、膝、鞋尖一致；
2. 发型、身形、纯黑服装和冷静气质保持 R2 身份；
3. 四相位解剖左右正确且前后脚交替清楚；
4. 合成结果为完整全身、两臂两手两腿两脚，无多余、缺失、融合或裁切；
5. 身体根部使用同一 128×128 逻辑锚点，序列无明显抖动；
6. 头身宽度、衬衫长度、腿长和鞋尺寸不随方向无故突变；
7. 左上光和共享有限色板一致；
8. 无队标、赞助商、平台/赛事 Logo、官方队服图案、赛事 UI 或水印；
9. 无武器、投掷物、火焰、文字、动作线或技能特效；
10. 128×128 下方向、发型和步态相位仍可读。

背面方向不因看不到正脸而失败第 2 项，但必须由后脑发型、头肩比例和服装
轮廓证明是同一角色。

### 7.2 握持 QA

每个 `direction_id × grip_id` 必须同时通过：

1. 两只手、两条手臂和肩关节完整；
2. pistol/rifle/sniper 的双手间距和肘部轮廓可区分；
3. 扳机手、支撑手与肩部锚点都为整数逻辑像素；
4. QA 合成时两只手与对应抽象 grip 点误差各不超过 1 个逻辑像素；
5. 四步态相位复用时只发生已记录的根部/肩部起伏；
6. 前后手遮挡与方向一致，不穿过头、躯干或彼此融合；
7. 合成角色保持完整解剖和 R2 身份；
8. 双手之间没有武器、半透明轮廓或辅助标记残留。

### 7.3 技术校验

机器校验至少覆盖：

- 方向集合精确等于 `n,ne,e,se,s,sw,w,nw`；
- 每方向 phase 集合精确等于
  `contact_l,passing_l,contact_r,passing_r`；
- grip 集合精确等于 `pistol,rifle,sniper`；
- canonical body layer 为 32，arm layer 为 48，握持组为 24；
- 96 个方向/相位/握持合成组合可确定性重建，无重复和缺项；
- cleaned 图为 `128×128 RGBA`、二值 alpha、透明四角、无强绿色残留；
- 可见色不超过批准共享色板；
- JSON 顶层 key、集合、路径、哈希、锚点、偏移和遮挡顺序符合 §4.3；
- body、前后手层和合成预览的 body root 都为 `(64,114)`；
- `phase_offsets` 完整、为整数且不超出 `-2..2`；
- C0 文件未被 `.gd/.tscn/.tres/project.godot` 引用；
- 十二项 Xiaodong A5 manifest 记录在 M4 正式生产前全部保持 `planned`。

自动检查不能替代八方向联系表的用户视觉批准，也不能替代独立视觉 Review。

## 8. C0、A5 与里程碑边界

- 本规格扩大的是 Xiaodong C0 走路方向与握持可行性，不提前生成其他角色、
  武器、动作、平台或正式玩法内容。
- C0 的 32 张 body layer、48 张 arm layer、24 个握持组和 96 个派生合成
  仍是概念与分层依据，不登记为 A5 `approved` 或 `in_game`。
- A5 到 M4 才制作 `grid_8x8` 正式 body sheet 和六张
  `horizontal_8x1` grip sheet，并完成 `support_grip_point`、连续瞄准映射、
  遮挡、Godot 导入和实机验收。
- M0 继续只裁决 AK 灰盒射击玩具；本规格不修改 M0 战斗实现，也不把 C0
  视觉结果当成 M0 Windows 实机证据。
- M4 前若实机证明八方向角色与连续鼠标瞄准组合不可读，必须另开设计变更，
  不能在本规格下擅自增加 64 种移动/瞄准交叉方向资产。
- M5 发布门仍需重新审查 R2 肖像权、第三方权利、地区和发布选择。

## 9. 完成条件

本补充规格的实施只有在以下条件全部成立时才可记录完成：

- 用户批准“八方向头身 + 三类握持”联系表；
- 32 张 canonical body layer、48 张 canonical arm layer 和 24 个
  canonical 握持组齐全；
- 96 个完整全身合成结果可确定性重建并全部通过；
- 方向/相位/握持 JSON schema、锚点、偏移和遮挡顺序完整；
- 机器 QA、内容校验、合成检查和独立视觉 Review 全部通过；
- R2 禁止元素、武器像素和辅助标记均为零；
- 设计卡、批次账本、文件哈希、候选状态和 manifest 边界一致；
- 形成独立资产提交和独立进度记录提交；
- 用户原有未提交改动保持未暂存且字节不变。

以上完成只代表 Xiaodong C0 八方向/握持扩展通过，不代表 M0、M1–M5、
Mac 1.0 或整个 `/goal` 完成。
