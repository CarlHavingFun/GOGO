# 小洞大人｜C0 批次证据账本｜2026-07-31

- 权威入口：`assets/characters/xiaodong/character_xiaodong_design.md`
- 权威规格：`docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`
- 批准母版：`xiaodong_c0_master_002`
- 用户决定：`2026-07-31T08:57:23+0800`，原文 `批准002`
- 参考图：`assets/source/references/characters/xiaodong/reference_01.jpg`
- 参考 SHA-256：`fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52`
- 权利策略：`R2`

本账本是角色设计卡中 2026-07-31 批次的可审计附件。设计卡继续拥有
候选决定和 C0/A5 边界；本文件保存逐输出文件证据、可重构的完整 Prompt、
技术 QA、动作 QA 和清理证据。它不是 A5 manifest，也不把任何 C0 文件
登记为正式 `approved` 或 `in_game` 素材。

## 1. 批次结论

| 项目 | 结果 |
|---|---:|
| 设计卡总候选 | 24 |
| 本批次新增 image generation 调用 | 22 |
| `accepted_for_concept` 总数 | 16 |
| `revise` 总数 | 8 |
| 正式 C0 cleaned 输出 | 16 |
| 头像母版 | 1 / 1 |
| `idle` 通过关键姿势 | 2 / 2（001、004） |
| `walk` 通过关键姿势 | 4 / 4（001–004） |
| `hit` 通过关键姿势 | 2 / 2 |
| `death` 通过关键姿势 | 3 / 3 |
| `skill_breakin` 通过关键姿势 | 3 / 3 |
| A5 manifest 状态 | 六项仍为 `planned` |
| Godot 运行时引用 | 0 |

`idle_002`、`idle_003`、`walk_002_v01`、`walk_003_v01`～
`walk_003_v04` 都保留为 `generated/revise` 证据，没有删除或伪装成通过。
机器块仍使用聚合 `artifact_state=generated`，因为上述 revise 候选没有进入
正式清理；各 accepted 候选的 cleaned 结果在下文独立记录。

## 2. 生成文件证据

所有 source 均为 `1254×1254 RGB`；所有 review preview 均为
`1024×1024 RGBA`。source 保留模型返回的近似纯绿原图，preview 统一使用：

```text
remove_chroma_key.py --auto-key border --soft-matte
--transparent-threshold 12 --opaque-threshold 220 --despill
```

随后裁取 alpha bbox，以 nearest-neighbor 规范到最长边最多 `819px`。
一般姿势以自身最长边规范；`skill_breakin` 为避免逐帧拉伸抹掉“压低重心”
语义，三帧共同使用 frame 003 的原始高度 `948px → 819px` 缩放率，得到
`746→811→819px` 的序列高度。站立和移动关键姿势水平中心为 `x=512`、
身体底部为 `y=922`；横躺 death 帧按躯干/髋部根部判断，不强制站立脚底。
下列表格的 bbox 统一使用 Pillow 半开区间 `[x0,y0,x1,y1)`；正文若写
“最后可见像素”或 `bottom`，则使用闭区间末像素，即表中 `x1/y1 - 1`。

| 候选 | source bytes / SHA-256 | preview bytes / SHA-256 | preview alpha bbox |
|---|---|---|---|
| `portrait_001` | 1,125,156 / `b1d5cdbb051bb02076343e5b73a3dce017d38f6c074e031f7db0fe3f39ad4960` | 414,090 / `b7c31866aa151acff11f5c7dfd3001e4b29dddf0b37bec9f7cb6f3a81da84eef` | `(223,102)–(801,921)` |
| `idle_001` | 1,090,046 / `ee331fb41f9c63567d843914d2ca813f358c7f7355d91f8bbd5904094fa637b9` | 255,551 / `f1dd0695115d1799bcdf6b6448b3392edf8e462a1f2381f55817406bc09dea79` | `(380,103)–(644,922)` |
| `idle_002` | 1,119,890 / `f54bac59cbb823b980942821d50f620ac4c228ed557f461ccea0c76e7bf29d89` | 270,788 / `e59678a214da67357faee242e65d78222da08f4f76ed0214ff38fb5ec54135ab` | `(376,103)–(648,922)` |
| `idle_003` | 1,109,214 / `a97bbf883c0cd739b82af2e0787eb82b9e8243ae7fcda9177578b727ff97396a` | 264,149 / `9deeca1b39f6b18d080b6c935ff209f5a4349371cb0ad4db781ea9c267961b11` | `(376,103)–(648,922)` |
| `idle_004` | 1,135,564 / `991f3be5952d1105cb0f674405f0239bda9ffff8bf8ad39a01ff1f87cbc11bd3` | 281,699 / `e22be1adde112074ce6db6b6fc68e78e90e77a65dcd8fad9b725c0b6eee34b32` | `(378,103)–(645,922)` |
| `walk_001` | 1,084,666 / `65fbf6e5438b01d35171483545e46eb239e5ef27b3af16b8cfe900ca87392408` | 258,185 / `47c1cf2371ffeb2ebad59896be9813cd9376667aabd0aac80563aaf33fb438bd` | `(343,103)–(681,922)` |
| `walk_002_v01` | 1,095,264 / `0833a4f9861b7ece5b007c3d2ac0fe571c687d99fad9f4446333641d13c11c5f` | 269,085 / `c37b4ecd55f144ca8270881aa24c7f86760ede5026ceaf55e4b344a87b334127` | `(341,103)–(683,922)` |
| `walk_002` | 1,103,696 / `599047cb17c737bd3d07be7f0912aa410b4a357f18c4abc29ec591da493850f3` | 270,523 / `8950af83dd96c363b3b4a8173a24f3f9e928d18b212987982ec8ccce681363df` | `(344,103)–(680,922)` |
| `walk_003_v01` | 1,103,128 / `c516e5ff7bf0a4871b2e744584b82f6bf9c795e4ea55b422067a66a6b3a1a03a` | 266,276 / `383d1f7ed1e9c9c74307ef87903c3fc5dd9d19e490c2d832e10a4a08fd6884de` | `(368,103)–(656,922)` |
| `walk_003_v02` | 1,118,350 / `e0be467c92cd2c007126f6abac25042e5cc036e44d179d865af6a8478640720b` | 269,285 / `b0d3b449bb2e772877bc8205bd8112415779253fb51410242c1bef7be461dec7` | `(370,103)–(654,922)` |
| `walk_003_v03` | 1,089,781 / `7e850d81b0e8f8b6f713f199f8faa9bad1f43e6358bc69adf70e52c260e05f09` | 262,605 / `1d57ccfbc0760445eb9c516271bac1f411ab7f2f68910f27daa1852a46995fca` | `(346,103)–(678,922)` |
| `walk_003_v04` | 1,097,049 / `835580be830a256d6479b83473ace6ba4e75cc19db86f9e26e8e641113f5136d` | 266,371 / `80ef5bb9cf3311aaa8ca1fc9ef677b96eef6344c272f1f5bfb838718d8064d58` | `(345,103)–(679,922)` |
| `walk_003` | 1,095,498 / `2c4df2415a5df0af0f96d9b1d57ebf0134b85756d603a38a0efd0ee8382b21ff` | 264,711 / `a9eda164f990d1c223b40dd0ade6e4d3b1d3c5e3d4537f836afc769ff7a3cfd3` | `(344,103)–(680,922)` |
| `walk_004` | 1,091,305 / `3f2cd9cfebb0049b20baea79edf546261ecbc20ad46967ffd806d25f3170fa28` | 261,762 / `c4232bc012b28cef7a6c390c6b9e62b82b00caadf386bffe2a1716cf28a0ea17` | `(373,103)–(651,922)` |
| `hit_001` | 1,095,045 / `07b6c5bcc93de07682c651c283c2fbb701b0e63bd7e5c64566099522e903936a` | 278,656 / `f9e5a805826631306c78812cf0a3101a1d11d05c8d407e82dc348846bbf38176` | `(323,103)–(700,922)` |
| `hit_002` | 1,104,065 / `f48f02da38773443a743ec14e9fa3f7a55750a2f75c2f1765968f0bd756fdb52` | 259,103 / `7d2f4a681dde1821fa6ec5320f3573bea79da0e8d743e5b51b40d0e3b89927fa` | `(374,103)–(649,922)` |
| `death_001` | 1,106,039 / `10369ab351d70b951850ab5622ec12307175ff89f0f94e41204babe8edeb247e` | 309,143 / `6c7621867178ef92515dd827a679d2bcfcb9d1f543a45bbde10533589ab3d4f2` | `(259,103)–(764,922)` |
| `death_002` | 1,122,058 / `c939dd5031722639d24d40ab5738eb1604300a7534147b6bbb240c872714ca36` | 373,119 / `eecfa6b6c3d03cf117c36ed2ca2a7cc2a5d61c87731445d0c1bdd5d194f22dcb` | `(102,277)–(921,923)` |
| `death_003` | 1,122,609 / `b6f8a6ebed925bbd95d8b3f55fbde1d5f60287d1fa5127753ff47e8e30ce71ff` | 257,257 / `048cbb28f5813762fcd0ba6ade52dc70bc9bd72e190de0841afbe2ceb2f857dd` | `(102,395)–(921,805)` |
| `skill_breakin_001` | 1,083,127 / `89461a5421ffe7e7f39d58f017515e4d570016722d70c27f98cda76831ba6082` | 255,543 / `054d5cdc2ec9b02771988058267b6c64510c87e4daac30688842525f4fe8ee15` | `(354,176)–(669,922)` |
| `skill_breakin_002` | 1,118,379 / `e43ff70abc48f766c8a99f0c37bade6545f4cd52d22ca4ccbef9c0c6bc818445` | 300,285 / `2814e348ad285cfe76623f0d201d09331354ce5a22d179db9f3c314b766c602b` | `(294,111)–(730,922)` |
| `skill_breakin_003` | 1,106,711 / `4b12b3955ce5cf86444188037337a6f29e375a9860f3834154a4a0bc21e07b42` | 264,406 / `53ceb85feaafa953d872f05c7f507d7bc9c4f3a071c6ce045786a50a9820d46e` | `(380,103)–(643,922)` |

批量技术校验结果：`GENERATED_COUNT=24`，`GENERATED_QA=PASS`。24 张
preview 均为透明四角、单一 8 邻域非零 alpha 主体、主体内强绿色像素 `0`。
`walk_003_v04` preview 曾含 1 个孤立 alpha 像素；只清理该 review preview，
raw source 保持未改，表中为清理后的 preview SHA。

## 3. 可重构实际完整 Prompt

每次调用的完整 Prompt 定义为“公共块 + 对应候选差异块”，两块按本节顺序
拼接，任何一块都不得省略。这样避免在 22 条记录中复制同一长排除段，同时
仍能逐候选重构完整正向要求、参考输入和排除项。生成工具为 Codex built-in
`image_gen`；底层模型名未暴露，因此不推定模型。

### 3.1 公共块 `C0-R2-COMMON`

```text
Use case: identity-preserve.
Create exactly one standalone Xiaodong C0 pixel-art candidate, never a collage or sprite sheet. The approved master 002 controls the non-mirrored character identity, compact chibi proportions, elevated top-down three-quarter camera, SCREEN LOWER-RIGHT direction, pixel language, palette, clothing, and upper-left light. The stable R2 reference controls recognizable facial relationships, brown jaw-length naturally center-parted medium-short hair, slim body type, and calm restrained presence.
Preserve the same single recognizable young character, loose plain pure-black short-sleeve shirt, black trousers, black shoes, empty hands, crisp hard-edged clustered pixels, 1–2 logical-pixel dark outline, limited brown/warm-skin/black-and-dark-gray palette, complete readable anatomy, and the approved hair, face, body width, shirt length, scale, and direction unless a candidate delta explicitly changes only an action joint.
Use a square generation canvas and a perfectly flat solid #00ff00 chroma-key background for local removal: one uniform color, no shadow, gradient, texture, reflection, floor plane, horizon, vignette, lighting variation, or environment. Do not use #00ff00 in the subject.
For a full-body candidate show exactly one complete character with exactly two arms, two hands, two legs, and two fully visible separate feet, generous padding, no crop, and a stable feet-midpoint/body-bottom anchor. For the intentional portrait crop show exactly one head, neck, two shoulders, and coherent visible upper arms, with face/shoulder anchors instead of feet.
No weapon, grenade, prop, projectile, impact effect, motion line, aura, text, letters, number, team logo, sponsor mark, platform or tournament logo, official team-jersey pattern, official tournament UI, trophy, stage, photography background, watermark, UI frame, environment, floor, cast/contact shadow, tactical vest, red or orange accent, extra/missing/detached/fused limbs, duplicated body part, blood, gore, wound, dismemberment, photorealism, smooth vector art, 3D render, blurry anti-aliased edges, or copyrighted character. Do not add “no real-person portrait”; recognizable R2 likeness is required.
```

### 3.2 头像与 idle 差异块

| Prompt ID | 参考输入顺序 | 必须追加的候选差异块 |
|---|---|---|
| `portrait_001` | master 002；reference 01 | `Asset type: C0 128×128 logical portrait master. Create a centered head-and-shoulders portrait only: head, neck, both shoulders and upper chest; keep the complete hair silhouette and both shoulders uncropped. Face, gaze, nose/chin, neck and shoulder axis point SCREEN LOWER-RIGHT. Subject longest dimension 75%–82%; calm restrained expression; face center and shoulder midpoint are the anchors. Do not generate legs, feet or a foot anchor.` |
| `idle_001` | master 002；reference 01 | `Asset type: idle key pose 001. Create the neutral restrained breathing-cycle start: quiet balanced natural standing, feet planted and clearly separated, hands relaxed at sides, no gesture or stride. Keep a modest neutral stance, stable feet midpoint and body-bottom anchor, and subject longest dimension 72%–80%.` |
| `idle_002` | master 002；reference 01；idle 001 preview | `Asset type: idle key pose 002 attempt. Add only a tiny inhale and weight shift: chest/shoulders move roughly 1–2 logical pixels and arms respond minimally. Both feet, pelvis, leg length, shoe spacing, angle, size, screen position and contact line must overlay idle 001 exactly. No new stance, lifted foot, walk, attack or large movement.` |
| `idle_003` | master 002；reference 01；idle 001 preview；failed idle 002 preview | `Use case: precise-object-edit. Start from idle 001; use idle 002 only to understand the intended inhale. Preserve idle 001 pixel-for-pixel in geometry from the waist down and modify only upper-chest/shoulder shirt clusters by about one logical pixel with at most a minute upper-arm response. Do not copy the failed foot drift.` |
| `idle_004` | reconstructed idle composite；idle 001 preview；master 002；reference 01 | `Use case: faithful cleanup of an already-correct idle composite. The edit target uses idle 003 above preview y=540 and idle 001 from y=540 downward. Preserve that silhouette and every lower-body joint/foot position; retain only the tiny upper-body inhale. Do not reinterpret, redraw, slide, rotate, resize or vertically offset either leg or shoe.` |

`idle_004` 的临时 edit target 可从已保留文件确定性重建，不是新的身份来源：
取 `idle_003_preview.png` 的 `y<540`，取 `idle_001_preview.png` 的
`y>=540`，在同一 `1024×1024` 透明画布合成。

### 3.3 walk 差异块

| Prompt ID | 参考输入顺序 | 必须追加的候选差异块 |
|---|---|---|
| `walk_001` | master 002；reference 01 | `Asset type: walk contact 001. Anatomical left foot makes a short forward contact along SCREEN LOWER-RIGHT; right leg trails with heel lifted. Right arm swings slightly forward and left arm slightly back. Upright compact walking, not running/lunge/attack; both shoes separate; root height fixed.` |
| `walk_002_v01` | master 002；reference 01；walk 001 preview | `Asset type: left-foot-weight-bearing passing attempt. Left shoe flat beneath pelvis as the single support; right knee bends and right foot lifts forward past the support leg with green separation beneath it. Arms pass near neutral; root and body volume match walk 001.` |
| `walk_002` | failed 002_v01；master 002；reference 01；walk 001 preview | `Targeted revision: retract the current lower-right forward anatomical-left shoe beneath the pelvis and make it the flat support. Lift the anatomical-right shoe, bend that knee and bring the right foot forward beside/beyond the support shin. Change only this leg configuration; keep upper body, identity, camera, scale and anchor.` |
| `walk_003_v01` | master 002；reference 01；walk 002 preview | `Asset type: right-foot-forward contact attempt. Continue the anatomical-right swing foot into contact, slightly screen-left of the body’s lower-right travel axis; anatomical-left leg trails toward screen upper-right. Reverse the arms relative to walk 001; do not repeat its limb arrangement.` |
| `walk_003_v02` | failed 003_v01；master 002；reference 01；walk 002 preview | `Targeted revision: keep the whole character facing SCREEN LOWER-RIGHT but reverse the gait relationship. Put the new forward-contact shoe lower and on SCREEN-LEFT of body center; put the trailing shoe higher and on SCREEN-RIGHT/upper-right. Reverse the small arm swing. Do not mirror head, torso, camera or light.` |
| `walk_003_v03` | master 002；reference 01；mirrored walk 001 pose guide | `Image 3 is pose-only: inherit only its opposite arm/leg phase, never its face direction, identity, gray background or lighting. Keep approved head/torso facing SCREEN LOWER-RIGHT. The leg trailing in walk 001 must cross forward and plant; the previous leader bends/lifts behind. The forward leg must originate from the opposite hip.` |
| `walk_003_v04` | mirrored walk 001 pose guide as edit target；master 002；reference 01 | `Targeted pose edit: preserve the guide’s planted shoe on SCREEN LOWER-LEFT of the pelvis and its bent lifted shoe on SCREEN RIGHT/UPPER-RIGHT, plus opposite arm swing. Correct only the mirrored identity/head/shoulder/hip direction to SCREEN LOWER-RIGHT and replace gray with chroma green. Do not swap the limbs back.` |
| `walk_003` | reconstructed pose composite；master 002；reference 01 | `Faithfully clean an already-correct opposite-contact composite. Preserve its full pose geometry exactly: planted leading shoe SCREEN LOWER-LEFT of pelvis, bent lifted trailing shoe SCREEN RIGHT/UPPER-RIGHT, opposite arm swing, face SCREEN LOWER-RIGHT. Harmonize only minor seam/style differences; never return to walk 001.` |
| `walk_004` | master 002；reference 01；walk 003_v02 preview | `Asset type: right-foot-weight-bearing passing pose. Anatomical-right shoe is the flat support beneath the pelvis on screen-right; anatomical-left knee bends and its lifted shoe passes on screen-left with green separation. Arms near neutral; upright compact walk; no two long contact legs.` |

`walk_003_v03/v04` 的 pose guide 是 `walk_001_preview.png` 的水平镜像。
最终 `walk_003` 的 edit target 也可确定性重建：取
`walk_001_preview.png` 的 `y<520`，取其水平镜像的 `y>=520`。v03 与
v04 仍回到 001 同相，因此保留为 revise；只有该复合 edit target 的输出
形成 screen-left 前脚、screen-right 后脚且头身继续右下。

### 3.4 hit、death 与 skill_breakin 差异块

| Prompt ID | 参考输入顺序 | 必须追加的候选差异块 |
|---|---|---|
| `hit_001` | master 002；reference 01 | `Create a compact non-gory impact beat: torso/head recoil slightly toward screen upper-left, shoulders compress, chin tucks, elbows bend and empty hands lift reflexively. One foot stays planted; the other only catches balance. Not a fall, attack, run or dramatic knockback; no attacker/projectile/effect.` |
| `hit_002` | master 002；reference 01；hit 001 preview | `Create immediate recovery: torso springs halfway upright, chin lifts, shoulders reopen and hands lower; planted foot keeps the anchor and shifted foot draws back. Keep a small residual lean so the pair reads impact—recovery, not a new impact or walk.` |
| `death_001` | master 002；reference 01 | `Create initial non-gory loss of balance: knees buckle, pelvis drops slightly, torso tilts screen upper-left, head lags and arms loosen. One shoe remains near the anchor while the other slips lower-right. Not yet kneeling, horizontal, airborne or already dead.` |
| `death_002` | master 002；reference 01；death 001 preview | `Continue into the fall midpoint: pelvis and one bent knee approach the implied ground, torso becomes strongly diagonal, one empty hand braces, the other trails, lower-right leg extends and the other folds. Not crouch, roll, dodge, attack, seated idle or completed corpse; keep fall direction.` |
| `death_003` | master 002；reference 01；death 002 preview | `Continue to a fully settled intact horizontal pose along the same diagonal, head screen upper-left and shoes screen lower-right. Eyes closed/soft, one arm near the former brace and the other beside/across torso, both legs naturally bent and shoes separate. Not sleep/lounge/crawl/roll; no skull, ghost, tombstone or sleep symbol.` |
| `skill_breakin_001` | master 002；reference 01 | `Create anticipation 001: controlled lowered center, knees flexed, hips lower, slight SCREEN LOWER-RIGHT lean, shoulders compact, hands beside body and both feet planted. This is restrained preparation, not attack or exaggerated charge.` |
| `skill_breakin_002` | master 002；reference 01；skill 001 preview | `Create peak burst 002: one short controlled displacement toward SCREEN LOWER-RIGHT; front foot advances, rear foot pushes, compact forward lean and small arm counter-swing. Empty hands; no weapon, flame, aura, speed line, dust, text or other effect.` |
| `skill_breakin_003` | master 002；reference 01；skill 002 preview | `Create recovery 003: forward foot settles, rear foot catches up, knees remain slightly flexed, hips recenter, torso rises to neutral right-down, shoulders release and arms relax with residual swing. Not a new run, attack, celebration or duplicate idle.` |

## 4. 设计与动作 QA

历史 `accepted_for_concept` 概念候选集合（单方向 `se` 全臂 pose guide）：

```text
master_002
portrait_001
idle_001 idle_004
walk_001 walk_002 walk_003 walk_004
hit_001 hit_002
death_001 death_002 death_003
skill_breakin_001 skill_breakin_002 skill_breakin_003
```

| # | C0 QA | accepted 集合 |
|---:|---|---:|
| 1 | 棕色齐下颌中短发可读 | 1 |
| 2 | 偏瘦身形稳定 | 1 |
| 3 | 纯黑宽松短袖、黑裤、黑鞋 | 1 |
| 4 | 冷静克制气质 | 1 |
| 5 | 俯视 3/4 且朝向右下 | 1 |
| 6 | 解剖完整、无多余或缺失肢体 | 1 |
| 7 | 无 Logo、文字、赞助商和赛事元素 | 1 |
| 8 | 空手，身体与武器完全分离 | 1 |
| 9 | 像素轮廓和有限色板符合项目语言 | 1 |
| 10 | 资产类型对应的动画锚点适用 | 1 |

头像的第 6 项按“意图明确的 bust crop 内解剖完整”判断，第 10 项按
face center / shoulder midpoint 判断；它不伪造脚和全身。其余 accepted
候选均为完整全身。动作的额外叠帧和语义结果如下：

| `accepted_for_concept` 候选 | QA1→QA10 |
|---|---|
| `master_002` | `1 1 1 1 1 1 1 1 1 1` |
| `portrait_001` | mapped `1 1 1 1 1 1 1 1 1 1`；5 项直接 + 5 项母版继承/资产类型映射 |
| `idle_001`、`idle_004` | 各 `1 1 1 1 1 1 1 1 1 1` |
| `walk_001`～`walk_004` | 各 `1 1 1 1 1 1 1 1 1 1` |
| `hit_001`、`hit_002` | 各 `1 1 1 1 1 1 1 1 1 1` |
| `death_001`～`death_003` | 各 `1 1 1 1 1 1 1 1 1 1`；002/003 的 QA10 使用躯干/髋部 root |
| `skill_breakin_001`～`skill_breakin_003` | 各 `1 1 1 1 1 1 1 1 1 1` |

| 序列 | 叠帧/语义证据 | 结果 |
|---|---|---|
| `idle_001/004` | generated preview 整体 IoU `0.9497`；清理后逻辑画布 `y=68–127` 下半身逐像素完全一致 | PASS |
| `walk_001–004` | 001 左接触、002 左支撑 passing、003 反相接触、004 右支撑 passing；四帧 bbox bottom 均为 922 | PASS |
| `hit_001–002` | 短促后撤防护—立即回正，无击飞、血液或攻击特效 | PASS |
| `death_001–003` | 失衡—单手支撑倒伏—同一对角横躺；无镜像跳变、肢解或血浆 | PASS |
| `skill_breakin_001–003` | 三帧以 003 的原始主体高度为统一缩放基准；逻辑 bbox top 为 `22→14→13`，明确形成压低重心—短距爆发—回稳；空手且无武器/文字/技能特效 | PASS |

`death_002` 与 `death_003` 的 preview bbox 中心都为 `(512,600)`，
cleaned bbox 中心约为 `(64,75)`。横躺帧以该躯干/髋部 root 叠加；
不以横向身体的 bbox bottom 代替 root。

revise 证据不进入 cleaned：

| 候选 | 基础 10 项 | 额外失败原因 | 决定 |
|---|---:|---|---|
| `idle_002` | 10/10 | 前脚底缘相对 001 约漂移 17px，约 2 个逻辑像素 | `revise` |
| `idle_003` | 10/10 | 足部 IoU 改善但仍约 2 个逻辑像素漂移 | `revise` |
| `walk_002_v01` | 10/10 | passing 不清，仍近似接触姿势 | `revise` |
| `walk_003_v01` | 10/10 | 未与 001 形成反相 | `revise` |
| `walk_003_v02` | 10/10 | 定向修复后前后脚侧仍未改变 | `revise` |
| `walk_003_v03` | 10/10 | 模型忽略镜像 pose guide，仍回到 001 同相 | `revise` |
| `walk_003_v04` | 10/10 | 以 pose guide 为 edit target 后仍回到 001 同相 | `revise` |

下一轮修改权限：

- 不得重绘旧候选；已批准补充规格另行授权 modular 八方向 C0。
- `idle_002/003`：若保留利用，只允许修正腰部以下和脚底叠帧，不改变
  身份、上身呼吸语义、方向、服装或色板；
- `walk_002_v01`：只允许修正为明确 passing 单脚承重，不改变身份和 root；
- `walk_003_v01–v04`：只允许修正反相前后脚和对应小幅摆臂，不改变头身
  右下方向、身份、服装、色板或画布锚点；
- 本批次已有通过替代帧，因此上述 revise 候选当前不再继续生成。

相对真实参考的共同差异仅为批准的紧凑 Q 版、俯视 3/4、有限像素色板和
动作姿势转译；未新增队伍、赛事、赞助、平台、武器或剧情身份元素。逐候选
相对母版的变化只限于第 3 节所列动作 delta。

## 5. 正式 C0 清理证据

清理只处理通过候选，不改变 A5 manifest。算法：

1. 从规范化 review preview 以 nearest-neighbor 缩为 `128×128`；
2. alpha 以 `128` 为阈值硬化，并只保留最大 8 邻域主体；
3. 由全部 16 个 accepted logical outputs 共同派生一套 32 色可见色板；
4. 无抖动映射到共享色板，透明像素规范为 `(0,0,0,0)`；
5. `idle_004` 的逻辑画布 `y=68–127` 从 `idle_001` 逐像素复制，锁定
   pelvis、腿、鞋和脚底；
6. 不进行补间、Sprite Sheet 组装、A5 路径复制或 Godot 导入。

共享可见色板：

```text
#fdd3b2 #fdcdab #f8b78e #e68b59 #c96b3d #b3552e #9b4b27 #7a442e
#80351c #642b17 #3d3135 #3b2b2e #352b2f #33292d #30262b #2a2326
#4e180b #30140f #262023 #26181a #211c1e #20181c #1d161a #1d0e0e
#161213 #120e0f #100b0d #090906 #0e0405 #060304 #020301 #010000
```

| cleaned 输出 | bytes | SHA-256 | alpha bbox |
|---|---:|---|---|
| `master/xiaodong_c0_master_002_cleaned.png` | 5,672 | `d87c3a64fc69fa19cfe40618a16f4a4cf521645702f83575345755f384f1efd0` | `(47,13)–(81,115)` |
| `portrait/xiaodong_c0_portrait_001_cleaned.png` | 7,375 | `d099a4f8aa1eaed8e039d8750db735c8557f19aabd49b8abbbf6af84a640489b` | `(28,13)–(100,115)` |
| `keyposes/idle/xiaodong_c0_idle_001_cleaned.png` | 5,553 | `42dda0eeb625262cb0da169ea46cc352eabfdb65ea66379431135b288cced4e3` | `(47,13)–(80,115)` |
| `keyposes/idle/xiaodong_c0_idle_004_cleaned.png` | 5,845 | `21d077c88d18b93a3c42c49827b18fbfa7046397b42fa9f78e357b1efa86b51c` | `(47,13)–(80,115)` |
| `keyposes/walk/xiaodong_c0_walk_001_cleaned.png` | 5,785 | `38993b0c4f259e0a729c89a86e3cb30784aad4b1697abc5d6dbbecd134786c85` | `(43,13)–(85,115)` |
| `keyposes/walk/xiaodong_c0_walk_002_cleaned.png` | 6,185 | `87c3fc466f65daeab1155c86d71b7b2b7c5e830ad3f0ae153a41b288f6d9b5c6` | `(43,13)–(85,115)` |
| `keyposes/walk/xiaodong_c0_walk_003_cleaned.png` | 5,842 | `614a83716ad2cd9b59c364cf808c891e68cf6db3061c2f1495153e5da5d49a27` | `(43,13)–(85,115)` |
| `keyposes/walk/xiaodong_c0_walk_004_cleaned.png` | 5,813 | `bb28dc6215fdc6043111ecb4b3859cece730567a0ee9c4aa6a1e1d7f05c0b5ed` | `(47,13)–(81,115)` |
| `keyposes/hit/xiaodong_c0_hit_001_cleaned.png` | 6,154 | `d479480d68ee3920e04d7744d1923b45c61fd584cca114c4dc7b4c3dbb52df26` | `(40,13)–(87,115)` |
| `keyposes/hit/xiaodong_c0_hit_002_cleaned.png` | 5,784 | `f0ea4dbbe512a26549ece44913184c3c1a32b4954b89c8f7ed54067e64c5f6cd` | `(47,13)–(81,115)` |
| `keyposes/death/xiaodong_c0_death_001_cleaned.png` | 6,880 | `bc19d4cddf6cb69c21e79b6301e298155d3955d720e91f2b78aeba91f36db8b4` | `(32,13)–(95,115)` |
| `keyposes/death/xiaodong_c0_death_002_cleaned.png` | 7,862 | `cc6061e0ad9d460f8c89666fb2f26d768012f896368bae41d4ab7973d4d6a7a3` | `(13,35)–(115,115)` |
| `keyposes/death/xiaodong_c0_death_003_cleaned.png` | 5,889 | `3dbf1399f2121ac01a85b8604f58d63b136058185c2e5882a12b74de143b8d9b` | `(13,49)–(115,100)` |
| `keyposes/skill_breakin/xiaodong_c0_skill_breakin_001_cleaned.png` | 5,807 | `a9d31f8c056ee9fbbfb92453657069ed93eef8fb819cf444eba0e581e8d39bc0` | `(44,22)–(84,115)` |
| `keyposes/skill_breakin/xiaodong_c0_skill_breakin_002_cleaned.png` | 6,428 | `e68e98cd5cfa3c77923b02a4533b49ba439c335bc8c43ff0b4bad7855ec6adce` | `(37,14)–(91,115)` |
| `keyposes/skill_breakin/xiaodong_c0_skill_breakin_003_cleaned.png` | 5,751 | `f607e24fbd4636f83dfadc98f996587f3725d73e185254bc5018ba6337f1441a` | `(47,13)–(80,115)` |

清理批量校验：`CLEANED_COUNT=16`，`CLEANED_QA=PASS`，
`IDLE_LOWER_BODY_EXACT_Y68_127=true`。每张均为 `128×128 RGBA`、
二值 alpha、透明四角、单连通主体、主体内强绿色 `0`、可见色不超过共享
32 色。清理输出仍是 C0 动作依据，不是 A5 Sprite Sheet。

## 6. 边界与下一阶段

- 本 checkpoint 不是用户批准的八方向 contact sheet；它只封存 2026-07-31 的
  单方向 `se` 概念与 pose 证据。`walk_001–004` 是全臂 pose guide，不计入
  后续 modular 八方向 body、arm、grip、合成 QA 或视觉门。

- 本批次没有编辑 `assets/asset_manifest.csv`；小洞大人六项 A5 正式记录
  继续保持 `planned`。
- 本批次没有把 generated、preview 或 cleaned C0 PNG 引入 `.gd`、
  `.tscn`、`.tres`、`project.godot` 或 Godot import 证据。
- C0 cleaned 只证明概念、轮廓、色板、透明边缘、锚点和小尺寸可读性；
  人工补间、正式 Sprite Sheet、A5 验收和实机导入仍受 M4 入口门控制。
- R2 不是最终肖像权或第三方授权结论；发布选择继续受 M5 人工门控制。
