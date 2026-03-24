# 决策框架

> 来源：艾森豪威尔矩阵 + 反转思维（《穷查理宝典》）

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
