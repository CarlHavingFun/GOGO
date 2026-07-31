# Xiaodong C0 单方向概念批次进度记录

- 结论：APPROVED AS HISTORICAL POSE GUIDE
- 范围：右下方向 master/portrait/idle/walk/hit/death/skill_breakin
- 候选：24
- accepted_for_concept：16
- revise：8
- cleaned：16 张 128×128 RGBA
- A5：当时六项仍为 planned
- Godot 引用：0
- 后续权威：2026-07-31 八方向/三类握持补充规格

现有四张右下 walk 图保留为身份、步态、身体宽度、相位和脚底锚点依据。
因为图中包含完整手臂，它们不能计入新的 32 张 arm-less walk_body，
也不能计入 48 张 arm layer 或 96 个派生 QA。

## Task 1 历史提交

- Task 1 commit：`e347760b846d7fb6ead1e54259b5e973bceb563c` — `art: checkpoint Xiaodong single-direction C0 concepts`
- 该提交是历史 C0 概念与 pose-guide 证据；不构成 A5 或 M0，也不构成八个方向的交付完成。

## Task 1 命令与原始输出

```text
test "$(git branch --show-current)" = "codex_goal"                         -> exit 0
shasum -a 256 project.godot .DS_Store docs/.DS_Store docs/design/.DS_Store ->
e7db663280b5a03f8df3646c8a7cb0470218436efa8d27d580e080baa0863bc3  project.godot
840196eaee5ec2abb7797bc252c91d8b8c4a5f485c173ec27bb1232dfb85153f  .DS_Store
84c98080a6f2add23440330c952d4680563406f0eaadc08ee3656e4d1cce482b  docs/.DS_Store
d0bf3ee859568700e440bf6e777b93872a30c1008ab0a856d53a551903eda85b  docs/design/.DS_Store
image mechanical QA -> SINGLE_DIRECTION_GENERATED=48
                       SINGLE_DIRECTION_CLEANED=16
                       SINGLE_DIRECTION_IMAGE_QA=PASS
ledger positive rg -> matches the real 24 / accepted_for_concept / revise / six-planned / Godot-0 conclusions
ledger negative rg -> exit 0, no `32 张 canonical`, `48 张 canonical`, `96 个.*PASS`, or <code>八方<!-- -->向.*完成</code> match
Godot C0-reference negative rg -> exit 0, no match
staged path count -> 62
staged forbidden-path negative rg -> exit 0, no `project.godot` or `.DS_Store`
git commit -m "art: checkpoint Xiaodong single-direction C0 concepts" -> exit 0
commit path count -> COMMIT_PATHS=62
```

## 审核记录

### 早期视觉审核

Task 1 的独立 per-image 视觉审核已批准身份、解剖、R2 排除及零武器像素；该审核不改变后续模块化计数边界。

### 补充后的独立边界审核

Fresh independent review verdict: PASS. Commit `e347760b846d7fb6ead1e54259b5e973bceb563c` consistently classifies `walk_001–004` as useful historical single-direction `se` full-arm pose evidence only. They count toward none of the later 32 arm-less `walk_body`, 48 arm layers, 24 grip groups, 96 derived/composited QA outputs, or the user visual gate; they do not establish A5, M0, or eight-direction completion. Preserve the minor technical note: Pillow bbox coordinates use the half-open interval `[x0,y0,x1,y1)`.

审核测量备注：Pillow bbox 采用半开区间 `[x0,y0,x1,y1)`。
