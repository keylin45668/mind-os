# 全局状态面板

> AI 每日更新。人类每周回顾时查看。

---

## 机器指标快照

```yaml
snapshot_date: 2026-03-23
inbox_clear_rate: null       # 待校准
review_completion: null
knowledge_growth: null
decision_review_rate: null
focus_hit_rate: null
knowledge_activity: null
human_participation: null
baseline_drift: 1.0
complexity_usage: null       # 活跃规则数 / 预算上限
collaboration_gain: null     # 协作增益率
robustness: null             # 鲁棒性
```

## 人类自评（每周填）

```yaml
last_self_review: null
decision_quality: null       # 1-5
energy_allocation: null      # 1-5
role_balance: null           # 1-5
system_experience: null      # 1-5
```

## 活跃进程

```yaml
active_thinking: []          # runtime/thinking/ 中的活跃进程
active_decisions: []         # runtime/decisions/ 中的活跃决策
pending_reviews: []          # 到期待回顾的决策
```

## 系统健康

```yaml
theory_modules: 16           # 活跃模块数（无预存上限，运行时≤3同时加载）
schema_rules: null/30        # 活跃规则数/上限（待统计）
last_quarterly_audit: null
chaos_edge: "healthy"        # healthy / too_ordered / too_chaotic
```
