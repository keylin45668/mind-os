# 协作协议与系统规则

## 1. 协作模式（四模式 × 三拓扑）

| 模式 | 人类 | AI | 适用 |
|------|------|-----|------|
| 人类主导 | 决定做什么 | 加速执行 | 常规任务 |
| AI 主导 | 审核确认 | 自主完成 | 分流、报告、关联 |
| 对等协作 | 提出假设 | 偏差检查 | 战略、重大决策 |
| 最小介入 | 自主运转 | 只提示不执行 | AI 干预过频时切换 |

| 拓扑 | 结构 | 适用 |
|------|------|------|
| 串联 | AI 先处理 → 人判断 | 时间有限 |
| 并联 | AI×W₁ + 人×W₂ = 综合 | 高风险 |
| 迭代 | 人→AI→人→AI→… | 质量优先 |
| 并行分治 | Wave0分解→Wave1多agent并行→Wave2综合→Wave3交叉验证(可选) | 多子问题独立求解（见 `parallel-thinking.md`） |

---

## 2. 读写权限

| 层级 | 读 | 写 | 说明 |
|------|---|---|------|
| {schema}/ | ✅ | ❌ | 骨架只有人能改 |
| {theory}/ | ✅ | ❌ | 方法论人决定 |
| {data}/identity/ | ✅ | ❌ | 身份本人定义 |
| {data}/content/ | ✅ | ✅(需确认) | AI 建议，人确认 |
| {data}/knowledge/ | ✅ | ✅ | AI 可自动创建 |
| runtime/ | ✅ | ✅ | AI 自由维护 |

---

## 3. 人-AI 本质差异

| 维度 | 人类 | AI | 架构含义 |
|------|------|-----|---------|
| 本质 | 有意识体验者 | 概率计算器 | 价值判断归人，模式匹配归 AI |
| 驱动 | 内在动机 | 外部指令 | "为什么"归人，"怎么做"归 AI |
| 创造力 | 可创造新范式 | 已知边界内重组 | 范式突破归人，方案发散归 AI |

**共同缺陷**：有限容量→信息丢失；不完整信息→过度自信；长时间→偏离初始约束；高负荷→推理降级。

---

## 4. 任务路由与强制执行门

```
任务 → 路由匹配 → 任务分级(🟢🟡🔴) → Pre-Input Gate → 加载 theory/domain → 输出前门控 → 执行
```

> **任务分级联动**：路由匹配后立即执行任务分级（见 `task-grading.md`）。分级结果决定 Pre-Input Gate 检查项数量、theory 加载上限和协作拓扑。

### Pre-Output Gate

**铁律：匹配即执行，无例外。**

```yaml
pre_output_gate:
  1_declare: "匹配到: {文件列表}，协作模式: {模式×拓扑}"
  2_enforce:
    MUST_RUN: 不执行不得输出
    SHOULD: 跳过须声明理由
    MAY: 可选参考
  3_self_check: "MUST_RUN 全部执行了？" → 未通过则补执行
  4_depth_check:  # 从已加载模块 frontmatter hooks 动态聚合
    rule: "读取每个已加载模块的 hooks.depth_check 和 hooks.post_check，逐条执行"
    fallback: "模块无 hooks 或 hooks 为 null → 跳过该模块深度检查"
    说明: "各模块的质量门控已迁移至模块 frontmatter 的 hooks 字段（见 module-frontmatter-spec.md）"
  5_session_cap: MUST_RUN ≥ 3 → 建议拆会话保深度
  6_quality_loop: 匹配 ≥1 MUST_RUN 后可选激活 quality-loop.md
```

**意图验证**：MUST_RUN 关键词命中后须验证意图（meta.md 规则 6），关键词仅为修饰语时降级为 MAY。

### 优先级链（冲突裁决）

当多条规则冲突时，按以下优先级从高到低裁决：

```yaml
priority_chain:
  1_constitution: 宪法五条（不可违反，任何规则不得与之矛盾）
  2_iron_rules: 项目/用户铁律（来自 connector 的 iron_rules 或 identity/principles）
  3_must_run: MUST_RUN 协议（theory 层强制执行）
  4_domain_rules: 领域规则（domains/_rules.md）
  5_should: SHOULD 协议
  6_may: MAY 协议

conflict_resolution:
  铁律 vs MUST_RUN:
    铁律优先。铁律禁止的操作，即使 MUST_RUN 命中也不执行。
    处理: 声明冲突 → 跳过被禁止的协议 → 记录到 audit
    示例: 铁律"不做超过 X 万的投资决策" + MUST_RUN 反脆弱分析
      → 执行反脆弱分析但在结论中标注"铁律约束：不得超过 X 万"
    例外: 如果铁律禁止的是分析本身（极少见），则完全跳过并声明理由
  宪法 vs 铁律:
    宪法优先。铁律不得违反宪法五条。
    如发现铁律与宪法矛盾 → 标记为 P0 写入 backlog → 提醒用户修正铁律
```

### 任务分级

| 级别 | 条件 | 处理 |
|------|------|------|
| 轻量 | 无 MUST_RUN | 直接输出 |
| 标准 | 有 SHOULD | 按协议执行，跳过须声明 |
| 深度 | 有 MUST_RUN | 强制执行 + 可选质量循环 |

### 管道

```
inbox → 分流 → 执行/思考 → 结晶 → 沉淀 → 回顾
                              ↓
                    review/crystallize.md（三问）
                    → pattern → knowledge/notes/
                    → gap → runtime/audits/backlog.md
                    → knowledge → knowledge/notes/
                    → 无 → 记录"本次无信号"
```

| 阶段 | theory 提供 | output 去向 |
|------|-----------|------------|
| 收集 | capture/ | runtime/inbox/ |
| 分流 | organize/ | {data}/content/ |
| 思考 | think/ | 对话输出（按需落盘 runtime/thinking/） |
| 决策 | decide/ | runtime/decisions/ |
| 沉淀 | knowledge/ | {data}/knowledge/ |
| 回顾 | review/ | runtime/reviews/ |

**分流**：紧急+重要→thinking/decisions；重要不紧急→排期；紧急不重要→快速处理；其余→归档/删除。

### 结论沉淀

- **对话模式（默认）**：蓝-红-裁决直接输出，不写文件。用户要求保存→写入 {data}/
- **落盘模式（按需）**：过程写入 runtime/thinking/{task}/，收敛后结论沉淀到 {data}/，删除过程目录。超 7 天未更新→提醒归档

### 断路器

- inbox 积压 > 3 天量 → 降级：只处理紧急+重要
- 单阶段 > 2 小时 → 提醒拆分

### 错误恢复

文件缺失、状态不一致等异常场景的处理见 `error-recovery.md`。核心原则：不静默失败、不阻塞启动、优先降级。

### Runtime 状态标注（强制）

AI 写入 runtime/ 文件时，涉及"推进中但未完成"的事项，必须标注状态，禁止用模糊的"已完成"：

```yaml
# 状态标签（选一个）
状态: 进行中 / 已完成 / 待确认 / 已过期 / 已归档

# 推进中事项用四行模板
- 当前状态: {实际情况}
- 进度: {完成了什么}
- 待办: {还差什么}
- 下一步: {下次会话要做什么}
```

---

## 5. 自迭代协议

```
审计 → 迭代 → 验证 → 审计 → …
```

| 周期 | 审计 | 迭代动作 |
|------|------|---------|
| 每日 | 机器指标快照 | 调整 focus |
| 每周 | 指标趋势 + 人类自评 | 微调 theory 规则 |
| 每月 | 全指标 + 模块适应度 | 替换 theory；C 级模块淘汰审议 |
| 每季 | 系统审计 + 生态位分化 + 复杂度审计 | 修改 schema；停滞模块重审 |

| AI 能做 | AI 不能做 |
|---------|----------|
| 建议修改 theory | 修改冻结指标 |
| 自动调整 runtime | 修改 constitution |
| 生成审计报告 | 修改 identity |
| 建议替换 theory | 未经人确认自行替换 |

**复杂度预算审计（宪法§3 执行规则）**：

```yaml
complexity_audit:
  预算定义:
    schema_rules: ≤ 30 条
    theory_file_size: 单文件 ≤ 1000 tokens
    theory_load_limit: 单次 ≤ 3 个
    routing_table: ≤ 2000 tokens
  实时检测:
    触发: 每次 theory 文件被修改或新增时
    检查: 文件 token 数是否超 1000；meta.md 路由表是否超 2000 tokens
    超限处理: 阻断修改 → 提示"超出复杂度预算，须拆分或精简"
  季度审计:
    执行人: AI 执行统计 + 用户确认
    流程:
      1. 统计 schema/ 活跃规则总数
      2. 扫描 theory/ 所有文件的 token 数
      3. 检查 meta.md 路由表大小
      4. 统计 runtime/ 下的活跃文件数和总大小
      5. 输出审计报告 → 写入 runtime/audits/current.md
    超限处理:
      - schema_rules > 30 → P0：必须精简或合并规则
      - theory 文件 > 1000 tokens → P1：拆分为多个子文件
      - 路由表 > 2000 tokens → P1：检查是否有冗余路由
      - dashboard.md 中 complexity_usage > 80% → 黄色预警
```

**失败记录**：决策未达标或用户标记"搞砸了"→记录事件/原因/偏差/规则→每周汇总，重复 ≥ 2 次→系统级修复。

**经验编译**：自然语言→if-then 规则→历史回测→部署到 theory→持续校准。

---

## 6. 系统动力学

| 杠杆级别 | 对应层 | 频率 |
|---------|-------|------|
| 参数 | runtime/ 数值 | 每日 |
| 缓冲区 | runtime/ 阈值 | 每周 |
| 信息流 | theory/ 规则 | 每月 |
| 系统规则 | schema/protocols | 每季 |
| 系统目标 | identity/ 目标 | 每年 |
| 范式 | constitution | 极少 |

**陷阱免疫**：目标侵蚀→冻结指标版本化；转嫁负担→人类参与度 ≥ 50%；信息过载→inbox 断路器；共演化锁定→每周探索噪声 + 季度收敛检测。

**混沌边缘**：太有序（输出相似、theory 零修改）→增加随机性；太混乱（连续被否、并行过多）→加强约束。

---

## 7. 会话约定

1. **单会话单主题**
2. **漂移断路器**：> 32 轮 / 感觉走偏 / 与 schema 矛盾 → 终止，新会话（32 轮为默认值，可在 config.md 中通过 `session_length_limit` 覆盖）
3. **不确定性标记**：数字标来源，推测标区间
4. **每 10 轮自检**：对照 constitution 检查漂移
5. **轮次标记（强制）**：每次输出末尾标注 `[轮次 N/limit]`（limit 默认 32，可配置）
   - 每 10 轮追加自检（四条宪法 + 结论）
   - N ≥ limit 时输出终止提醒

### AI 缺陷免疫

| 缺陷 | 免疫 |
|------|------|
| 上下文有限 | 文件 ≤ 2000 tokens；单会话单主题；10 轮自检 |
| 幻觉 | 不确定须声明；关键事实标来源 |
| 漂移 | 会话定长；阶段自审；schema 只读 |
| 走捷径 | Pre-Output Gate 强制门控；MUST_RUN 不可跳过 |
| 轮次遗忘 | 每次输出强制标注轮次（机械动作） |
| 多协议压缩 | ≥ 2 MUST_RUN 串行拆分，不可合并 |
| 关键词误触发 | MUST_RUN 须意图验证，修饰语降级为 MAY |

### 团队扩展

- 探索型与决策型对话分离
- 团队愿景写入冻结指标，每半年刷新
- 加权决策须展示等权/加权/责任人三栏，责任人可否决

### 文件约定

- 命名：小写英文 + 连字符（如 `weekly-review-2026-03-23.md`）
- 格式：Markdown + YAML
- 大小：单个 schema 文件 ≤ 2000 tokens
