# 芒格25条补充

> 来源：《穷查理宝典》

芒格25条与卡尼曼偏差检查互补，特定场景触发：

```yaml
social_influence:
  trigger: 团队决策
  checks: [社会认同偏差, 权威服从偏差]
  protocol: 匿名独立判断 → 再公开讨论

incentive_bias:
  trigger: 设计薪酬/绩效/激励
  checks: [激励机制偏差, 自利偏差]
  protocol: 检查激励是否与期望行为对齐

consistency_bias:
  trigger: 评估"是否坚持原路线"
  checks: [一致性偏差, 承诺升级]
  protocol: 归零测试 + 反转思维

output: "🧲 芒格检查：场景={scenario}，命中偏差={biases}，对策={actions}"
```
