# 自迭代协议

---

## 1. 三个原语

```
审计（Audit）→ 迭代（Iterate）→ 验证（Verify）→ 审计 → …
```

| 原语 | 做什么 | 谁主导 |
|------|--------|--------|
| 审计 | 收集指标，对照冻结标准评估 | AI 主导，人审核 |
| 迭代 | 提出改进假设，修改 theory 或 schema | 对等协作 |
| 验证 | 跑一个周期，看效果 | AI 主导 |

---

## 2. 迭代节奏

| 周期 | 审计什么 | 可能的迭代动作 |
|------|---------|-------------|
| 每日 | 机器指标快照 | 调整 runtime/focus.md |
| 每周 | 机器指标趋势 + 人类自评 | 微调 {theory}/ 规则 |
| 每月 | 全指标综合 | 决定是否替换 theory pack |
| 每季 | 系统级审计 | 决定是否修改 schema/ |

---

## 3. AI 迭代权限

| AI 能做的 | AI 不能做的 |
|----------|-----------|
| 建议修改 {theory}/ | 修改 {schema}/metrics.md |
| 自动调整 runtime/ | 修改 schema/constitution.md |
| 生成审计报告 | 修改 {data}/identity/ |
| 提出替换 theory 的建议 | 自行替换 theory 不经人确认 |

---

## 4. 结构化失败记录

```yaml
trigger: 决策结果未达冻结指标 OR 用户标记"搞砸了"
template:
  event: "发生了什么？"
  cause: "根本原因是什么？"
  outcome: "偏差值多少？"
  principle: "提炼出什么 if-then 规则？"
review: 每周回顾时 AI 汇总，重复模式 ≥ 2次 → 触发系统级修复
```

---

## 5. 经验→规则编译管道

```
1_draft: 自然语言写下原则
2_formalize: AI 辅助转化为 if-then 规则
3_backtest: 用 archive/ 历史数据检验
4_deploy: 写入 {theory}/ 对应模块
5_monitor: 后续决策中持续校准
```
