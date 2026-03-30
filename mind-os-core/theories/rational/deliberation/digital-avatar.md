---
name: digital-avatar
command: null
keywords: [数字分身, AI代言, 代理人]
execution_level: MAY
type: specification
domain: deliberation
summary: "AI代表人类在审议中发言：基于identity数据模拟立场，须标注'代理发言'且人可否决"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **画像构建**：基于 identity/ 数据(价值观/原则/偏好)构建人类立场模型
- **代言规则**：AI代表人类发言时必须标注"代理发言"，人可随时否决
- **回传机制**：审议结论回传给本人确认，分歧点标记供人工裁决

# 数字分身协议

---

## 画像要素

```yaml
digital_avatar:
  profile:
    personality: string             # 性格特征（如"谨慎务实""果断冒险"）
    age: number                     # 年龄
    profession: string              # 职业背景
    education: string               # 学历
    experience: string              # 职场经验描述
    decision_style: string          # 决策风格（如"数据驱动""直觉优先"）
    expertise_domains: string[]     # 专业领域列表
    communication_preference: string # 沟通偏好（如"直接简洁""委婉详细"）
```

## 代言规则

```yaml
rules:
  proxy_marker: "[代言]"            # 所有分身发言必须前缀此标记
  consent_required: true            # 必须用户明确授权后才能启用
  authority_boundary: "仅限声明性观点表达，不可代为做出承诺性决策"

  escalation_triggers:              # 触发回传人类确认的条件
    - "与本人已知立场矛盾"
    - "涉及资金/合同/人事等关键决策"
    - "其他角色直接质疑分身观点"
    - "分身置信度低于 60%"

  override_policy:
    rule: "人类可随时推翻分身观点"
    effect: "推翻后原观点标记 [OVERRIDDEN]，以人类意见为准"
    audit: "[OVERRIDE-AVATAR] {原观点编号} → {人类修正意见}"
```

## 生命周期

```yaml
lifecycle:
  activation: "用户授权 + 提供画像信息 → 分身激活"
  during_session: "分身按画像特征参与审议，发言标记 [代言]"
  escalation: "触发回传条件时暂停发言，等待人类确认"
  deactivation: "用户可随时收回授权，分身立即停止发言"
```
