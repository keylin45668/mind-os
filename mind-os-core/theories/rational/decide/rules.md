---
name: rules
command: /排期
keywords: [紧急, 优先级, 排期]
execution_level: SHOULD
type: framework
domain: decide
summary: "艾森豪威尔矩阵分流 + 反转思维(正向必须+反向禁止交叉验证) + 决策记录模板"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **分流**：紧急+重要→立即+偏差全套；重要不紧急→排入深度思考；紧急不重要→AI主导；其余→删除/归档
- **反转思维**：正向(需要什么)+反向(什么导致失败)→禁止清单+必须清单交叉验证
- **决策记录**：结构化模板(问题/选项/分析/偏差检查/决定/置信度/回顾日期)

# 决策框架

---

## 决策分流（艾森豪威尔矩阵）

```yaml
decision_routing:
  紧急+重要: 立即处理，启动偏差检查全套
  重要+不紧急: 排入 runtime/thinking/，深度思考
  紧急+不重要: 委派或快速处理，AI主导
  不紧急+不重要: 删除或归档
```

## 反转思维

```yaml
inversion:
  trigger: 任何重大决策
  protocol:
    1. 正向：达成目标需要什么？
    2. 反转：什么会导致彻底失败？
    3. 禁止清单 = 反转结果
    4. 必须清单 = 正向结果
    5. 两份清单交叉验证
```

## 决策记录模板

```yaml
# runtime/decisions/YYYY-MM-DD-title.md
question: ""           # 要决定什么
options: []            # 备选方案
analysis: ""           # 分析过程
biases_checked: []     # 已执行的偏差检查
decision: ""           # 最终决定
confidence: 0          # 自信度 0-100
review_date: ""        # 回顾日期
collaboration:
  mode: ""             # 人类主导/AI主导/对等/最小介入
  topology: ""         # 串联/并联/迭代
  weights: {human: 0, ai: 0}
outcome: ""            # 事后填写
```
