# 小洞大人 C0 八方向与三类握持视觉门批次

- 批次日期：2026-07-31
- 状态：`halted_after_user_simplification`
- 新批次候选数：`4`
- 全局候选数：`28`
- canonical 目标（本视觉门）：`8 body + 20 arm layers`
- derived QA 目标（本视觉门）：`10 unique composites + 1 eleven-cell gate sheet`
- 边界：本联系表获得用户明确视觉批准前，不生成其余 24 个 body layer 或
  14 个 grip group，不进入 A5/Godot。

> 2026-07-31 用户在第 4 个成功返回图后终止本分层方案。后续改为“一个完整
> 人物 × 八方向 × 各动作帧”，武器是独立图层并按方向固定挂点贴附；不再生产
> `walk_body + back_arm/front_arm + pistol/rifle/sniper grip group`。本文件
> 只作为被终止方案的生成证据，不再是后续生产合同。

## 1. 权威基线

- 总设计基线：
  `docs/superpowers/specs/2026-07-30-gogo-vnext-xiaodong-c0-design.md`
- 八方向补充规格：
  `docs/superpowers/specs/2026-07-31-gogo-xiaodong-eight-direction-grip-design.md`
- 批准的书面规格提交：`b974af1`
- 执行计划提交：`3cdb12b4cefc268d3a30d0719122785ee9c7417a`
- 12 项内容校验合同提交：`959152bfc05351dbbe6be4e00f4fa6948246dade`
- 权威设计与 A5 治理提交：`b147f4a7070c9665a115fc4d497705a11f9d0e6c`
- 用户批准：八方向头身同步转向；空手表现不同武器握持；方向共用；
  pistol/rifle/sniper 三类分层；书面规格已批准。

## 2. 固定输入与权利边界

| 输入 | 路径 | bytes / 尺寸 | SHA-256 | 角色 |
|---|---|---|---|---|
| `reference_01` | `assets/source/references/characters/xiaodong/reference_01.jpg` | `77554` / `853×1280` | `fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52` | R2 身份参考，不是 edit target |
| `master_002_source` | `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_002_source.png` | `1254×1254` | `2c8d1f241caf81751df87b2a4959684112debe5b79c159646f7794c639c007a1` | 用户批准的右下视觉母版 source |
| `master_002_preview` | `assets/source/generated/c0/xiaodong/master/xiaodong_c0_master_002_preview.png` | `1024×1024` | `0df03821de864e678971d103cfb1d39d79b9ea9ef446d799e0e076469f9e3fe3` | 透明审阅参考 |
| `master_002_cleaned` | `assets/source/cleaned/c0/xiaodong/master/xiaodong_c0_master_002_cleaned.png` | `128×128` | `d87c3a64fc69fa19cfe40618a16f4a4cf521645702f83575345755f384f1efd0` | 尺寸、色板和轮廓参考 |
| `se_contact_l_guide` | `assets/source/cleaned/c0/xiaodong/keyposes/walk/xiaodong_c0_walk_001_cleaned.png` | `128×128` | `38993b0c4f259e0a729c89a86e3cb30784aad4b1697abc5d6dbbecd134786c85` | 仅 `se/contact_l` 全臂 pose guide |

权利策略固定为 `R2`：优先保留可识别神似；禁止战队 Logo、赞助商、
平台/赛事 Logo、官方队服图案、官方赛事 UI、奖杯、舞台和水印。角色与握持
层均不得包含武器像素。

## 3. 固定集合、命名与输入顺序

- 方向顺序：`n,ne,e,se,s,sw,w,nw`
- C0 相位顺序：`contact_l,passing_l,contact_r,passing_r`
- 握持顺序：`pistol,rifle,sniper`
- body candidate：
  `xiaodong_c0_walk_body_<direction>_contact_l_<candidate>_{source,preview}.png`
- cleaned body：
  `xiaodong_c0_walk_body_<direction>_contact_l_cleaned.png`
- grip candidate：
  `xiaodong_c0_grip_<grip>_<direction>_<candidate>_{source,preview}.png`
- cleaned arms：
  `xiaodong_c0_grip_<grip>_<direction>_{back,front}_arm_cleaned.png`
- 每方向候选编号从 `001` 开始；grip 每组 `001=back_arm`、
  `002=front_arm`，重试继续单调递增且不覆盖。
- body 输入顺序：master 002、R2 reference；仅 `se` 再加入
  `se_contact_l_guide`。
- arm 输入顺序：同方向已接受 arm-less body、master 002、R2 reference。

## 4. 方向语义与拟议遮挡

| ID | Camera-relative body reading | 拟议遮挡顺序 |
|---|---|---|
| `n` | screen-up；rear view；后脑齐颌发尾与背部居中 | `front_arm,weapon,body,back_arm` |
| `ne` | screen-upper-right；rear three-quarter | `front_arm,weapon,body,back_arm` |
| `e` | screen-right；clean right profile | `back_arm,body,weapon,front_arm` |
| `se` | screen-lower-right；批准身份三分之四 seed | `back_arm,body,weapon,front_arm` |
| `s` | screen-down；front-facing top-down | `back_arm,body,weapon,front_arm` |
| `sw` | screen-lower-left；front three-quarter | `front_arm,body,weapon,back_arm` |
| `w` | screen-left；clean left profile | `front_arm,body,weapon,back_arm` |
| `nw` | screen-upper-left；rear three-quarter | `front_arm,weapon,body,back_arm` |

`weapon` 在 C0 合成中始终为空槽。

## 5. Body 共用 Prompt

```text
Use case: stylized-concept
Asset type: GOGO C0 modular game-character walk body layer
Input images: Image 1 is approved master 002 for identity, pixel treatment, scale and upper-left light. Image 2 is the user-designated R2 identity reference only, not an edit target. For se only, Image 3 is a pose-only contact_l guide.
Primary request: Create one Xiaodong C0 pixel-art WALK BODY LAYER on a perfectly uniform #00ff00 chroma background. This is an internal modular layer, not a complete character: include one complete head and hair, neck, torso, pelvis, two complete legs and two complete separate feet; end both shoulders at clean green connection edges and include no arm, forearm, hand, weapon, prop, guide, marker, shadow, text or effect.
Subject: Preserve the approved master 002 identity and R2 reference: recognizable facial relationships when visible, brown jaw-length center-parted medium-short hair, slim body, loose plain pure-black short-sleeve shirt, black trousers, black shoes, calm restrained presence, compact top-down chibi proportions, fixed upper-left light, hard clustered pixels and the approved shared dark/brown/warm-skin palette.
Pose: Anatomical contact_l: the character's anatomical LEFT foot contacts forward along the declared screen direction and the anatomical RIGHT foot trails. Keep the same body scale and body-root target. The head/face or back-of-head, chest, pelvis, shoulder-axis normal, hip-axis normal, both knees and both shoe tips all point to the same declared direction.
Scene/backdrop: perfectly flat solid #00ff00; one uniform color; no shadows, gradients, texture, reflections, floor plane or lighting variation; generous padding; no use of #00ff00 in the subject.
Constraints: no team logo, sponsor, platform/tournament logo, official jersey pattern, tournament UI, trophy, stage, watermark, red/orange accent, extra/missing/fused limb, photorealism, vector art, 3D render or blurry antialiasing. Do not mirror the light. No weapon pixels.
```

每次调用在上述共用块后追加 §4 对应的唯一方向句。

## 6. Arm 共用 Prompt

```text
Use case: stylized-concept
Asset type: GOGO C0 modular empty-hand grip arm layer
Input images: Image 1 is the accepted same-direction arm-less body alignment reference. Image 2 is approved master 002. Image 3 is the user-designated R2 identity reference.
Primary request: Create one Xiaodong C0 pixel-art ARM LAYER on a perfectly uniform #00ff00 chroma background, aligned to the supplied arm-less body reference on the same square canvas. Output only ONE anatomically complete shoulder-to-hand arm named by the role sentence; all other pixels remain green.
Subject: Preserve the approved skin, black short-sleeve cuff, pixel clusters, upper-left light and scale. The shoulder end must connect to the supplied body without a gap or duplicate shoulder. The hand assumes an empty-handed invisible-weapon grip: fingers may curl naturally, but there is no weapon, transparent weapon, weapon silhouette, prop, guide, anchor cross, line, text, shadow or effect.
Scene/backdrop: perfectly flat solid #00ff00; one uniform color; no shadows, gradients, texture, reflections, floor plane or lighting variation; no use of #00ff00 in the arm.
Constraints: do not output torso, head, pelvis, legs or the other arm; no team/sponsor/tournament material; no extra fingers, fused anatomy, antialiasing, watermark or weapon pixels.
```

类句：

- `pistol`：compact two-hand spacing; trigger hand close to chest, support hand
  close enough to cup it.
- `rifle`：medium two-hand spacing; trigger hand near chest, support hand extended
  a moderate distance.
- `sniper`：longest support reach; trigger hand close to shoulder, rear elbow
  slightly raised but restrained.

角色句：

- `back_arm`：output only the trigger-side arm and trigger hand that belongs behind
  the absent weapon.
- `front_arm`：output only the support-side arm and support hand that belongs in
  front of the absent weapon.

每次调用再追加 §4 对应的方向句。

## 7. 候选与 QA 记录

每个成功或失败的返回图都必须追加一行；不能删除 revise 证据。`QA1–QA10`
适用于 body/完整合成；`G1–G8` 适用于 grip。坐标均为整体
`1024×1024` 预览的整数坐标。

| Candidate ID | 时间 / 工具 | 类型 / 方向 / phase / grip / role | 输入顺序 | source path / SHA | preview path / SHA | cleaned path / SHA | source anchor → target anchor | QA1–QA10 | G1–G8 | decision / reason | 下一轮仅可改项 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `xiaodong_c0_walk_body_n_contact_l_001` | `2026-07-31T11:58:14+0800` / built-in `image_gen` | body / `n` / `contact_l` / — / arm-less | master 002；R2 reference | `assets/source/generated/c0/xiaodong/direction_grip/walk_body/n/xiaodong_c0_walk_body_n_contact_l_001_source.png` / `e1fed83ce8b59f9ddbbf43dce5da13938cb5408a322451081c31e0c395df26f2` | — | — | — | 未完成 | — | `checkpoint_only` / 方案被用户终止；后视与后脑方向可作新方案参考 | 不继续此分层候选 |
| `xiaodong_c0_walk_body_ne_contact_l_001` | `2026-07-31T11:59:41+0800` / built-in `image_gen` | body / `ne` / `contact_l` / — / 实际含双臂 | master 002；R2 reference | `assets/source/generated/c0/xiaodong/direction_grip/walk_body/ne/xiaodong_c0_walk_body_ne_contact_l_001_source.png` / `5bd04018bf654b960235647f7f89cca67d752591f35ecaed4bc0262ef73ad462` | — | — | — | 未完成；不符合旧方案无臂要求 | — | `checkpoint_only` / 实际完整人物轮廓可作简化方案方向参考 | 不继续此分层候选 |
| `xiaodong_c0_walk_body_s_contact_l_001` | `2026-07-31T11:57:43+0800` / built-in `image_gen` | body / `s` / `contact_l` / — / arm-less | master 002；R2 reference | `assets/source/generated/c0/xiaodong/direction_grip/walk_body/s/xiaodong_c0_walk_body_s_contact_l_001_source.png` / `1e87c30d5dfa5b3eea3110714318f7187392ebba641975595d614248f62a63be` | — | — | — | 方向通过；解剖左脚未前置 | — | `revise` / 实际是相反接触相位 | 只换步态左右 |
| `xiaodong_c0_walk_body_s_contact_l_002` | `2026-07-31T11:59:11+0800` / built-in `image_gen` | body / `s` / `contact_l` / — / arm-less | `s_001` edit target；master 002；R2 reference | `assets/source/generated/c0/xiaodong/direction_grip/walk_body/s/xiaodong_c0_walk_body_s_contact_l_002_source.png` / `689cf5e8c923db5d09095d28522b2f0044b322ac083fdca7146fb90296f71af4` | — | — | — | 方向与 `contact_l` 通过；未做清理 QA | — | `checkpoint_only` / 方案被用户终止 | 不继续此分层候选 |

## 8. Gate 产出

- 独特合成：`0 / 10`
- gate cells：`0 / 11`（`rifle_se` 与 `se_rifle` 复用同一合成）
- gate sheet：
  `assets/source/qa/c0/xiaodong/direction_grip/gate/xiaodong_c0_eight_direction_three_grip_gate.png`
- gate sheet SHA-256：待生成
- 用户视觉批准：待定
