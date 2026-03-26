# 评分体系

> 来源：多准则决策分析（MCDA）+ 闭环反馈理论
> 定义决策质量的量化评估机制

---

## 评分维度（声明式列表）

```yaml
dimensions:
  - name: feasibility
    description: "技术和资源上能否实现"
    scale: 1-10

  - name: benefit
    description: "实施后的价值大小"
    scale: 1-10

  - name: risk_control
    description: "潜在风险是否被充分识别和缓解"
    scale: 1-10

  - name: completeness
    description: "是否考虑了足够多的维度"
    scale: 1-10

  - name: consensus
    description: "各角色对结论的认同程度"
    scale: 1-10
```

> 维度列表为声明式 YAML 数组，工程层用 JSONB 存储，天然支持扩展。

## 双阶段评分

```yaml
phases:
  theoretical:
    timing: "审议共识形成后"
    self_score: true    # 各角色对结论自评
    peer_score: true    # 角色间互评
    output: "各维度的理论得分 + 置信度标注"

  actual:
    timing: "决策实施完成后"
    self_score: true    # 参与者对实施效果评分
    peer_score: false
    output: "各维度的实际得分"
```

## 差距分析

```yaml
gap_analysis:
  trigger: "actual 阶段得分提交后自动触发"
  process:
    1. 逐维度计算 |theoretical - actual| 差距
    2. 差距 ≥ 3 分的维度标记为"显著偏差"
    3. 识别偏差根因：哪一步判断失准
    4. 生成改进建议
  output:
    - dimension_gaps       # 各维度差距值
    - root_cause           # 偏差根因识别
    - improvements         # 改进建议
    - role_feedback        # 反馈到角色模板优化
```

## 评分规则

```yaml
rules:
  minimum_scorers: 2          # 至少 2 个角色参与评分
  outlier_detection: true     # 单角色评分偏离均值 ≥ 3 时标记异常
  human_override: true        # 人类可修正任何评分并记录原因
```
