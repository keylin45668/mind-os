---
name: bias-peak-end
command: null
keywords: [回顾, 复盘, 总结]
execution_level: SHOULD
type: checklist
domain: think
summary: "峰终定律检测：识别峰值+终点事件 → 对比过程均分 → 偏差提示"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 峰终定律

```yaml
trigger: 日/周/月回顾
protocol:
  1. 识别峰值(最好+最差)和末尾事件
  2. peak_end_score vs process_score，偏差 > 1.5 → 提示
  3. 强制展示每日客观数据流水后再评分
output: "🔄 峰终：峰值={peak}，终点={end}，过程均分={Y}，偏差={Z}"
```
