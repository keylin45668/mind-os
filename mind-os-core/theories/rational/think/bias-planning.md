---
name: bias-planning
command: null
keywords: [项目计划, 时间估算, 排期]
execution_level: SHOULD
type: checklist
domain: think
summary: "规划谬误检测：历史基准预测 + 置信区间 + 时间预算系数"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 规划谬误

```yaml
trigger: 新项目 OR 更新项目时间线
protocol:
  1. 选择最相似的历史项目类别
  2. 基准预测 = 历史中位数，给出80%置信区间
  3. 用户估算 < P10 → 警告"比90%历史情况都乐观"
  4. 时间预算 = 用户估算 × 1.5(首次) 或 ×1.2(有经验)
output: "📅 规划：估算={X}，基准={Y}([{P10}-{P90}])，建议={Z}"
```
