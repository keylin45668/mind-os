# Frontmatter 自描述 + 渐进加载 — 设计规格

> 日期：2026-03-30
> 状态：已实施、已验证
> 版本：v5.3

## 1. 问题

Mind OS v5.2 的 theory 模块存在三个工程化治理缺陷：

1. **元数据单点集中** — 模块的 command/keywords/execution_level 全部集中在 meta.md 路由表中，模块文件本身无自描述能力。新增模块必须手动编辑 meta.md，遗忘则路由断链。
2. **加载粒度唯一** — 无论任务轻重，都全量加载模块文件。🟢 轻量任务（如"帮我分类邮件"）也加载完整的 1000+ token 文件，浪费上下文预算。
3. **质量门控硬编码** — Pre-Output Gate 的 `4_depth_check` 只覆盖 4 个模块（iterative-engine/antifragile/system-audit/_index），硬编码在 protocols.md 中。新增模块的质量门控无法自动纳入。

## 2. 设计来源

借鉴 Claude Code Skills 的三个核心模式：

| Claude Code Skills 模式 | Mind OS 对应实现 |
|------------------------|-----------------|
| SKILL.md YAML frontmatter | 模块 frontmatter（name/command/keywords/hooks 等） |
| 三级渐进披露（metadata → instructions → resources） | Level 1 metadata → Level 2 摘要 → Level 3 全文 |
| allowed-tools / hooks | hooks.depth_check / hooks.post_check |

同构关系：Claude Code Skill = Mind OS theory 模块（自描述 + 按需加载 + 专业化 + 可组合）。

## 3. 方案

### 3.1 Frontmatter 自描述

每个 theory 模块文件顶部添加 YAML frontmatter：

```yaml
---
name: antifragile           # 与文件名一致
command: /反脆弱             # 斜杠命令（null = 无命令）
keywords: [风险, 投资, 反脆弱]
execution_level: MUST_RUN    # MUST_RUN | SHOULD | MAY
type: framework             # specification | framework | checklist | router | metric
domain: decide
summary: "一句话摘要"
context: default            # default | isolated
hooks:
  pre_check: null
  post_check: null
  depth_check: "质量检查条件"
---
```

规范文件：`schemas/default/module-frontmatter-spec.md`

### 3.2 三级渐进加载

与 task-grading.md 分级联动：

| 加载级别 | 内容 | Token 消耗 | 适用任务 |
|---------|------|-----------|---------|
| Level 1 | frontmatter summary 字段 | ~50 | 路由表展示、/模块列表 |
| Level 2 | frontmatter + `## 摘要` 节 | ~200 | 🟢 轻量任务 |
| Level 3 | 完整文件 | ≤1000 | 🟡🔴 标准/深度任务 |

- 模块 < 800 bytes → 无 `## 摘要`，Level 2 退化为全文加载（仍在预算内）
- 模块 ≥ 800 bytes → 必须有 `## 摘要` 节

### 3.3 模块级 Hooks

Pre-Output Gate `4_depth_check` 从硬编码改为动态聚合：

```yaml
4_depth_check:
  rule: "读取每个已加载模块的 hooks.depth_check/post_check，逐条执行"
  fallback: "hooks 为 null → 跳过"
```

已迁移的 hooks：

| 模块 | hook 类型 | 内容 |
|------|----------|------|
| iterative-engine | depth_check | 红方须与蓝方观点不同 |
| antifragile | depth_check | 三元分类每类须有具体百分比和理由 |
| system-audit-method | depth_check | 至少 2 个方法有实质产出 |
| _index | depth_check | 偏差须关联用户具体情境 |
| creative | depth_check | 发散阶段至少用2种路径 |
| task-iterate | depth_check | 至少1个方向完成完整蓝-红-裁决 |
| session-audit | post_check | 审查清单每项有具体依据 |
| session-rating | post_check | 每维度评分有文档中客观依据 |
| crystallize | post_check | 三问全部执行且有结论 |

### 3.4 上下文隔离

5 个重量级模块标记 `context: isolated`：

- think/iterative-engine.md — 多轮红蓝对抗
- think/task-iterate.md — 任务级多轮迭代
- deliberation/protocol.md — 多角色审议
- collaboration/parallel-thinking.md — 多 agent 并行
- review/cross-session-audit.md — 跨会话独立复审

## 4. 改动文件清单

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `schemas/default/module-frontmatter-spec.md` | frontmatter 规范文件 |
| 修改 | theories/rational/ 下 44 个模块 | 添加 frontmatter + 摘要 |
| 修改 | `theories/rational/meta.md` | 添加 §8 渐进加载 + §9 上下文隔离 |
| 修改 | `schemas/default/protocols.md` | 4_depth_check 改动态聚合 |
| 修改 | `schemas/default/task-grading.md` | 添加 §3.1 分级加载深度 |
| 修改 | `autoevolve/module-evolve.md` | Step 2 添加 frontmatter 验证 |
| 修改 | `autoevolve/evaluator.md` | 新增 J 类 12 项检查（权重 22） |
| 新建 | `tests/frontmatter-optimization-tests.md` | 38 个测试用例 |
| 新建 | `autoevolve/scenarios/progressive-loading.md` | 10 个场景 |
| 新建 | `autoevolve/scenarios/dynamic-hooks.md` | 14 个场景 |
| 修改 | `DESIGN-NOTES.md` | 增加 Layer 23 设计推导 |
| 修改 | `BOOT.md` | 面板增加渐进加载标识 |
| 修改 | `config-template.md` | 版本号 → v5.3 |
| 修改 | `theories/rational/README.md` | 更新模块格式说明 |

## 5. 向后兼容

- meta.md 路由表保持原有格式，frontmatter 是补充而非替代
- 无 frontmatter 的模块仍可通过 meta.md 关键词路由正常工作
- Pre-Output Gate 对无 hooks 模块自动跳过（fallback 规则）
- 渐进加载对无 `## 摘要` 模块退化为全量加载

## 6. 验证结果

8 个模拟场景全部 PASS：

| 场景 | 结果 |
|------|------|
| 🟢 "帮我快速分类邮件" | PASS — summary_only 加载 + null hooks 跳过 |
| 🟡 "投资风险大不大？值不值50万？" | PASS — 双 MUST_RUN 全量加载 + hooks 聚合 2 条 |
| 🔴 "/深度迭代 转型做无人机" | PASS — isolated 提示 + 全量加载 |
| 命令路由 "/反脆弱" | PASS — frontmatter command 一致 |
| 边界误判 "写感谢信给投资人" | PASS — 意图验证降级 MAY |
| 会话结束 | PASS — session-audit/rating post_check 聚合 |
| /模块迭代 frontmatter 验证 | PASS — 6 项检查全通过 |
| 无 frontmatter 新模块兼容 | PASS — 路由正常 + hooks 跳过 + 模块迭代报 ❌ |
