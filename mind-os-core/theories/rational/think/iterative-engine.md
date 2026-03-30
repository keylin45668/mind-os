---
name: iterative-engine
command: /分析
keywords: [帮我分析, 深度思考, 多方向, 对比方案, 利弊]
execution_level: MUST_RUN
type: specification
domain: think
summary: "红蓝对抗迭代引擎：多方向并行探索 + 质量驱动收敛 + 评分 Agent 门控"
context: isolated
hooks:
  pre_check: null
  post_check: null
  depth_check: "红方须与蓝方观点不同"
---

## 摘要

- **红蓝对抗**：每个方向蓝方提案→红方质疑（首要=本源检查）→裁决，编号制([B-]/[R-])可追溯
- **收敛条件**：质量驱动而非固定轮次，red_new==0/confidence plateau/all_resolved 任一触发收敛
- **并行模型**：层内并行探索多方向，层间串行收敛，state.yaml 为唯一真相源
- **质量门控**：评分 Agent 5 维打分 ≥ min_score 才允许收敛，不达标追加迭代

# 迭代思考引擎

---

## 输出模式：对话优先，按需落盘

```yaml
output_mode:
  default: conversation    # 蓝-红-裁决在对话中直接输出，不写文件
  persist: file            # 仅在 persist_trigger 命中时落盘

persist_trigger:
  - 用户明确要求（"记录下来""保存思考过程"）
  - 多轮迭代预计跨会话（上下文可能被压缩）
  - 用户标记为重大决策（"这个很重要""存档"）

persist_cleanup:
  - 收敛后 → 结论沉淀到 {data} → 删除 runtime/thinking/{task}/
  - 超过 7 天未更新 → AI 提醒用户归档或删除
```

---

## 红蓝对抗协议（编号制 + 机械可数）

**核心原则：所有论点和质疑必须有唯一编号，收敛指标由脚本 grep 编号计算，不依赖 AI 自报。**

### 编号规则

```yaml
id_format:
  蓝方论点:  [B-{方向}{轮次}-{序号}]     # 如 [B-d1r1-01]
  红方质疑:  [R-{方向}{轮次}-{序号}]     # 如 [R-d1r1-01]
  红方标记:  [NEW] 或 [REPEAT:R-d1r1-02] # 新质疑 or 重复（引用旧 ID）
  蓝方回应:  [RESP:R-d1r1-01]            # 回应哪条红方质疑
  裁决结果:  [SURVIVED:B-d1r1-01] 或 [FALLEN:B-d1r1-02] 或 [MODIFIED:B-d1r1-03]
```

### 蓝方 Agent

```yaml
blue_agent:
  角色: 方向倡导者
  铁律: 从本源出发（宪法第四条）
  输出格式:
    ## 本源声明
    一句话本质

    ## 论点
    - [B-d1r1-01] 论点内容
    - [B-d1r1-02] 论点内容
    - [B-d1r1-03] 论点内容

    ## 成功条件
    - ...

    ## 回应红方（第2轮起）
    - [RESP:R-d1r1-01] 我的回应内容
    - [RESP:R-d1r1-02] 我的回应内容
    - [NO-RESP:R-d1r1-03] 无法回应，原因: ...
```

### 红方 Agent

```yaml
red_agent:
  角色: 方向质疑者
  铁律: 首要质疑 = 本源检查
  输出格式:
    ## 本源检查
    结论: 触及本质 / 偏离 / 严重偏离

    ## 质疑
    - [R-d1r1-01] [NEW] [致命] 攻击 [B-d1r1-01]: 质疑内容
    - [R-d1r1-02] [NEW] [严重] 攻击 [B-d1r1-02]: 质疑内容
    - [R-d1r1-03] [NEW] [轻微] 隐含假设: 质疑内容
    - [R-d1r2-01] [REPEAT:R-d1r1-02] [严重] 上轮未充分回应，继续质疑

    ## 最坏场景
    - ...
```

### 裁决 Agent

```yaml
verdict_agent:
  角色: 中立裁判
  输出格式:
    ## 本源裁决
    通过 / 需调整 / 需重来

    ## 逐条裁决
    - [SURVIVED:B-d1r1-01] 经受住 [R-d1r1-01] 的质疑，理由: ...
    - [FALLEN:B-d1r1-02] 被 [R-d1r1-02] 攻破，原因: ...
    - [MODIFIED:B-d1r1-03] 需修正，原因: ...

    ## 遗留问题
    - [OPEN-01] 待验证: ...
    - [OPEN-02] 待验证: ...
```

### 指标计算（脚本 grep，非 AI 自报）

```yaml
metrics_computation:
  # 以下全部由 think-converge-check.sh 从文档中 grep 计算

  blue_count:                 # 蓝方论点总数
    公式: grep -c '\[B-' blue.md

  red_total:                  # 红方质疑总数
    公式: grep -c '\[R-' red.md

  red_new:                    # 红方新质疑数
    公式: grep -c '\[NEW\]' red.md

  red_repeat:                 # 红方重复质疑数
    公式: grep -c '\[REPEAT:' red.md

  survived:                   # 存活论点数
    公式: grep -c '\[SURVIVED:' verdict.md

  fallen:                     # 被攻破论点数
    公式: grep -c '\[FALLEN:' verdict.md

  modified:                   # 被修正论点数
    公式: grep -c '\[MODIFIED:' verdict.md

  fatal_total:                # 致命质疑总数
    公式: grep -c '\[致命\]' red.md

  fatal_responded:            # 蓝方已回应的致命质疑
    公式: 交叉匹配 red.md 中的 [致命] ID 和 blue.md 中的 [RESP:同ID]

  fatal_unresolved:           # 致命质疑未回应数
    公式: fatal_total - fatal_responded

  open_issues:                # 遗留问题数
    公式: grep -c '\[OPEN-' verdict.md

  blue_resp_count:            # 蓝方回应数（第2轮起）
    公式: grep -c '\[RESP:' blue.md

  blue_no_resp:               # 蓝方无法回应数
    公式: grep -c '\[NO-RESP:' blue.md

  confidence:                 # 信心度（计算而非打分）
    公式: survived / (survived + fallen + modified)
    范围: 0.0 - 1.0
```

---

## 收敛条件（精确量化，脚本计算）

**核心原则：每个条件都是 grep 结果的数值比较，不依赖 AI 的语义判断。**

```yaml
converge_check:
  输入: 本轮 blue.md + red.md + verdict.md（脚本 grep 提取编号计数）

  # ── 计算步骤（由 think-converge-check.sh 执行）──
  # step 1: grep -c '[NEW]' red.md         → red_new
  # step 2: grep -c '[RESP:' blue.md       → blue_resp
  # step 3: grep -c '[NO-RESP:' blue.md    → blue_no_resp
  # step 4: grep -c '[SURVIVED:' verdict.md → survived
  # step 5: grep -c '[FALLEN:' verdict.md  → fallen
  # step 6: grep -c '[OPEN-' verdict.md    → open_issues
  # step 7: 计算 fatal_unresolved（交叉匹配）
  # step 8: confidence = survived / (survived + fallen + modified)

  # ── 单方向收敛条件（任一触发 → 该方向停止）──

  red_exhausted:
    条件: red_new == 0
    计算: grep -c '\[NEW\]' red.md 结果为 0
    判定: converged
    含义: 红方本轮没有标记任何 [NEW] 质疑 → 再也挑不出新毛病

  blue_no_defense:
    条件: blue_no_resp > 0 且 blue_resp == 0
    计算: grep -c '\[NO-RESP:\]' > 0 且 grep -c '\[RESP:\]' == 0
    判定: excluded
    含义: 蓝方对所有质疑都标了 [NO-RESP] → 完全无法辩护

  fatal_deadlock:
    条件: fatal_unresolved > 0（本轮有致命质疑未被 [RESP:] 回应）
    计算: red.md 中 [致命] 的 ID 集合 - blue.md 中 [RESP:同ID] 的 ID 集合
    判定: 如连续 2 轮 fatal_unresolved > 0 → excluded
    含义: 有致命缺陷且蓝方无法修补

  confidence_plateau:
    条件: 连续 2 轮 confidence 变化 < 0.05
    计算: |survived/(survived+fallen+modified) 本轮 - 上轮| < 0.05
    判定: converged
    含义: 论点存活率已稳定

  all_resolved:
    条件: open_issues == 0 且 fatal_unresolved == 0 且 red_new == 0
    计算: grep -c '\[OPEN-' == 0 且 交叉匹配致命=0 且 grep -c '\[NEW\]' == 0
    判定: converged
    含义: 没有遗留问题 + 没有新质疑 + 没有致命缺陷

  user_confirm:
    条件: 用户输入包含明确终止指令
    计算: user-input-r{N}.md 存在且包含终止关键词
    判定: converged

  # ── 红蓝独立性检测（F06 量化标准）──

  independence_check:
    目的: 防止红方走形式（直接同意蓝方 = 深度不足）
    触发: 每轮裁决完成后
    量化规则:
      rule_1_new_attacks:
        条件: red_new >= 1（红方每轮至少提出 1 个 [NEW] 质疑）
        违反: red_new == 0 且 red_repeat == 0 → 红方无实质输出，独立性=0
      rule_2_attack_diversity:
        条件: 红方 [NEW] 质疑攻击的蓝方论点 ID 不少于 2 个不同的 [B-] 编号
        计算: 从 red.md 提取 "攻击 [B-xxx]" 中的 xxx → 去重 → count >= 2
        违反: 只攻击 1 个论点 → 独立性不足（红方未充分审查）
      rule_3_origin_check:
        条件: red.md 中存在 "## 本源检查" 章节且结论非空
        计算: grep -c '## 本源检查' red.md >= 1
        违反: 缺少本源检查 → 未履行宪法第四条
      rule_4_no_echo:
        条件: 红方不可直接复述蓝方结论作为自己的观点
        计算: verdict.md 中 fallen + modified >= 1（红方至少成功挑战 1 个论点）
        违反: fallen == 0 且 modified == 0 且 survived == blue_count → 红方完全同意蓝方
    综合判定:
      pass: rule_1 + rule_3 必须通过，rule_2 + rule_4 至少通过 1 个
      fail: rule_1 或 rule_3 违反 → 标记"⚠️ 红蓝独立性不足，需重新执行红方"
      fail_action: 重新生成红方输出，提示"本轮红方未展现独立视角，请重新执行本源检查和质疑"

  # ── 全局收敛 ──

  all_converged:
    条件: 所有方向 status ∈ {converged, excluded}
    → 追加 comparison 步骤

  # ── 质量门控（分数不够不让收敛）──

  quality_gate:
    条件: 所有方向满足技术收敛条件后，还需通过评分门控
    触发: 技术收敛（red_exhausted / all_resolved 等）达成时
    流程:
      1. 启动评分 Agent（独立 Agent，读文档评分，不依赖上下文）
      2. Agent 读取: manifest.md + 所有 verdict.md + comparison.md
      3. Agent 按 5 维度评分（与会话评分相同维度）
      4. 每维度从文档中提取客观依据（不是拍脑袋打分）
      5. 计算总分并与 min_score 比较
    判定:
      score >= min_score → 通过，允许收敛
      score < min_score → 拦截，追加新一轮迭代 + 评分反馈写入下轮 blue 的输入
    评分写入: state.yaml 的 quality_scores[] 数组

  # ── 安全阀（兜底，非正常出口）──

  emergency_brake:
    条件: 单方向轮次 > 50
    判定: 强制 converged + 标记 ⚠️（即使分数不够也终止，但标注未达标）
```

### 指标对照表

| 指标 | grep 命令 | 收敛阈值 | 含义 |
|------|----------|---------|------|
| red_new | `grep -c '\[NEW\]' red.md` | == 0 → 收敛 | 红方无新弹药 |
| blue_resp | `grep -c '\[RESP:' blue.md` | 见 blue_no_defense | 蓝方回应数 |
| blue_no_resp | `grep -c '\[NO-RESP:' blue.md` | > 0 且 resp==0 → 排除 | 蓝方放弃辩护 |
| survived | `grep -c '\[SURVIVED:' verdict.md` | 用于 confidence | 存活论点 |
| fallen | `grep -c '\[FALLEN:' verdict.md` | 用于 confidence | 被攻破论点 |
| modified | `grep -c '\[MODIFIED:' verdict.md` | 用于 confidence | 被修正论点 |
| open_issues | `grep -c '\[OPEN-' verdict.md` | == 0 → 可收敛 | 遗留问题 |
| fatal_unresolved | 交叉匹配 | > 0 连续2轮 → 排除 | 致命缺陷 |
| confidence | survived/(S+F+M) | Δ < 0.05 连续2轮 → 收敛 | 存活率 |

---

## 并行执行模型

```yaml
parallel_execution:
  原则: 层内并行，层间串行

  # 同一层的所有方向可以并行启动
  # 红方必须等蓝方完成（依赖蓝方输出）
  # 裁决必须等红方完成（依赖蓝+红输出）

  round_N:
    layer_1_blue:      # 并行
      - Agent("d1 蓝方") ──┐
      - Agent("d2 蓝方") ──┼── 同时启动，各自独立
      - Agent("d3 蓝方") ──┘
      → 全部完成后进入 layer_2

    layer_2_red:       # 并行
      - Agent("d1 红方", input=d1-blue) ──┐
      - Agent("d2 红方", input=d2-blue) ──┼── 同时启动
      - Agent("d3 红方", input=d3-blue) ──┘
      → 全部完成后进入 layer_3

    layer_3_verdict:   # 并行
      - Agent("d1 裁决", input=d1-blue+d1-red) ──┐
      - Agent("d2 裁决", input=d2-blue+d2-red) ──┼── 同时启动
      - Agent("d3 裁决", input=d3-blue+d3-red) ──┘
      → 全部完成后进入收敛检查

    layer_4_converge:  # 串行
      - 逐方向检查质量指标
      - 已收敛方向 → 移出下轮
      - 未收敛方向 → 加入 Round N+1 的 queue
      - 全收敛 → 生成比较报告

  queue.md 标记:
    同层步骤标记 parallel_group:
    "### STEP-002 [TODO] {parallel: layer1-r1}"
    "### STEP-003 [TODO] {parallel: layer1-r1}"
    → 编排器看到同一 parallel_group → 同时启动
```

---

## state.yaml — 唯一真相源

```yaml
task: "任务名"
created: "2026-03-23T10:00:00"
status: running          # running / waiting / converged / aborted

completeness: 0.5
directions_count: 3
min_score: 0             # 0=不设门控，1-5=必须达到此分才能收敛
quality_scores: []       # 每次评分 Agent 的评分记录

directions:
  - id: d1
    label: "方向1描述"
    status: active       # active / converged / excluded
    current_round: 2
    phase: blue          # blue / red / verdict / done
    confidence: 3
    confidence_history: [0, 3, 3]   # 逐轮信心度（用于 plateau 检测）
    red_novelty_history: [5, 2]     # 逐轮红方新质疑数（用于 exhaustion 检测）
    blue_delta_history: [3, 1]      # 逐轮蓝方改进数
    open_issues: 1
    fatal_unresolved: 0

current_round: 2
rounds_completed: 1

pending_questions: []
user_responses: {}
auto_reply: "ai_decide"
timeout: 120
```

---

## 信息评估与校准

```yaml
assess:
  变量: 目标/约束/偏好/背景（各 明确/模糊/未提及）
  completeness: 明确数 / 4

calibrate:
  directions: ceil(5 × (1 - completeness))   # 1-5
  # 注意：不再有 max_rounds——由质量指标驱动收敛
  # 安全阀 = 50 轮（紧急刹车）

策略: ai_decide / top_n / all_directions / conservative / custom
```

---

## 强制提问规则（mandatory_ask）

```yaml
mandatory_ask:
  触发条件: 任务初始化阶段，以下任一成立即触发
    - 存在"模糊"或"未提及"的变量且影响结论方向
    - min_score 未设置（默认0 = 用户未表态质量要求）
  执行级别: MUST_RUN

  行为:
    1. 评估后立即检查关键信息缺口
    2. 有 → 暂停分析，先向用户提问
    3. 同时询问质量要求:
       "这个分析你要求多严格？"
       - 快速参考（min_score=0，不设门控，跑1轮出结论）
       - 标准分析（min_score=3，需要有质量的红蓝对抗）
       - 严格深挖（min_score=4+，不达标继续迭代）
       - 或者直接告诉我分数要求（1-5）
    4. 用户回答 → 更新 completeness + min_score → 继续
    5. 用户跳过质量问题 → 默认 min_score=0（不设门控）

  原则:
    - 只问影响结论方向的关键问题
    - 一次性列出 + 说明为什么问 + 不同答案如何改变分析
    - AI 不得自行推测关键信息
    - AI 不得跳过质量要求询问——min_score=0 必须是用户的选择，不是 AI 的默认
```

---

## 编排流程（层内并行 + 质量驱动收敛）

```
用户发起任务
  ↓
【初始化】评估 → state.yaml + manifest.md + queue.md（含 parallel 标记）
  ↓
┌─ 循环（编排器 / Agent 自驱动）────────────────────────────┐
│                                                            │
│  读 queue.md → 找同一 parallel_group 的所有 [TODO]          │
│    → 同时启动多个 Agent（层内并行）                          │
│    → 全部完成后取下一个 parallel_group                       │
│                                                            │
│  Round N:                                                  │
│    🔵 蓝方 d1,d2,d3 并行 → 完成                            │
│    🔴 红方 d1,d2,d3 并行 → 完成                            │
│    ⚖️ 裁决 d1,d2,d3 并行 → 完成 → 输出质量指标             │
│    🔍 收敛检查:                                             │
│       逐方向检查 verdict 中的质量指标                        │
│       red_novelty=0 → 该方向 converged                     │
│       fatal_deadlock → 该方向 excluded                     │
│       仍有 active 方向 → 动态追加 Round N+1 步骤到 queue    │
│       全收敛 → 追加 comparison 步骤                         │
│                                                            │
│  ⚡ 上下文压缩 → PostCompact hook 读 context.md             │
│  ⚡ 尝试停止 → Stop hook 检查 queue.md [TODO]               │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**关键变化**：queue.md 不在初始化时生成全部轮次的步骤——只生成 Round 1，后续轮次由收敛检查动态追加。因为不知道要跑几轮。

---

## 输出规范（MUST_RUN）

**所有最终输出必须遵循 `output-template.md` 模板——总纲 + 分章节引用。**

```yaml
output_rules:
  模板文件: schemas/default/output-template.md
  执行级别: MUST_RUN（与红蓝对抗同级）
  核心约束:
    - 总纲(summary.md) ≤ 800 tokens，一页纸读完
    - 每个章节文件 ≤ 1500 tokens
    - 总纲必含: 一句话结论 + 推荐方案 + 方向速览 + 下一步 + 章节链接
    - 详情拆到 direction-{id}.md / adversarial-{id}.md / comparison.md
    - 违规 = 输出不完整，要求补全

  落盘结构:
    runtime/thinking/{task}/output/
      summary.md          ← 总纲
      direction-d1.md     ← 方向详情（每方向一个）
      adversarial-d1.md   ← 红蓝对抗记录（每方向一个）
      comparison.md       ← 五维对比表
      appendix.md         ← 附录（可选）

  对话模式:
    先输出总纲 → 再按章节顺序输出详情 → 用 --- 分隔
    用户要求保存 → 按上述结构落盘
```

---

## 质量门控：评分 Agent 协议

```yaml
scoring_agent:
  触发: 技术收敛条件达成 + min_score > 0
  角色: 独立评分员（不参与蓝红对抗的第三方）

  输入（只读文档，不依赖上下文）:
    - manifest.md（任务定义 + min_score）
    - 所有 verdict.md（各方向各轮裁决）
    - comparison.md（如已生成）

  评分维度（与会话评分相同 5 维，但从文档中量化提取）:

    D1 任务完成度:
      量化方法: manifest.md 中原始问题的关键词 vs comparison.md 中是否有对应结论
      公式: 被回答的关键问题数 / 总关键问题数
      1分: < 20%  2分: 20-40%  3分: 40-60%  4分: 60-80%  5分: > 80%

    D2 分析深度:
      量化方法: 从 verdict.md 提取
      公式: 平均 confidence (survived/(S+F+M)) × 5
      辅助: 总轮次 ≥ 2 加 0.5 分（经历过红蓝对抗）

    D3 协议合规:
      量化方法: 检查文档结构
      - blue.md 有 [B-] 编号？(+1)
      - red.md 有 [NEW]/[REPEAT] 标记？(+1)
      - red.md 有本源检查章节？(+1)
      - verdict.md 有 [SURVIVED]/[FALLEN] 裁决？(+1)
      - 存在至少 1 轮完整蓝-红-裁决？(+1)
      公式: 满足条件数 / 5 × 5

    D4 效率:
      量化方法: 收敛轮次
      公式: 5 - (总轮次 - 1) × 0.5（封底 1 分）
      含义: 越快收敛越高效

    D5 可行动性:
      量化方法: comparison.md 中是否有
      - 明确推荐方向？(+2)
      - 具体下一步？(+2)
      - 风险说明？(+1)
      公式: 满足条件数 / 5 × 5

  输出: task-score.md
    ```
    ## 任务评分
    task: "任务名"
    scored_at: "2026-03-24T10:00:00"
    D1: 4 (关键问题回答率: 80%)
    D2: 3.5 (confidence=0.67, 经2轮对抗+0.5)
    D3: 5 (5/5 结构合规)
    D4: 4 (2轮收敛)
    D5: 4 (有推荐+下一步，缺风险量化)
    total: 4.1
    min_score: 3.5
    verdict: PASS (4.1 >= 3.5)
    ```

  门控判定:
    total >= min_score → PASS → 允许收敛
    total < min_score → FAIL → 输出改进建议 + 追加新一轮
      改进建议写入下轮蓝方输入:
        "评分 Agent 反馈: D2=2.5(深度不足)，建议加强红蓝对抗"
```

### 用户设置 min_score 的方式

```yaml
user_setting:
  方式1_任务级: 用户发起任务时说"这个很重要，分数至少要 4 分"
    → manifest.md 写入 min_score: 4
    → state.yaml 写入 min_score: 4

  方式2_全局默认: preferences.md 中设置
    default_min_score: 3.5
    → 所有任务默认使用此值，除非任务级覆盖

  方式3_对话中修改: 用户中途说"标准提高到 4.5"
    → 更新 state.yaml min_score: 4.5

  值域:
    0: 不设门控（默认）
    1-2: 宽松（允许粗糙结论）
    3-4: 标准（需要有质量的分析）
    4.5-5: 严格（接近完美才放行）
```

---

## 落盘时的文件架构

> 仅当 persist_trigger 命中时创建。

```
runtime/thinking/{task}/
  ├── state.yaml                    ← 唯一真相源
  ├── manifest.md                   ← 任务定义 + min_score
  ├── queue.md                      ← 工作队列 {parallel: group}
  ├── context.md                    ← 压缩恢复
  ├── log.md                        ← 执行日志
  ├── task-score.md                 ← 评分 Agent 输出
  │
  ├── d1-round-1-blue.md            ← 过程文件（蓝/红/裁决）
  ├── d1-round-1-red.md
  ├── d1-round-1-verdict.md
  ├── ...
  ├── user-input-r2.md
  │
  └── output/                       ← 最终输出（总纲+分章节）
      ├── summary.md                ← 总纲（≤ 800 tokens）
      ├── direction-d1.md           ← 方向详情（≤ 1500 tokens）
      ├── direction-d2.md
      ├── adversarial-d1.md         ← 红蓝对抗记录
      ├── adversarial-d2.md
      ├── comparison.md             ← 五维对比表
      └── appendix.md               ← 附录（可选）
```

**过程文件 vs 输出文件分离**：过程文件是草稿（蓝红裁决），输出文件是成品（总纲+章节）。收敛后输出文件沉淀到 {data}，过程文件可删除。
