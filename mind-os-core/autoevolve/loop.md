# AutoEvolve — 迭代循环协议

> 设计文档。基础概念见 ENTRY.md，三文件契约和同构映射见 README.md。

---

## 可变资产范围

| 文件 | 可改什么 | 不可改什么 |
|------|---------|----------|
| BOOT.md | 启动步骤措辞、门控逻辑 | 不可删除任何 Phase |
| protocols.md | 门控规则、免疫措施 | 不可违反宪法 |
| meta.md | 关键词、执行级别 | 不可超 2000 tokens |
| domains/_router.md | 路由规则 | 不可超预算 |

**不可变**：constitution.md、evaluator.md、program.md、scenarios/*.md、data/identity/*

---

## 主循环

```
SELECT(场景) → EXECUTE(模拟) → EVALUATE(评分)
  ↓                                    ↓
score ≥ 999? ──YES──→ REGRESS(回归) → 全通过? ──YES──→ DONE
  ↓ NO                                  ↓ NO
ANALYZE(根因) → MUTATE(修改) → COMMIT(版本化) → RE-TEST(验证)
  ↑                                                    ↓
  └─── improved? NO → RESET + 尝试不同 mutation ────────┘
                 YES → KEEP → 下一场景
```

---

## 步骤要点

| 步骤 | 要点 |
|------|------|
| SELECT | round-robin + 失败频率加权；新场景先全跑 baseline |
| EXECUTE | dual-LLM 模拟：executor(按规则运行) + evaluator(审计)，单次 ≤ 5 min，零状态泄漏 |
| EVALUATE | 按 evaluator.md 40 项清单逐条检查，输出 passed/failed/score/analysis |
| REGRESS | 当前场景 ≥ 999 后重跑所有已通过场景，任何退化→回到 ANALYZE |
| DONE | 所有场景连续 N 轮 ≥ 999，生成报告，等人类确认 |
| ANALYZE | 从 failure history + 源文件定位 root cause + affected file/section |
| MUTATE | 最小修改优先：①强化措辞 ②增加冗余 ③增加检查点 ④修路由 ⑤加正反例 ⑥结构变更 |
| COMMIT | git commit + 记录 hash 到 results.tsv |
| RE-TEST | 重跑失败场景 + 3 个随机已通过场景；improved→KEEP，not→RESET |

---

## 收敛策略

| 阶段 | 聚焦 | 策略 |
|------|------|------|
| phase_1 baseline | 全场景 | 建立初始 score |
| phase_2 fix_critical | 致命项（单项失败 = <999） | 逐个修复 + 回归 |
| phase_3 fix_weighted | 权重 ≥ 2 | 按影响面从大到小 |
| phase_4 polish | 权重 = 1 | 批量小修 |
| phase_5 stress_test | 全场景 | 连续 50 轮 ≥ 999 → DONE |

---

## 防退化机制

- **每次 KEEP 后**：重跑全部场景，退化→立即回滚
- **连续 10 轮无改善**：暂停，请求人类调整 program.md
- **单场景反复失败 ≥ 5 次**：标记"需人类介入"
- **复杂度守卫**：每次修改后检查 schema ≤ 30 规则、文件 ≤ 1000 tokens，超限→自动回滚

---

## 执行方式

| 方式 | 说明 |
|------|------|
| A 全自动 | `claude "执行 autoevolve/loop.md 完整循环"` — Agent 自动派生 executor+evaluator |
| B 人工逐轮 | 人类说"跑一轮"→ AI 执行→人类说"分析"→ AI 修复 |
| C 批量+审批 | AI 自动跑 baseline→人类审批→AI 跑 fix→每个 KEEP 暂停等确认 |
