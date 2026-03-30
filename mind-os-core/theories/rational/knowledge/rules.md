---
name: knowledge-rules
command: /知识
keywords: [笔记, 知识, 学习]
execution_level: SHOULD
type: framework
domain: knowledge
summary: "Zettelkasten原子笔记 + 跨学科链接(密度≥20%) + 知识价值评估"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **原子笔记**：一条笔记一个想法，用自己的话重述，必须标注学科标签+关联模型+来源
- **强制关联**：每条笔记至少链接1条已有笔记，AI自动发现跨域连接
- **价值评估**：use_value > labor_value×2→保留，< 0.5持续3月→降级归档

# 知识管理理论

---

## 原子笔记规则

```yaml
note_rules:
  1. 一条笔记一个想法（原子性）
  2. 用自己的话重新表述（不是摘抄）
  3. 必须标注：学科标签 + 关联模型 + 来源
  4. 必须至少链接 1 条已有笔记（强制关联）
  5. AI 自动发现跨域连接，生成桥接笔记
```

## 笔记模板

```yaml
# data/knowledge/notes/YYYYMMDD-title.md
id: ""
title: ""
content: ""
tags: []              # 学科标签
models: []            # 关联的决策模型
links: []             # 双向链接
source: ""            # 来源
created: ""
last_referenced: ""
```

## 知识价值评估

```yaml
labor_value: 获取成本（人时×社会平均工资）
use_value: 引用频率 × 效果权重
threshold:
  use_value > labor_value×2 → 保留并维护
  use_value < labor_value×0.5 持续3月 → 降级或归档
cognitive_capital:
  stock: [知识库容量, 技能水平, AI模型版本, 协作默契度]
  health: 认知利润(flow_in - flow_out) 连续3期为负 → 资本收缩流程
```

## 主题地图

```yaml
# data/knowledge/maps/{topic}.md
topic: ""
core_notes: []        # 核心笔记列表
peripheral_notes: []  # 边缘笔记
cross_domain: []      # 跨域桥接笔记
last_updated: ""
```
