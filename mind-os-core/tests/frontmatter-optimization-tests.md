# Frontmatter 优化测试用例

> 版本：v5.3 | 日期：2026-03-30
> 覆盖：frontmatter 格式验证、meta.md 一致性、摘要覆盖、hooks 迁移、渐进加载、上下文隔离
> 共 10 大类、60+ 测试用例

---

## 一、Frontmatter 格式验证

### T-FM-01：全部模块存在 frontmatter

```yaml
前置: theories/rational/ 下所有 .md 文件（排除 README.md、SOURCES.md）
输入: 扫描每个文件前 3 行
验证:
  - 第 1 行 == "---"
  - 文件中存在第二个 "---"（闭合标记）
  - frontmatter 区域包含合法 YAML
预期: 46 个模块文件全部有合法 YAML frontmatter
失败影响: 致命 — 无 frontmatter 的模块将无法被渐进加载和动态 hooks 聚合
```

### T-FM-02：必填字段完整性

```yaml
前置: 每个模块的 frontmatter
验证（每个模块逐一检查）:
  - name 字段存在且非空
  - command 字段存在（可为 null）
  - keywords 字段存在且为数组
  - execution_level 字段存在且值 ∈ {MUST_RUN, SHOULD, MAY}
  - type 字段存在且值 ∈ {specification, framework, checklist, router, metric}
  - domain 字段存在且值 ∈ {think, decide, review, collaboration, knowledge, organize, capture, deliberation}
  - summary 字段存在且非空
  - context 字段存在且值 ∈ {default, isolated}
  - hooks 字段存在且包含 pre_check, post_check, depth_check 三个子字段
预期: 46 个模块全部通过
```

### T-FM-03：name 与文件名一致性

```yaml
前置: 每个模块的 frontmatter
验证:
  - name 字段值 == 文件名去掉 .md 后缀
  - 示例: antifragile.md → name: antifragile ✅
  - 示例: bias-anchor.md → name: bias-anchor ✅
  - 示例: _index.md → name: _index ✅
  - 反例: antifragile.md → name: anti-fragile ❌
预期: 全部一致
失败影响: name 不一致会导致 module-evolve 验证失败、模块间引用断链
```

### T-FM-04：type 分类合理性

```yaml
前置: 每个模块的 frontmatter type 字段
验证:
  - bias-*.md → type: checklist（单概念检查器）
  - iterative-engine.md, task-iterate.md, system-audit-method.md → type: specification
  - meta.md, _index.md, models/meta.md → type: router
  - session-rating.md, session-audit.md, deliberation/scoring.md → type: metric
  - 其余大多为 framework
预期: type 与模块实际结构匹配
```

---

## 二、Frontmatter 与 meta.md 一致性

### T-FM-05：command 字段一致性

```yaml
前置: meta.md 路由表中每个有命令的行
验证（逐行对比）:
  | meta.md 命令 | 对应文件 | 文件 frontmatter command |
  |-------------|---------|------------------------|
  | /收集 | capture/rules.md | /收集 ✅ |
  | /整理 | organize/rules.md | /整理 ✅ |
  | /偏差 | think/_index.md | /偏差 ✅ |
  | /分析 | think/iterative-engine.md | /分析 ✅ |
  | /审计 | think/system-audit-method.md | /审计 ✅ |
  | /排期 | decide/rules.md | /排期 ✅ |
  | /反脆弱 | decide/antifragile.md | /反脆弱 ✅ |
  | /竞争 | decide/competition.md | /竞争 ✅ |
  | /模型 | decide/models/meta.md | /模型 ✅ |
  | /回顾 | review/rules.md | /回顾 ✅ |
  | /知识 | knowledge/rules.md | /知识 ✅ |
  | /协作 | collaboration/rules.md | /协作 ✅ |
  | /动力学 | collaboration/dynamics.md | /动力学 ✅ |
  | /团队 | collaboration/learning-org.md | /团队 ✅ |
  | /原则 | collaboration/principles.md | /原则 ✅ |
  | /经济 | collaboration/economics.md | /经济 ✅ |
  | /进化 | collaboration/evolution.md | /进化 ✅ |
  | /结晶 | review/crystallize.md | /结晶 ✅ |
  | /评分 | review/session-audit.md | /评分 ✅ |
  | /质量 | think/quality-loop.md | /质量 ✅ |
  | /深度迭代 | think/task-iterate.md | /深度迭代 ✅ |
  | /创意 | think/creative.md | /创意 ✅ |
  | /执行 | organize/execute.md | /执行 ✅ |
  | /沟通 | collaboration/communication.md | /沟通 ✅ |
  | /学习 | knowledge/learning.md | /学习 ✅ |
  | /跨审 | review/cross-session-audit.md | /跨审 ✅ |
  | /并行 | collaboration/parallel-thinking.md | /并行 ✅ |
  | /审议 | deliberation/meta.md | /审议 ✅ |
预期: 全部一致
失败影响: 命令路由失效 — 用户输入 /命令 无法正确加载对应模块
```

### T-FM-06：execution_level 一致性

```yaml
前置: meta.md 路由表
验证:
  MUST_RUN 模块:
    - think/_index.md (偏差) → execution_level: MUST_RUN ✅
    - think/iterative-engine.md (分析) → execution_level: MUST_RUN ✅
    - think/system-audit-method.md (审计) → execution_level: MUST_RUN ✅
    - decide/antifragile.md (反脆弱) → execution_level: MUST_RUN ✅
    - review/session-audit.md (评分) → execution_level: MUST_RUN ✅
    - think/task-iterate.md (深度迭代) → execution_level: MUST_RUN ✅
    - think/task-iterate-signals.md → execution_level: MUST_RUN ✅
    - review/session-rating.md → execution_level: MUST_RUN ✅
  SHOULD 模块:
    - capture/rules.md, organize/rules.md, decide/rules.md 等 → SHOULD ✅
  MAY 模块:
    - collaboration/rules.md, dynamics.md, learning-org.md 等 → MAY ✅
预期: 全部一致
失败影响: 致命 — execution_level 不一致导致 MUST_RUN 被跳过或 MAY 被强制执行
```

### T-FM-07：keywords 一致性

```yaml
前置: meta.md 路由表的"关键词"列
验证（抽样 10 个模块）:
  - antifragile: meta.md="风险/投资/反脆弱" → frontmatter=[风险, 投资, 反脆弱] ✅
  - iterative-engine: meta.md="帮我分析/深度思考/多方向/对比方案/利弊" → frontmatter 匹配 ✅
  - creative: meta.md="设计/创意/方案/产品/点子/命名/想个" → frontmatter 匹配 ✅
  - communication: meta.md="说服/谈判/汇报/沟通/表达/演讲/怎么说" → frontmatter 匹配 ✅
  - evolution: meta.md="进化/适应度/淘汰/分化" → frontmatter 匹配 ✅
预期: 关键词集合一致（顺序可不同）
失败影响: 关键词路由失效 — 用户输入无法匹配到正确模块
```

---

## 三、摘要节覆盖验证

### T-FM-08：大模块有摘要节

```yaml
前置: 所有正文（不含 frontmatter）≥ 800 bytes 的模块
验证:
  - 文件中存在 "## 摘要" 标题
  - 摘要节位于 frontmatter 闭合 "---" 之后、第一个内容标题之前
  - 摘要节内容为 2-4 个要点
  需要有摘要的模块（预期列表）:
    - think/iterative-engine.md ✅
    - think/system-audit-method.md ✅
    - think/creative.md ✅
    - think/task-iterate.md ✅
    - think/task-iterate-signals.md ✅
    - think/quality-loop.md ✅
    - think/bias-inference-ladder.md ✅
    - think/bias-munger25.md ✅
    - think/certainty-layers.md ✅
    - decide/antifragile.md ✅
    - decide/rules.md ✅
    - decide/competition.md ✅
    - collaboration/rules.md ✅
    - collaboration/dynamics.md ✅
    - collaboration/principles.md ✅
    - collaboration/evolution.md ✅
    - collaboration/parallel-thinking.md ✅
    - collaboration/communication.md ✅
    - review/session-audit.md ✅
    - review/session-rating.md ✅
    - review/crystallize.md ✅
    - knowledge/learning.md ✅
    - organize/execute.md ✅
    - deliberation/protocol.md ✅
预期: 全部有 ## 摘要
失败影响: 🟢 轻量任务无法使用 summary_only 模式，退化为全量加载
```

### T-FM-09：小模块无摘要节不报错

```yaml
前置: 所有正文 < 800 bytes 的模块（bias-anchor, bias-loss-aversion 等小型 checklist）
验证:
  - 这些模块可以没有 ## 摘要 节
  - frontmatter 的 summary 字段作为摘要（已验证存在）
  - 全文加载仍在 token 预算内
预期: 小模块无 ## 摘要 不影响系统功能
```

### T-FM-10：摘要内容质量

```yaml
前置: 有 ## 摘要 的模块
验证（抽样 5 个）:
  antifragile.md 摘要:
    - 覆盖三元分类 ✅
    - 覆盖杠铃策略 ✅
    - 覆盖否定法 ✅
    - 未遗漏核心步骤 ✅
  iterative-engine.md 摘要:
    - 覆盖红蓝对抗 ✅
    - 覆盖收敛条件 ✅
    - 覆盖并行模型 ✅
    - 覆盖质量门控 ✅
  creative.md 摘要:
    - 覆盖约束提取 ✅
    - 覆盖四种发散路径 ✅
    - 覆盖产出要求 ✅
    - 覆盖收敛阶段 ✅
预期: 摘要足以让 🟢 任务理解核心步骤并执行简化版
失败影响: 摘要不完整导致 🟢 任务执行质量下降
```

---

## 四、Hooks 迁移完整性

### T-FM-11：原 protocols.md 硬编码项已迁移

```yaml
前置: 原 protocols.md 中 4_depth_check 的 4 条硬编码规则
验证:
  原规则 → 迁移目标:
  - "iterative-engine: 红方须与蓝方观点不同" → iterative-engine.md hooks.depth_check ✅
  - "antifragile: 须给具体百分比和理由" → antifragile.md hooks.depth_check ✅
  - "system-audit: 至少 2 个方法有实质产出" → system-audit-method.md hooks.depth_check ✅
  - "think/_index: 偏差须关联用户具体情境" → _index.md hooks.depth_check ✅
  protocols.md 中:
  - 4_depth_check 已改为动态聚合规则 ✅
  - 不再包含硬编码模块名 ✅
预期: 四条规则完整迁移，protocols.md 无硬编码残留
失败影响: 致命 — depth_check 丢失导致 MUST_RUN 执行走形式
```

### T-FM-12：新增 hooks 完整性

```yaml
前置: 计划中新增 hooks 的模块
验证:
  - think/creative.md → hooks.depth_check: "发散阶段至少用2种路径" ✅
  - think/task-iterate.md → hooks.depth_check: "至少1个方向完成完整蓝-红-裁决" ✅
  - review/crystallize.md → hooks.post_check: "三问全部执行且有结论" ✅
  - review/session-audit.md → hooks.post_check: "审查清单每项有具体依据" ✅
  - review/session-rating.md → hooks.post_check: "每维度评分有文档中客观依据" ✅
预期: 5 个新增 hooks 全部就位
```

### T-FM-13：所有 MUST_RUN 模块有 depth_check

```yaml
前置: 所有 execution_level: MUST_RUN 的模块
验证:
  - iterative-engine.md: hooks.depth_check ≠ null ✅
  - antifragile.md: hooks.depth_check ≠ null ✅
  - system-audit-method.md: hooks.depth_check ≠ null ✅
  - _index.md: hooks.depth_check ≠ null ✅
  - task-iterate.md: hooks.depth_check ≠ null ✅
  - session-audit.md: hooks.post_check ≠ null ✅（用 post_check 替代）
  - session-rating.md: hooks.post_check ≠ null ✅
  - task-iterate-signals.md: hooks 全 null — 可接受（它是 metric 类型，由 task-iterate 驱动）
预期: MUST_RUN 模块至少有 depth_check 或 post_check 覆盖质量门控
```

---

## 五、渐进加载功能验证

### T-FM-14：🟢 轻量任务只读摘要

```yaml
user_input: "帮我快速整理一下这些文件"
keyword_match: "整理" → organize/rules.md (SHOULD)
task_grade: 🟢（单模块、无高风险）
expected:
  - 任务分级为 🟢
  - 加载 organize/rules.md 时只读 frontmatter + 全文（该模块 < 800 bytes，无 ## 摘要，读全文）
  - 不额外加载其他模块
  - 输出仍按 PARA 规则分类
验证点: 🟢 任务不触发 Level_3 全量加载
```

### T-FM-15：🟢 轻量任务 — 大模块只读到摘要

```yaml
user_input: "简单说一下反脆弱是什么意思"
keyword_match: "反脆弱" → decide/antifragile.md (MUST_RUN)
task_grade: 🟢（但命中 MUST_RUN 会升级为 🟡）
expected:
  - 因命中 MUST_RUN 升级为 🟡
  - 🟡 → 加载完整模块（Level_3）
  - 如果用户明确"不用深入分析，简单说说"→ 维持 🟢
  - 🟢 时只读 frontmatter + ## 摘要
验证点: MUST_RUN 触发自动升级为 🟡，升级后全量加载
```

### T-FM-16：🟡 标准任务全量加载

```yaml
user_input: "帮我分析这三个方案的利弊"
keyword_match: "帮我分析/利弊" → iterative-engine.md (MUST_RUN)
task_grade: 🟡（涉及决策，匹配 MUST_RUN）
expected:
  - 加载 iterative-engine.md 完整内容（Level_3）
  - 不在 ## 摘要 处截断
  - 完整的红蓝对抗协议可用
  - 编号规则、收敛条件、并行模型全部加载
验证点: 🟡/🔴 任务必须全量加载，不可只读摘要
```

### T-FM-17：🔴 深度任务多阶段加载

```yaml
user_input: "这是个战略级决策，帮我全面审视"
task_grade: 🔴（不可逆决策、战略级）
expected:
  - 匹配多个模块，全量加载
  - 可分阶段多次加载不同模块
  - 每阶段重新过 Pre-Input Gate
验证点: 🔴 任务支持分阶段多次加载
```

---

## 六、动态 Hooks 聚合验证

### T-FM-18：Pre-Output Gate 动态读取 hooks

```yaml
user_input: "帮我深度分析这个投资机会的风险"
加载模块:
  - iterative-engine.md (hooks.depth_check: "红方须与蓝方观点不同")
  - antifragile.md (hooks.depth_check: "三元分类每类须有具体百分比和理由")
expected:
  Pre-Output Gate 4_depth_check 执行:
    - 检查: "红方须与蓝方观点不同" → 来自 iterative-engine.md frontmatter ✅
    - 检查: "三元分类每类须有具体百分比和理由" → 来自 antifragile.md frontmatter ✅
  不应出现:
    - 硬编码的 "system-audit: 至少 2 个方法有实质产出"（未加载该模块）
    - 硬编码的 "think/_index: 偏差须关联用户具体情境"（未加载该模块）
验证点: 只聚合已加载模块的 hooks，不执行未加载模块的 hooks
```

### T-FM-19：无 hooks 模块不报错

```yaml
user_input: "帮我做一下本周回顾"
加载模块: review/rules.md (hooks 全部为 null)
expected:
  Pre-Output Gate 4_depth_check:
    - review/rules.md hooks 全 null → 跳过深度检查 ✅
    - 不报错、不阻塞输出 ✅
    - 其他 gate 步骤（1_declare, 2_enforce, 3_self_check）正常执行
验证点: hooks 为 null 时 fallback 正常工作
```

### T-FM-20：post_check 在模块执行后触发

```yaml
user_input: "今天就到这里吧"
触发: session-audit.md + session-rating.md (MUST_RUN)
expected:
  session-audit.md 执行后:
    - hooks.post_check: "审查清单每项有具体依据" → 检查审查输出 ✅
  session-rating.md 执行后:
    - hooks.post_check: "每维度评分有文档中客观依据" → 检查评分输出 ✅
验证点: post_check 在模块协议执行完毕后触发，不是在加载时触发
```

### T-FM-21：动态 hooks 与步间门控清单的关系

```yaml
user_input: "/分析 + /反脆弱 这个项目的风险"
加载模块: iterative-engine.md + antifragile.md
expected:
  - 步间门控清单（meta.md 规则 7）仍然工作
  - 动态 hooks (4_depth_check) 在所有步间门控完成后再执行
  - 两者不重复检查同一项
  - 步间门控 = 过程检查（每步完成后）
  - depth_check = 最终输出检查（Pre-Output Gate）
验证点: 步间门控和动态 hooks 互补不重复
```

---

## 七、上下文隔离验证

### T-FM-22：isolated 模块识别

```yaml
前置: 扫描所有模块的 context 字段
验证:
  context: isolated 的模块:
    - think/iterative-engine.md ✅
    - think/task-iterate.md ✅
    - deliberation/protocol.md ✅
    - collaboration/parallel-thinking.md ✅
    - review/cross-session-audit.md ✅
  context: default 的模块:
    - 其余全部 41 个模块 ✅
预期: 恰好 5 个 isolated，其余全部 default
```

### T-FM-23：isolated 模块加载时提示

```yaml
user_input: "/分析 帮我深度分析这个方案"
加载模块: iterative-engine.md (context: isolated)
expected:
  - 检测到 context == isolated
  - 声明: "⚠️ 该模块建议在隔离上下文中执行"
  - 或: 直接用 subagent 执行（Claude Code 环境）
  - 降级场景: 无法隔离 → 在当前上下文执行，但声明风险
验证点: isolated 标记被识别并提示
```

### T-FM-24：default 模块不触发隔离提示

```yaml
user_input: "/反脆弱 分析这个投资"
加载模块: antifragile.md (context: default)
expected:
  - 不出现隔离提示
  - 在当前上下文正常执行
验证点: default 模块无多余提示
```

---

## 八、Module-Evolve 验证增强

### T-FM-25：/模块迭代 包含 frontmatter 验证

```yaml
user_input: "/模块迭代 反脆弱"
expected:
  Step 2 诊断输出中包含:
    - "Frontmatter: ✅ 存在" 或 "Frontmatter: ❌ 缺失"
    - "name 一致性: ✅" 或 "❌ name={X} 但文件名={Y}"
    - "keywords 一致性: ✅" 或 "⚠️ 与 meta.md 不一致"
    - "execution_level 一致性: ✅" 或 "⚠️ 与 meta.md 不一致"
    - "摘要节: ✅ 存在" 或 "❌ 模块 ≥ 800 bytes 但无 ## 摘要"
    - "hooks 覆盖: ✅ depth_check 已定义" 或 "⚠️ MUST_RUN 模块无 depth_check"
验证点: frontmatter 验证已集成到模块迭代诊断流程
```

### T-FM-26：/模块列表 展示 frontmatter 信息

```yaml
user_input: "/模块列表"
expected:
  列表中每个模块展示:
    - 模块名（来自 frontmatter name）
    - 执行级别（来自 frontmatter execution_level）
    - 类型（来自 frontmatter type）
    - 一句话摘要（来自 frontmatter summary）
    - 合规率（来自 results.tsv）
验证点: 模块列表可以利用 frontmatter 数据展示更丰富的信息
```

---

## 九、回归验证（确保不破坏现有功能）

### T-FM-27：命令路由回归 — /反脆弱 仍然工作

```yaml
user_input: "/反脆弱 这个投资机会值不值得做"
expected:
  - 命令路由识别 "/反脆弱" → decide/antifragile.md ✅
  - 读取文件时跳过 frontmatter，从正文开始执行 ✅
  - 三元分类 + 杠铃策略 + 否定法全部执行 ✅
  - 与 S-CMD-01 场景结果一致
验证点: 添加 frontmatter 不影响命令路由
```

### T-FM-28：关键词路由回归 — 决策场景仍然触发偏差检查

```yaml
user_input: "我该不该从大厂跳出来自己创业？"
expected:
  - "该不该" 命中 think/_index.md (MUST_RUN) ✅
  - 偏差扫描正常执行 ✅
  - 与 S-GATE-01 场景结果一致
验证点: frontmatter 不干扰关键词路由
```

### T-FM-29：多 MUST_RUN 串行回归

```yaml
user_input: "帮我深度分析一下这个投资机会的风险，顺便审计一下我的投资决策系统"
expected:
  - 3 个 MUST_RUN 模块全部加载 ✅
  - 串行拆分 + 步间门控正常执行 ✅
  - 与 S-GATE-07 场景结果一致
验证点: frontmatter 不影响多 MUST_RUN 串行执行
```

### T-FM-30：边界关键词回归 — 不误触发

```yaml
user_input: "帮我写一封感谢信给投资人"
expected:
  - "投资" 为修饰语，不触发 antifragile MUST_RUN ✅
  - 意图验证正确降级为 MAY ✅
  - 与 S-GATE-08 场景结果一致
验证点: MUST_RUN 意图验证在 frontmatter 模式下仍然有效
```

### T-FM-31：Pre-Output Gate 完整流程回归

```yaml
user_input: "这个投资机会风险大不大？"
expected:
  Pre-Output Gate 全部步骤正常:
    1_declare: 声明匹配文件 ✅
    2_enforce: MUST_RUN 不执行不得输出 ✅
    3_self_check: 全部执行确认 ✅
    4_depth_check: 从 frontmatter hooks 动态聚合（不是硬编码）✅
    5_session_cap: MUST_RUN ≥ 3 建议拆会话 ✅
    6_quality_loop: 可选激活 ✅
验证点: Pre-Output Gate 6 步在动态 hooks 模式下全部正常
```

### T-FM-32：BOOT 流程回归

```yaml
user_input: "启动"
expected:
  - Phase 0-5 正常执行 ✅
  - Phase 4 加载 meta.md 路由表 ✅
  - meta.md 中新增的渐进加载规则和隔离规则被加载 ✅
  - 启动面板格式不变 ✅
验证点: BOOT 流程不受 frontmatter 改造影响
```

### T-FM-33：会话评分回归

```yaml
user_input: "今天先到这里"
expected:
  - 结束信号触发 session-audit + session-rating (MUST_RUN) ✅
  - session-audit 的 hooks.post_check 被动态聚合执行 ✅
  - session-rating 的 hooks.post_check 被动态聚合执行 ✅
  - 评分流程完整（AI评→人评→终分）✅
  - 与 H01-H05 检查项结果一致
验证点: 会话生命周期在 hooks 迁移后不受影响
```

---

## 十、异常场景与边界条件

### T-FM-34：frontmatter 损坏降级

```yaml
场景: 某模块的 frontmatter YAML 格式错误（缺闭合 ---、字段格式错误等）
expected:
  - 加载时检测到 frontmatter 解析失败
  - 降级: 忽略 frontmatter，按传统方式加载全文
  - 声明: "⚠️ {模块名} frontmatter 解析失败，降级为全量加载"
  - 模块功能不受影响（正文内容完整）
  - 记录到 runtime/audits/backlog.md
验证点: frontmatter 损坏不阻塞模块加载
```

### T-FM-35：frontmatter 与正文内容冲突

```yaml
场景: frontmatter 中 execution_level: SHOULD，但 meta.md 路由表中该模块是 MUST_RUN
expected:
  - meta.md 路由表优先（它是已有的加载逻辑入口）
  - module-evolve 诊断时标记: "⚠️ execution_level 不一致: frontmatter=SHOULD, meta.md=MUST_RUN"
  - 不静默忽略冲突
验证点: 一致性冲突被检测和报告，不导致静默降级
```

### T-FM-36：摘要节位置错误

```yaml
场景: ## 摘要 出现在文件中间（不在 frontmatter 之后）
expected:
  - 🟢 摘要加载时可能读到错误位置
  - module-evolve 诊断时标记: "⚠️ ## 摘要 位置不正确，应紧跟 frontmatter 之后"
验证点: 摘要位置异常被检测
```

### T-FM-37：空 hooks 与 null hooks 的区别

```yaml
场景: hooks 字段存在但子字段为 null
  hooks:
    pre_check: null
    post_check: null
    depth_check: null
expected:
  - Pre-Output Gate 4_depth_check 跳过该模块（fallback 规则）
  - 不报错
  - 不将 "null" 作为检查条件执行
验证点: null hooks 被正确识别为"无检查"
```

### T-FM-38：新增模块无 frontmatter 时的处理

```yaml
场景: 用户手动创建 theories/rational/think/new-module.md，未添加 frontmatter
expected:
  - meta.md 关键词路由仍然能匹配到该模块（如果路由表中已添加）
  - Pre-Output Gate 4_depth_check 跳过（无 hooks）
  - /模块迭代 new-module 时诊断报告: "❌ 缺少 frontmatter，请添加"
  - 给出 module-frontmatter-spec.md 的参考链接
验证点: 向后兼容 — 无 frontmatter 的模块不崩溃，但被标记为不合规
```

---

## 执行说明

### 测试分层

| 层级 | 测试类型 | 测试数量 | 执行方式 |
|------|---------|---------|---------|
| L1 格式 | T-FM-01 ~ T-FM-04 | 4 | 可脚本自动化（grep/YAML解析）|
| L2 一致性 | T-FM-05 ~ T-FM-07 | 3 | 脚本对比 frontmatter 与 meta.md |
| L3 覆盖 | T-FM-08 ~ T-FM-10 | 3 | 脚本 + 人工抽检 |
| L4 功能 | T-FM-11 ~ T-FM-24 | 14 | 模拟会话场景（autoevolve）|
| L5 回归 | T-FM-27 ~ T-FM-33 | 7 | 重跑现有 autoevolve 场景 |
| L6 异常 | T-FM-34 ~ T-FM-38 | 5 | 人工构造异常场景 |

### 与现有测试的关系

- **gate-enforcement.md**: S-GATE-01 ~ S-GATE-11 不变，但 4_depth_check 的验证方式变化（从硬编码变为动态聚合）
- **command-routing.md**: S-CMD-01 ~ S-CMD-11 不变，frontmatter 不影响命令路由
- **routing-accuracy.md**: S-ROUTE-01 ~ S-ROUTE-08 不变，关键词路由逻辑不变
- **new-modules.md**: S-NEW-01 ~ S-NEW-13 不变，但新增模块现在有 frontmatter
