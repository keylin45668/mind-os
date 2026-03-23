# AutoEvolve — 迭代循环协议

> **本文件定义自迭代的完整闭环。** 对应 autoresearch 的主循环。
>
> 核心理念同 autoresearch：**单一可变资产 + 标量指标 + 时间盒实验 + accept/reject**

---

## 三文件契约（不可打破）

```
┌─────────────────────────────────────────────────────┐
│  evaluator.md    ← 尺子（不可变，人类独占修改权）     │
│  program.md      ← 方向（不可变，人类独占修改权）     │
│  目标文件         ← 唯一可变资产（循环可修改）         │
└─────────────────────────────────────────────────────┘
```

**可变资产范围**（循环可以编辑的文件）：

| 文件 | 可改什么 | 不可改什么 |
|------|---------|----------|
| BOOT.md | 启动步骤措辞、门控逻辑、面板模板 | 不可删除任何 Phase |
| protocols.md | 门控规则、免疫措施、约定 | 不可违反宪法四条 |
| meta.md | 关键词、执行级别、加载规则 | 不可超过 2000 tokens |
| domains/_router.md | 路由规则 | 不可超过预算 |

**不可变文件**（循环绝对不能碰）：
- `constitution.md`（宪法）
- `evaluator.md`（评估器）
- `program.md`（人类元指令）
- `scenarios/*.md`（测试用例）
- `data/identity/*`（用户身份）

---

## 主循环

```
┌──────────────────────────────────────────────┐
│              AutoEvolve Main Loop             │
│                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │ 1.SELECT │───▶│2.EXECUTE│───▶│3.EVALUATE│ │
│  └─────────┘    └─────────┘    └────┬──────┘ │
│       ▲                             │        │
│       │         ┌─────────┐         │        │
│       │    NO   │score ≥   │   YES  │        │
│       ├─────────│  999?    │◀───────┘        │
│       │         └────┬─────┘                 │
│       │              │ YES                   │
│       │         ┌────▼─────┐                 │
│       │         │4.REGRESS │                 │
│       │         └────┬─────┘                 │
│       │              │                       │
│       │    ┌─────────▼─────────┐             │
│       │    │ 全部场景 ≥ 999?    │             │
│       │    └──┬──────────┬─────┘             │
│       │   NO  │          │ YES               │
│       │       │     ┌────▼────┐              │
│       │       │     │ 5.DONE  │              │
│       │       │     └─────────┘              │
│       │  ┌────▼─────┐                        │
│       │  │6.ANALYZE │                        │
│       │  └────┬─────┘                        │
│       │  ┌────▼──────┐                       │
│       │  │7.MUTATE   │                       │
│       │  └────┬──────┘                       │
│       │  ┌────▼──────┐                       │
│       │  │8.COMMIT   │                       │
│       │  └────┬──────┘                       │
│       │  ┌────▼──────┐                       │
│       │  │9.RE-TEST  │                       │
│       │  └────┬──────┘                       │
│       │       │                              │
│       │  ┌────▼──────┐                       │
│       │  │improved?  │                       │
│       │  └──┬─────┬──┘                       │
│       │  NO │     │ YES                      │
│       │  ┌──▼──┐  └──▶ KEEP (next scenario)  │
│       │  │RESET│      ──────▶ ▲              │
│       │  └──┬──┘              │              │
│       │     └─────────────────┘              │
│       │                                      │
│       └──────── (try different mutation) ────│
│                                              │
└──────────────────────────────────────────────┘
```

---

## 步骤详解

### Step 1: SELECT（选择场景）

```yaml
strategy: round-robin + priority-weighted
  1. 按 program.md 优先级排序失败场景
  2. 新场景首轮全部跑一遍（建立 baseline）
  3. 此后按失败频率加权随机选择
```

### Step 2: EXECUTE（模拟执行）

```yaml
method: dual-LLM simulation
  executor_llm:
    role: "你是一个严格按照 Mind OS 规则运行的 AI"
    input:
      - 完整 Mind OS 文件集（当前版本）
      - 测试场景的用户输入
    output: Mind OS 完整响应（启动面板 + 任务处理）

  time_box: 单次模拟不超过 5 分钟

  isolation: 每次模拟在独立上下文中运行，零状态泄漏
```

### Step 3: EVALUATE（合规评分）

```yaml
method: evaluator-LLM + rubric
  evaluator_llm:
    role: "你是合规审计员，严格按 evaluator.md 的 40 项清单逐条检查"
    input:
      - executor 的完整输出
      - evaluator.md 的检查清单
      - 测试场景的预期行为
    output:
      passed: [A01, A02, ...]
      failed: [C03, C06, ...]
      compliance_score: 967
      failure_analysis: "MUST_RUN 匹配了 iterative-engine 但未创建 thinking 目录"

  scoring: 按 evaluator.md 权重公式计算
```

### Step 4: REGRESS（回归测试）

```yaml
trigger: 当前场景达到 ≥ 999 后
action: 重跑所有已通过的场景，确保没有退化
  如果任何已通过场景退化 → 视为失败，回到 Step 6
```

### Step 5: DONE（达标终止）

```yaml
condition: 所有场景连续 N 轮 ≥ 999
action:
  - 生成最终报告
  - 列出所有 KEEP 的修改及其效果
  - 等待人类确认合并
```

### Step 6: ANALYZE（失败分析）

```yaml
method: pattern-matching on failure history
  input:
    - 当前失败的 check IDs
    - results.tsv 历史记录
    - 对应的 Mind OS 源文件
  output:
    root_cause: "BOOT.md Phase 5 的门控描述不够强制性，AI 将其理解为建议而非命令"
    affected_file: "BOOT.md"
    affected_section: "Phase 5 ④"
    confidence: 0.8
```

### Step 7: MUTATE（修改规则）

```yaml
principles:
  - 最小修改原则：改最少的字来解决问题
  - 不可破坏约束：检查 program.md 的约束列表
  - 优先强化措辞：先试"必须/不得/违规不输出"等命令语
  - 其次增加冗余：关键规则在多处重复（BOOT.md + protocols.md）
  - 最后增加结构：新增检查步骤或门控条件

mutation_types:
  1_strengthen_wording:  # 最优先
    example: "AI 应该检查" → "AI 必须检查，不检查不得输出"

  2_add_redundancy:      # 关键路径双重保险
    example: 门控规则同时写在 BOOT.md 和 protocols.md

  3_add_checkpoint:      # 增加验证步骤
    example: 在 Phase 5 增加 "⑥ 执行后自检：逐条对照已执行协议"

  4_improve_routing:     # 修复路由精度
    example: 扩展关键词覆盖 "这个值不值" → 增加 "有没有必要/合不合适"

  5_add_example:         # 增加正例/反例
    example: 在门控规则后增加 "✅ 正确示例: ... / ❌ 错误示例: ..."

  6_structural_change:   # 最后手段
    example: 新增独立的 checklist 文件
```

### Step 8: COMMIT（版本化）

```yaml
action:
  - git add {modified_files}
  - git commit -m "autoevolve #{experiment_id}: {change_description}"
  - 记录 commit hash 到 results.tsv
```

### Step 9: RE-TEST（验证）

```yaml
action:
  - 重跑触发失败的场景
  - 重跑 3 个随机已通过场景（防退化）

accept_criteria:
  - 目标场景 compliance_score 提升
  - 已通过场景 compliance_score 不下降

if_improved: KEEP commit
if_not_improved: git reset --hard {previous_commit}, 记录失败原因, 尝试不同 mutation
```

---

## 收敛策略

```yaml
phase_1_baseline:          # 第 1-N 轮
  action: 全场景跑一遍，建立 baseline
  output: 每个场景的初始 compliance_score

phase_2_fix_critical:      # 先修致命项
  focus: C03, C06-C09, D02, E02（单项失败 = 直接 < 999）
  strategy: 每个致命项单独修复 + 回归

phase_3_fix_weighted:      # 再修高权重项
  focus: 权重 ≥ 2 的检查点
  strategy: 按影响面从大到小修复

phase_4_polish:            # 最后修低权重
  focus: 权重 = 1 的检查点
  strategy: 批量小修

phase_5_stress_test:       # 压力验证
  action: 连续 50 轮全场景回归
  pass: 连续 50 轮 ≥ 999 → DONE
  fail: 回到 phase_2
```

---

## 防退化机制

```yaml
regression_guard:
  每次 KEEP 后:
    - 重跑全部场景
    - 任何场景退化 → 立即回滚本次修改

  results.tsv 趋势监控:
    - 连续 10 轮无改善 → 暂停，请求人类调整 program.md
    - 单场景反复失败 ≥ 5 次 → 标记为"需人类介入"

  complexity_budget:
    - 每次修改后检查：schema 规则数 ≤ 30？文件 ≤ 1000 tokens？
    - 超限 → 自动回滚 + 记录"复杂度超限"
```

---

## 执行方式

### 方式 A：Claude Code Agent 全自动

```bash
# 人类启动后去蒸桑拿
claude "请执行 autoevolve/loop.md 的完整迭代循环"
```

Agent 行为：
1. 读取 program.md + evaluator.md + scenarios/
2. 进入主循环
3. 每轮使用 Agent tool 派生两个子 agent（executor + evaluator）
4. 根据结果修改文件、git commit/reset
5. 记录到 results.tsv
6. 达标或卡住时通知人类

### 方式 B：人工启动逐轮

```
人类: "跑一轮 autoevolve，场景: gate-must-run-01"
AI: [执行 Step 2-3，报告结果]
人类: "分析失败原因"
AI: [执行 Step 6，报告根因]
人类: "试试强化措辞"
AI: [执行 Step 7-9，报告是否改善]
```

### 方式 C：批量自动 + 人类审批

```
AI 自动跑 phase_1（baseline）→ 生成报告
人类审批 → AI 自动跑 phase_2-4 → 每个 KEEP 暂停等人类确认
人类确认 → 继续
```

---

## 与 autoresearch 的同构映射

| autoresearch | AutoEvolve | 原理 |
|---|---|---|
| train.py（630行） | BOOT.md + protocols.md + meta.md | 唯一可变资产 |
| val_bpb（越低越好） | compliance_score（越高越好，目标 999） | 标量指标 |
| prepare.py（不可变） | evaluator.md + constitution.md | 不可变尺子 |
| program.md（人类方向） | program.md（人类方向） | 元编程 |
| 5 分钟训练 | 单场景模拟执行 | 时间盒 |
| git commit | git commit | 检查点 |
| git reset | git reset | 回滚 |
| results.tsv | results.tsv | 实验日志 |
| ~12 实验/小时 | ~10 场景/小时（取决于模型速度） | 吞吐量 |

**关键差异**：autoresearch 修改 Python 代码让 GPU 跑；AutoEvolve 修改自然语言规则让 LLM 执行。本质相同——**用标量反馈驱动的自动化搜索**。
