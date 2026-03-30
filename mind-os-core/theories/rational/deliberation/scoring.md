---
name: deliberation-scoring
command: null
keywords: [审议评分, 决策质量评估]
execution_level: SHOULD
type: metric
domain: deliberation
summary: "5维审议评分(深度/合规/效率/可行动性/自定义) + 理论得分vs实际得分对比"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **5维评分**：深度/合规/效率/可行动性/自定义第5维，每维 1-5 分
- **双阶段**：理论评分(审议完成时预测) + 实际评分(ground truth 提交后)→差距驱动进化
- **客观依据**：每维打分必须从文档中提取依据，不允许拍脑袋

# 评分体系

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
  trigger_chain:
    1. "actual 阶段得分提交"
    2. "系统自动逐维度计算 |theoretical - actual|"
    3. "差距 ≥ 3 分的维度标记为显著偏差"
    4. "生成差距分析报告"
    5. "自动触发 evolution.md 进化反馈流程"

  output:
    - dimension_gaps       # 各维度差距值 + 偏差方向
    - root_cause           # 偏差根因识别
    - improvements         # 改进建议
    - role_feedback        # 反馈到角色模板优化

  evolution_interface:
    ref: "evolution.md"
    handoff: "差距分析报告作为 evolution 的输入"
    feedback_targets:
      - "role_templates → 调整盲区/反对模式"
      - "protocol_parameters → 调整收敛阈值/辩论轮数"
      - "decision_level_calibration → 校准默认等级"
```

## 版本化

```yaml
versioning:
  rule: "评分记录不可变，修改产生新版本"
  format: "v{major}.{minor} — major: 重评, minor: 补充评分"
  recompute: "评分修改后自动重算差距分析"
  history: "保留所有版本，支持趋势追踪"
  audit: "[SCORE-v{version}] {修改原因} by {修改人}"
```

## 评分规则

```yaml
rules:
  minimum_scorers: 2          # 至少 2 个角色参与评分
  outlier_detection: true     # 单角色评分偏离均值 ≥ 3 时标记异常
  human_override: true        # 人类可修正任何评分并记录原因
```
