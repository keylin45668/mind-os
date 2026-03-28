# 并行思考协议

> 来源：Template-Parallel（_architecture）适配思考场景

## 集成说明

- **meta.md 路由接入**：建议在路由表新增 `/并行` 命令，关键词 `并行/多子问题/独立思考/分治`，加载本文件，执行级别 SHOULD
- **protocols.md 拓扑关系**：本协议扩展「并联拓扑」，将 AI×W₁ + 人×W₂ 泛化为多 agent 并行思考 + 人综合裁决
- **协作模式**：默认「对等协作 × 迭代」，Wave 2 综合阶段切换为「人类主导」

---

## 1. 触发条件（满足 ≥2 项）

| 条件 | 判定方法 |
|------|---------|
| 问题可分解为 ≥2 个独立子问题 | Wave 0 分解后验证 |
| 子问题之间无数据依赖 | 输入/输出无交叉 |
| 涉及多个 domain 或多个 project connector | 查 `_router.md` 路由命中 ≥2 项目 |

不满足时退回串联拓扑，按 protocols.md 常规流程执行。

---

## 2. Wave 调度模型

```
Wave 0 ─ 问题分解 + 独立性验证（串行，必须先完成）
  ├── 拆出子问题清单
  ├── 验证无数据依赖（输入/输出不交叉）
  └── 为每个子问题指定 theory routing 路径
         ↓
Wave 1 ─ 并行思考（每个子问题独立 agent）
  ├── 各 agent 只写 runtime/thinking/{task-id}/
  ├── 各自走 meta.md 关键词路由加载 theory
  └── 输出格式：结论 + 置信度 + 关键假设
         ↓
Wave 2 ─ 综合决策（串行，依赖 Wave 1 全部完成）
  ├── 汇总各 agent 结论
  ├── 冲突检测（见 §3）
  └── 输出统一决策或分歧报告
         ↓
Wave 3 ─ 交叉验证（可选，仅 🔴 级任务）
  └── 红蓝对抗：各 agent 审查其他 agent 的结论
```

---

## 3. 隔离与冲突处理

- **写隔离**：每个并行 agent 只写 `runtime/thinking/{task-id}/`，禁止跨目录写入
- **合并检查**：Wave 2 开始前，对比各 agent 结论的关键假设和推荐方向
- **冲突处理链**：列出分歧 → 人裁决；若人不可用 → 追加 red-blue 对抗（iterative-engine.md）

---

## 4. 与多项目连接器的关系

当思考任务涉及多个 `local/projects/*.md` 连接器时：

1. Wave 0 中为每个子问题绑定对应连接器（读取 context_files + theories）
2. 发出「决策契约」：明确各子问题的输出格式和边界约束
3. Wave 1 各 agent 按各自连接器的 iron_rules 和 constraints 执行
4. Wave 2 合并时按 `_router.md` 优先级解决跨项目冲突

---

## 5. Claude Code 实际执行方式

### 多窗口实现

```
窗口 1（主会话）：Wave 0 分解 → 生成 handoff 文档 → Wave 2 综合
窗口 2..N（子会话）：各自执行 Wave 1 子问题
```

### Handoff 文档格式

```yaml
# runtime/thinking/{task-id}/handoff.md
子问题: {描述}
约束:
  - {来自 Wave 0 的边界}
  - {来自连接器的 iron_rules}
输出要求:
  - 结论（≤ 200 tokens）
  - 置信度（高/中/低 + 理由）
  - 关键假设列表
theory_routing: {meta.md 匹配到的文件}
```

子会话完成后将结论写入 `runtime/thinking/{task-id}/conclusion.md`，主会话读取后进入 Wave 2。

---

## 6. 上下文隔离与同步协议

### 子会话上下文传递

子会话（Wave 1）不自动继承主会话的 Mind OS 完整上下文。主会话必须通过 handoff 文档显式传递所需信息：

```yaml
context_transfer:
  必须传递:
    - handoff.md（子问题定义 + 约束 + 输出要求）
    - theory routing 路径（指定子会话该加载哪些 theory 文件）
    - 相关项目连接器的 iron_rules（如有）
  不传递:
    - 其他子问题的 handoff（隔离保证独立性）
    - 主会话的完整对话历史（避免偏见传染）
    - runtime 状态文件（子会话只写不读 runtime/）
```

### 子会话漂移防护

```yaml
drift_protection:
  机制: 子会话输出必须包含 handoff.md 中定义的所有"输出要求"字段
  检查时机: 子会话完成时，主会话读取 conclusion.md 前
  检查规则:
    - conclusion.md 必须包含: 结论、置信度、关键假设（handoff 要求的 3 项）
    - 缺少任一项 → 主会话标记该子问题为"不完整"，Wave 2 中降低其权重
  超时: 子会话未在合理时间内完成 → 主会话标记为"超时"，Wave 2 用已有信息继续
```

### 上下文窗口丢失处理

```yaml
context_loss:
  问题: 子会话的上下文窗口可能因长度压缩丢失 Mind OS 规则
  对策:
    - handoff.md 中内联关键约束（不依赖子会话自行读取 schema/）
    - 子会话的 theory 文件路径写在 handoff.md 中，子会话启动时直接读取
    - 如果子问题预计复杂（🔴级），建议子会话也执行 BOOT（handoff 中标注 boot: true）
```
