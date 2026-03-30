---
name: _index
command: /偏差
keywords: [决策, 判断, 选择, 要不要, 该不该, 值不值]
execution_level: MUST_RUN
type: router
domain: think
summary: "偏差检查子路由：按关键词匹配加载具体偏差模块 + 多偏差叠加告警"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: "偏差须关联用户具体情境"
---

## 摘要

- **二级路由**：按关键词匹配具体偏差模块(锚定/WYSIATI/损失厌恶/规划谬误/峰终/过度自信/推论阶梯/能力圈/芒格25条)
- **叠加告警**：2个同向→常规告警，3个同向→强制冷静期，4+个→暂停决策引入外部视角
- **审计入口**：审计/迭代/系统检查 → system-audit-method.md

# 思考模块 — 按需加载路由

> AI 不要加载本目录下所有文件。根据任务关键词匹配，只加载命中的文件。

| 关键词 | 加载文件 | 说明 |
|--------|---------|------|
| 数值估计/方案排序/定价 | bias-anchor.md | 锚定效应 |
| 信息不足/信息源少/片面 | bias-wysiati.md | WYSIATI |
| 放弃/终止/继续/沉没成本 | bias-loss-aversion.md | 损失厌恶 |
| 项目计划/时间估算/排期 | bias-planning.md | 规划谬误 |
| 回顾/复盘/总结 | bias-peak-end.md | 峰终定律 |
| 大额/战略/不可逆 | bias-overconfidence.md | 过度自信+事前验尸 |
| 我觉得/我认为/人际冲突 | bias-inference-ladder.md | 推论阶梯 |
| 新领域/首次/不熟悉 | bias-competence-circle.md | 能力圈 |
| 团队决策/薪酬/绩效 | bias-munger25.md | 芒格25条补充 |
| 审计/迭代/系统检查 | system-audit-method.md | 方法A/B/C/D |
| 深度思考/多方向/发散/对比分析 | iterative-engine.md | 迭代思考引擎（输出模板见 schemas/default/output-template.md） |

**多偏差叠加规则**：匹配到 ≥ 2 个偏差时全部加载 + 叠加告警：
- 2 个同向 → 常规告警
- 3 个同向 → 强制冷静期
- 4+ 个同向 → 暂停决策，引入外部视角
