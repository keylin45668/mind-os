---
name: principles
command: /原则
keywords: [原则, 评估, 增益]
execution_level: MAY
type: framework
domain: collaboration
summary: "痛苦+反思=进步 + BWDM可信度加权 + 协作质量五维评估 + 鲁棒性测试"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **痛苦→进步**：事件记录→根因分析→提炼if-then规则→写入theory→设复盘提醒
- **可信度加权**：w = accuracy×0.4 + evidence×0.3 + experience×0.3
- **协作五维**：accuracy(0.3)/efficiency(0.2)/robustness(0.2)/satisfaction(0.2)/ethics(0.1)
- **鲁棒性测试**：异常输入+压力+对抗+反转，通过率≥70%

# 原则化管理 + 协作评估

---

## 痛苦+反思=进步

```yaml
pain_protocol:
  trigger: 决策结果未达标 OR 用户标记"搞砸了"
  1. 记录痛苦事件（结构化失败记录，参见 schema/protocols.md）
  2. 根本原因分析
  3. 提炼 if-then 规则
  4. 写入 theory/ 对应模块
  5. 设置复盘提醒
```

## BWDM 可信度加权

```yaml
w_i = (accuracy_history × 0.4) + (evidence_quality × 0.3) + (domain_experience × 0.3)
ai_weight:
  数据密集型决策: 初始权重较高
  价值判断型决策: 权重 = 0
  动态衰减: 近5次预测偏差>阈值 → 降权20%
```

## 协作质量五维评估

```yaml
evaluation_framework:
  accuracy:      # 结论与事实的吻合度
    weight: 0.30
  efficiency:    # 决策耗时与资源消耗
    weight: 0.20
  robustness:    # 边界和异常情况下的稳定性
    weight: 0.20
    note: "AI在异常数据下易幻觉，人在压力下易情绪化"
  satisfaction:  # 利益相关方主观认可
    weight: 0.20
  ethics:        # 价值观对齐、有无偏见
    weight: 0.10
    note: "高风险场景中需提升至≥0.30"
  composite: accuracy×0.3 + efficiency×0.2 + robustness×0.2 + satisfaction×0.2 + ethics×0.1
```

## 协作增益判定

```yaml
synergy_assessment:
  trigger: 每月回顾
  判定:
    - 协作结果系统性优于单独任何一方 → ✅
    - 叠加后与单方持平或更差 → ⚠️ 协作结构有问题
    - 叠加后放大了错误 → 🚨 必须重新设计分工
  action_on_failure:
    - 检查模式×拓扑组合
    - 检查权重分配
    - 检查鲁棒性
    - 调整后重新试运行一个周期
```

## 鲁棒性测试

```yaml
robustness_test:
  trigger: 新协作模式上线 OR 季度审计
  protocol:
    1. 异常输入测试
    2. 压力测试：时间压缩50%、信息量翻倍
    3. 对抗测试：AI故意给错误建议，检验人类识别能力
    4. 反转测试：人类故意情绪化，检验AI纠偏能力
  pass_criteria: 通过率 ≥ 70%
```
