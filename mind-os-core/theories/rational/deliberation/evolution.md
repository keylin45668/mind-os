# 进化反馈协议

> 来源：PDCA 循环 + 闭环控制理论
> 定义理论得分 vs 实际得分的差距如何驱动系统优化

---

## 触发条件

```yaml
evolution:
  trigger: "actual 阶段评分提交后自动触发"
  prerequisite: "scoring.md → gap_analysis 已完成"
```

## 差距分析

```yaml
gap_analysis:
  process:
    1_dimension_comparison:
      method: "逐维度对比理论得分与实际得分"
      significant_threshold: 3    # 差距 ≥ 3 分为显著偏差
      output: "各维度差距值 + 偏差方向（高估/低估）"

    2_root_cause_identification:
      method: "定位失准环节"
      targets:
        - "哪个角色的评估偏差最大"
        - "哪个阶段（盲审/辩论/合成）产生了误判"
        - "是信息不足还是框架偏差"
      output: "根因列表 + 置信度标注"

    3_improvement_suggestions:
      method: "基于根因生成优化建议"
      output: "可执行的改进项列表"
```

## 反馈目标

```yaml
feedback_targets:
  role_templates:
    action: "调整角色的盲区声明、反对模式、评价维度权重"
    example: "PM 角色连续低估技术风险 → 增加 blind_spots: '技术复杂度'"

  protocol_parameters:
    action: "优化协议参数"
    targets:
      - "辩论轮数上限"
      - "收敛阈值"
      - "共识判定的评分差阈值"

  decision_level_calibration:
    action: "校准决策分级"
    example: "某类决策频繁被 override 升级 → 调整默认等级"
```

## 进化循环

```yaml
cycle:
  steps:
    1. "actual 评分提交 → 自动触发差距分析"
    2. "差距分析 → 生成优化建议"
    3. "优化建议 → 人工确认（不自动应用）"
    4. "人工确认 → 更新角色模板/协议参数/分级标准"
  human_gate: "第 3 步必须人工确认，防止自动漂移"
  audit: "[EVOLVE-{date}] {优化项} 来源: {差距分析编号}"
```
