# Theory Pack: rational — 按需加载路由表

> 当前活跃模块：**25**（无预存上限，按需加载）
> **AI 启动时只读本文件，不加载任何子目录内容。任务进来后按关键词匹配加载。**

---

## 路由表

> **执行级别**：MUST_RUN=匹配即执行不可跳过 | SHOULD=应执行跳过须声明 | MAY=可选参考
> **命令触发**：用户输入 `/命令` 直接加载对应模块，跳过关键词匹配，执行级别强制为 MUST_RUN

| 命令 | 关键词（自动匹配） | 加载文件 | 执行级别 | 模块说明 |
|------|--------|---------|---------|---------|
| `/收集` | 收集/inbox/信息输入 | capture/rules.md | SHOULD | GTD收集规则 |
| `/整理` | 分类/整理/归档 | organize/rules.md | SHOULD | PARA分流规则 |
| `/偏差` | 决策/判断/选择/要不要/该不该/值不值 | think/_index.md → 子路由 | **MUST_RUN** | 偏差检查（匹配即扫描） |
| `/分析` | 帮我分析/深度思考/多方向/对比方案/利弊 | think/iterative-engine.md | **MUST_RUN** | 迭代引擎（必须跑红蓝对抗） |
| `/审计` | 审计/迭代/系统检查 | think/system-audit-method.md | **MUST_RUN** | 方法A/B/C/D+深度追问 |
| `/排期` | 紧急/优先级/排期 | decide/rules.md | SHOULD | 艾森豪威尔+反转思维 |
| `/反脆弱` | 风险/投资/反脆弱 | decide/antifragile.md | **MUST_RUN** | 三元分类+杠铃+否定法 |
| `/竞争` | 竞争/对手/市场/战略 | decide/competition.md | SHOULD | 五事七计+博弈+不战而胜 |
| `/模型` | 模型/跨学科/格栅 | decide/models/meta.md | MAY | 多模型格栅 |
| `/回顾` | 回顾/复盘/总结 | review/rules.md | SHOULD | 日/周/月/季/年回顾 |
| `/知识` | 笔记/知识/学习 | knowledge/rules.md | SHOULD | Zettelkasten+知识价值 |
| `/协作` | 协作/分工/路由 | collaboration/rules.md | MAY | 任务路由+拓扑选择+权重 |
| `/动力学` | 系统/回路/陷阱/动力学 | collaboration/dynamics.md | MAY | 陷阱识别+创造性张力 |
| `/团队` | 团队/学习/对话 | collaboration/learning-org.md | MAY | 深度汇谈+双环学习 |
| `/原则` | 原则/评估/增益 | collaboration/principles.md | MAY | 五维评估+鲁棒性测试 |
| `/经济` | 经济/成本/资本 | collaboration/economics.md | MAY | 比较优势+认知资本 |
| `/进化` | 进化/适应度/淘汰/分化 | collaboration/evolution.md | SHOULD | 模块适应度+淘汰归档+生态位分化 |
| `/评分` | 会话结束/评分/质量 | review/session-audit.md → review/session-rating.md | **MUST_RUN** | 先执行审查再评分（串行） |
| `/质量` | 质量循环/打磨/quality loop | think/quality-loop.md | MAY | 任务级质量迭代 |
| `/深度迭代` | 深度迭代/多轮迭代/加速思考 | think/task-iterate.md | **MUST_RUN** | 任务级自动多轮迭代（蓝红N轮+收敛检测） |
| `/创意` | 设计/创意/方案/产品/点子/命名/想个 | think/creative.md | SHOULD | 发散-收敛创造力引擎 |
| `/执行` | 执行/计划/拆解/步骤/落地/OKR/行动方案 | organize/execute.md | SHOULD | 决策→行动桥梁（目标分解+第一步锚定） |
| `/沟通` | 说服/谈判/汇报/沟通/表达/演讲/怎么说 | collaboration/communication.md | SHOULD | 受众分析+策略选择+预演 |
| `/学习` | 学习/入门/提升/技能/怎么学/学习路径 | knowledge/learning.md | SHOULD | 费曼技巧+刻意练习+能力圈扩展 |

### 系统命令（非 theory 模块）

| 命令 | 作用 | 说明 |
|------|------|------|
| `/理论` | 列出所有可用命令和模块说明 | 相当于 theory 帮助菜单 |
| `/切换 {档案}` | 会话中切换数据档案 | 触发 BOOT.md 切换协议 |
| `/焦点` | 查看/设置今日焦点 | 读写 runtime/focus.md |
| `/面板` | 重新展示启动面板 | 刷新当前状态 |

### 迭代命令

| 命令 | 作用 | 说明 |
|------|------|------|
| `/迭代` | 跑一轮 autoevolve 系统迭代 | 读取 autoevolve/ENTRY.md 执行 |
| `/迭代进度` | 查看 autoevolve 当前进度 | 读取 state.yaml 展示合规率 |
| `/迭代聚焦 {场景}` | 指定下一轮迭代的目标场景 | 更新 state.yaml 的 next_action |
| `/迭代暂停` | 暂停 autoevolve | state.yaml status → paused |
| `/迭代继续` | 恢复 autoevolve | state.yaml status → running |
| `/模块迭代 {模块名}` | 对单个 theory/schema 模块执行改进迭代 | 见模块迭代协议 |
| `/模块列表` | 列出所有可迭代的模块及状态 | 扫描 theory/ + schema/ 文件 |

---

## 加载规则

### 命令路由（优先级最高）

```yaml
command_routing:
  触发: 用户输入以 / 开头
  流程:
    1. 在路由表"命令"列精确匹配
    2. 匹配到 →
       - 加载对应文件
       - 执行级别强制为 MUST_RUN（用户主动触发 = 明确意图，无需意图验证）
       - 跳过关键词匹配，直接进入门控
    3. 未匹配到 → 提示："未找到命令 /{cmd}，输入 /理论 查看所有可用命令"
  组合使用:
    - "/反脆弱 分析一下这个投资机会" → 加载 antifragile.md，用户描述作为 input
    - "/分析 + /反脆弱" → 同时加载两个模块（多命令空格分隔）
    - 单独 "/反脆弱" 无后续描述 → AI 用 AskUserQuestion 询问要分析什么
```

### 关键词路由

1. **单匹配**：只加载命中的文件
2. **多匹配**：加载所有命中文件，**上限 3 个**（超过时只加载相关度最高的 3 个）
3. **无匹配**：不加载任何 theory，使用 schema/ 通用规则
4. **think/ 二级路由**：命中 think 后，再查 think/_index.md 匹配具体偏差条目
5. **每个文件 ≤ 1000 tokens**：确保按需加载后上下文可控（3 文件 × 1000 = 3000 tokens 预算）
6. **MUST_RUN 意图验证（两遍路由）**：关键词命中 MUST_RUN 后，必须追加一步意图检查：
   ```
   问："用户的主要任务是否关于 {匹配到的领域}？"
   ├── 是（关键词=任务核心）→ 维持 MUST_RUN
   └── 否（关键词=修饰语/背景提及）→ 降级为 MAY，**必须在输出中显式声明降级**
   ```
   **降级必须显式声明**：不可静默跳过。声明格式示例："「投资」为修饰语，非任务核心，反脆弱分析不适用，降级为 MAY"
   判定技巧：关键词出现在「动词/任务」位置=核心；出现在「宾语修饰」或「对象描述」位置=修饰语
   示例：
   - "这个投资机会值不值得做" → 投资=任务核心（动词位） → 维持 MUST_RUN ✅
   - "帮我写封感谢信给投资人" → 投资人=修饰语（对象描述） → 降级为 MAY ✅
   - "帮我翻译这段关于投资理论的文献" → 投资=修饰语（宾语修饰） → 降级为 MAY ✅
   - "帮我分析这三个方案的利弊" → 分析=任务核心（动词位） → 维持 MUST_RUN ✅
7. **多 MUST_RUN 串行拆分 + 步间门控**：当同时命中 ≥ 2 个 MUST_RUN 协议时，不得在单次输出中压缩执行。必须：
   ```
   声明: "检测到 {N} 个 MUST_RUN 协议，将分步执行："
   Step 1: 执行最轻量的协议（如 antifragile 三元分类）
     → 步间门控: 列出该协议的必要产出清单，逐条自检 ✅/❌
     → 全部 ✅ 才进入下一步
   Step 2: 执行下一个协议（如 system-audit 方法 A/B/C/D）
     → 步间门控: 同上
   Step 3: 执行最重量的协议（如 iterative-engine 红蓝对抗）
     → 步间门控: 同上
   ```
   排序原则：检查清单型（antifragile, audit）先于生成型（iterative-engine）
   依赖传递：后续步骤可引用前序步骤的产出（如 antifragile 的三元分类结果传入 iterative-engine）

   **步间门控清单**（每个协议完成后必须逐条核对）：
   ```yaml
   antifragile_checklist:
     - ☐ 三元分类完成（脆弱/强韧/反脆弱 + 百分比）
     - ☐ 杠铃策略检查（安全端+冒险端+准入条件）
     - ☐ 否定法（"不做会怎样"）

   system_audit_checklist:
     - ☐ 路径选择（A 或 B）并声明理由
     - ☐ 方法 A（数学形式化）— 即使不适用也声明"不适用，原因: ..."
     - ☐ 方法 B（原子操作分解，≤7 个）
     - ☐ 方法 C（正反对称检验）
     - ☐ 方法 D（同构检验）

   iterative_engine_checklist:
     - ☐ 至少 1 个方向完成完整蓝-红-裁决（非摘要，默认在对话中输出）
     - ☐ 红方首要质疑 = 本源检查（宪法第四条）
     - ☐ 比较报告或阶段结论
     - ☐ 如用户要求保存 → 结论沉淀到 {data}/content/ 或 knowledge/
   ```

---

## 理论来源

《思考，快与慢》/ 《穷查理宝典》/ 《反脆弱》/ 《黑天鹅》/ 《孙子兵法》/ 《道德经》/ 《系统之美》/ 《第五项修炼》/ 《原则》/ 《复杂》/ 《国富论》/ **《物种起源》** / GTD / PARA / Zettelkasten / 延展心智论 / Licklider人机共生 / 博弈论 / 比较优势
