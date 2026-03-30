---
name: bias-anchor
command: null
keywords: [数值估计, 方案排序, 定价]
execution_level: SHOULD
type: checklist
domain: think
summary: "锚定效应检测：生成反向锚 + 多锚呈现 + 调整幅度警告"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 锚定效应

```yaml
trigger: 决策涉及数值估计 OR 方案排序
protocol:
  1. 生成反向锚（合理但相反的极端值）
  2. 多锚呈现（3个不同来源）
  3. 调整幅度 < 20% → 警告
  4. 方案排列顺序随机化
output: "⚓ 锚定检查：初始锚={X}，反向锚={Y}，调整幅度={Z}%"
```
