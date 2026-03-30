---
name: decision-levels
command: null
keywords: [决策分级, 人类干预]
execution_level: SHOULD
type: framework
domain: deliberation
summary: "🟢1角色(AI独立)/🟡2-3角色(盲审+辩论)/🔴3-4角色+外部专家，人类干预规则"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **🟢 轻量**：1角色(AI独立)，快速输出，无需盲审
- **🟡 标准**：2-3角色，盲审→辩论→收敛，人审核结果
- **🔴 重大**：3-4角色+外部专家，完整审议协议，人参与裁决

# 决策分级标准

---

## 三级定义

```yaml
levels:
  small:
    description: "日常运营决策"
    convergence: "自动收敛——审议合成报告生成后直接标记 adopted"
    human_required: false
    examples:
      - 日常排期调整
      - 小功能优先级
      - 非关键供应商选择

  medium:
    description: "部门级决策"
    convergence: "系统建议 + 人类确认——合成报告需至少 1 位人类确认"
    human_required: true
    min_human_confirmations: 1
    examples:
      - 新功能方向选择
      - 技术栈切换
      - 中等预算审批

  major:
    description: "战略级决策"
    convergence: "所有人类参与者投票同意——合成报告需全体人类确认"
    human_required: true
    min_human_confirmations: "all"
    examples:
      - 产品线方向
      - 重大投资
      - 组织架构调整
      - 核心合作伙伴选择
```

## 等级调整（Override）

```yaml
override:
  direction: "双向——人类可升级或降级决策等级"
  rules:
    - 调整必须记录原因
    - 降级需声明"已知风险已评估"
    - 升级立即生效，当前收敛进度保留
  audit_format: "[OVERRIDE] {原等级}→{新等级} 原因: {reason}"
```

## 收敛超时

```yaml
timeout:
  small: "无超时，自动收敛"
  medium: "72h 未确认 → 提醒人类"
  major: "7d 未全票 → 升级通知 + 列出未投票人"
```

## 与审议协议的关系

```yaml
integration:
  timing: "审议启动时由发起人指定等级，默认 medium"
  protocol_impact:
    small: "可跳过交叉辩论，直接盲审→合成"
    medium: "完整流程"
    major: "完整流程 + 强制多轮辩论（≥2 轮）"
```
