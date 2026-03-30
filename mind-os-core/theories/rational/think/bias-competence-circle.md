---
name: bias-competence-circle
command: null
keywords: [新领域, 首次, 不熟悉]
execution_level: SHOULD
type: checklist
domain: think
summary: "能力圈检测：历史检索→圈内/圈外判定→圈外触发证否协议"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 能力圈

```yaml
trigger: 不常接触领域 OR 首次在某领域决策
protocol:
  1. 从identity/和archive/检索用户该领域历史
  2. 圈内：≥3次记录 AND 成功率≥60%
     圈外：首次 OR 成功率<40%
  3. 圈外 → 证否协议：AI 生成最强反对论证，用户逐条反驳
  4. 无法反驳≥2条 → 建议引入外部专家
output: "🎯 能力圈：领域={domain}，{n}次决策，成功率{rate}%，判定={圈内/边界/圈外}"
```
