# 场景集：新增模块（创造力/执行/沟通/学习）

> 覆盖 evaluator.md B01, B05, C01-C05 对新模块的路由与执行验证

---

## S-NEW-01：创意模块 — 基础触发

```yaml
user_input: "帮我想几个新产品的方案"
keyword_match: "想个/方案" → think/creative.md (SHOULD)
expected:
  - 加载 creative.md
  - 执行发散阶段：至少 2 种发散路径（类比迁移/逆向设计/SCAMPER/极端约束）
  - 产出 ≥ 5 个差异化方案
  - 发散阶段不出现"不可行"等否定评判
  - 收敛阶段引用宪法第四条（本源检查）
checks: [B01, B05]
```

## S-NEW-02：创意模块 — 与分析模块串联

```yaml
user_input: "/创意 帮我设计一个会员体系，然后分析哪个方案最好"
keyword_match:
  - "/创意" → think/creative.md (MUST_RUN，命令触发)
  - "分析" → think/iterative-engine.md (MUST_RUN)
expected:
  - 声明: "检测到 2 个 MUST_RUN 协议，将分步执行"
  - Step 1: creative.md 发散 → 产出 ≥ 5 个方案
  - Step 2: iterative-engine.md 对筛选后的方案做红蓝对抗
  - creative 的产出作为 iterative-engine 的 input（依赖传递）
checks: [B01, B05, C01, C03]
```

## S-NEW-03：创意模块 — 边界（非创意任务不误触发）

```yaml
user_input: "帮我把这个设计文档翻译成英文"
keyword_match: "设计" 出现但任务核心是翻译
expected:
  - 不加载 creative.md
  - 或加载后意图验证降级为 MAY
checks: [B08]
```

---

## S-NEW-04：执行模块 — 基础触发

```yaml
user_input: "好，就按方案A来，帮我拆成具体步骤"
keyword_match: "步骤/拆" → organize/execute.md (SHOULD)
expected:
  - 加载 execute.md
  - 输出包含: 目标澄清（成功画面）
  - 输出包含: 里程碑分解（3-5 个，每个有交付物）
  - 输出包含: "今天第一步"（具体到可立刻动手，≤ 30 分钟）
  - 输出包含: 检查点（日期 + 检查内容）
  - 任何单个任务 ≤ 2 小时
checks: [B01, B05]
```

## S-NEW-05：执行模块 — 与决策模块衔接

```yaml
user_input: "这三个投资方向哪个好？确定后帮我出执行计划"
keyword_match:
  - "投资/哪个好" → decide/antifragile.md (MUST_RUN)
  - "执行计划" → organize/execute.md (SHOULD)
expected:
  - 先执行 antifragile（三元分类+杠铃）
  - 决策结论作为 execute 的输入
  - execute 输出的目标 = antifragile 的推荐方案
  - 里程碑中包含 antifragile 识别的关键风险的对应检查点
checks: [B01, B05, C03]
```

## S-NEW-06：执行模块 — 防退化（过度拆分）

```yaml
user_input: "/执行 帮我规划下个月的学习计划"
expected:
  - 里程碑 ≤ 5 个（不过度拆分）
  - 每个任务有明确完成标准
  - 有"今天第一步"
  - 不出现空泛任务（如"调研一下"→ 应是"打开X网站搜索Y"）
checks: [B01]
```

---

## S-NEW-07：沟通模块 — 基础触发

```yaml
user_input: "明天要跟老板谈涨薪，怎么说比较好"
keyword_match: "谈/怎么说" → collaboration/communication.md (SHOULD)
expected:
  - 加载 communication.md
  - 输出包含: 受众分析（老板的角色/关心什么/可能的立场）
  - 输出包含: 目标定义（底线目标 + 理想目标）
  - 输出包含: 策略选择（谈判策略，非汇报策略）
  - 输出包含: 预演（模拟老板可能的反应 ≥ 2 种）
  - 不从"我要涨薪"出发，而从"老板关心什么"出发
checks: [B01, B05]
```

## S-NEW-08：沟通模块 — 策略分类正确

```yaml
test_cases:
  - input: "帮我准备下周给董事会的汇报"
    expected_strategy: "汇报/提案（对上）"
    expected_structure: "结论先行 → 支撑论据 → 风险预案"

  - input: "怎么说服同事接受新流程"
    expected_strategy: "说服/推动（对等）"
    expected_structure: "共同利益 → 问题 → 方案 → 对方获益"

  - input: "要跟供应商砍价，怎么谈"
    expected_strategy: "谈判（利益冲突）"
    expected_structure: "共识区 → 分歧 → 交换 → 锚定"

  - input: "要告诉团队有人被裁了"
    expected_strategy: "高难度对话（冲突/坏消息）"
    expected_structure: "事实描述 → 影响 → 感受 → 请求"
checks: [B01]
```

## S-NEW-09：沟通模块 — 边界

```yaml
user_input: "帮我写一封感谢邮件"
keyword_match: 可能匹配"沟通"但实质是写作
expected:
  - 优先匹配 domain: writing
  - communication.md 不触发或降级为 MAY
  - 按 writing domain 的规则执行
checks: [B08]
```

---

## S-NEW-10：学习模块 — 基础触发

```yaml
user_input: "我想学投资，完全不懂，从哪开始"
keyword_match: "学/入门" → knowledge/learning.md (SHOULD)
expected:
  - 加载 learning.md
  - 输出包含: 定位（当前水平=完全不懂，目标水平）
  - 输出包含: 能力圈映射（与用户已有能力的交集作为锚点）
  - 输出包含: 结构化路径（核心概念 → 常用技能 → 进阶，严格串行）
  - 推荐资源 ≤ 3 个（不造成选择过载）
  - 输出包含: "今天第一步"
checks: [B01, B05]
```

## S-NEW-11：学习模块 — 费曼检查点

```yaml
user_input: "/学习 帮我规划学 Python 的路径"
expected:
  - 路径中每个阶段有检查点
  - 检查点包含费曼验证: "能用自己的话解释给不懂的人"
  - 路径从用户已有技能出发（锚点），不是从零开始的通用路径
  - 有刻意练习建议（针对性练习，不是"多写代码"）
checks: [B01]
```

## S-NEW-12：学习模块 — 与知识模块联动

```yaml
user_input: "学了一些投资知识，帮我整理沉淀一下"
keyword_match:
  - "知识/整理" → knowledge/rules.md (SHOULD)
  - 可能匹配 learning.md
expected:
  - 优先匹配 knowledge/rules.md（Zettelkasten）
  - 学习到的内容按原子笔记法沉淀
  - learning.md 不抢 knowledge.md 的场景
checks: [B01, B08]
```

---

## S-NEW-13：四模块交叉 — 完整链路

```yaml
user_input: "我想创业做一个AI教育产品，帮我从头想清楚"
expected_chain:
  1. creative.md 发散: 产品方向 ≥ 5 个方案
  2. iterative-engine.md 收敛: 红蓝对抗筛选出 Top 2
  3. antifragile.md 风险: 三元分类确认
  4. execute.md 落地: 选定方案 → 里程碑 + 第一步
  - 如匹配 > 3 个 MUST_RUN → 建议拆会话
  - 声明完整链路: "本任务涉及创意发散→决策分析→风险评估→执行规划"
checks: [B01, B02, B05, C01, C03]
```
