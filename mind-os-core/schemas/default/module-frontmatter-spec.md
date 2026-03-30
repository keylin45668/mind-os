# 模块 Frontmatter 规范

> 版本：1.0 | 适用范围：theories/ 下所有 .md 模块文件
> 设计来源：Claude Code Skills 自描述模式 + Mind OS 正交分离原则

---

## 标准 Schema

```yaml
---
name: antifragile                    # 唯一 ID，必须与文件名（去 .md）一致
command: /反脆弱                      # 斜杠命令（无命令的模块设为 null）
keywords: [风险, 投资, 反脆弱]        # 自动匹配关键词（与 meta.md 路由表同步）
execution_level: MUST_RUN            # MUST_RUN | SHOULD | MAY
type: framework                      # 见下方类型定义
domain: decide                       # 见下方领域定义
summary: "三元分类(脆弱/坚韧/反脆弱) + 杠铃策略 + 否定法"
context: default                     # default | isolated
hooks:
  pre_check: null                    # 执行前条件验证（字符串或 null）
  post_check: null                   # 执行后质量验证
  depth_check: null                  # 深度检查（原 protocols.md 硬编码项迁移至此）
---
```

---

## 字段说明

### name（必填）

模块唯一标识，**必须**与文件名一致（去掉 `.md` 后缀）。用于路由匹配、日志记录、模块间引用。

### command（必填，可为 null）

对应 meta.md 路由表中的斜杠命令。无独立命令的模块（如通过父路由器访问的 bias-* 文件）设为 `null`。

### keywords（必填）

关键词数组，用于自动匹配。必须与 meta.md 路由表中对应行的"关键词"列保持一致。

### execution_level（必填）

| 值 | 含义 |
|---|---|
| `MUST_RUN` | 匹配即执行，不可跳过 |
| `SHOULD` | 应执行，跳过须声明理由 |
| `MAY` | 可选参考 |

### type（必填）

| 值 | 说明 | 典型大小 |
|---|---|---|
| `specification` | 完整算法规格（状态机、收敛条件、文件架构） | > 3000 bytes |
| `framework` | 步骤式方法论（触发→协议→产出→防退化） | 1000-3000 bytes |
| `checklist` | 单概念检查器（触发→协议→产出） | < 800 bytes |
| `router` | 路由表（关键词→子模块映射） | 1000-2000 bytes |
| `metric` | 评分/评估系统（维度定义+计算公式） | 2000-5000 bytes |

### domain（必填）

模块所属领域：`think` | `decide` | `review` | `collaboration` | `knowledge` | `organize` | `capture` | `deliberation`

### summary（必填）

一句话摘要，覆盖模块核心概念。用于：
- meta.md 路由表的模块说明列
- 🟢 轻量任务的快速参考（当模块无 `## 摘要` 节时）
- `/模块列表` 展示

### context（必填）

| 值 | 含义 | 适用场景 |
|---|---|---|
| `default` | 在当前上下文中执行 | 大多数模块 |
| `isolated` | 建议在隔离上下文中执行 | 多轮迭代、多角色审议、并行思考 |

### hooks（必填，子字段可为 null）

模块级质量门控，Pre-Output Gate 动态聚合所有已加载模块的 hooks 执行。

| 子字段 | 触发时机 | 示例 |
|--------|---------|------|
| `pre_check` | 模块执行前 | "是否有量化数据支撑？无数据降级为定性分析" |
| `post_check` | 模块执行后 | "三问全部执行且有结论" |
| `depth_check` | Pre-Output Gate 深度检查 | "红方须与蓝方观点不同" |

---

## 摘要节规则

| 模块原始大小 | 处理 |
|-------------|------|
| < 800 bytes | 不需要 `## 摘要` 节，frontmatter `summary` 字段即摘要 |
| >= 800 bytes | 必须有 `## 摘要` 节，位于 frontmatter 之后、第一个内容标题之前 |

`## 摘要` 格式：2-4 个要点，覆盖核心步骤，控制在 ~200 tokens 以内。

---

## Token 预算

- frontmatter **不计入** 1000 token 预算（它是元数据，不是思维内容）
- 模块正文（含 `## 摘要`）仍遵守 ≤ 1000 tokens 的宪法第三条约束
- 添加 frontmatter 后，删除正文中的 `> 来源：...` 行（已由 frontmatter 承载，避免重复）

---

## 与 meta.md 的关系

- **当前阶段**：meta.md 路由表手动维护，frontmatter 作为模块自描述的补充
- **一致性要求**：模块 frontmatter 的 command/keywords/execution_level 必须与 meta.md 路由表对应行一致
- **验证**：module-evolve.md Step 2 诊断中包含 frontmatter 一致性检查
- **未来演进**：meta.md 路由表可从各模块 frontmatter 自动生成

---

## 示例

### checklist 类型（小模块，无 ## 摘要）

```yaml
---
name: bias-anchor
command: null
keywords: [锚定, 数值估计, 方案排序]
execution_level: SHOULD
type: checklist
domain: think
summary: "锚定效应检测：生成反向锚 + 重新排序"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---
```

### framework 类型（中等模块，有 ## 摘要）

```yaml
---
name: antifragile
command: /反脆弱
keywords: [风险, 投资, 反脆弱]
execution_level: MUST_RUN
type: framework
domain: decide
summary: "三元分类(脆弱/坚韧/反脆弱) + 杠铃策略 + 否定法"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: "三元分类每类须有具体百分比和理由"
---

## 摘要

- **三元分类**：识别冲击→判定脆弱/强韧/反脆弱→组合健康度检查
- **杠铃策略**：强制两极化，冒险端准入=最大损失已知+潜在收益≥5x
- **否定法**：减法优先，新增缺省拒绝，90天未引用则归档
```

### specification 类型（大模块，隔离执行）

```yaml
---
name: iterative-engine
command: /分析
keywords: [帮我分析, 深度思考, 多方向, 对比方案, 利弊]
execution_level: MUST_RUN
type: specification
domain: think
summary: "红蓝对抗迭代引擎：多方向并行探索 + 质量驱动收敛 + 评分 Agent"
context: isolated
hooks:
  pre_check: null
  post_check: null
  depth_check: "红方须与蓝方观点不同"
---

## 摘要

- **红蓝对抗**：每个方向蓝方提案→红方质疑（首要=本源检查）→裁决，编号制可追溯
- **收敛条件**：质量驱动而非固定轮次，评分 Agent 打分 ≥ min_score 才收敛
- **并行模型**：层内并行探索多方向，层间串行收敛，state.yaml 为唯一真相源
- **输出模式**：默认对话输出，按需落盘到 runtime/thinking/{task}/
```
