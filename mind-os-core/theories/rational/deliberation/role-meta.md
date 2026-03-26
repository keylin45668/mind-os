# 角色元模型

> 来源：组织行为学 + 利益相关方分析 + Mind OS 正交架构
> 定义审议角色的完整结构，供工程层实例化具体角色

---

## 元模型结构

```yaml
role_meta:
  identity:
    name: string                    # 角色名称（如"产品经理""架构师"）
    code: string                    # 角色编码（如 PM、ARCH），用于编号制
    perspective: string             # 一句话：该角色看问题的视角
    stance_tendency: string         # 立场倾向：偏保守 | 偏进取 | 中立 | 批判

  evaluation_framework:
    focus_metrics: string[]         # 核心关注指标（如 ROI、系统复杂度）
    evaluation_dimensions: string[] # 评价维度（如 可行性、成本、用户体验）
    typical_objections: string[]    # 典型反对理由模式
    blind_spots: string[]           # 已知信息盲区（自我声明）

  behavior:
    communication_style: string     # 沟通风格：数据驱动 | 直觉优先 | 风险警示 | 用户共情
    decision_weight_factors: string[] # 影响决策权重的因素
    interaction_rules: string[]     # 与其他角色互动时的规则
```

## 约束

```yaml
constraints:
  code_uniqueness: 同一审议中角色编码不可重复
  blind_spots_mandatory: 每个角色必须声明至少 1 个盲区
  perspective_independence: 不同角色的 perspective 不得语义重复
```

## 编号制

```yaml
numbering:
  format: "[{RoleCode}-r{round}-{seq}]"
  examples:
    - "[PM-r1-01]"    # 产品经理，第1轮，第1条
    - "[ARCH-r1-01]"  # 架构师，第1轮，第1条
    - "[FIN-r2-03]"   # 财务，第2轮，第3条
  rules:
    - RoleCode 取自 identity.code
    - round 从 1 开始递增
    - seq 每轮每角色从 01 开始
```

## 内置角色模板（示例，工程层可扩展）

| 编码 | 名称 | 视角 | 立场倾向 |
|------|------|------|---------|
| PM | 产品经理 | 需求价值与用户优先级 | 进取 |
| ARCH | 架构师 | 技术可行性与系统影响 | 保守 |
| FIN | 财务 | 成本结构与现金流 | 保守 |
| UX | 用户代言人 | 体验与痛点 | 中立 |
| RISK | 风控官 | 潜在风险与合规 | 批判 |
