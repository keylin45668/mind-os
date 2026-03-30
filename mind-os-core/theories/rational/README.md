# Theory Pack: rational

> 基于西方理性主义传统的思维方法论集合

---

## 设计哲学

这套 theory pack 的核心假设是：**人类决策质量可以通过系统性的偏差检查和多模型交叉验证来提升。**

它适合你，如果你：
- 偏好数据驱动、逻辑分析
- 愿意用结构化流程来辅助决策
- 认同"错误可以被系统性地预防"

它可能不适合你，如果你：
- 更信赖直觉和经验
- 偏好东方哲学的整体观
- 觉得过多检查流程会阻碍行动力

---

## 模块格式（v5.3 Frontmatter 规范）

每个模块文件遵循统一格式：

```yaml
---
name: module-name          # 与文件名一致
command: /命令              # 斜杠命令（无则 null）
keywords: [关键词1, 关键词2] # 自动匹配关键词
execution_level: MUST_RUN   # MUST_RUN | SHOULD | MAY
type: framework            # specification | framework | checklist | router | metric
domain: think              # 所属领域
summary: "一句话摘要"       # 模块核心概念概述
context: default           # default | isolated（重量级模块隔离执行）
hooks:                     # 模块级质量门控
  pre_check: null
  post_check: null
  depth_check: "质量检查条件"
---

## 摘要                    ← 大模块（≥800 bytes）必须有此节

- **要点一**：...
- **要点二**：...

# 模块标题               ← 正文从此开始

（完整方法论内容）
```

**三级渐进加载**（与任务分级联动）：
- **Level 1**：frontmatter summary（~50 tokens）— 路由表展示、模块列表
- **Level 2**：frontmatter + `## 摘要`（~200 tokens）— 🟢 轻量任务
- **Level 3**：完整文件 — 🟡🔴 标准/深度任务

详见 `schemas/default/module-frontmatter-spec.md`。

---

## 理论来源（11本书 + 6个理论）

| 来源 | 贡献 |
|------|------|
| 《思考，快与慢》(Kahneman) | 双系统思考、6大认知偏差检查 |
| 《穷查理宝典》(Munger) | 多模型格栅、25条误判心理、反转思维、能力圈 |
| 《反脆弱》(Taleb) | 三元分类、杠铃策略、否定法、小压力源 |
| 《黑天鹅》(Taleb) | 极端事件意识、选择权检查 |
| 《孙子兵法》 | 五事七计、不战而胜、虚实分析 |
| 《道德经》 | 否定法、无为（自组织条件） |
| 《系统之美》(Meadows) | 存量-流量、杠杆点、系统陷阱 |
| 《第五项修炼》(Senge) | 创造性张力、推论阶梯、深度汇谈、双环学习 |
| 《原则》(Dalio) | 痛苦+反思=进步、可信度加权、经验编译管道 |
| 《复杂》(Waldrop) | 混沌边缘、自组织、涌现 |
| 《国富论》(Smith) | 比较优势、分工、认知资本 |
| **《物种起源》**(Darwin) | 模块适应度、淘汰归档、生态位分化 |
| GTD (Allen) | 收集、分流、回顾节奏 |
| PARA (Forte) | 项目/领域/资源/归档四分法 |
| Zettelkasten | 原子笔记、双向链接、跨域桥接 |
| 延展心智论 + Licklider人机共生 | 人机协作理论基础 |
| 博弈论 | 囚徒困境、重复博弈、纳什均衡 |
| 比较优势(Ricardo) | 人机分工原则 |

---

## 模块结构

详见 [meta.md](meta.md) 路由表。

当前共 **44 个模块**，分布在 8 个领域：

| 领域 | 模块数 | 说明 |
|------|--------|------|
| think/ | 17 | 偏差检查、迭代引擎、创造力、确定性分层等 |
| decide/ | 4 | 反脆弱、竞争策略、决策框架、多模型格栅 |
| review/ | 5 | 回顾、结晶、会话审查、评分、跨会话审计 |
| collaboration/ | 8 | 协作路由、动力学、沟通、并行思考、进化等 |
| knowledge/ | 2 | Zettelkasten 知识管理、结构化学习 |
| organize/ | 2 | PARA 分流、执行落地 |
| capture/ | 1 | GTD 收集 |
| deliberation/ | 7 | 多角色审议（角色元模型、协议、评分、分级等） |

---

## 想创建替代 pack？

1. 复制本目录为模板
2. 替换你想用的方法论
3. 为每个模块添加 frontmatter（参照 `module-frontmatter-spec.md`）
4. 更新 meta.md 路由表
5. 改 config.md 指向新 pack

例如可以创建 `theories/eastern/`（道德经+禅宗+中医整体观）或 `theories/lean/`（只保留 3 个最核心模块的极简版）。
