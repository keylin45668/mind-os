# 场景集：渐进加载与上下文隔离

> 覆盖 meta.md §8 渐进加载协议 + §9 上下文隔离规则
> 与 task-grading.md §3.1 loading_depth 联动

---

## S-LOAD-01：🟢 轻量任务 — 小模块全文加载

```yaml
user_input: "帮我快速分类一下这些文件"
keyword_match: "分类" → organize/rules.md (SHOULD)
task_grade: 🟢
expected:
  - organize/rules.md < 800 bytes（无 ## 摘要）→ 读全文
  - 全文在 token 预算内
  - 不触发 MUST_RUN → 不升级任务级别
  - 按 PARA 规则分类后直接输出
  - Pre-Output Gate: 1_declare + 2_enforce(SHOULD) + 无 depth_check(hooks=null)
checks: [B01, B05, C01, C10]
```

## S-LOAD-02：🟢 轻量任务 — 大模块只读摘要

```yaml
user_input: "沟通技巧简单说几个要点就行"
keyword_match: "沟通" → collaboration/communication.md (SHOULD)
task_grade: 🟢（用户明确要求简单）
expected:
  - communication.md ≥ 800 bytes → 有 ## 摘要
  - 🟢 任务 → loading_depth: summary_only
  - AI 只读到 ## 摘要 结束处（下一个 ## 标题前停止）
  - 输出基于摘要内容（受众分析→目标定义→策略选择→预演）
  - 不包含完整的 Step 1-4 详细 YAML 内容
checks: [B01, C10]
```

## S-LOAD-03：🟢 → 🟡 自动升级触发全量加载

```yaml
user_input: "帮我用反脆弱分析一下"
keyword_match: "反脆弱" → antifragile.md (MUST_RUN)
task_grade: 🟢 初始 → 检测到 MUST_RUN → 升级为 🟡
expected:
  - 路由匹配到 MUST_RUN → 自动升级为 🟡
  - 🟡 → loading_depth: full
  - antifragile.md 全文加载（包括三元分类器 YAML、杠铃策略 YAML 等完整内容）
  - 不在 ## 摘要 处截断
  - 三元分类 + 杠铃 + 否定法全部执行
checks: [B01, B05, C03, C08]
```

## S-LOAD-04：🟡 标准任务 — 多模块全量加载

```yaml
user_input: "这个投资方案帮我仔细分析一下利弊和风险"
keyword_match:
  - "分析/利弊" → iterative-engine.md (MUST_RUN)
  - "风险/投资" → antifragile.md (MUST_RUN)
task_grade: 🟡（2 个 MUST_RUN）
expected:
  - 两个模块全量加载
  - iterative-engine.md: 红蓝对抗协议完整可用（编号规则、收敛条件等）
  - antifragile.md: 三元分类器完整可用
  - 串行拆分执行（meta.md 规则 7）
  - 步间门控清单完整
checks: [B01, B02, C03, C06, C08]
```

## S-LOAD-05：🔴 深度任务 — 分阶段加载

```yaml
user_input: "这是一个战略级决策，要不要进入无人机赛道，帮我全面审视"
task_grade: 🔴（不可逆决策、战略级）
expected:
  - 匹配模块可能 > 3 个
  - 🔴 支持分阶段多次加载
  - 阶段 1: 加载 antifragile + iterative-engine + _index
  - 阶段 2: 完成后追加 competition.md
  - 每阶段重新过 Pre-Input Gate
  - 每个模块全量加载
checks: [B01, B02, C03]
```

## S-LOAD-06：摘要模式下 hooks 仍然生效

```yaml
user_input: "帮我简单过一下这个方案的风险"
keyword_match: "风险" → antifragile.md (MUST_RUN)
假设维持 🟢（用户要求简单）:
expected:
  - 即使只读摘要，frontmatter 中的 hooks 仍然可读
  - hooks.depth_check: "三元分类每类须有具体百分比和理由"
  - Pre-Output Gate 4_depth_check 仍然执行该 hook
  - 即 summary_only 只影响加载深度，不影响质量门控
检查: hooks 不因 summary_only 加载模式而丢失
```

---

## S-LOAD-07：isolated 模块 — 建议隔离执行

```yaml
user_input: "/深度迭代 要不要转型做SaaS"
keyword_match: "/深度迭代" → task-iterate.md (MUST_RUN, context: isolated)
expected:
  - 读取 task-iterate.md frontmatter → context: isolated
  - 声明: "⚠️ 该模块建议在隔离上下文中执行（多轮迭代可能消耗大量上下文）"
  - 如果在 Claude Code 中: 建议使用 subagent
  - 如果无法隔离: 在当前上下文执行，但提醒用户
checks: [B01, G01]
```

## S-LOAD-08：isolated 模块 — 并行思考隔离

```yaml
user_input: "/并行 这个问题拆成产品和技术两个方向分别分析"
keyword_match: "/并行" → parallel-thinking.md (SHOULD, context: isolated)
expected:
  - 检测到 context: isolated
  - 按 Wave 模型执行:
    - W0: 在当前上下文分解问题
    - W1: 建议在隔离上下文中并行执行（每个子问题独立 agent）
    - W2: 回到主上下文综合
  - handoff 文档传递正确
checks: [B01]
```

## S-LOAD-09：非 isolated 模块 — 无隔离提示

```yaml
user_input: "/回顾 帮我做本周回顾"
keyword_match: "/回顾" → review/rules.md (MUST_RUN, context: default)
expected:
  - 不出现隔离提示
  - 在当前上下文直接执行
  - 回顾模板正常展示
checks: [B01, C01]
```

## S-LOAD-10：摘要加载与完整加载的输出质量对比

```yaml
对比测试:
  场景A（🟢 摘要模式）:
    user_input: "简单说说杠铃策略是什么"
    加载: antifragile.md → 只读摘要
    expected_output: 简洁回答，覆盖杠铃策略核心（强制两极化、冒险端准入条件）

  场景B（🟡 全量模式）:
    user_input: "帮我用杠铃策略分析我的资产配置"
    加载: antifragile.md → 全文
    expected_output: 完整执行杠铃策略协议（安全端+冒险端+比例定义+增速判定）

验证:
  - 场景A 的输出是场景B 输出的子集 ✅
  - 场景A 不包含场景B 中的细节（如"正业务增速 < 10% → 冒险端提升"）✅
  - 两者都不违反宪法 ✅
checks: 质量差异在预期范围内，摘要足以回答简单问题
```
