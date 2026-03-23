# Mind OS 版本升级说明

> 格式：`## vX.Y — 日期 — 一句话标题`
> 每个版本包含：**变更摘要**、**新增/修改/删除的文件**、**升级指引**（从上一版迁移需要做什么）。

---

## v4.13 — 2026-03-24 — 输出文档模板（总纲+分章节） + 安全阀50轮

### 变更摘要

- **输出文档模板（MUST_RUN）**：总纲 + 分章节引用，强制执行
  - summary.md ≤ 800 tokens（一页纸读完：一句话结论+推荐+速览+下一步+章节链接）
  - 每章节 ≤ 1500 tokens（direction-{id}.md / adversarial-{id}.md / comparison.md）
  - 过程文件（蓝红裁决）与输出文件（总纲+章节）物理分离
  - 质量门控 D3 增加模板合规检查（summary存在/大小/必选章节/方向文件/对比表）
- **安全阀提高到 50 轮**
- **think/_index.md 更新**：迭代引擎关联输出模板

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| schemas/default/output-template.md | 🆕 输出文档模板（总纲+4种章节+强制规则） |
| theories/rational/think/iterative-engine.md | 输出规范(MUST_RUN) + 文件架构增加 output/ |
| theories/rational/think/_index.md | 迭代引擎关联 output-template.md |
| scripts/think-quality-gate.sh | D3 增加 5 项模板合规检查 |
| scripts/think-init.sh | emergency_brake: 50 |

---

## v4.12 — 2026-03-24 — 质量门控（分数不够不让收敛）

### 变更摘要

- **任务级质量门控（quality_gate）**：用户可设置 `min_score`，评分不够不允许收敛
  - 评分 Agent 读文档 grep 计算 5 维分数（零 AI 自报）
  - D1 完成度: comparison 推荐/方向数
  - D2 深度: confidence=survived/(S+F+M)
  - D3 合规: 编号/标记/本源/裁决/完整轮（5 项检查）
  - D4 效率: 收敛轮次
  - D5 可行动: 推荐+下一步+风险
  - FAIL → 输出改进建议 + 追加新一轮迭代
  - PASS → 允许收敛
- **三种设置方式**：任务级 / preferences 全局默认 / 对话中修改
- **与安全阀互动**：emergency_brake 触发时即使分数不够也终止，但标注未达标

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| scripts/think-quality-gate.sh | 🆕 从文档 grep 计算 5 维评分 + PASS/FAIL 判定 |
| theories/rational/think/iterative-engine.md | 增加 quality_gate 收敛条件 + 评分 Agent 协议 + min_score 设置 |
| scripts/think-init.sh | 增加 min_score 参数 + state.yaml 字段 |
| data-template/identity/preferences.md | 增加 default_min_score 字段 |

---

## v4.11 — 2026-03-24 — 会话评分系统 + 量化收敛

### 变更摘要

- **会话评分系统**：每次会话结束时强制评分
  - 5 维度: 任务完成度 / 分析深度 / 协议合规 / 效率 / 可行动性（各 1-5）
  - AI 自评 ×0.4 + 人类评分 ×0.6 = 加权总分
  - Stop hook 触发评分提示，收集后写入 `runtime/ratings/current.md`
  - 滚动压缩: 超 3000 bytes → 计算均分 → 归档原始 → 重置
- **收敛条件精确量化**：编号制 + grep 机械计算
  - 蓝方论点 `[B-d1r1-01]`，红方质疑 `[R-d1r1-01] [NEW] [致命]`
  - 裁决 `[SURVIVED:]` / `[FALLEN:]` / `[MODIFIED:]`
  - 所有指标由 `grep -c` 从文档中计算，零 AI 自报
  - confidence = survived / (survived + fallen + modified)
- **并行执行模型**：queue.md 增加 `{parallel: group}` 标记，同层方向并行启动

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| theories/rational/review/session-rating.md | 🆕 评分协议（5维×权重×滚动压缩） |
| scripts/hook-session-rating.sh | 🆕 Stop hook：AI 自评 + 评分提示 |
| scripts/think-rating-write.sh | 🆕 评分写入 + 滚动压缩 |
| theories/rational/think/iterative-engine.md | 编号制输出格式 + 精确量化收敛 + 并行模型 |
| scripts/think-converge-check.sh | grep 机械计算收敛指标 |
| scripts/think-init.sh | queue 并行标记 + 质量驱动收敛 |
| theories/rational/meta.md | 新增 session-rating 路由（MUST_RUN） |
| .claude/settings.json | 新增 session-rating Stop hook |

---

## v4.10 — 2026-03-23 — AutoEvolve 持续迭代（输出验证器 + 深度执行）

### 变更摘要

AutoEvolve 持续迭代 #18-27，引入**输出验证器**（blocking enforcement）和多项深度修复：

- **输出验证器 v2**（hook-output-validator.sh）：AI 输出不合规时**物理阻断**，强制重试
  - 三层检查：结构存在性 + 语义深度启发式 + 流程完整性
  - 红方深度：必须 ≥2 个质疑问题 + 不可与蓝方一致
  - 反脆弱深度：三元分类必须量化（百分比/程度/可逆性）
  - 意图降级识别：显式声明"修饰语→降级 MAY"时，验证器接受并跳过协议检查
- **Schema 写入拦截**（hook-schema-guard.sh）：PreToolUse hook 物理阻断对 constitution/identity/evaluator 的写入
- **硬性断路器**：超限后验证器阻断不含终止声明的输出
- **语言锁细化**：排除代码块后 30% 阈值检测英文输出
- **10 轮自检验证**：验证器阻断不含自检结论的输出
- **≥3 MUST_RUN 强制拆分**：验证器阻断不含拆分会话建议的输出
- **Race condition 修复**：compliance-check 不再删除 marker 文件

### 合规率提升

| 维度 | v4.9 | v4.10 |
|------|------|-------|
| 加权平均 | ~957/1000 | **~970/1000** |
| S-GATE-07 三重协议 | 93% | **97%**（强制拆分） |
| S-SESSION-01 语言锁 | 94% | **97%**（深度检测） |
| S-SESSION-05 断路器 | 93% | **97%**（blocking） |

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| scripts/hook-output-validator.sh | 🆕→v2: 三层检查 + 深度启发式 + 意图降级 + 断路器 + 自检 + 语言锁 + 拆分 |
| scripts/hook-schema-guard.sh | 🆕 PreToolUse: 拦截 schema/identity/evaluator 写入 |
| scripts/hook-must-run-check.sh | v3: 写入 marker + ≥3 协议强制拆分 |
| scripts/hook-turn-counter.sh | v2: 硬性断路器（写标记文件） |
| scripts/hook-compliance-check.sh | 修复 race condition（不再删除 marker） |
| .claude/settings.json | 新增 PreToolUse hook + output-validator |

---

## v4.9 — 2026-03-23 — AutoEvolve 第一轮迭代成果（规则+Hooks 三层修复）

### 变更摘要

AutoEvolve 第一轮完整迭代，跑了 30 个场景、17 轮实验，识别并修复了 3 个致命缺陷：

- **Fix 1: MUST_RUN 意图验证**（meta.md 规则 6）：关键词命中后追加意图检查，修饰语/背景降级为 MAY
  - 误触发率 20% → ~5%
- **Fix 2: 多 MUST_RUN 串行拆分 + 步间门控**（meta.md 规则 7）：≥2 个 MUST_RUN 串行执行，每步清单自检
  - 三重协议全执行率 5% → ~83%
- **Fix 3: 轮次标记机械注入**（protocols.md 规则 6 + hook-turn-counter.sh）：外部 Hook 每轮注入 [轮次 N/limit]
  - 10 轮自检率 5% → ~92%，断路器 10% → ~90%
- **新增执行深度检查**（protocols.md 4_depth_check）：防止走形式——红方必须有真分歧，三元分类必须量化
- **新增会话 MUST_RUN 上限**（protocols.md 5_session_cap）：≥3 个建议拆会话，宁拆保深度
- **Hooks 升级**：hook-must-run-check.sh v2（意图验证+串行提醒）、新增 hook-turn-counter.sh、hook-compliance-check.sh、hook-session-reset.sh

### 合规率提升

| 维度 | 修复前 | 修复后 |
|------|--------|--------|
| 加权平均合规率 | ~53% | ~86% |
| 最弱场景（三重MUST_RUN） | 5% | ~68% |
| 最大提升（10轮自检） | 5% | ~92% |

### 修改文件

| 文件 | 变更 |
|------|------|
| theories/rational/meta.md | 新增规则 6（意图验证）、规则 7（串行拆分+步间门控+清单） |
| schemas/default/protocols.md | Pre-Output Gate 增加意图验证例外、深度检查、会话上限；轮次标记规则；AI缺陷免疫表增加 4 项 |
| scripts/hook-must-run-check.sh | v2: 意图验证提醒+串行提醒 |
| scripts/hook-turn-counter.sh | 🆕 外部轮次计数+自检触发+断路器 |
| scripts/hook-compliance-check.sh | 🆕 Stop hook: 合规标记检查 |
| scripts/hook-session-reset.sh | 🆕 会话启动时重置计数器 |
| .claude/settings.json | 新增 3 个 hook 配置 |
| autoevolve/evaluator.md | C06 更新（默认对话输出） |
| autoevolve/results.tsv | 17 轮实验记录 |

### 升级指引

- Hooks 自动生效（settings.json 已配置）
- 无数据迁移需求
- 轮次计数器状态文件: runtime/.turn-counter（自动创建）

---

## v4.8 — 2026-03-23 — AutoEvolve 自迭代引擎

### 变更摘要

- **新增 AutoEvolve 自迭代引擎**：参考 Karpathy autoresearch 的闭环机制，为 Mind OS 设计自动化合规优化循环
  - **三文件契约**：evaluator.md（不可变尺子）+ program.md（人类方向）+ 可变资产（BOOT/protocols/meta）
  - **标量指标**：compliance_score = (passed_checks / total_checks) × 1000，目标 ≥ 999
  - **40 项检查清单**：覆盖启动(10) + 路由(8) + 门控(10) + 会话(7) + 宪法(5)
  - **30 个测试场景**：boot-flow(4) + gate-enforcement(8) + session-rules(10) + routing-accuracy(8)
  - **五阶段收敛**：baseline → 修致命项 → 修高权重 → 打磨 → 压力测试
  - **accept/reject 闭环**：git commit 保留改善，git reset 回滚退化
  - **防退化机制**：每次 KEEP 后全场景回归 + 复杂度预算自动检查
- **三种执行模式**：全自动（Agent 闭环）、逐轮人工、批量+审批

### 新增文件

| 文件 | 说明 |
|------|------|
| autoevolve/program.md | 人类元指令（方向控制） |
| autoevolve/evaluator.md | 合规评估器（40 项检查清单） |
| autoevolve/loop.md | 迭代循环协议（主引擎） |
| autoevolve/results.tsv | 实验日志 |
| autoevolve/README.md | 快速指南 |
| autoevolve/scenarios/boot-flow.md | 启动流程场景 × 4 |
| autoevolve/scenarios/gate-enforcement.md | 门控执行场景 × 8 |
| autoevolve/scenarios/session-rules.md | 会话规则场景 × 10 |
| autoevolve/scenarios/routing-accuracy.md | 路由精度场景 × 8 |

### 升级指引

- 新增目录，无迁移需求
- 可选启用：执行 `claude "读取 autoevolve/loop.md，执行完整迭代循环"` 即可开始

---

## v4.7 — 2026-03-24 — Pre-Output Gate + Hooks 强制执行

### 变更摘要

- **新增输出前门控（Pre-Output Gate）**：解决"加载 ≠ 执行"的致命架构漏洞
  - BOOT.md Phase 5 增加 ④ 门控步骤：匹配即执行，无例外
  - meta.md 路由表增加执行级别列：MUST_RUN / SHOULD / MAY
  - protocols.md 增加强制执行规则 + 任务分级（轻量/标准/深度）
  - AI 缺陷免疫表增加"走捷径"免疫
- **3 个 Claude Code Hooks（技术层强制）**：
  - **Stop hook**：queue.md 有 [TODO] 时阻止 AI 停止，强制继续执行
  - **PostCompact hook**：上下文压缩后自动注入"读 context.md 恢复"指令
  - **UserPromptSubmit hook**：扫描 MUST_RUN 关键词，注入强制执行提醒到 AI 上下文
- **关键词精度优化**：迭代引擎 / 决策偏差关键词更精确
- **设计原则**：协议约束（protocols.md）+ 技术强制（hooks）双保险

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| .claude/settings.json | 🆕 3 个 hooks 配置（Stop/PostCompact/UserPromptSubmit） |
| scripts/hook-stop-guard.sh | 🆕 Stop hook：阻止有未完成任务时停止 |
| scripts/hook-post-compact.sh | 🆕 PostCompact hook：压缩恢复指令注入 |
| scripts/hook-must-run-check.sh | 🆕 UserPromptSubmit hook：MUST_RUN 关键词扫描 |
| BOOT.md | Phase 5 增加 ④ 输出前门控 |
| schemas/default/protocols.md | 增加 Pre-Output Gate 规则 + 走捷径免疫 |
| theories/rational/meta.md | 路由表增加执行级别列 + 关键词优化 |

### 升级指引

- 需将 `.claude/settings.json` 放到项目根目录
- hooks 脚本在 `mind-os/scripts/hook-*.sh`，需有执行权限

---

## v4.6 — 2026-03-23 — 迭代思考引擎（Agent + 文件驱动 + 红蓝对抗）

### 变更摘要

- **新增迭代思考引擎**：多方向 × 多轮次的发散-收敛思考
  - **架构：Agent + 文件驱动**——每轮迭代零上下文假设，所有状态在文件中
  - **红蓝对抗**：每个方向每轮 = 蓝方(正向论证) → 红方(质疑挑刺) → 裁决(综合双方)
  - state.yaml 唯一真相源 + manifest.md 任务定义 + 每轮 round-*.md 存档
  - 信息完整度自动评估 → 方向数(1-5)和迭代深度(2-4轮)自校准
  - 预设应答规则（ai_decide / top_n / all_directions / conservative / custom）
  - 超时自动继续（think-timer.sh 计时 + think-orchestrator.sh 编排）
  - 三种收敛条件：饱和(相似度>80%) / 达标(用户确认) / 预算(轮次上限) + 红方击杀
  - 最终输出 5 维比较报告 + 对抗强度摘要（存活率越高排名越高）
- **宪法第四条（铁律）**：一切思考必须指向本源，红方首要质疑方向永远是本源检查
- **上下文抗丢失**：跨会话恢复、崩溃恢复、并行任务隔离全由文件保证
- **新增脚本**：think-init.sh（初始化）+ think-timer.sh（计时）+ think-orchestrator.sh（编排）+ think-loop-check.sh（轮询）
- **preferences.md 扩展**：增加 auto_reply_rules 迭代思考设置

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| theories/rational/think/iterative-engine.md | 🆕 迭代引擎核心规则（Agent+文件架构） |
| scripts/think-init.sh | 🆕 任务初始化（校准公式 + 生成 state.yaml） |
| scripts/think-orchestrator.sh | 🆕 编排器（状态机：9 种转换） |
| scripts/think-timer.sh | 🆕 超时计时器 |
| scripts/think-loop-check.sh | 🆕 /loop 状态轮询 |
| data-template/identity/preferences.md | 增加 auto_reply_rules 字段 |
| theories/rational/think/_index.md | 增加迭代引擎路由 |
| theories/rational/meta.md | 增加迭代引擎路由 + 模块数 15→16 |
| tests/iterative-engine-tests.md | 🆕 50 个测试用例 |

### 升级指引

- 已有用户需手动将 auto_reply_rules 配置添加到自己的 preferences.md
- scripts/ 为新增目录，无迁移需求

---

## v4.5 — 2026-03-23 — 复杂度预算重构

### 变更摘要

- **宪法第三条重构**：复杂度预算从"存储时"转移到"运行时"
  - 取消 theory ≤ 15 模块的预存硬上限
  - 新增运行时约束：单次加载 ≤ 3 个 theory 文件
  - 单文件 ≤ 1000 tokens（原 300 tokens，不可执行）
  - 路由表 meta.md ≤ 2000 tokens
- **上下文总预算**：schema(≤2000) + meta.md(≤2000) + theory(≤3×1000) + domain(≤1000) = ≤8000 tokens/任务

### 修改文件

| 文件 | 变更 |
|------|------|
| schemas/default/constitution.md | 第三条重写 |
| theories/rational/meta.md | 加载规则更新（上限3文件、1000 tokens） |
| runtime/dashboard.md | theory_modules 字段更新 |
| domains/_router.md | 复杂度预算说明更新 |
| theories/rational/README.md | 模块结构标题更新 |
| test.sh | 相关断言更新 |
| tests/architecture-tests.md | T-ORTH-05 更新 |

### 升级指引

- 无需迁移，向后兼容
- 现有 theory 文件超过 1000 tokens 的建议逐步精简或拆分

---

## v4.4 — 2026-03-23 — 启动体验优化

### 变更摘要

- **schema 文件合并**：6 个文件合并为 2 个（constitution.md + protocols.md），启动读取量减半
- **首次安装选项化**：5 个逐一提问 → 8 个选项化问题一次展示，所有问题允许跳过
- **新增通用背景采集**：行业/团队规模/当前阶段/专业技能
- **去掉金额决策门槛**：不再在初始化时询问
- **启动面板可视化**：用框架图替代纯文字确认
- **新增引导菜单**：启动后展示 5 选菜单（描述任务/设焦点/了解功能/应用场景/关于项目）
- **新增体验示例**：提供预设任务让新用户快速上手
- **profile.md 模板扩展**：增加 industry、team_size、current_stage、skills 字段

### 文件变更

| 操作 | 文件 |
|------|------|
| 合并 | `metrics.md` → 内容合入 `constitution.md` |
| 合并 | `symbiosis.md` + `pipeline.md` + `iteration.md` + `conventions.md` + `dynamics.md` → `protocols.md` |
| 删除 | `schemas/default/metrics.md`、`symbiosis.md`、`pipeline.md`、`iteration.md`、`conventions.md`、`dynamics.md` |
| 修改 | `BOOT.md`（选项化安装 + 可视化面板 + 引导菜单） |
| 修改 | `data-template/identity/profile.md`（增加背景字段） |
| 修改 | `data-template/identity/preferences.md`（去掉 large_amount_threshold） |
| 修改 | `config.md`（version 4.3 → 4.4） |
| 修改 | `examples/first-session.md`（适配新启动流程） |

### 从 v4.3 升级

1. 无需迁移数据——data/ 结构兼容
2. schema/ 从 7 个文件变为 2 个，如有自定义 schema 需要手动合并
3. profile.md 新增 4 个字段（industry/team_size/current_stage/skills），老用户留空即可

---

## v4.3 — 2026-03-23 — 双入口分发 + 智能数据检测

### 变更摘要

- **新增 SKILL.md**：适配 Claude Skill 生态，支持关键词触发（"启动 Mind OS"）
- **新增 CLAUDE.md**：放在项目根目录，实现会话自动启动，零操作
- **archive/ 移出分发包**：设计历史文档不再随系统分发，仅开发者保留
- **数据目录三步检测**：Phase 0 从"不存在就创建"改为"检测默认路径 → 询问是否有其他位置 → 都没有才创建"
- **子目录按需创建**：data/ 下的 content/、knowledge/、archive/ 不再预创建空目录

### 文件变更

| 操作 | 文件 |
|------|------|
| 新增 | `SKILL.md`、`../CLAUDE.md` |
| 新增 | `CHANGELOG.md`（本文件） |
| 修改 | `config.md`（加入 version 字段） |
| 修改 | `BOOT.md`（三入口兼容 + 三步数据检测 + 按需创建子目录） |
| 修改 | `SETUP.md`（三种安装方式：自动/手动/Skill） |
| 修改 | `README.md`（文件索引加入 CLAUDE.md 和 SKILL.md） |
| 移出 | `archive/` → 项目根目录（不在 mind-os/ 内） |

### 从 v4.2 升级

1. 无需迁移数据——data/ 结构未变
2. 把 `CLAUDE.md` 放到 mind-os/ 的上级目录即可获得自动启动
3. archive/ 如果不需要可以删掉，不影响系统运行

---

## v4.2 — 2026-03-23 — 系统落地：从文档到可执行文件系统

### 变更摘要

- **四文档拆为 ~50 个可执行文件**，组织为目录结构
- **新增 BOOT.md**：AI 唯一入口，6 阶段启动协议
- **schema/ 拆为 7 个文件**：constitution、metrics、pipeline、symbiosis、dynamics、iteration、conventions
- **theory/ 拆为模块化文件**：meta.md 路由表 + 按需加载
- **新增 domains/_router.md**：任务关键词→领域映射
- **新增 data-template/**：首次安装自动复制模板
- **新增 runtime/**：focus.md + dashboard.md
- **config.md 单点切换**：schema/theory/data 三维独立配置
- **data/ 移出 mind-os/**：用户数据物理隔离，迁移成本 O(0)
- **傻瓜安装**：2 步完成，AI 自动检测首次使用并引导配置

### 从 v4.1 升级

v4.1 是设计文档，v4.2 是可执行系统。这是全新形态，无法增量迁移——直接使用新系统，旧文档归入 archive/。

---

## v4.1 — 2026-03-23 — 协作拓扑整合

### 变更摘要

- **注入协作拓扑**：4 种模式（谁主导）× 3 种拓扑（怎么交互：串联/并联/迭代）
- **五维评估**：自主性、认知负荷、方案多样性、执行效率、学习速率
- **协作增益率**：新增冻结指标，协作结果须系统性超越单方
- **人-AI 本质差异**：偏差同构表，14 项 AI 偏差对应人类偏差
- **并联加权 ≡ BWDM**：方法 D 发现同构，统一为权重框架

### 从 v4.0 升级

协作维度嵌入 Schema 的 symbiosis 部分，不新增模块，维持 15/15 复杂度预算。

---

## v4.0 — 2026-03-23 — 三层正交分离

### 变更摘要

- **核心审计发现**：v3.13 文档本身违反最高法则——schema/theory/data 三层耦合
- **拆分为四文件**：Schema（纯架构）、Theory-Pack（可替换方法论）、Data-Template（角色无关）、Design-Notes（推导记录）
- **总行数从 2330 压缩到 ~1200**，冗余消除
- **换人 O(1)、换理论 O(1)**："CEO"从出现 30+ 次降为 0 次

### 从 v3.13 升级

全新架构，不兼容旧版。旧版 Mind-OS-v3.13 归档为设计历史。

---

## v3.13 及更早 — 原始版本

详见 `archive/` 目录中的历史文档：

- `Mind-OS-v3.13-original.md` — 最终单体文档（2330 行）
- 经历 Layer 0 → Layer 16 共 17 轮审计迭代
- 融合 11 本书 + 6 套理论的认知框架
- 完整推导过程见 `DESIGN-NOTES.md`

---

## 版本号规则

```
主版本.次版本
  │       └── 功能迭代（新模块、新机制、文件重组）
  └────────── 架构变更（schema/theory/data 结构性调整）
```

- **主版本升级**（如 3→4）：架构不兼容，需要重新理解系统
- **次版本升级**（如 4.2→4.3）：向后兼容，增量更新即可

发布检查清单：
1. 更新 `config.md` 的 `version:` 字段
2. 在本文件顶部新增版本条目
3. 确保 BOOT.md 启动确认模板能正确显示新版本号
