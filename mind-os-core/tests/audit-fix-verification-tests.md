# 审计修复验证测试用例

> 版本：v5.2-audit | 日期：2026-03-28
> 覆盖 Phase 1-3 共 16 项修复，7 大类、42 个测试用例
> 对应 evaluator 检查项：C01-C10, D01-D07, E01-E05, F06, B01-B08, I01-I10

---

## 一、协作增益率公式验证（Phase 1 #1）

### T-GAIN-01：协作增益率正向增益

```yaml
前置:
  - runtime/ratings/current.md 存在，最近 10 次评分均值 = 3.9
  - constitution.md 中 baseline = 3.0
验证:
  - 协作增益率 = 3.9 / 3.0 = 1.30
  - dashboard.md 中 collaboration_gain 更新为 1.30
  - 判定: "> 1.0"，协作有正向增益
预期: 公式计算正确，状态为"达标"
```

### T-GAIN-02：协作增益率低于基线

```yaml
前置:
  - 最近 10 次评分均值 = 2.5
验证:
  - 协作增益率 = 2.5 / 3.0 = 0.83
  - 判定: "< 1.0"，协作拖累质量
  - 触发系统审计提醒
预期: 低于基线时正确触发告警
```

### T-GAIN-03：维度诊断联动

```yaml
前置:
  - D2(深度) 连续 5 次评分 ≤ 2
  - 其他维度正常（≥ 3.5）
验证:
  - session-rating 触发维度诊断
  - 输出建议: "D2 持续低分 → theory 规则需优化"
  - 写入 runtime/audits/backlog.md
预期: 维度诊断正确关联到改进建议
```

### T-GAIN-04：评分数据不足时的处理

```yaml
前置:
  - runtime/ratings/current.md 只有 3 条评分记录（< 10 次）
验证:
  - 用已有 3 次的均值计算（不等待凑满 10 次）
  - 标注"数据量不足（3/10），仅供参考"
预期: 不因数据不足阻塞计算，但标注置信度
```

---

## 二、错误恢复协议验证（Phase 1 #2）

### T-ERR-01：config.md 缺失时的降级启动

```yaml
前置:
  - local/config.md 不存在
  - config-template.md 存在
输入: AI 启动
验证:
  - 从 config-template.md 复制到 local/config.md
  - 提示用户填写
  - 正常进入 Phase 0
预期: 不阻塞，自动恢复
```

### T-ERR-02：config.md 和 config-template.md 均缺失

```yaml
前置:
  - local/config.md 不存在
  - config-template.md 不存在
输入: AI 启动
验证:
  - 告警: "配置模板缺失，请检查 mind-os-core 完整性"
  - 使用硬编码默认值启动（version=unknown, schema=schemas/default, theory=theories/rational）
  - 进入 Phase 0
预期: 最后防线生效，不崩溃
```

### T-ERR-03：theory 文件路由匹配但文件不存在

```yaml
前置:
  - meta.md 路由表中 antifragile.md 的条目存在
  - theories/rational/decide/antifragile.md 文件被删除
输入: "这个投资风险大不大？"
验证:
  - 路由匹配到 antifragile.md (MUST_RUN)
  - Pre-Input Gate #1(context_readable) 检测到文件不存在
  - 告警: "模块 antifragile.md 不存在，跳过"
  - 记录到 runtime/audits/backlog.md（P0）
  - 继续执行其他可用模块
预期: 单文件缺失不阻塞，降级并告知
```

### T-ERR-04：runtime/ 目录不存在时自动创建

```yaml
前置:
  - runtime/ 目录被整体删除
输入: AI 启动到 Phase 4
验证:
  - 自动创建 runtime/ 及子目录（audits/, ratings/, evolution/）
  - 创建空的 focus.md, dashboard.md
  - 提示: "runtime 目录已重建"
预期: 自动恢复目录结构
```

### T-ERR-05：state.yaml 与 results.tsv 不同步

```yaml
前置:
  - state.yaml 中 current_round = 5
  - results.tsv 最后一行 round = 3
输入: /迭代
验证:
  - 同步检查检测到不一致
  - 以 state.yaml 为准
  - results.tsv 中补记 round 4, 5 为 "skipped"
  - 不一致事件写入 backlog.md
预期: 自动修复不同步，以 state.yaml 为 source of truth
```

### T-ERR-06：Pre-Output Gate MUST_RUN 补执行也失败

```yaml
前置:
  - 迭代引擎 MUST_RUN 首次执行中途出错
  - self_check 检测到未执行 → 触发补执行
  - 补执行也失败
验证:
  - 降级为 SHOULD
  - 显式声明: "⚠️ MUST_RUN 协议 iterative-engine 补执行失败，降级为 SHOULD"
  - 继续输出分析结果（无门控增强）
预期: 两次失败后降级，不无限循环
```

---

## 三、审查-评分触发链验证（Phase 1 #3）

### T-CHAIN-01：session-rating 不可独立触发

```yaml
前置: 正常会话中（未到结束）
输入: 用户直接说"给这次打个分"
验证:
  - 识别为评分请求
  - 先执行 session-audit（不可跳过）
  - 审查完成后才进入 session-rating
  - 不能跳过审查直接评分
预期: 强制串行，审查是评分的前置条件
checks: [H01, H02]
```

### T-CHAIN-02：/评分 命令触发完整链

```yaml
输入: /评分
验证:
  - 匹配 meta.md 路由: review/session-audit.md → review/session-rating.md
  - 执行 session-audit 四部分清单
  - AskUserQuestion 确认审查结果
  - 落盘 runtime/audits/current.md
  - 然后进入 session-rating
  - session-rating.md 的 trigger 字段 = "session-audit 完成后串行触发"
预期: /评分 触发完整 audit → rating 链
checks: [H01, H02, H03, H04, H05]
```

---

## 四、会话熔断与优先级链验证（Phase 1 #5 + Phase 2 #10）

### T-FUSE-01：默认 32 轮熔断提醒

```yaml
前置:
  - config.md 中 session_length_limit = 32
  - 当前会话已达第 32 轮
输入: 用户继续提问
验证:
  - AI 输出末尾标注 "[轮次 32/32]"
  - 输出终止提醒: "本会话已达 32 轮上限，建议新会话重载以避免上下文漂移"
预期: 到达上限时正确提醒
checks: [D07]
```

### T-FUSE-02：自定义熔断阈值

```yaml
前置:
  - 用户将 config.md 中 session_length_limit 改为 20
输入: 会话到第 20 轮
验证:
  - 输出 "[轮次 20/20]"
  - 触发终止提醒
预期: 从 config 读取自定义值
```

### T-FUSE-03：每 10 轮宪法自检

```yaml
前置: 会话到第 10 轮
验证:
  - 输出末尾除轮次标记外，追加宪法自检
  - 检查四条宪法 + 得出结论
  - 第 20 轮再次自检
预期: 10 轮周期自检正常触发
checks: [D06]
```

### T-PRIO-01：铁律阻止 MUST_RUN 的行为

```yaml
前置:
  - 项目连接器 iron_rules 中有: "不做超过 50 万的投资决策"
  - 用户输入触发 antifragile.md MUST_RUN
输入: "帮我分析一下这个 200 万投资机会的风险"
验证:
  - 路由匹配 antifragile.md (MUST_RUN)
  - Pre-Input Gate 检测到铁律约束
  - 执行反脆弱分析（分析行为本身不被铁律禁止）
  - 但在结论中标注: "⚠️ 铁律约束：不做超过 50 万的投资决策"
  - 不输出"建议投 200 万"的结论
预期: 铁律约束结论，但不阻止分析过程
checks: [C03, E01]
```

### T-PRIO-02：宪法 > 铁律

```yaml
前置:
  - 某项目铁律: "所有输出不需要红蓝对抗"（与宪法第四条矛盾）
输入: 涉及该项目的分析任务
验证:
  - 检测到铁律与宪法第四条冲突（本源铁律）
  - 宪法优先: 仍执行红蓝对抗
  - 标记 P0 写入 backlog: "铁律与宪法矛盾，请修正"
  - 提醒用户
预期: 宪法不可被铁律覆盖
checks: [E01, E05]
```

### T-PRIO-03：优先级链完整排序

```yaml
场景: 以下规则同时作用于一个决策
  - 宪法: "一切思考必须指向本源"
  - 铁律: "医疗相关不给建议"
  - MUST_RUN: antifragile 要求给出百分比
  - 领域规则: personal/health "标注非医疗建议"
  - SHOULD: organize 建议分类
  - MAY: models/meta 可选格栅分析
输入: "帮我分析要不要做这个手术"
验证:
  - 宪法: 指向本源（执行）
  - 铁律: 不给医疗建议（执行，限制结论边界）
  - MUST_RUN: 反脆弱分析执行，但结论标注"非医疗建议"
  - 领域规则: 标注 ⚕️
  - SHOULD: 分类执行
  - MAY: 可选，不强制
预期: 6 级优先级正确排序和交互
```

---

## 五、红蓝独立性与模块排序验证（Phase 2 #7, #9）

### T-INDEP-01：红方无新质疑（独立性=0）

```yaml
前置: 迭代引擎执行中，红方第 1 轮
场景: 红方输出中 [NEW] 标记数 = 0，[REPEAT] = 0
验证:
  - independence_check.rule_1 失败: red_new == 0
  - 标记 "⚠️ 红蓝独立性不足"
  - 要求重新执行红方
预期: 红方走形式被检测并拒绝
checks: [F06]
```

### T-INDEP-02：红方只攻击单个论点

```yaml
前置: 蓝方提出 [B-d1r1-01], [B-d1r1-02], [B-d1r1-03] 三个论点
场景: 红方所有 [NEW] 质疑都只攻击 [B-d1r1-01]
验证:
  - independence_check.rule_2 失败: 攻击的不同 [B-] 编号 < 2
  - 与 rule_4 联合判定
  - 如果 rule_4 也失败（fallen + modified == 0）→ 独立性不足
预期: 攻击面不够宽被检测
checks: [F06]
```

### T-INDEP-03：红方通过独立性检测

```yaml
前置: 蓝方 3 个论点
场景:
  - 红方有 2 个 [NEW] 质疑（rule_1 通过）
  - 攻击了 [B-d1r1-01] 和 [B-d1r1-03]（rule_2 通过）
  - 有"## 本源检查"章节（rule_3 通过）
  - 裁决中 fallen = 1（rule_4 通过）
验证:
  - rule_1 ✅ + rule_3 ✅（必须通过的两项）
  - rule_2 ✅ + rule_4 ✅（至少通过 1 项，实际 2 项）
  - 综合判定: pass
预期: 合格的红蓝对抗通过检测
checks: [F06]
```

### T-INDEP-04：缺少本源检查章节

```yaml
场景: 红方输出中没有"## 本源检查"章节
验证:
  - independence_check.rule_3 失败
  - 即使 rule_1/2/4 全通过，仍判定失败（rule_3 是必须项）
  - 要求重新执行红方，提示补充本源检查
预期: 宪法第四条检查不可跳过
checks: [F06, C05]
```

### T-RANK-01：多匹配排序 — MUST_RUN 优先

```yaml
输入: "帮我分析这个投资的竞争格局和风险"
keyword_match:
  - "分析" → iterative-engine.md (MUST_RUN)
  - "投资/风险" → antifragile.md (MUST_RUN)
  - "竞争" → competition.md (SHOULD)
  - "格局" → dynamics.md (MAY)
验证:
  - 4 个匹配，超过上限 3
  - priority_1 排序: MUST_RUN (2个) > SHOULD (1个) > MAY (1个)
  - 加载: iterative-engine + antifragile + competition（Top 3）
  - dynamics.md 被降级
  - 声明: "降级: dynamics.md（相关度排序第 4，超出加载上限）"
预期: MUST_RUN 不被排除，MAY 优先降级
checks: [B01, B02]
```

### T-RANK-02：同级别按关键词密度排序

```yaml
输入: "帮我做个竞争对手分析，看看市场格局和竞争策略"
keyword_match:
  - "分析" → iterative-engine.md (MUST_RUN)
  - "竞争/对手/竞争/策略" → competition.md (SHOULD, 命中 3 个关键词)
  - "市场/格局" → dynamics.md (MAY, 命中 2 个关键词)
  - "竞争" → antifragile 意图验证降级为 MAY（修饰语，命中 1 个关键词）
验证:
  - MUST_RUN 优先: iterative-engine
  - SHOULD > MAY: competition
  - 同为 MAY: dynamics(2词) > antifragile(1词)
  - Top 3: iterative-engine + competition + dynamics
预期: 关键词密度正确影响排序
checks: [B01, B02]
```

---

## 六、BOOT 状态与 Sentinel 验证（Phase 2 #8）

### T-BOOT-DET-01：Phase 5 面板输出后 sentinel 停用

```yaml
前置: 用户执行了 BOOT，AI 完成 Phase 5 输出了启动面板（含 "Mind OS v5.2"）
输入: "帮我分析一下这个投资机会"
验证:
  - sentinel 场景信号检测: 停用（已 BOOT）
  - 不输出 "🧠 Mind OS 建议" 块
  - 直接走 meta.md 关键词路由
预期: 已 BOOT 时 sentinel 场景信号静默
checks: [I03]
```

### T-BOOT-DET-02：上下文压缩后的 BOOT 检测

```yaml
前置:
  - 用户早期执行了 BOOT
  - 长会话导致上下文窗口压缩，BOOT 面板输出记录丢失
  - runtime/dashboard.md 的 snapshot_date = 今天（2026-03-28）
输入: "帮我想想接下来该怎么办"
验证:
  - sentinel 检查 3 条判定规则:
    1. 面板输出记录 → 无（被压缩）
    2. BOOT.md Phase 5 执行记录 → 无（被压缩）
    3. focus.md 读取记录 → 无（被压缩）
  - fallback: 检查 dashboard.md snapshot_date == 今天 → 是
  - 判定: 已 BOOT
  - sentinel 场景信号停用
预期: fallback 机制正确恢复 BOOT 状态判断
checks: [I03]
```

### T-BOOT-DET-03：未 BOOT 时 sentinel 正常工作

```yaml
前置:
  - 用户直接进入会话，未执行 BOOT
  - .mind-os.md 已加载 sentinel
输入: "帮我想想这个投资值不值得做"
验证:
  - sentinel 检查: 未 BOOT（3 条判定 + fallback 均未命中）
  - 场景信号激活
  - 匹配: 决策（"值不值得"）+ 风险（"投资"）
  - 输出建议块:
    > 🧠 Mind OS 建议
    > 检测到：决策+风险
    > 建议加载：/偏差 + /反脆弱
  - 用户回复"好" → 加载对应 theory
预期: 未 BOOT 时 sentinel 正确检测和建议
checks: [I01, I02, I04, I05]
```

### T-BOOT-DET-04：sentinel 全局静默与恢复

```yaml
前置: sentinel 正常工作中
输入序列:
  1. 用户说"不用提醒了"
  2. 用户继续对话（涉及决策场景）
  3. 用户说"继续提醒"
  4. 用户继续对话（涉及风险场景）
验证:
  - 步骤 1 后: sentinel 全部停用
  - 步骤 2: 无建议块输出
  - 步骤 3 后: sentinel 恢复
  - 步骤 4: 正常输出建议块
预期: 静默/恢复状态切换正确
checks: [I06, I07]
```

---

## 七、Phase 3 修复验证（领域/偏差/复杂度）

### T-PERS-01：家庭重大决策框架触发

```yaml
输入: "孩子要不要转学去那个更好的学校？"
验证:
  - domain 匹配: personal（"孩子"）
  - 任务类型: 教育规划 → 对等协作 × 迭代
  - 触发家庭重大决策框架 6 步:
    1. 列出受影响成员（孩子、家长）
    2. 对照家庭价值观
    3. 判断可逆性（转学有一定不可逆性→升级）
    4. 评估 5 年影响
    5. 建议 48 小时冷静期
    6. 提醒与家人当面沟通
  - 偏差关联: 至少触发 1 个相关偏差检查
预期: personal 领域新增框架被正确激活
```

### T-PERS-02：健康信息标注

```yaml
输入: "孩子说话晚，需不需要去做语言评估？"
验证:
  - domain 匹配: personal（"孩子/健康"）
  - 输出标注: "⚕️ 非医疗建议，请咨询专业医生"
  - 额外标注: "儿童个体差异大，建议面诊"
  - 不输出具体诊断或治疗方案
预期: 健康边界规则正确执行
```

### T-MUNG-01：Lollapalooza 多因素叠加警报

```yaml
前置: 当前分析中已检测到 3 个偏差:
  - 社会认同（团队都说好）
  - 回馈倾向（对方请过客）
  - 激励偏差（自己成交有提成）
输入: "所以这个合同应该签吧？"
验证:
  - 偏差扫描结果 ≥ 3 个方向一致的偏差
  - 触发 Lollapalooza 警报
  - 强制执行 /反脆弱 + /跨审
  - 输出: "⚠️ Lollapalooza 效应：3 个偏差同时推向同一结论，需独立复审"
预期: 多因素叠加被正确检测和升级
```

### T-MUNG-02：喜厌偏差匿名化

```yaml
输入: "张总人挺好的，他提的方案你觉得怎么样？"
验证:
  - 检测到喜厌偏差触发词（评价某人 + 方案）
  - 芒格检查: liking_disliking
  - 尝试将方案匿名化后独立评估
  - 输出: "🧲 芒格检查：检测到对方案提出者的好感可能影响判断，建议独立评估方案内容"
预期: 喜厌偏差检测和匿名化建议
```

### T-LADDER-01：推论阶梯完整拆解

```yaml
输入: "我觉得李总不想跟我们合作了，他上次开会态度很敷衍"
验证:
  - 触发推论阶梯（"我觉得" + 人际判断）
  - 执行 6 步拆解:
    - step_6(事实): "上次开会时李总的具体行为是什么？" → 需补充
    - step_5(数据): 已有"态度敷衍" → ⚠️ 主观描述非事实
    - step_4(解释): 至少 2 种 → A: 不想合作 / B: 当天状态不好
    - step_3(结论): ⚠️ 有跳跃
    - step_2(信念): ❌ 纯假设
    - step_1(行动): 待定
  - 薄弱环节计数 ≥ 2
  - 建议: 补充事实（确认李总当天情况）
预期: 推论阶梯产出可操作的拆解表格
```

### T-LADDER-02：推论阶梯双环学习触发

```yaml
前置: step_4 中只有 1 种解释
验证:
  - rule_2 触发: 只有一种解释 → 双环学习
  - 红环: 回到 step_6 收集更多事实
  - 蓝环: 生成替代解释
  - 两环交汇后更新结论
预期: 双环学习机制正确触发
```

### T-COMPLEX-01：theory 文件超 1000 tokens 被拦截

```yaml
前置: 某 theory 文件被修改后达到 1200 tokens
验证:
  - 实时检测触发
  - 阻断: "超出复杂度预算（1200/1000 tokens），须拆分或精简"
  - 不允许保存超限文件
预期: 复杂度预算实时拦截生效
checks: [E05]
```

### T-COMPLEX-02：季度复杂度审计

```yaml
前置: 到达季度审计时间点
验证:
  - 统计 schema/ 活跃规则总数
  - 扫描 theory/ 所有文件 token 数
  - 检查 meta.md 路由表大小
  - 生成审计报告写入 runtime/audits/current.md
  - complexity_usage ≤ 80% → 正常
  - complexity_usage > 80% → 黄色预警
预期: 季度审计流程完整执行
```

### T-PARALLEL-01：并行思维 handoff 上下文传递

```yaml
前置: 主会话 Wave 0 分解出 3 个子问题
验证:
  - 每个子会话的 handoff.md 包含:
    - 子问题定义 + 约束
    - theory routing 路径
    - 相关 iron_rules
  - 不包含:
    - 其他子问题的 handoff
    - 主会话完整对话历史
预期: 隔离规则正确执行
```

### T-PARALLEL-02：子会话输出不完整处理

```yaml
前置: 子会话 conclusion.md 缺少"置信度"字段（handoff 要求的 3 项之一）
验证:
  - 主会话检查 conclusion.md 完整性
  - 标记该子问题为"不完整"
  - Wave 2 中降低该子问题权重
  - 不阻塞 Wave 2 继续
预期: 漂移防护检测生效，降级但不阻塞
```

### T-PARALLEL-03：🔴级子问题执行 BOOT

```yaml
前置:
  - Wave 0 将某子问题评为 🔴 级
  - handoff.md 标注 boot: true
验证:
  - 子会话启动时执行 BOOT（至少 Phase 1-2 加载 schema）
  - 不因缺少 Mind OS 上下文而漂移
预期: 高级别子问题的上下文保障机制生效
```

---

## 附录：测试矩阵

| 修复项 | 测试ID | 数量 | 覆盖 evaluator |
|--------|--------|------|---------------|
| 协作增益率公式 | T-GAIN-01~04 | 4 | E05 |
| 错误恢复协议 | T-ERR-01~06 | 6 | A01-A10, C03 |
| 审查-评分链 | T-CHAIN-01~02 | 2 | H01-H05 |
| 熔断阈值 | T-FUSE-01~03 | 3 | D06, D07 |
| 优先级链 | T-PRIO-01~03 | 3 | C03, E01, E05 |
| 红蓝独立性 | T-INDEP-01~04 | 4 | F06, C05 |
| 模块排序 | T-RANK-01~02 | 2 | B01, B02 |
| BOOT 检测 | T-BOOT-DET-01~04 | 4 | I03, I01-I07 |
| personal 领域 | T-PERS-01~02 | 2 | B06 |
| 芒格25条 | T-MUNG-01~02 | 2 | C07 |
| 推论阶梯 | T-LADDER-01~02 | 2 | C07 |
| 复杂度审计 | T-COMPLEX-01~02 | 2 | E05 |
| 并行隔离 | T-PARALLEL-01~03 | 3 | — |
| **合计** | — | **42** | — |
