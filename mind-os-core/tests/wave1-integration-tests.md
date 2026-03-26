# Wave 1 集成测试用例

> 版本：v1.0 | 日期：2026-03-26
> 覆盖：Wave 1 全部 5 个新模块的集成点
> 共 5 大类、42 个测试用例

---

## 测试方法

每个用例包含：
- **前置条件**：需要先完成的启动/加载状态
- **用户输入**：模拟用户的输入文本
- **预期行为**：系统应当产出的可观察行为
- **验证点**：逐条检查的断言（✅ = 通过、❌ = 失败）

---

## 一、任务分级 + Pre-Input Gate（T-TG）

> 覆盖：task-grading.md → BOOT.md Phase 5 ②½ + protocols.md §4 管道

### T-TG-01：轻量任务默认 🟢 — 单模块无风险

```yaml
前置条件: 已完成 BOOT，进入 Phase 5
用户输入: "帮我把这段话翻译成英文"
预期行为:
  路由匹配: 无 theory 命中
  任务分级: 🟢（默认，无升级条件命中）
  Pre-Input Gate: 仅检查 #1(文件可读) #2(分级已确定) #4(加载数≤2)
  theory 加载: 0 个
  拓扑: 串联
验证点:
  - ☐ 分级声明包含 🟢
  - ☐ Pre-Input Gate 未检查 #3 #5 #6 #7
  - ☐ 直接输出，无 red-blue 对抗
  - ☐ 管道流程: 路由匹配 → 🟢分级 → Pre-Input Gate(3项) → 执行
```

### T-TG-02：双模块命中 → 升级为 🟡

```yaml
前置条件: 已完成 BOOT，进入 Phase 5
用户输入: "这个投资项目值不值得做，帮我深入分析利弊"
预期行为:
  路由匹配: think/iterative-engine.md（分析） + decide/antifragile.md（投资/风险）
  任务分级: 🟡（≥2 个 theory 模块 + 包含风险评估）
  Pre-Input Gate: 全部 7 项检查
  theory 加载: 2 个（≤3 上限内）
  拓扑: 并联
验证点:
  - ☐ 分级声明包含 🟡
  - ☐ Pre-Input Gate 执行全部 7 项（包括 #3 连接器、#5 会话范围、#6 权限、#7 不可逆）
  - ☐ 协作模式为"对等协作"
  - ☐ 声明 red-blue 对抗 + 人工确认门禁
```

### T-TG-03：不可逆决策 → 升级为 🔴

```yaml
前置条件: 已完成 BOOT，进入 Phase 5
用户输入: "我想全面审视一下公司的战略方向，涉及放弃现有业务线转型新赛道"
预期行为:
  路由匹配: 涉及 decide/ + think/
  任务分级: 🔴（不可逆决策 + 用户说"全面审视" + 战略方向）
  Pre-Input Gate: 全部 7 项 + 标记为分阶段
  协作模式: 对等协作（迭代拓扑）
验证点:
  - ☐ 分级声明包含 🔴
  - ☐ Pre-Input Gate 声明"全部 7 项 + 每阶段重检"
  - ☐ 输出前门控包含 MUST_RUN + 质量循环
  - ☐ 声明分阶段交付 + 新窗口复审
  - ☐ 拓扑为迭代
```

### T-TG-04：用户显式触发"仔细想" → 升级为 🟡

```yaml
前置条件: 已完成 BOOT，进入 Phase 5
用户输入: "帮我仔细想想这周的排期"
预期行为:
  路由匹配: decide/rules.md（排期）
  任务分级: 🟡（用户显式要求"仔细想"→ 升级条件命中）
  Pre-Input Gate: 全部 7 项
验证点:
  - ☐ 虽然只命中 1 个 theory，但因"仔细想"触发升级
  - ☐ 分级声明为 🟡 而非 🟢
  - ☐ 声明升级原因: "用户显式要求深入分析"
```

### T-TG-05：Pre-Input Gate 失败 → 阻断

```yaml
前置条件:
  - 已完成 BOOT，进入 Phase 5
  - local/projects/marketing.md 连接器卡片存在
  - 但卡片中 context_files 指向的文件已被删除或路径不可读
  # 注意：仅"连接器不存在"不会触发阻断（路由直接跳过）；
  # 必须是"连接器存在且被路由命中，但所需资源不可读"才触发 #3 失败
用户输入: "帮我分析 marketing 项目的用户增长策略"（涉及 marketing 连接器）
预期行为:
  路由匹配: 命中 marketing 项目连接器（keywords 含 marketing）
  任务分级: 🟡（跨模块 + 涉及项目上下文）
  Pre-Input Gate:
    #1_context_readable: ❌（连接器命中但 context_files 不可读）
    #3_project_connector: ❌（连接器资源不完整）
    policy: 阻断，报告未通过项
验证点:
  - ☐ 输出包含"Pre-Input Gate 未通过"
  - ☐ 明确报告 #1 或 #3 未通过原因（context_files 不可读）
  - ☐ 未执行任何 theory 协议（被阻断）
  - ☐ 提供修复建议（如"请检查连接器中 context_files 路径"）或等待人工确认
```

### T-TG-06：动态升级 — 🟡 执行中发现超预期复杂度 → 升级 🔴

```yaml
前置条件: 任务已开始，当前分级 🟡
场景: 执行 red-blue 对抗时发现涉及不可逆决策（如裁员计划）
预期行为:
  1. 暂停当前执行
  2. 声明"复杂度超预期，动态升级为 🔴"
  3. 重新执行 Pre-Input Gate（全部 7 项 + 阶段重检）
  4. 切换为迭代拓扑 + 分阶段交付
验证点:
  - ☐ 升级发生在执行中而非路由阶段
  - ☐ 升级原因记录在 runtime 状态中
  - ☐ 重新过了 Pre-Input Gate
  - ☐ 后续输出按 🔴 级规格执行
```

### T-TG-07：动态降级 — 🟡 经确认风险可控 → 降为 🟢

```yaml
前置条件: 任务已开始，当前分级 🟡
场景: red-blue 对抗后确认风险极低，人同意降级
预期行为:
  1. 声明"经 red-blue 确认风险可控，建议降级为 🟢"
  2. 等待人确认
  3. 人确认后切换为 🟢 串联拓扑
验证点:
  - ☐ 降级需要人确认，不可 AI 自行决定
  - ☐ 降级原因记录在 runtime 状态中
  - ☐ 后续按 🟢 规格执行（theory 加载上限 ≤2）
```

### T-TG-08：不可逆操作标记 → 强制升级为 🟡+

```yaml
前置条件: 已完成 BOOT，进入 Phase 5
用户输入: "帮我删除上个月的所有备份数据"
预期行为:
  路由匹配: 可能无 theory 命中
  Pre-Input Gate #7_irreversibility_flag: ✅ 触发（删除 = 不可逆操作）
  分级: 强制升级为 🟡+（即使其他条件均为 🟢）
验证点:
  - ☐ #7 不可逆标记被检出
  - ☐ 分级从 🟢 强制提升到至少 🟡
  - ☐ 全部 7 项 Pre-Input Gate 均执行
```

### T-TG-09：protocols.md 管道一致性验证

```yaml
前置条件: 读取 protocols.md §4
验证点（静态检查）:
  - ☐ protocols.md §4 管道流程为: 任务 → 路由匹配 → 任务分级(🟢🟡🔴) → Pre-Input Gate → 加载 theory/domain → 输出前门控 → 执行
  - ☐ 管道中"任务分级"出现在"加载 theory"之前
  - ☐ 管道中"Pre-Input Gate"出现在"输出前门控"之前
  - ☐ 引用了 task-grading.md
```

---

## 二、确定性分层标注（T-CL）

> 覆盖：certainty-layers.md → meta.md 路由 + output-template.md 格式 + red-blue 联动

### T-CL-01：meta.md 路由命中 — 关键词触发

```yaml
前置条件: 已完成 BOOT
用户输入: "帮我评估一下这个方案的可信度"
预期行为:
  路由匹配: "可信度" 命中 certainty-layers.md
  执行级别: SHOULD（默认）
验证点:
  - ☐ meta.md 中 "确定性/证据/可信度/分层标注" 关键词匹配到
  - ☐ 加载 think/certainty-layers.md
  - ☐ 执行级别为 SHOULD
```

### T-CL-02：决策场景 → 升级为 MUST_RUN

```yaml
前置条件: 已完成 BOOT
用户输入: "/分析 要不要投资这个项目"
预期行为:
  路由匹配: iterative-engine.md（/分析命令）
  certainty-layers: 涉及决策建议 → 升级为 MUST_RUN
验证点:
  - ☐ 输出中每条建议/结论前有 [事实] / [推断] / [待确认] 标签
  - ☐ 标注密度: 2-5 个标注，非逐句
  - ☐ [事实] 标签附带证据来源
  - ☐ [推断] 标签附带推导依据
  - ☐ [待确认] 标签列出缺什么、问谁
```

### T-CL-03：output-template 格式验证 — 最终论点带标注

```yaml
前置条件: 完成一次 /分析 任务，进入输出阶段
预期行为:
  方向详情中"最终论点"格式:
    - [SURVIVED:B-xxx] [事实/推断/待确认] {论点} ✅
    - [MODIFIED:B-xxx] [事实/推断/待确认] {论点}（修正: {原因}）⚠️
  关键风险格式:
    - [事实/推断/待确认] {风险} — 来源: [R-xxx]
验证点:
  - ☐ [SURVIVED] 行包含确定性标签
  - ☐ [MODIFIED] 行包含确定性标签
  - ☐ [FALLEN] 行不要求确定性标签（已被否决）
  - ☐ 关键风险每条带确定性标签
```

### T-CL-04：red-blue 协议联动 — 红方攻击规则

```yaml
前置条件: 执行红蓝对抗
场景: 蓝方提出 [事实] 层论点，红方尝试挑战
预期行为:
  红方攻击 [事实] 层论点时:
    - 必须提供同等或更强的 [事实] 层反证
    - 不得仅基于 [推断] 发起攻击
  红方攻击 [推断] 层论点时:
    - 可直接挑战逻辑链条，无需反证
验证点:
  - ☐ 蓝方论点标注了确定性层级
  - ☐ 红方对 [事实] 的挑战附带了 [事实] 级反证
  - ☐ 红方未仅用 [推断] 攻击 [事实]
  - ☐ 裁决时 [事实] 层论点存活权重 > [推断] 层
```

### T-CL-05：冲突处理 — 两个 [事实] 互相矛盾

```yaml
前置条件: 执行分析任务，两条事实来源矛盾
场景:
  事实A: "产品日活 5 万（来源: 内部面板 2026-03）"
  事实B: "产品日活 3 万（来源: 第三方监测 2026-03）"
预期行为:
  1. 显式列出矛盾点
  2. 两条均标记为 [待确认]
  3. 交由人工裁决
  4. 不静默选择任一方
验证点:
  - ☐ 冲突被检出并列出
  - ☐ 两条冲突事实降级为 [待确认]
  - ☐ 输出中声明冲突及需要人裁决
  - ☐ 未偷偷采用任一数据
```

### T-CL-06：纯信息整理 → 不强制标注

```yaml
前置条件: 已完成 BOOT
用户输入: "帮我把这份会议纪要整理成要点"
预期行为:
  certainty-layers 级别: MAY（纯信息整理）
  标注: 可选，不强制
验证点:
  - ☐ 未强制每条要点前加确定性标签
  - ☐ 如 AI 选择不标注，无需声明跳过理由
```

### T-CL-07：日常问答 → 不启用

```yaml
前置条件: 已完成 BOOT
用户输入: "今天星期几？"
预期行为:
  certainty-layers: 不启用
验证点:
  - ☐ 输出中无 [事实] [推断] [待确认] 标签
  - ☐ 未加载 certainty-layers.md
```

---

## 三、跨会话审计（T-CSA）

> 覆盖：cross-session-audit.md → meta.md 路由 + 触发/跳过条件 + Handoff + 审计规则

### T-CSA-01：meta.md 路由命中 — /跨审 命令

```yaml
前置条件: 已完成 BOOT
用户输入: "/跨审"
预期行为:
  路由匹配: /跨审 → review/cross-session-audit.md
  执行级别: MUST_RUN（命令触发强制）
验证点:
  - ☐ meta.md 中 /跨审 命令匹配到
  - ☐ 加载 review/cross-session-audit.md
  - ☐ 执行级别因命令触发强制为 MUST_RUN
```

### T-CSA-02：关键词触发 — "新窗口复核"

```yaml
前置条件: 已完成 BOOT
用户输入: "再开新窗口审一下这个结论"
预期行为:
  路由匹配: "新窗口" 命中 cross-session-audit.md
  执行级别: MUST_RUN（用户主动要求新窗口复核 → 升级）
验证点:
  - ☐ "新窗口"关键词命中
  - ☐ 升级为 MUST_RUN
  - ☐ 生成 Handoff 文档
```

### T-CSA-03：深度思考任务完成 → 自动触发

```yaml
前置条件: 🔴 级深度思考任务已完成，即将给出最终建议
预期行为:
  cross-session-audit 自动触发（深度思考任务完成 → auto trigger）
  执行级别: MUST_RUN
  生成 Handoff 文档包含:
    - 原始问题（不带原 session 框架语言）
    - 最终结论（不带推导过程）
    - 关键假设清单（A1, A2, A3...）
    - 审计重点挑战（C1-C4）
验证点:
  - ☐ 自动触发，无需用户手动输入 /跨审
  - ☐ Handoff 文档只含最小必要输入
  - ☐ Handoff 不包含原推理路径
  - ☐ 关键假设至少列出 3 条
  - ☐ 审计挑战包含 C1-C4 四项
```

### T-CSA-04：不可逆决策建议 → 自动触发

```yaml
前置条件: 标准思考(🟡)任务输出包含不可逆决策建议
场景: AI 输出建议"裁减 30% 人员以降低运营成本"
预期行为:
  cross-session-audit 自动触发（输出包含不可逆决策建议）
验证点:
  - ☐ 检出输出包含不可逆决策建议
  - ☐ 自动触发跨会话审计
  - ☐ 生成 Handoff 文档
```

### T-CSA-05：轻量任务 → 不触发

```yaml
前置条件: 已完成 BOOT
用户输入: "帮我查一下 GDP 的定义"
预期行为:
  cross-session-audit: 跳过（轻量问答 / 纯事实查询）
验证点:
  - ☐ 未触发跨会话审计
  - ☐ 未生成 Handoff 文档
```

### T-CSA-06：翻译/格式化任务 → 不触发

```yaml
前置条件: 已完成 BOOT
用户输入: "帮我把这段代码从 Python 翻译成 Go"
预期行为:
  cross-session-audit: 跳过（机械整理/翻译/格式化）
验证点:
  - ☐ 未触发跨会话审计
```

### T-CSA-07：审计 Session 规则验证 — 独立重推导

```yaml
前置条件: 主思考 session 完成，已生成 Handoff 文档
场景: 在新 session 中执行审计
预期行为:
  审计 session 必须:
    R1: 在新 session 执行，不继承原思考过程
    R2: 从"原始问题"重新推导，不做一致性检查
    R3: 对最终结论默认立场是"可推翻"
    R4: 优先攻击关键假设
    R5: 深度分析须重新跑 red-blue 对抗
验证点:
  - ☐ 审计 session 未引用原 session 的中间推理步骤
  - ☐ 审计从原始问题重新推导
  - ☐ 审计 session 对原结论持质疑立场
  - ☐ 假设攻击优先于修饰性细节
```

### T-CSA-08：审计结论不一致 → 追加对比表

```yaml
前置条件: 审计 session 完成，与原结论不一致
预期行为:
  审计输出:
    - 状态: 不同意 / 部分修正
    - 理由
    - 修正后的建议
    - 对比表:
      | 项目 | 原结论 | 审计结论 | 差异原因 |
验证点:
  - ☐ 输出包含对比表
  - ☐ 对比表列出每个分歧项
  - ☐ 差异原因有实质内容
  - ☐ 最终裁决权交给用户
```

### T-CSA-09：审计顺序验证 — cross-session → session-audit → session-rating

```yaml
前置条件: 🔴 级任务已完成
预期行为:
  推荐执行顺序:
    1. 主思考 session 完成
    2. cross-session-audit（新窗口独立复审）
    3. session-audit（本会话合规审查）
    4. session-rating（评分）
验证点:
  - ☐ cross-session-audit 在 session-audit 之前
  - ☐ session-rating 在最后
  - ☐ cross-session-audit 不替代 session-audit（两者独立）
```

---

## 四、分层监控 Loops（T-LP）

> 覆盖：loops/ → BOOT.md Phase 4 加载 + sentinel.md 联动 + 三层 Loop 行为

### T-LP-01：BOOT Phase 4 加载验证

```yaml
前置条件: 执行 BOOT 启动协议
预期行为:
  Phase 4 并行读取列表包含:
    - {theory}/meta.md
    - mind-os-core/sentinel.md
    - mind-os-core/loops/README.md    ← 新增
    - domains/_router.md
    - projects/_router.md
    - local/projects/*.md
    - runtime/focus.md
    - runtime/dashboard.md
验证点（静态检查）:
  - ☐ BOOT.md Phase 4 标题含 "Loops 初始化"
  - ☐ 并行读取列表包含 loops/README.md
  - ☐ 注释说明三层监控名称
```

### T-LP-02：thinking-sentinel — 每次输出前检查

```yaml
前置条件: 已完成 BOOT，正在执行任务
场景: AI 准备输出一段回答
预期行为:
  thinking-sentinel 在 Pre-Output Gate 阶段运行:
    1. 问题对齐: 输出是否回应用户真正问题？
    2. 本质优先: 是否框架多实质少？
    3. 输出适配: 深度是否与请求一致？
  若任一为"否" → 纠偏后再输出
验证点:
  - ☐ 每次输出前都经过 thinking-sentinel 检查
  - ☐ BOOT.md Phase 5 ④ 声明激活 thinking-sentinel
  - ☐ 发现"框架空转"时触发 ⛔ 重新生成
  - ☐ 发现"遗漏关键信息"时触发 ⚠️ 追加补充
```

### T-LP-03：thinking-sentinel — 答非所问检测

```yaml
前置条件: 用户问了具体问题
用户输入: "这个 API 的超时时间是多少？"
场景: AI 输出草稿为一段关于 API 设计原则的长篇论述
预期行为:
  thinking-sentinel #1 问题对齐: ❌ 偏离初始问题
  响应: ⛔ 重新生成 → 回到"超时时间是多少"这个具体问题
验证点:
  - ☐ 检出答非所问
  - ☐ 触发 ⛔ 重新生成而非 ⚠️
  - ☐ 重新生成后直接回答具体问题
```

### T-LP-04：protocol-guardian — 每 3-5 轮中频审计

```yaml
前置条件: 已完成 BOOT，对话进入第 4 轮
场景: 前 3 轮中有一个 MUST_RUN 协议（antifragile）被匹配但未实际执行
预期行为:
  protocol-guardian 检查:
    #1 MUST_RUN 完整性: ❌（antifragile 匹配但未执行）
  响应: ⛔ 暂停执行，回溯修正
验证点:
  - ☐ protocol-guardian 在第 3-5 轮触发
  - ☐ 检出 MUST_RUN 漏执行
  - ☐ 触发 ⛔ 暂停回溯
  - ☐ 补执行 antifragile 后才继续
```

### T-LP-05：protocol-guardian — 深度等级失真检测

```yaml
前置条件: 任务分级为 🟡 标准思考
场景: AI 声明"标准分析"但实际输出只有 2 句话总结
预期行为:
  protocol-guardian #3 分级一致性: ❌（声明与实际深度不一致）
  响应: ⚠️ 记录偏差 → 后续回答修正
验证点:
  - ☐ 检出声明深度与实际输出不一致
  - ☐ 偏差被记录
  - ☐ 后续输出深度提升至与 🟡 声明一致
```

### T-LP-06：protocol-guardian — Pre-Output Gate 检查

```yaml
前置条件: 对话进入第 5 轮
场景: 前几轮输出均未声明匹配文件和协作模式
预期行为:
  protocol-guardian #2 Pre-Output Gate: ❌（未声明匹配文件、协作模式、拓扑）
  响应: ⚠️ 记录偏差 → 后续补声明
验证点:
  - ☐ 检出 Pre-Output Gate 声明缺失
  - ☐ 后续输出恢复声明
```

### T-LP-07：knowledge-auditor — 会话结束时触发

```yaml
前置条件: 已完成任务，用户发出结束信号
用户输入: "今天就到这吧，再见"
预期行为:
  knowledge-auditor 触发:
    1. 检查 runtime/ 状态文件是否过期
    2. 检查 data/knowledge/ 中本次引用的事实
    3. 检查项目连接器可访问性
  生成过期清单（若有）
验证点:
  - ☐ 会话结束时触发 knowledge-auditor
  - ☐ 检查 runtime、knowledge、connector 三类
  - ☐ 发现过期项时生成清单
  - ☐ 不自动修改知识库，只提示确认
```

### T-LP-08：knowledge-auditor — 连接器失效检测

```yaml
前置条件: 某项目连接器中 context_files 指向的文件已被删除
场景: 会话结束时 knowledge-auditor 运行
预期行为:
  connector 失效项: 1 个
  建议: "请确认后再清理或更新"
验证点:
  - ☐ 检出连接器中文件路径不可读
  - ☐ 标记为失效
  - ☐ 未擅自删除连接器
  - ☐ 给出"确认/更新/删除/忽略"四选一建议
```

### T-LP-09：三层优先级验证

```yaml
场景: thinking-sentinel 和 protocol-guardian 同时发现问题
  - thinking-sentinel: 答非所问（⛔）
  - protocol-guardian: MUST_RUN 未执行（⛔）
预期行为:
  优先处理 thinking-sentinel（高频优先）→ 再处理 protocol-guardian
验证点:
  - ☐ thinking-sentinel 优先级 > protocol-guardian
  - ☐ protocol-guardian 阻断 > protocol-guardian ⚠️ 记录
  - ☐ knowledge-auditor 优先级最低
```

### T-LP-10：sentinel.md 联动验证

```yaml
前置条件: 读取 sentinel.md
验证点（静态检查）:
  - ☐ sentinel.md 包含"与 Runtime Loops 的关系"章节
  - ☐ 声明互补分工: sentinel 检测意图建议加载，loops 监控执行质量
  - ☐ 声明不重叠: sentinel 加载模块后，执行质量由 loops 接管
  - ☐ 声明会话结束: sentinel 触发 /评分，knowledge-auditor 负责审计
```

### T-LP-11：未 BOOT 场景 — loops 不激活

```yaml
前置条件: 未执行 BOOT 启动协议（直接开聊）
用户输入: "帮我分析一下这个问题"
预期行为:
  sentinel.md 生效（检测意图并建议加载）
  loops 不生效（未经 BOOT，loops/README.md 未加载）
验证点:
  - ☐ sentinel 建议 /分析
  - ☐ 无 thinking-sentinel / protocol-guardian / knowledge-auditor 行为
  - ☐ loops 仅在 BOOT 后激活
```

---

## 五、并行思考（T-PT）

> 覆盖：parallel-thinking.md → meta.md 路由 + protocols.md 拓扑 + Wave 模型 + 隔离/冲突

### T-PT-01：meta.md 路由命中 — /并行 命令

```yaml
前置条件: 已完成 BOOT
用户输入: "/并行 帮我同时分析这三个市场的机会"
预期行为:
  路由匹配: /并行 → collaboration/parallel-thinking.md
  执行级别: MUST_RUN（命令触发强制）
验证点:
  - ☐ meta.md 中 /并行 命令匹配到
  - ☐ 加载 collaboration/parallel-thinking.md
  - ☐ 执行级别因命令触发强制为 MUST_RUN
```

### T-PT-02：关键词触发 — "分治"

```yaml
前置条件: 已完成 BOOT
用户输入: "这个问题能不能分治处理，几个子问题分开想"
预期行为:
  路由匹配: "分治" 命中 parallel-thinking.md
  执行级别: SHOULD
验证点:
  - ☐ "分治"关键词命中
  - ☐ 加载 parallel-thinking.md
```

### T-PT-03：触发条件验证 — 满足 ≥2 项才启用

```yaml
前置条件: 已完成 BOOT，加载 parallel-thinking.md
用户输入: "帮我分析竞争对手"
场景:
  条件1（≥2 独立子问题）: ❌ 单一问题
  条件2（无数据依赖）: N/A
  条件3（多 domain/connector）: ❌ 单一 domain
  满足条件数: 0 < 2
预期行为:
  退回串联拓扑，不启用并行
验证点:
  - ☐ 触发条件未满足 ≥2 项
  - ☐ 声明退回串联拓扑
  - ☐ 按 protocols.md 常规流程执行
```

### T-PT-04：触发条件满足 — 多子问题 + 无依赖

```yaml
前置条件: 已完成 BOOT
用户输入: "/并行 帮我分析三件事：1) marketing 的用户增长策略 2) 制度优化的进展 3) 儿童干预方案的风险"
场景:
  条件1（≥2 独立子问题）: ✅（3 个独立子问题）
  条件2（无数据依赖）: ✅（三个问题输入/输出不交叉）
  条件3（多 project connector）: ✅（涉及 3 个不同项目）
  满足条件数: 3 ≥ 2
预期行为:
  启用并行思考协议，进入 Wave 调度
验证点:
  - ☐ 3 个触发条件均满足
  - ☐ 进入 Wave 0 问题分解
```

### T-PT-05：Wave 0 — 问题分解 + 独立性验证

```yaml
前置条件: T-PT-04 场景，启用并行
预期行为:
  Wave 0（串行，必须先完成）:
    1. 拆出子问题清单（3 个）
    2. 验证无数据依赖
    3. 为每个子问题指定 theory routing 路径
验证点:
  - ☐ Wave 0 在 Wave 1 之前完成
  - ☐ 每个子问题有独立描述
  - ☐ 每个子问题指定了 theory routing
  - ☐ 独立性验证通过
```

### T-PT-06：Wave 1 — 并行思考 + 写隔离

```yaml
前置条件: Wave 0 完成
预期行为:
  Wave 1（并行）:
    各 agent 各自执行子问题
    输出格式: 结论 + 置信度 + 关键假设
    写入路径: runtime/thinking/{task-id}/ 各自子目录
验证点:
  - ☐ 各 agent 只写 runtime/thinking/{task-id}/ 下
  - ☐ 禁止跨目录写入
  - ☐ 每个子问题输出包含: 结论、置信度（高/中/低+理由）、关键假设
  - ☐ 各 agent 独立走 meta.md 关键词路由加载 theory
```

### T-PT-07：Wave 2 — 综合决策 + 冲突检测

```yaml
前置条件: Wave 1 全部完成
预期行为:
  Wave 2（串行，依赖 Wave 1）:
    1. 汇总各 agent 结论
    2. 冲突检测: 对比关键假设和推荐方向
    3. 无冲突 → 统一决策；有冲突 → 分歧报告
验证点:
  - ☐ Wave 2 在 Wave 1 全部完成后才开始
  - ☐ 汇总了所有 agent 结论
  - ☐ 执行了冲突检测
```

### T-PT-08：Wave 2 冲突处理 — 分歧 → 人裁决

```yaml
前置条件: Wave 1 完成，两个 agent 结论矛盾
场景:
  Agent A 结论: "应该扩张"
  Agent B 结论: "应该收缩"
预期行为:
  1. 列出分歧
  2. 交由人裁决
  3. 若人不可用 → 追加 red-blue 对抗
验证点:
  - ☐ 分歧被明确列出
  - ☐ 首选人裁决而非 AI 独断
  - ☐ 人不可用时才退到 red-blue 对抗
```

### T-PT-09：Wave 3 — 仅 🔴 级任务才执行交叉验证

```yaml
前置条件: 并行思考任务
场景A: 任务分级 🟡 → Wave 3 不执行
场景B: 任务分级 🔴 → Wave 3 执行（各 agent 审查其他 agent 结论）
验证点:
  - ☐ 🟢/🟡 级任务跳过 Wave 3
  - ☐ 🔴 级任务执行 Wave 3 交叉验证
  - ☐ Wave 3 中使用 red-blue 对抗
```

### T-PT-10：protocols.md 拓扑验证

```yaml
前置条件: 读取 protocols.md §1
验证点（静态检查）:
  - ☐ 拓扑表包含"并行分治"行
  - ☐ 结构描述: Wave0分解→Wave1多agent并行→Wave2综合→Wave3交叉验证(可选)
  - ☐ 适用场景: 多子问题独立求解
  - ☐ 引用了 parallel-thinking.md
```

### T-PT-11：Handoff 文档格式验证

```yaml
前置条件: Wave 0 完成，准备启动 Wave 1 子会话
预期行为:
  每个子问题的 Handoff 文档 (runtime/thinking/{task-id}/handoff.md) 包含:
    - 子问题描述
    - 约束（来自 Wave 0 + 连接器 iron_rules）
    - 输出要求（结论≤200 tokens + 置信度 + 关键假设）
    - theory_routing（meta.md 匹配结果）
验证点:
  - ☐ Handoff 文档含四个必填字段
  - ☐ 约束中包含连接器 iron_rules
  - ☐ 输出要求中结论 ≤ 200 tokens
  - ☐ 子会话完成后结论写入 conclusion.md
```

---

## 六、跨模块交叉验证（T-CROSS）

> 覆盖：多个新模块之间的联动正确性

### T-CROSS-01：🔴 任务 = 任务分级 + 跨会话审计 + 并行思考联动

```yaml
场景: 用户提出涉及多项目的战略级不可逆决策
用户输入: "全面审视三条业务线，决定是否放弃其中一条"
预期行为:
  1. 任务分级: 🔴（不可逆 + 跨项目 + 战略级）
  2. 并行思考: 三条业务线各自独立分析（Wave 0-2）
  3. 确定性标注: 每条结论带 [事实/推断/待确认]
  4. 跨会话审计: 🔴 完成后自动触发
  5. thinking-sentinel: 每次输出前巡检
验证点:
  - ☐ 五个模块全部激活
  - ☐ 任务分级在路由后、执行前
  - ☐ 并行思考在 Wave 模型内运行
  - ☐ 确定性标注出现在最终输出中
  - ☐ 跨会话审计在最终建议输出前触发
  - ☐ thinking-sentinel 持续运行
```

### T-CROSS-02：管道完整流程 — 全链路走通

```yaml
场景: 从 BOOT 到任务完成的完整流程
步骤:
  1. BOOT Phase 4: 加载 loops/README.md ✓
  2. Phase 5 路由匹配 → 命中 theory
  3. Phase 5 ②½ 任务分级 + Pre-Input Gate
  4. 加载 theory（含 certainty-layers 如需）
  5. Pre-Output Gate + thinking-sentinel 巡检
  6. 执行输出（含确定性标注）
  7. 每 3-5 轮 protocol-guardian 审计
  8. 🔴 任务完成 → cross-session-audit
  9. 会话结束 → knowledge-auditor
验证点:
  - ☐ 9 步顺序无跳步
  - ☐ Pre-Input Gate 在 Pre-Output Gate 之前
  - ☐ thinking-sentinel 在每次输出中运行
  - ☐ protocol-guardian 在中段运行
  - ☐ knowledge-auditor 在最后运行
```
