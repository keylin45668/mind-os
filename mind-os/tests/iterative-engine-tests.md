# 迭代思考引擎 — 测试用例

> 版本：v5.0 | 日期：2026-03-24
> 架构：Agent + 文件驱动（零上下文依赖）
> 共 11 大类、60 个测试用例

---

## 一、信息完整度评估（T-IE-ASSESS）

### T-IE-ASSESS-01：四维全部明确 → completeness = 1.0

```yaml
用户输入: "我是互联网行业创业者，预算50万以内，3个月内要完成，
          偏好稳健方案，想评估是否要做出海业务"
评估:
  目标: 明确（评估出海业务）
  约束: 明确（50万、3个月）
  偏好: 明确（稳健）
  背景: 明确（互联网、创业者）
  completeness: 4/4 = 1.0
预期校准:
  directions: ceil(5 × 0) = 1（单方向深挖）
  max_rounds: 2 + ceil(2 × 0) = 2（最少轮次）
结果: ✅ 信息充分，最小展开
```

### T-IE-ASSESS-02：四维全部未提及 → completeness = 0

```yaml
用户输入: "帮我想想接下来该怎么办"
评估:
  目标: 未提及
  约束: 未提及
  偏好: 未提及
  背景: 未提及（需从 profile.md 补充部分背景）
  completeness: 0/4 = 0
预期校准:
  directions: ceil(5 × 1) = 5（最大展开）
  max_rounds: 2 + ceil(2 × 1) = 4（最多轮次）
结果: ✅ 信息极度模糊，全面展开
```

### T-IE-ASSESS-03：部分明确部分模糊 → completeness = 0.5

```yaml
用户输入: "要不要换工作，我在大厂干了5年，有点倦怠"
评估:
  目标: 明确（评估是否换工作）
  约束: 未提及（薪资底线、家庭负担不明）
  偏好: 模糊（"倦怠"暗示想变，但未明确说）
  背景: 明确（大厂5年）
  completeness: 2/4 = 0.5
预期校准:
  directions: ceil(5 × 0.5) = 3
  max_rounds: 2 + ceil(2 × 0.5) = 3
结果: ✅ 中等展开
```

### T-IE-ASSESS-04：模糊项视为 0.5 而非 0

```yaml
用户输入: "想做点副业，可能跟AI相关"
评估:
  目标: 模糊（"做副业"方向有但不具体）→ 0.5
  约束: 未提及 → 0
  偏好: 未提及 → 0
  背景: 模糊（"跟AI相关"但无深度）→ 0.5
  completeness: 1/4 = 0.25
预期校准:
  directions: ceil(5 × 0.75) = 4
  max_rounds: 2 + ceil(2 × 0.75) = 4
结果: ✅ 模糊计半分，区别于完全未提及
```

### T-IE-ASSESS-05：profile.md 补充背景

```yaml
用户输入: "这笔投资值不值得做"
profile.md: industry="互联网/科技", current_stage="创业初期", roles=["创业者","投资者"]
评估:
  目标: 明确（投资决策）
  约束: 未提及（金额、期限不明）
  偏好: 未提及
  背景: 明确（从 profile.md 补充）
  completeness: 2/4 = 0.5
验证: AI 能从 profile.md 自动补充背景维度
结果: ✅ 跨文件信息整合
```

---

## 二、参数自动校准（T-IE-CALIBRATE）

### T-IE-CAL-01：校准公式边界值验证

```yaml
测试矩阵:
  | completeness | directions 公式 | 预期 | max_rounds 公式 | 预期 |
  |-------------|----------------|------|----------------|------|
  | 0.00 | ceil(5×1.0)  | 5 | 2+ceil(2×1.0) | 4 |
  | 0.25 | ceil(5×0.75) | 4 | 2+ceil(2×0.75) | 4 |
  | 0.50 | ceil(5×0.5)  | 3 | 2+ceil(2×0.5) | 3 |
  | 0.75 | ceil(5×0.25) | 2 | 2+ceil(2×0.25) | 3 |
  | 1.00 | ceil(5×0.0)  | 1*| 2+ceil(2×0.0) | 2 |

  * ceil(0)=0 但 min=1，所以取 1

验证: directions 恒在 [1,5]，max_rounds 恒在 [2,4]
结果: ✅ 公式单调递减，边界安全
```

### T-IE-CAL-02：directions 不超过 max=5

```yaml
极端输入: completeness = -0.1（异常值）
公式结果: ceil(5 × 1.1) = 6
验证: 被 max=5 截断
预期: directions = 5
结果: ✅ 上限保护生效
```

### T-IE-CAL-03：timeout 读取优先级

```yaml
场景A: preferences.think_timeout = 60
  预期: timeout = 60s

场景B: preferences.think_timeout 未设置
  预期: timeout = 120s（默认值）

场景C: preferences.think_timeout = 0
  预期: 跳过计时，立即按 timeout_fallback 处理
结果: ✅ 三级降级正确
```

---

## 三、预设应答规则（T-IE-PRESET）

### T-IE-PRESET-01：strategy = ai_decide

```yaml
前置: auto_reply_rules.strategy = "ai_decide"
场景: Round 1 提问3个问题，用户未回答，计时器超时
验证:
  - AI 自主为 3 个问题选择最合理答案
  - 每个选择附带一句理由
  - 不分叉方向（AI 已替用户做了选择）
  - 事后汇报: "我为你做了以下选择: Q1→a(因为...) Q2→b(因为...)"
预期: AI 全权决定，透明汇报
```

### T-IE-PRESET-02：strategy = top_n (n=2)

```yaml
前置: auto_reply_rules.strategy = "top_n", top_n = 2
场景: 信息评估得出 directions=4
验证:
  - AI 列出 4 个候选方向
  - 按重要性排序
  - 只保留 Top 2 个方向执行
  - 输出: "4个方向中，选择了最重要的2个: ①... ②..."
预期: 按重要性截断到 N 个
```

### T-IE-PRESET-03：strategy = all_directions

```yaml
前置: auto_reply_rules.strategy = "all_directions"
场景: Round 1 提问2个问题，每个问题3个选项，用户全部跳过
验证:
  - Q1 的 3 个选项 → 3 个分支
  - Q2 的 3 个选项 → 3 个分支
  - 组合: 3 × 3 = 9 个方向，但受 max=5 上限截断
  - 输出: "未回答问题产生 9 种组合，取影响力最大的 5 种"
预期: 分叉展开 + 上限截断
```

### T-IE-PRESET-04：strategy = conservative

```yaml
前置: auto_reply_rules.strategy = "conservative"
场景: 信息评估得出 directions=4
验证:
  - AI 评估 4 个方向的风险
  - 只走风险最低的 1 个方向
  - 其余 3 个标记为"未探索（高风险）"
  - 比较报告中仍列出未探索方向供参考
预期: 单方向保守执行
```

### T-IE-PRESET-05：strategy = custom（自定义 if-then）

```yaml
前置:
  auto_reply_rules:
    strategy: "custom"
    custom_rules:
      - if: "风险相关问题"
        then: "选最保守方案"
      - if: "技术选型"
        then: "由AI决定"

场景: Round 1 提问 "技术栈选 React 还是 Vue？"
验证:
  - 匹配 custom_rules 第2条（"技术选型"）
  - 执行 "由AI决定"
  - AI 自主选择并记录理由
预期: 自定义规则精确匹配并执行
```

### T-IE-PRESET-06：preset_answers 关键词匹配

```yaml
前置:
  preset_answers:
    预算相关: "控制在10万以内"
    时间相关: "3个月内"

场景: Round 1 AI 提问 "这个项目的预算范围？"
验证:
  - 问题匹配"预算相关"关键词
  - 自动填入 "控制在10万以内"
  - 不启动计时器（已有预设答案）
  - 输出: "使用预设答案: 预算控制在10万以内"
预期: 预设答案免等待
```

---

## 四、超时与状态流转（T-IE-TIMER）

### T-IE-TIMER-01：正常超时流程

```yaml
执行: ./think-timer.sh 10 /tmp/test-status
验证:
  - 立即写入 "waiting" 到状态文件
  - 每 5s 输出剩余时间
  - 10s 后写入 "timeout"
  - 输出 "⏰ 超时（10s），按预设规则自动继续"
  - 退出码 = 0
预期: 完整超时流程
```

### T-IE-TIMER-02：超时前用户回答

```yaml
执行: ./think-timer.sh 120 /tmp/test-status &
操作: 3s 后执行 echo "answered" > /tmp/test-status
验证:
  - 脚本在下次检查时检测到 "answered"
  - 输出 "✅ 用户已回答，继续迭代"
  - 提前退出，不等到 120s
预期: 中断等待，立即继续
```

### T-IE-TIMER-03：超时前用户跳过

```yaml
执行: ./think-timer.sh 120 /tmp/test-status &
操作: 3s 后执行 echo "skipped" > /tmp/test-status
验证:
  - 脚本检测到 "skipped"
  - 输出 "⏭️  用户跳过，按预设规则继续"
  - 提前退出
预期: 跳过走预设策略
```

### T-IE-TIMER-04：状态文件目录不存在

```yaml
执行: ./think-timer.sh 10 /tmp/nonexistent/deep/path/.wait_status
验证:
  - 自动创建目录 /tmp/nonexistent/deep/path/
  - 正常写入状态文件
预期: mkdir -p 保证目录存在
```

### T-IE-TIMER-05：默认参数

```yaml
执行: ./think-timer.sh（无参数）
验证:
  - TIMEOUT 默认 120
  - STATUS_FILE 默认 "runtime/thinking/.wait_status"
预期: 默认值安全可用
```

### T-IE-TIMER-06：loop-check 五种状态

```yaml
测试矩阵:
  | 状态文件内容 | 预期输出 | 预期 ACTION |
  |------------|---------|------------|
  | waiting    | ⏳ 等待中 | 无 ACTION |
  | answered   | ✅ 已回答 | continue_with_answer |
  | skipped    | ⏭️ 跳过  | continue_with_preset |
  | timeout    | ⏰ 超时  | continue_with_fallback |
  | converged  | 🎯 收敛  | generate_comparison |
  | 文件不存在  | 📋 无任务 | 无 ACTION |
  | "garbage"  | ❓ 未知  | 无 ACTION |

验证: 每种状态正确映射到对应输出
```

---

## 五、红蓝对抗协议（T-IE-RB）

### T-IE-RB-01：蓝方必须声明本源

```yaml
输入: 方向 = "跳槽到竞品公司"
验证 d1-round-1-blue.md:
  - 第一个章节必须是 "## 本源声明"
  - 内容: 一句话概括本质（如"本质是用确定性换不确定性的职业博弈"）
  - 后续论点必须从本源推导，不能脱离
预期: 蓝方从本源出发，不是直接套 SWOT/波特五力
```

### T-IE-RB-02：红方本源检查——触及本质 → 通过

```yaml
场景: 蓝方本源声明 = "本质是创业资金的时间价值 vs 机会窗口"
红方评估:
  - 检查是否触及了事物的根本矛盾
  - 判定: "触及本质"
验证 d1-round-1-red.md:
  ## 本源检查
  ### 蓝方是否触及本质？ → 是
  ### 分析从本源出发，框架是工具不是目的
预期: 通过本源检查，继续常规质疑
```

### T-IE-RB-03：红方本源检查——偏离 → 需调整

```yaml
场景: 用户问"要不要换工作"
蓝方本源声明 = "根据艾森豪威尔矩阵分析紧急度和重要度"
红方评估:
  - "这不是本源。艾森豪威尔矩阵是排期工具，换工作的本源是'你想要什么样的人生'。"
  - 判定: "偏离"
验证 d1-round-1-red.md:
  ## 本源检查
  ### 蓝方是否触及本质？ → 偏离
  ### 去掉框架后的本源: "这是一个关于人生方向的选择，不是紧急度排序"
裁决 verdict:
  ## 本源裁决: 偏离 → 需调整
  → 蓝方下轮须重新从"人生方向"出发
预期: 红方把蓝方拉回本质
```

### T-IE-RB-04：红方本源检查——严重偏离 → 需重来

```yaml
场景: 用户问"这笔投资值不值"
蓝方: 洋洋洒洒用了杠铃策略+五事七计+博弈论，但完全没分析"这个生意到底赚不赚钱"
红方评估:
  - "严重偏离。一堆框架堆砌，但一个核心问题没回答：这生意的利润从哪来？"
  - 判定: "严重偏离"
裁决:
  ## 本源裁决: 严重偏离 → 需重来
  → 蓝方下轮必须从"利润来源"这个本源重新论证
  → 本轮蓝方分析标记为 ❌ 无效
预期: 最严格的纠偏机制
```

### T-IE-RB-05：红方常规质疑——薄弱环节攻击

```yaml
场景: 蓝方论证"应该跳槽，薪资涨幅预期50%"
红方质疑:
  ## 薄弱环节
  - 论点"50%涨幅": 质疑强度=严重。"数据来源？行业均值？你的议价能力？"
  ## 隐含假设
  - "假设新公司文化适应无障碍"——未验证
  ## 最坏场景
  - "试用期不通过，高薪≠稳定"
验证: 每条质疑有具体理由 + 标注强度
预期: 不是无理取闹，是有据质疑
```

### T-IE-RB-06：裁决 Agent——逐条评判

```yaml
输入:
  blue.md: 3 个论点
  red.md: 本源通过 + 3 条质疑（致命×1, 严重×1, 轻微×1）
验证 verdict.md:
  ## 本源裁决: 通过
  ## 经受住质疑的论点 ✅（轻微质疑的那个）
  ## 被修正的论点 ⚠️（严重质疑的那个 + 修正方案）
  ## 被放弃的论点 ❌（致命质疑的那个 + 原因）
  ## 信心度: 从 3/5 降到 2/5
预期: 致命攻破→放弃，严重→修正，轻微→保留
```

### T-IE-RB-07：第2轮蓝方——必须先回应本源质疑

```yaml
前置: Round 1 裁决 = "本源偏离，需调整"
验证 d1-round-2-blue.md:
  - ## 本源声明（重新从本质出发）
  - ## 对红方本源质疑的回应（第一个回应章节）
  - ## 对红方其他质疑的回应
  - ## 更新后的核心论点
预期: 本源优先回应，不是先回应细节
```

### T-IE-RB-08：编排器 phase 流转 ✅ 已通过自动化

```yaml
自动化测试结果:
  blue → ACTION: run_blue_agent   ✅
  red  → ACTION: run_red_agent    ✅
  verdict → ACTION: run_verdict_agent ✅
  done → ACTION: next_round       ✅
  done(全收敛) → ACTION: run_comparison_agent ✅
  done(达max) → ACTION: run_comparison_agent  ✅
```

### T-IE-RB-09：比较报告含对抗强度

```yaml
验证 comparison.md 必须包含:
  ## 对抗强度摘要
  | 方向 | 蓝方论点数 | 红方质疑数 | 经受住的 | 存活率 |
  | d1   | 3         | 5         | 2       | 40%   |
  | d2   | 4         | 3         | 3       | 75%   |
  排序优先级: 存活率高的方向排名更高
预期: 经过红方验证的结论更可信
```

### T-IE-RB-10：红方"击杀"方向

```yaml
场景: d3 方向蓝方论点全部被红方致命质疑攻破
裁决: 所有论点 ❌，信心度 0/5
验证:
  - d3.status 变为 excluded（不是 converged）
  - 排除原因: "红方质疑全部致命，蓝方无法回应"
  - 该方向不再进入下一轮
  - 比较报告中标注: "⛔ 被红方击杀: [原因]"
预期: 经不起质疑的方向直接淘汰
```

---

## 六、每轮迭代协议（T-IE-ROUND）

### T-IE-ROUND-01：首轮——从零开始

```yaml
输入: "要不要换工作"（completeness=0.5 → 3方向 × 3轮）
Round 1 验证:
  1_ask: 提出 1-3 个问题
    - "Q1: 现在最不满意的是什么？ a)薪资 b)成长 c)氛围 d)跳过"
    - "Q2: 家庭负担？ a)低 b)中 c)高 d)跳过"
    - 问题简洁、有选项、可跳过
  2_execute: 3 个方向独立执行
    - d1: 留下+内部转岗
    - d2: 跳槽同行业
    - d3: 转行/创业
  3_output: 输出 3 个文件
    - runtime/thinking/换工作/d1-round-1.md
    - runtime/thinking/换工作/d2-round-1.md
    - runtime/thinking/换工作/d3-round-1.md
    - 每个文件含: 结论 + 关键假设 + 信心度 + 下轮待验证
  4_converge_check: Round 1 通常不收敛
预期: 首轮完整执行
```

### T-IE-ROUND-02：后续轮——上轮为起点

```yaml
前置: Round 1 完成，d1-round-1.md 结论="内部转岗可行性中等，需确认机会"
Round 2 验证:
  1_ask: 基于上轮结果追问
    - "Q: 你了解过内部有什么岗位机会吗？ a)有 b)没有 c)跳过"
  2_execute: 以 d1-round-1.md 为起点深化
    - 不是重新分析，而是在上轮基础上验证假设、补充细节
  3_output: d1-round-2.md
    - 引用上轮结论，标注变化: "信心度 3→4，新增信息: ..."
  4_converge_check: 与 round-1 对比相似度
预期: 链式迭代，不断深化
```

### T-IE-ROUND-03：偏差扫描自动触发

```yaml
前置: 用户在思考"要不要继续投这个亏损项目"
Round 1 执行阶段:
验证:
  - 关键词"继续/沉没成本" → 自动匹配 bias-loss-aversion.md
  - 关键词"大额" → 可能匹配 bias-overconfidence.md
  - 偏差扫描结果嵌入 round 输出文件
  - 标注: "⚠️ 检测到损失厌恶偏差，已校正分析"
预期: think/_index.md 偏差检查自动介入
```

### T-IE-ROUND-04：用户中途回答收窄方向

```yaml
前置: Round 1 有 4 个方向
Round 2 追问: "预算范围？"
用户回答: "最多20万"
验证:
  - 需要 >20万 的方向被标记为"约束不满足"
  - 该方向停止迭代（但保留 round-1 输出存档）
  - 剩余方向继续 Round 2
  - 比较报告中被排除方向标注"因约束排除"
预期: 回答即收窄，不浪费轮次
```

### T-IE-ROUND-05：每轮输出文件格式验证

```yaml
验证 d{n}-round-{m}.md 必须包含:
  - ## 结论（一段话概要当前方向的判断）
  - ## 关键假设（本轮分析依赖的假设列表）
  - ## 信心度（1-5 分 + 一句话理由）
  - ## 下轮待验证（还有什么不确定，下轮需要回答什么）
  - ## 偏差扫描（如触发，记录偏差名称和校正措施）
预期: 格式统一，可机器解析
```

---

## 六、收敛条件（T-IE-CONVERGE）

### T-IE-CONV-01：饱和收敛——相似度 > 80%

```yaml
场景:
  d1-round-2.md 结论: "建议内部转岗到产品线A，可行性高"
  d1-round-3.md 结论: "确认内部转岗到产品线A，可行性高，已联系HR"
验证:
  - 两轮结论核心判断相同（转岗+产品线A）
  - 相似度 > 80%
  - 该方向标记 converged，停止迭代
  - 其他方向若未收敛可继续
预期: 单方向独立收敛
```

### T-IE-CONV-02：达标收敛——用户确认

```yaml
场景: Round 2 结束后用户说 "方向2的分析已经够了，就这么办"
验证:
  - 所有方向立即停止迭代
  - 用户确认的方向标记为"用户选定"
  - 跳过后续轮次，直接生成比较报告
  - 比较报告中标注 "用户已在 Round 2 选定方向2"
预期: 用户一票终止
```

### T-IE-CONV-03：预算收敛——达到 max_rounds

```yaml
场景: max_rounds=3，Round 3 结束但仍有方向未饱和
验证:
  - 强制停止所有方向
  - 未收敛方向标记: "⚠️ 未完全收敛（达到轮次上限）"
  - 仍然生成比较报告
  - 报告中标注哪些方向结论信心度较低
预期: 硬上限保护，不无限迭代
```

### T-IE-CONV-04：部分方向收敛、部分继续

```yaml
场景: 3 个方向，Round 2 后:
  d1: 相似度 90% → converged
  d2: 相似度 50% → 继续
  d3: 因约束排除 → stopped
Round 3:
  只有 d2 继续迭代
验证:
  - d1 不再执行（已收敛）
  - d2 继续 Round 3
  - d3 已排除不再执行
  - 最终报告包含全部 3 个方向（标注各自状态）
预期: 方向独立收敛，不互相阻塞
```

### T-IE-CONV-05：所有方向 Round 1 即收敛

```yaml
场景: completeness=1.0 → 1个方向 × 2轮
  Round 1 输出信心度 5/5，下轮待验证为空
验证:
  - 检测到无待验证项 → 视为饱和
  - 跳过 Round 2
  - 直接输出最终结论（无需比较报告，只有1个方向）
预期: 信息充分时快速收敛，不浪费轮次
```

---

## 七、比较报告（T-IE-COMPARE）

### T-IE-COMP-01：标准比较报告格式

```yaml
场景: "要不要换工作" 3方向均完成
验证 comparison.md 结构:
  ## 任务概要
  - 原始问题 + 信息完整度 + 校准参数
  ## 各方向最终结论
  - d1: ... / d2: ... / d3: ...
  ## 对比矩阵
  | 维度 | d1:留下转岗 | d2:跳槽同行 | d3:转行创业 |
  |------|-----------|-----------|-----------|
  | 可行性 | 4/5 理由 | 3/5 理由 | 2/5 理由 |
  | 风险   | 1/5 理由 | 3/5 理由 | 5/5 理由 |
  | 成本   | ... | ... | ... |
  | 时间   | ... | ... | ... |
  | 价值契合 | ... | ... | ... |
  ## 综合推荐
  - ★★★ d1 > ★★ d2 > ★ d3 + 一句话理由
  ## 每个方向至少 1 个风险
  ## 声明: 推荐 ≠ 替用户决定
预期: 5 维评分 + 排序 + 风险 + 声明
```

### T-IE-COMP-02：单方向无需比较表

```yaml
场景: completeness=1.0 → 只有 1 个方向
验证:
  - 不生成对比矩阵（没有可比对象）
  - 输出格式简化为: 结论 + 风险 + 建议下一步
预期: 单方向直接出结论，不套比较模板
```

### T-IE-COMP-03：有排除方向的报告

```yaml
场景: 4 方向中 d3 因约束排除，d4 未完全收敛
验证 comparison.md:
  - d1, d2: 正常参与对比
  - d3: 单独列出，标注 "⛔ 因约束排除: 预算超限"
  - d4: 参与对比但标注 "⚠️ 未完全收敛，信心度较低"
预期: 所有方向都出现在报告中，状态透明
```

### T-IE-COMP-04：报告不隐藏劣势

```yaml
场景: AI 综合推荐 d1
验证:
  - d1 的风险列至少有 1 条（不能全是优点）
  - 被排在后面的方向也要列出优点（不能全是缺点）
  - 报告末尾声明: "以上为分析建议，最终决策权归您"
预期: 平衡呈现，不引导用户
```

### T-IE-COMP-05：报告存档路径正确

```yaml
场景: 任务名 = "换工作分析"
验证文件:
  runtime/thinking/换工作分析/d1-round-1.md  ✅
  runtime/thinking/换工作分析/d1-round-2.md  ✅
  runtime/thinking/换工作分析/d2-round-1.md  ✅
  runtime/thinking/换工作分析/d2-round-2.md  ✅
  runtime/thinking/换工作分析/d3-round-1.md  ✅
  runtime/thinking/换工作分析/comparison.md   ✅
  runtime/thinking/换工作分析/.wait_status    ✅（最终值 converged）
预期: 完整存档可追溯
```

---

## 八、端到端场景测试（T-IE-E2E）

### T-IE-E2E-01：完整流程——信息模糊 + ai_decide + 3轮收敛

```yaml
用户: "帮我想想下半年该做什么"
偏好: strategy=ai_decide, timeout=120

预期流程:
  评估: completeness≈0 → 5方向 × 4轮
  Round 1:
    追问: "最想改变的是事业/家庭/健康？预算？时间投入？"
    超时 → AI 按 ai_decide 自主选择
    5 方向展开，输出 5 个 d*-round-1.md
  Round 2:
    追问: 基于 Round 1 结果的细化问题
    用户回答 1 个 → 部分方向收窄
    输出 round-2.md（部分方向已收敛）
  Round 3:
    剩余方向继续
    多数方向相似度 > 80% → 收敛
  输出: comparison.md（5 方向完整对比）

验证: 从输入到报告全流程不中断
```

### T-IE-E2E-02：完整流程——信息充分 + 快速收敛

```yaml
用户: "要把公司主站从 React 迁到 Next.js，团队3人，预算5万，
       2个月内完成，目标是提升 SEO 和首屏速度"
偏好: strategy=ai_decide

预期流程:
  评估: completeness=1.0 → 1方向 × 2轮
  Round 1:
    追问: 可能无需追问（信息已充分）
    单方向执行: Next.js 迁移方案
    输出 d1-round-1.md（信心度可能已达 4-5）
  Round 2（如果 Round 1 未收敛）:
    细化: 具体迁移步骤 + 风险点
  输出: 直接结论（无比较表）

验证: 信息充分时 ≤ 2 轮完成，不过度展开
```

### T-IE-E2E-03：完整流程——用户中途介入

```yaml
用户: "评估三个投资标的: A公司、B公司、C公司"
偏好: strategy=top_n, top_n=3

预期流程:
  评估: 目标明确 → completeness≈0.5（缺约束和偏好）
  → 3方向（恰好对应3个标的）× 3轮

  Round 1: 三标的各自初步分析
  Round 2 追问: "风险承受能力？投资期限？"
    用户回答: "中等风险，持有2年"
    → 3 方向均纳入约束继续
  Round 3 追问: "单笔上限？"
    用户回答: "跳过"
    → 按 top_n 策略，AI 不分叉，自行估算
  输出: comparison.md（三标的 5 维对比）

验证: 用户部分回答+部分跳过的混合场景
```

### T-IE-E2E-04：完整流程——conservative 策略 + 高风险任务

```yaml
用户: "要不要卖掉房子全职创业"
偏好: strategy=conservative

预期流程:
  评估: completeness≈0.25 → 公式得 4 方向
  但 conservative 策略 → 只走风险最低的 1 个方向
  方向选择:
    d1: 不卖房，兼职创业（最低风险）← 选中
    d2: 卖房全职 → 标记"未探索"
    d3: 部分变现 → 标记"未探索"
    d4: 先融资再辞职 → 标记"未探索"

  执行 2-3 轮仅对 d1 深度分析
  输出: 深度报告 + 未探索方向列表供用户参考

验证: conservative 模式不扩散，聚焦最安全选项
```

### T-IE-E2E-05：完整流程——custom 规则 + preset_answers

```yaml
偏好:
  strategy: "custom"
  custom_rules:
    - if: "涉及金额 > 10万"
      then: "必须并联拓扑 + 对等协作"
    - if: "涉及人事"
      then: "人类主导，AI 只提供数据"
  preset_answers:
    预算相关: "控制在50万以内"

用户: "要不要花30万扩招3个人"

预期流程:
  匹配 custom_rules:
    "涉及金额 > 10万" → 30万 > 10万 ✅ → 并联拓扑
    "涉及人事" → 扩招 ✅ → 人类主导
  匹配 preset_answers:
    预算问题 → 自动填入"50万以内"（30万在预算内）

  迭代模式 = 人类主导 × 并联 × 迭代引擎
  AI 提供数据和分析，但不替用户做决定

验证: custom 规则和 preset_answers 联合生效
```

---

## 九、脚本与文件驱动测试（T-IE-SCRIPT）— 已通过自动化验证

### T-IE-SCRIPT-01：think-init.sh 校准公式 ✅ 已通过

```yaml
自动化测试结果:
  completeness=0    → directions=5  max_rounds=4  ✅
  completeness=0.25 → directions=4  max_rounds=4  ✅
  completeness=0.5  → directions=3  max_rounds=3  ✅
  completeness=0.75 → directions=2  max_rounds=3  ✅
  completeness=1.0  → directions=1  max_rounds=2  ✅
验证: 公式单调递减，边界安全，min/max 截断正确
```

### T-IE-SCRIPT-02：think-init.sh 文件生成 ✅ 已通过

```yaml
验证:
  - state.yaml 创建成功，字段完整（task/status/completeness/directions/rounds/auto_reply）
  - manifest.md 创建成功，参数区域正确
  - 目录 runtime/thinking/{task}/ 自动创建
```

### T-IE-SCRIPT-03：think-orchestrator.sh 状态机——9 种转换 ✅ 已通过

```yaml
自动化测试结果:
  | 当前状态 | 条件 | ACTION 输出 | 结果 |
  |---------|------|-----------|------|
  | running + 无待回答 | — | run_round_agent | ✅ |
  | running + 有待回答 | — | waiting_for_user | ✅ |
  | waiting | answered + 有文件 | run_round_agent | ✅ |
  | waiting | skipped | run_round_agent | ✅ |
  | waiting | timeout | run_round_agent | ✅ |
  | converged | 无 comparison.md | run_comparison_agent | ✅ |
  | converged | 有 comparison.md | done | ✅ |
  | aborted | — | aborted | ✅ |
  | 无 state.yaml | — | need_init | ✅ |
```

### T-IE-SCRIPT-04：think-timer.sh 三种中断 ✅ 已通过

```yaml
自动化测试结果:
  正常超时(6s):  状态文件 → "timeout"  ✅
  提前回答:      检测 "answered" → 提前退出  ✅
  提前跳过:      检测 "skipped" → 提前退出  ✅
  目录不存在:    自动 mkdir -p  ✅
```

### T-IE-SCRIPT-05：timer + orchestrator 端到端联动 ✅ 已通过

```yaml
自动化测试结果:
  Step1: 编排器检测到待回答 → ACTION: waiting_for_user  ✅
  Step2: timer 启动 → 8s 超时 → 写入 "timeout"  ✅
  Step3: 编排器检测到超时 → 生成 user-input-r1.md → ACTION: run_round_agent  ✅
  Step4: user-input 内容 = "超时，按 ai_decide 策略处理"  ✅
  Step5: state.yaml 回到 running  ✅
```

---

## 十、上下文抗丢失测试（T-IE-CONTEXT）

### T-IE-CTX-01：Agent 冷启动——只从文件恢复

```yaml
场景: 会话上下文完全丢失（新会话），但文件完整
前置:
  runtime/thinking/task-x/state.yaml 存在，current_round=2
  d1-round-1.md, d2-round-1.md 存在
操作: 新 Agent 只读文件，不依赖任何上下文
验证:
  - Agent 从 state.yaml 读取 current_round=2
  - 读取 d*-round-1.md 作为上轮输出
  - 正常执行 Round 2
  - 输出 d*-round-2.md
预期: 零上下文假设下正常恢复
```

### T-IE-CTX-02：中途会话崩溃——state.yaml 保证一致性

```yaml
场景: Agent 执行到一半崩溃（只写了 d1-round-2.md，没更新 state.yaml）
验证:
  - state.yaml 仍显示 current_round=2, rounds_completed=1
  - 重新启动 Agent → 发现 d1-round-2.md 已存在但 state 未更新
  - 选择: 覆盖重新执行（幂等性）
预期: 崩溃恢复不丢数据
```

### T-IE-CTX-03：多会话间传递——人工接力

```yaml
场景:
  会话A: 完成 Round 1-2，用户说"明天继续"
  （隔天，新会话B）
  用户: "继续昨天的换工作分析"
操作:
  Agent 读取 runtime/thinking/换工作分析/state.yaml
  检查 current_round=3, 方向状态
  无缝继续 Round 3
验证: 跨会话连续性完全由文件保证
```

### T-IE-CTX-04：并行任务互不干扰

```yaml
场景: 同时运行两个迭代任务
  runtime/thinking/task-A/state.yaml
  runtime/thinking/task-B/state.yaml
操作:
  编排器分别对两个任务目录操作
验证:
  - task-A 的状态变化不影响 task-B
  - 各自独立的 .wait_status 文件
  - 各自独立的 user-input-r*.md
预期: 目录级隔离，互不干扰
```

### T-IE-CTX-05：文件驱动 vs 上下文驱动对比验证

```yaml
验证清单:
  | 信息 | 存储位置 | 上下文依赖？ |
  |------|---------|------------|
  | 任务定义 | manifest.md | ❌ 文件 |
  | 当前轮次 | state.yaml | ❌ 文件 |
  | 方向列表和状态 | state.yaml | ❌ 文件 |
  | 上轮结论 | d*-round-{n}.md | ❌ 文件 |
  | 用户回答 | user-input-r{n}.md | ❌ 文件 |
  | 预设规则 | preferences.md | ❌ 文件 |
  | 等待状态 | .wait_status | ❌ 文件 |
  | 比较报告 | comparison.md | ❌ 文件 |
预期: 8/8 全部文件驱动，零上下文依赖 ✅
```

---

## 测试覆盖率汇总

| 测试类别 | 用例数 | 覆盖要点 |
|---------|-------|---------|
| 信息完整度评估 | 5 | 四维评分、全明确、全模糊、部分模糊、profile补充 |
| 参数自动校准 | 3 | 公式边界值、上限保护、timeout优先级 |
| 预设应答规则 | 6 | 5种策略各1个 + preset_answers |
| 超时与状态流转 | 6 | 正常超时、提前回答、提前跳过、目录创建、默认参数、loop-check |
| **红蓝对抗协议** | **10** | **本源检查(触及/偏离/严重偏离)、蓝方声明、红方质疑、裁决、phase流转、击杀、比较报告** |
| 每轮迭代协议 | 5 | 首轮、链式迭代、偏差扫描、中途收窄、输出格式 |
| 收敛条件 | 5 | 饱和、达标、预算、部分收敛、快速收敛 |
| 比较报告 | 5 | 标准格式、单方向、排除方向、不隐藏劣势、存档路径 |
| 端到端场景 | 5 | 模糊+ai_decide、充分+快速、中途介入、conservative、custom+preset |
| 脚本与文件驱动 | 5 | init校准、文件生成、状态机9转换、timer中断、联动 |
| 上下文抗丢失 | 5 | 冷启动恢复、崩溃恢复、跨会话接力、并行隔离、8/8文件驱动 |
| **合计** | **60** | — |
