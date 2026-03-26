# 审议协议

> 来源：德尔菲法 + 结构化辩论 + Mind OS 协作拓扑
> 定义多角色审议的完整流程（Phase 1：盲审 + 合成）

---

## 流程总览

```yaml
phases: [blind_review, synthesis]
# Phase 2 将增加: cross_debate, human_participation, convergence
```

---

## 盲审阶段

```yaml
blind_review:
  goal: "各角色独立分析，确保视角独立性"
  rules:
    - 各角色在独立上下文中分析，互不可见
    - 每个角色输出结构化观点，使用编号制标记
    - 输出必须包含：立场声明、论据、评分、盲区自检

  output_format:
    header: "[{RoleCode}-r1-00] 立场声明: {一句话立场}"
    arguments: "[{RoleCode}-r1-{seq}] {论据}"
    score: "按 scoring.md 维度自评"
    blind_spot_check: "声明本角色可能遗漏的视角"

  completion: "所有角色提交盲审报告后进入下一阶段"
```

## 合成阶段

```yaml
synthesis:
  goal: "识别共识与分歧，生成结构化合成报告"
  process:
    1_consensus_detection:
      method: "逐维度对比各角色评分和论据"
      consensus_threshold: "所有角色评分差 ≤ 2 分"
      output: "共识清单——各方一致认同的结论"

    2_divergence_marking:
      method: "评分差 > 2 分的维度标记为分歧点"
      output: "分歧清单——含各方论据对比"
      format: "[DIVERGE-{seq}] 维度: {dim}, 分歧: {角色A} vs {角色B}"

    3_blind_spot_discovery:
      method: "汇总各角色的盲区自检，识别无人覆盖的维度"
      output: "盲区清单——审议中未被任何角色覆盖的视角"
      format: "[BLIND-{seq}] {未覆盖的维度或视角}"

  report:
    sections:
      - 共识结论（高置信度）
      - 分歧点（需人类裁决）
      - 盲区发现（需补充分析）
      - 各维度综合评分
    status: "pending_decision"
```

## 决策标记

```yaml
decision:
  after_synthesis: "按 decision-levels.md 的等级规则收敛"
  markers:
    - "[ADOPTED] {结论编号} — 被采纳"
    - "[REJECTED] {结论编号} — 被否决，原因: {reason}"
    - "[DEFERRED] {结论编号} — 延后决策，条件: {condition}"
```

## 编号制（引用 role-meta.md）

```yaml
numbering:
  ref: "role-meta.md → numbering"
  cross_reference:
    response: "[RESP:{原编号}] {回应内容}"
    support: "[SUPPORT:{原编号}] {支持理由}"
    challenge: "[CHALLENGE:{原编号}] {质疑理由}"
```
