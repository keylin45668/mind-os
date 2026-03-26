# 审议协议

> 来源：德尔菲法 + 结构化辩论 + Mind OS 协作拓扑
> 定义多角色审议的完整流程

---

## 流程总览

```yaml
phases: [blind_review, cross_debate, human_participation, convergence, synthesis]
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

## 交叉辩论阶段

```yaml
cross_debate:
  goal: "角色间基于盲审结果的结构化辩论，暴露分歧与补充"
  trigger: "盲审阶段完成后自动进入"
  rules:
    - 每个角色看到其他角色的盲审结果
    - 回应类型: support（支持）/ oppose（反对）/ supplement（补充）
    - 编号制: "[{RoleCode}-r{round}-{seq}]"
    - 回应必须引用目标: "target_ref: {原编号}"
    - 每轮每角色最多 3 条回应，防止发散

  convergence:
    ref: "decision-levels.md → integration.protocol_impact"
    small: "跳过辩论，直接盲审→合成"
    medium: "至少 1 轮辩论"
    major: "至少 2 轮辩论"
    stop_condition: "连续一轮无新 oppose 类回应，视为收敛"

  output_format:
    response: "[{RoleCode}-r{round}-{seq}] target_ref:{原编号} type:{support|oppose|supplement} {内容}"
```

## 人类参与阶段

```yaml
human_participation:
  goal: "人类以平等参与者身份加入审议"
  timing: "辩论阶段中或辩论后均可介入"

  modes:
    A_bound_role:
      name: "指定角色"
      rule: "人类发言绑定某角色，归类到该角色名下"
      numbering: "[{RoleCode}-r{round}-H{seq}]"

    B_free_agent:
      name: "自由身"
      rule: "人类不绑定角色，可对任意观点评论"
      numbering: "[HUMAN-r{round}-{seq}]"

    C_multi_human:
      name: "多人各带角色"
      rule: "多个人类各绑定不同角色，AI 填补缺失角色"
      numbering: "[{RoleCode}-r{round}-H{humanId}-{seq}]"

  digital_avatar:
    ref: "digital-avatar.md"
    rule: "已授权的数字分身按代言规则参与，发言前缀 [代言]"
    escalation: "触发回传条件时暂停，等待人类确认"
```

## 收敛阶段

```yaml
convergence:
  goal: "基于辩论结果判定是否可进入合成"
  ref: "decision-levels.md"
  process:
    1. 统计各维度的 support/oppose/supplement 比例
    2. 按 decision-levels.md 的等级规则判定收敛
    3. 未收敛 → 进入下一轮辩论
    4. 已收敛 → 进入合成阶段
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
