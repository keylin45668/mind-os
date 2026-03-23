# Theory Pack: rational — 按需加载路由表

> 当前活跃模块：**17**（无预存上限，按需加载）
> **AI 启动时只读本文件，不加载任何子目录内容。任务进来后按关键词匹配加载。**

---

## 路由表

> **执行级别**：MUST_RUN=匹配即执行不可跳过 | SHOULD=应执行跳过须声明 | MAY=可选参考

| 关键词 | 加载文件 | 执行级别 | 模块说明 |
|--------|---------|---------|---------|
| 收集/inbox/信息输入 | capture/rules.md | SHOULD | GTD收集规则 |
| 分类/整理/归档 | organize/rules.md | SHOULD | PARA分流规则 |
| 决策/判断/选择/要不要/该不该/值不值 | think/_index.md → 子路由 | **MUST_RUN** | 偏差检查（匹配即扫描） |
| 帮我分析/深度思考/多方向/对比方案/利弊 | think/iterative-engine.md | **MUST_RUN** | 迭代引擎（必须跑红蓝对抗） |
| 审计/迭代/系统检查 | think/system-audit-method.md | **MUST_RUN** | 方法A/B/C/D+深度追问 |
| 紧急/优先级/排期 | decide/rules.md | SHOULD | 艾森豪威尔+反转思维 |
| 风险/投资/反脆弱 | decide/antifragile.md | **MUST_RUN** | 三元分类+杠铃+否定法 |
| 竞争/对手/市场/战略 | decide/competition.md | SHOULD | 五事七计+博弈+不战而胜 |
| 模型/跨学科/格栅 | decide/models/meta.md | MAY | 多模型格栅 |
| 回顾/复盘/总结 | review/rules.md | SHOULD | 日/周/月/季/年回顾 |
| 笔记/知识/学习 | knowledge/rules.md | SHOULD | Zettelkasten+知识价值 |
| 协作/分工/路由 | collaboration/rules.md | MAY | 任务路由+拓扑选择+权重 |
| 系统/回路/陷阱/动力学 | collaboration/dynamics.md | MAY | 陷阱识别+创造性张力 |
| 团队/学习/对话 | collaboration/learning-org.md | MAY | 深度汇谈+双环学习 |
| 原则/评估/增益 | collaboration/principles.md | MAY | 五维评估+鲁棒性测试 |
| 经济/成本/资本 | collaboration/economics.md | MAY | 比较优势+认知资本 |
| 会话结束/评分/质量 | review/session-rating.md | **MUST_RUN** | 5维评分(AI×0.4+人×0.6)+滚动压缩 |
| 质量循环/打磨/quality loop | think/quality-loop.md | MAY | 任务级质量迭代（由 Pre-Output Gate 自动触发，手动路由亦可） |

---

## 加载规则

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

《思考，快与慢》/ 《穷查理宝典》/ 《反脆弱》/ 《黑天鹅》/ 《孙子兵法》/ 《道德经》/ 《系统之美》/ 《第五项修炼》/ 《原则》/ 《复杂》/ 《国富论》/ GTD / PARA / Zettelkasten / 延展心智论 / Licklider人机共生 / 博弈论 / 比较优势
