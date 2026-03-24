# 输出文档模板（MUST_RUN）

> 迭代引擎最终输出遵循本模板。**总纲言简意赅，详情分章节，单文件 ≤ 1500 tokens。**
> 对话模式下不创建文件，但输出按同样结构组织。

---

## 文件结构

```
runtime/thinking/{task}/output/
  ├── summary.md           ← 总纲（≤ 800 tokens）
  ├── direction-d{N}.md    ← 方向详情
  ├── adversarial-d{N}.md  ← 红蓝对抗记录
  ├── comparison.md        ← 五维对比
  └── appendix.md          ← 附录（可选）
```

---

## 总纲（summary.md ≤ 800 tokens）

```markdown
# {任务名} — 分析总纲

> 日期: {date} | 方向: {N}个 | 轮次: {M}轮 | 信心度: {X}%
> 收敛原因: {red_exhausted / all_resolved / ...}

## 一句话结论
{≤ 50 字回答核心问题}

## 推荐方案
{方向} — {理由}
- 存活率: {X}% | 信心度: {Y}/5
- 优势: {1-2 点} | 风险: {1-2 点}

## 各方向速览
| 方向 | 结论 | 存活率 | 状态 |
|------|------|--------|------|

## 下一步行动
1. {行动项 + 截止时间}

## 详细章节
- [方向详情](direction-d1.md) | [对比表](comparison.md) | [对抗记录](adversarial-d1.md)
```

---

## 方向详情（direction-d{N}.md ≤ 1500 tokens）

```markdown
# 方向 {id}: {名称}

> 状态: {converged/excluded} | 轮次: {N} | 信心度: {X}%

## 本源
{事物本质}

## 最终论点（经红方验证）
- [SURVIVED:B-xxx] {论点} ✅
- [MODIFIED:B-xxx] {论点}（修正: {原因}）⚠️

## 被否决论点
- [FALLEN:B-xxx] {论点}（原因: {红方攻破理由}）❌

## 关键风险
1. {风险} — 来源: [R-xxx]

## 成功条件
1. {条件}
```

---

## 红蓝对抗记录（adversarial-d{N}.md）

```markdown
# 方向 {id} — 红蓝对抗

| 轮次 | 蓝方论点 | 红方质疑 | 存活/倒下/修正 | 信心度 |
|------|---------|---------|--------------|--------|

## 关键转折点
- R{X}→R{Y}: {关键变化} → 收敛

## 编号索引
[B-d1r1-01] {摘要}
[R-d1r1-01] [NEW] [严重] {摘要}
```

---

## 五维对比（comparison.md）

```markdown
# 五维对比

| 维度 | d1 | d2 | d3 | 依据 |
|------|----|----|----|----|
| 可行性 | {1-5} | | | |
| 风险 | {1-5} | | | |
| 成本 | {1-5} | | | |
| 时间 | {1-5} | | | |
| 价值契合 | {1-5} | | | |
| **总分** | | | | |

## 排序
★★★ {方向} > ★★ {方向} > ★ {方向} — {理由}
```

---

## 强制规则

```yaml
validation:
  summary: 存在 + ≤ 800 tokens + 含 5 个必选章节
  direction: 每个 active 方向有对应文件 + 含 [SURVIVED:] 引用
  comparison: 有五维评分表
  all_chapters: ≤ 1500 tokens
  conversation_mode: 先总纲 → 再各方向详情 → 用 --- 分隔
```
