---
name: bias-loss-aversion
command: null
keywords: [放弃, 终止, 继续, 沉没成本]
execution_level: SHOULD
type: checklist
domain: think
summary: "损失厌恶检测：双框架呈现 + 归零测试 + 沉没成本隔离"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

# 损失厌恶

```yaml
trigger: 资源分配 OR 项目继续/终止 OR 投资决策
protocol:
  1. 双框架呈现（获得框架 + 损失框架）
  2. 归零测试："如果现在没有这个项目，你会重新启动它吗？"
  3. 沉没成本隔离：只展示增量成本与增量收益
output: "📊 损失厌恶：获得框架={gain}，损失框架={loss}，归零={yes/no}"
```
