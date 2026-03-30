---
name: session-audit
command: /评分
keywords: [会话结束, 评分, 质量]
execution_level: MUST_RUN
type: metric
domain: review
summary: "会话结束审查：协议执行合规检查 + 系统优化点发现，与session-rating串行(先审后评)"
context: default
hooks:
  pre_check: null
  post_check: "审查清单每项有具体依据"
  depth_check: null
---

## 摘要

- **定位**：回答"哪里没做到、系统怎么改"（session-rating 回答"多少分"）
- **执行时机**：会话结束时，先执行本协议审查，再进入 session-rating 评分
- **检查维度**：MUST_RUN 是否全部执行 / Pre-Output Gate 是否合规 / 是否有遗漏的偏差检查
- **输出**：优化建议写入 runtime/audits/backlog.md

# 会话执行审查协议

---

## 触发条件

```yaml
trigger: 会话结束信号（与 session-rating 同触发）
执行顺序: session-audit（本协议）→ session-rating（评分）
耗时预算: AI 自审 ≤ 2 分钟，用户确认 ≤ 1 轮交互
```

---

## 审查清单（AI 自审 + 用户确认）

### 第一部分：路由与门控

AI 回顾本次会话，逐条自检：

```yaml
routing_check:
  R1_keyword_match: "路由关键词匹配是否准确？有无漏匹配/误匹配？"
    # ✅ 准确 / ⚠️ 有偏差（说明）/ ❌ 明显错误
  R2_intent_verify: "MUST_RUN 意图验证是否执行？降级是否显式声明？"
    # ✅ 已执行 / ⚠️ 执行但不严谨 / ❌ 跳过 / ➖ 无 MUST_RUN 不适用
  R3_gate_pass: "输出前门控（declare → enforce → self_check）是否完整通过？"
    # ✅ 完整 / ⚠️ 部分缺失 / ❌ 跳过门控
  R4_mode_fit: "协作模式×拓扑选择是否合理？"
    # ✅ 合理 / ⚠️ 可优化（说明）
```

### 第二部分：宪法对齐

```yaml
constitution_check:
  C1_transform: "认知活动是否符合 Transform(input, context) → output？"
    # ✅ 符合 / ❌ 脱离范式
  C2_frozen_metrics: "是否触碰/篡改了冻结指标？"
    # ✅ 未触碰 / ❌ 违规（说明）
  C3_complexity: "复杂度是否在预算内？（加载文件数、规则数）"
    # ✅ 在预算内 / ⚠️ 接近上限 / ❌ 超限
  C4_origin: "分析是否指向本源？还是在套框架？"
    # ✅ 触及本源 / ⚠️ 部分表面 / ❌ 纯套框架
```

### 第三部分：执行质量

```yaml
execution_check:
  E1_must_run: "所有 MUST_RUN 协议是否实质执行（非走形式）？"
    # ✅ 实质执行 / ⚠️ 走形式 / ❌ 跳过 / ➖ 无 MUST_RUN
  E2_depth_check: "执行深度验证是否通过？（红方≠蓝方、量化非空泛）"
    # ✅ 通过 / ⚠️ 深度不足 / ❌ 未验证 / ➖ 不适用
  E3_output_template: "输出是否符合 output-template 规范？（总纲+分章节）"
    # ✅ 符合 / ⚠️ 部分符合 / ❌ 不符合 / ➖ 轻量级任务不适用
  E4_session_rules: "会话规则是否遵守？（语言锁定、轮次标记、不确定性标记）"
    # ✅ 遵守 / ⚠️ 部分遗漏（说明）
```

### 第四部分：系统改进发现

```yaml
improvement_scan:
  I1_protocol_gap: "本次执行中发现协议/规则的缺口或矛盾？"
    # 具体描述 / 无
  I2_routing_gap: "有任务/场景路由表未覆盖？需要新增路由条目？"
    # 具体描述 / 无
  I3_theory_gap: "现有 theory 模块是否能支撑本次任务？缺什么？"
    # 具体描述 / 无
  I4_ux_issue: "交互体验上有什么卡点？（信息采集、输出格式等）"
    # 具体描述 / 无
```

### 第五部分：进化信号检查（宪法第五条）

> 每次任务必须产出两类结果：用户的答案 + 系统进化的信号。
> 本部分检查进化信号是否被捕获——如果全部为"无"，说明进化回路可能断裂。

```yaml
evolution_check:
  V1_pattern_captured: "本次任务中是否发现了可复用的思考模式？"
    # 具体描述（如"团队管理类任务的标准分析框架"）/ 无
    # 如有 → 应沉淀到 knowledge/ 或 反馈到 theory 模块

  V2_module_feedback: "任务执行过程中，哪个模块表现好？哪个不够用？"
    # 好: {模块名} — {为什么好}
    # 不够用: {模块名} — {缺什么} → 写入 backlog

  V3_data_enriched: "用户的 data 是否因本次任务变得更丰富？"
    # ✅ 新增了 content/knowledge 文件
    # ⚠️ 有价值信息但未沉淀
    # ➖ 轻量任务，无需沉淀

  V4_acceleration_potential: "如果下次遇到类似任务，能比这次更快吗？为什么？"
    # 能: {原因，如"已有组织架构模板，下次直接复用"}
    # 不能: {原因，如"纯一次性任务"}
    # 这不是考核，是进化信号采集——"不能"也是有效回答

  V5_evolution_landed: "进化信号是否已落入持久化存储？"
    # 检查: backlog / knowledge / audit 记录中至少一处有本次发现
    # ✅ 已落盘 / ❌ 发现了但没记录（违反宪法第五条）/ ➖ 无发现
```

---

## 执行流程

```yaml
audit_flow:
  step_1_ai_self_audit:
    # AI 回顾会话，填写上述 4 部分清单
    # 输出格式：表格（见下方模板）
    # 每条给出 ✅/⚠️/❌/➖ 标记 + 简短说明

  step_2_user_confirm:
    # 通过 AskUserQuestion 让用户确认
    方法: |
      AskUserQuestion:
        question: "以上审查结果是否准确？有补充吗？"
        header: "审查确认"
        options:
          - label: "确认无误"
            description: "审查结果准确，直接记录"
          - label: "有补充"
            description: "选'其他'输入你发现的问题或不同意的地方"

  step_3_save:
    # 将审查结果追加到 runtime/audits/current.md
    # 如有 ⚠️ 或 ❌ 条目 → 同时生成改进工单到 runtime/audits/backlog.md

  step_4_then_rating:
    # 审查完成后，进入 session-rating 评分流程
```

---

## 落盘格式

### runtime/audits/current.md（审查记录）

```markdown
## {date} — {任务摘要}

| 检查项 | 结果 | 说明 |
|--------|------|------|
| R1 路由匹配 | ✅ | — |
| R2 意图验证 | ⚠️ | 降级声明不够显式 |
| ... | | |

改进发现：
- I4: 评分应改为点击选项式（已修复）
```

### runtime/audits/backlog.md（改进待办）

```markdown
# 系统改进待办

| 日期 | 来源 | 问题 | 改进建议 | 状态 | 优先级 |
|------|------|------|---------|------|--------|
| 03-24 | I4 | 评分用手动输入不一致 | 改为 AskUserQuestion | done | P1 |
| 03-24 | R3 | 会话结束漏触发评分 | 扩展结束信号关键词 | done | P1 |
```

**状态流转：** open → in_progress → done
**优先级：** P0=宪法违规必须立即修 / P1=协议缺口尽快修 / P2=体验优化有空再修

---

## 滚动压缩

```yaml
compression:
  # 与 session-rating 相同策略
  max_size: 2000 tokens
  trigger: 文件超限时压缩历史记录
  archive: runtime/audits/archive-{yyyy-mm}.md
```

---

## 与其他协议的关系

```yaml
dependencies:
  前置: 无（会话结束时第一个执行）
  后续: session-rating（审查完成后触发评分）
  输入: 本次会话的路由声明、门控记录、执行过程
  输出: 审查记录 + 改进待办
  联动:
    - backlog 中 P0/P1 项 → 下次 autoevolve 时优先处理
    - 连续 3 次同一检查项 ⚠️/❌ → 升级为 P0，触发专项修复
```
