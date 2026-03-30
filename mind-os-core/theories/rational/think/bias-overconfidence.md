---
name: bias-overconfidence
command: null
keywords: [大额, 战略, 不可逆]
execution_level: SHOULD
type: checklist
domain: think
summary: "过度自信检测：事前验尸(假设失败) + 失败路径排序 + 历史校准"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 过度自信 + 事前验尸 + 反转

```yaml
trigger: 金额 > 大额阈值 OR 战略级 OR 不可逆承诺
protocol:
  1. "假设一年后彻底失败了"
  2. 用户独立写3-5个失败原因
  3. AI 补充遗漏的失败路径
  4. 按"可能性×影响度"排序
  5. 失败路径 → 禁止清单 + 必须清单
  6. 用户给成功概率 → 对比历史校准
  7. 设置30天复盘提醒
output: "🎯 置信度={X}%，历史校准={Y}%，禁止=[...]，必须=[...]"
```
