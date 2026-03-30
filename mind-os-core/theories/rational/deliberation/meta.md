---
name: deliberation-meta
command: /审议
keywords: [多角色, 审议, 多视角, 角色讨论, 多方讨论]
execution_level: SHOULD
type: router
domain: deliberation
summary: "多角色审议子路由：角色元模型 + 审议协议 + 评分体系 + 决策分级 + 进化反馈"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **文件索引**：role-meta(角色定义) / protocol(审议流程) / scoring(评分) / decision-levels(决策分级) / digital-avatar(AI代言) / evolution(进化反馈)
- **加载规则**：本文件为入口，按任务需要加载具体文件，max 3个，≤1000 tokens/文件
- **与红蓝辩论互补**：审议处理多角色多方讨论，红蓝辩论处理二元对抗

# 审议模块路由表

---

## 文件索引

| 文件 | 主题 | 何时加载 |
|------|------|---------|
| `role-meta.md` | 角色元模型（identity + evaluation_framework + behavior） | 需要定义或理解审议角色时 |
| `protocol.md` | 审议协议（盲审→辩论→收敛→合成） | 启动多角色审议流程时 |
| `scoring.md` | 评分体系（5 维度 + 理论/实际双阶段） | 需要评估决策质量时 |
| `decision-levels.md` | 决策分级（小/中/重大 + 收敛策略） | 需要判定决策等级时 |
| `digital-avatar.md` | 数字分身协议（画像+代言+回传） | 需要人类 AI 代言机制时 |
| `evolution.md` | 进化反馈协议（差距分析→角色优化） | 实际评分提交后触发优化时 |

## 加载规则

```yaml
loading:
  entry: 本文件（meta.md）
  then: 按任务需要加载上表中的具体文件
  max_concurrent: 3  # 与根路由表一致
  budget: ≤1000 tokens/文件
```

## 与其他模块的关系

| 模块 | 关系 |
|------|------|
| `think/iterative-engine.md` | 互补——审议处理多角色多方讨论，红蓝辩论处理二元对抗 |
| `collaboration/parallel-thinking.md` | 盲审阶段借鉴 Wave 并行模型 |
| `think/certainty-layers.md` | 审议结论使用确定性分层标注置信度 |
| `review/` | 评分闭环与回顾模块共享理论基础 |
