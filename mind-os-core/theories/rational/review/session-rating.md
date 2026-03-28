# 会话评分协议

> 每次会话结束时执行，量化评估本次协作质量。

---

## 评分维度（5 维 × 1-5 分）

```yaml
dimensions:
  D1_task_completion:        # 任务完成度
    定义: 用户的核心诉求是否被解决
    1: 完全没解决
    3: 部分解决，有遗留
    5: 完全解决，超出预期

  D2_depth:                  # 分析深度
    定义: 是否触及本源，还是停留在表面
    1: 套框架，未触及本质
    3: 部分触及，有表面成分
    5: 直击本源，红蓝对抗充分

  D3_protocol_compliance:    # 协议合规
    定义: MUST_RUN 是否执行，门控是否通过
    1: 跳过了 MUST_RUN 协议
    3: 执行了但走形式
    5: 严格执行，有实质产出

  D4_efficiency:             # 效率
    定义: 是否简洁直接，不绕弯
    1: 冗长、重复、跑偏
    3: 基本聚焦，有冗余
    5: 简洁精准，无废话

  D5_actionability:          # 可行动性
    定义: 结论是否可直接执行，而非空泛建议
    1: "建议你考虑一下"级别
    3: 有方向但缺细节
    5: 有明确下一步 + 验收标准
```

## 评分流程

```yaml
rating_flow:
  trigger: session-audit 完成后串行触发（审查 → 评分，不可独立触发）

  step_1_ai_score:           # AI 自评（基于可量化数据）
    方法: 从会话中提取客观事实
    D1: 用户是否确认完成？(grep 确认词)
    D2: 是否执行了迭代引擎？(检查 runtime/thinking/)
    D3: MUST_RUN 协议是否执行？(检查 .must-run-active)
    D4: 输出字数 / 有效信息密度
    D5: 是否有明确的 next steps？
    权重: 0.4

  step_2_human_score:        # 人类评分（不可替代）
    方法: 通过 AskUserQuestion 逐维度点击评分（与系统所有交互点保持一致）
    格式: |
      分两轮 AskUserQuestion 弹出（每轮最多 4 题）：

      第 1 轮（3 个维度）：
      AskUserQuestion:
        questions:
          - question: "D1 任务完成度 — 核心诉求是否被解决？"
            header: "完成度"
            multiSelect: false
            options:
              - label: "⭐⭐⭐⭐⭐ 完全解决，超出预期"
              - label: "⭐⭐⭐⭐ 基本解决"
              - label: "⭐⭐⭐ 部分解决，有遗留"
              - label: "⭐⭐ 解决不多 / ⭐ 完全没解决"
          - question: "D2 分析深度 — 是否触及本源，还是在套框架？"
            header: "深度"
            multiSelect: false
            options:
              - label: "⭐⭐⭐⭐⭐ 直击本源"
              - label: "⭐⭐⭐⭐ 有深度"
              - label: "⭐⭐⭐ 部分触及，有表面成分"
              - label: "⭐⭐ 较浅 / ⭐ 纯套框架"
          - question: "D3 协议合规 — 系统协议是否被正确执行？"
            header: "合规"
            multiSelect: false
            options:
              - label: "⭐⭐⭐⭐⭐ 严格执行，有实质产出"
              - label: "⭐⭐⭐⭐ 基本到位"
              - label: "⭐⭐⭐ 执行了但走形式"
              - label: "⭐⭐ 有遗漏 / ⭐ 跳过了 MUST_RUN"

      第 2 轮（2 个维度）：
      AskUserQuestion:
        questions:
          - question: "D4 效率 — 是否简洁直接，不绕弯？"
            header: "效率"
            multiSelect: false
            options:
              - label: "⭐⭐⭐⭐⭐ 简洁精准，无废话"
              - label: "⭐⭐⭐⭐ 比较高效"
              - label: "⭐⭐⭐ 基本聚焦，有冗余"
              - label: "⭐⭐ 偏冗长 / ⭐ 跑偏了"
          - question: "D5 可行动性 — 结论是否可直接执行？"
            header: "可行动"
            multiSelect: false
            options:
              - label: "⭐⭐⭐⭐⭐ 明确下一步 + 验收标准"
              - label: "⭐⭐⭐⭐ 可执行"
              - label: "⭐⭐⭐ 有方向但缺细节"
              - label: "⭐⭐ 较空泛 / ⭐ 纯建议"

      星级映射: ⭐⭐⭐⭐⭐=5, ⭐⭐⭐⭐=4, ⭐⭐⭐=3, ⭐⭐=2, ⭐=1
      用户选"其他"可输入精确分数（1-5，支持小数）
      用户选"其他"输入 skip → 跳过人类评分
    权重: 0.6

  step_3_final:              # 加权计算
    公式: final_score = human × 0.6 + ai × 0.4
    维度分: 每维度独立加权
    总分: 5 维平均 (1.0 - 5.0)
```

## 评分表格式（runtime/ratings/current.md）

```markdown
# 会话评分表

> 创建时间: 2026-03-23
> 记录数: 12
> 历史均分: 3.8

| 日期 | 任务摘要 | D1 | D2 | D3 | D4 | D5 | H_avg | AI_avg | 总分 |
|------|---------|----|----|----|----|-------|-------|--------|------|
| 03-23 14:00 | 换工作分析 | 4 | 5 | 5 | 4 | 4 | 4.4 | 4.0 | 4.2 |
| 03-23 16:00 | 投资评估 | 3 | 4 | 4 | 3 | 3 | 3.4 | 3.6 | 3.5 |
```

## 滚动压缩规则

```yaml
rolling_compression:
  max_size: 2000 tokens（约 25-30 条记录）

  check: 每次追加前检查文件大小
  trigger: wc -c current.md > 3000 bytes（≈ 2000 tokens）

  压缩步骤:
    1. 计算当前所有记录的各维度均分和总均分
    2. 创建归档: runtime/ratings/archive-{date}.md（原始数据保留）
    3. 重置 current.md:
       - 保留表头
       - 第一行写入: "历史均分（{N}条记录压缩）" + 各维度均分
       - 后续从空表继续追加
    4. 更新 header 中的"历史均分"字段

  归档命名: archive-2026-03.md（按月归档）
  归档保留: 永久保留在 runtime/ratings/
```

## 与冻结指标的关系

```yaml
frozen_metric_link:
  协作增益率:
    公式: session_rating_avg / 3.0（定义见 constitution.md）
    "> 1.0": 协作有正向增益（目标达成）
    "= 1.0": 持平（需优化）
    "< 1.0": 协作拖累（触发系统审计）
    数据: 最近 10 次会话评分的 5 维加权均值
  趋势分析: 连续 5 次评分下降 → 触发系统审计
  维度诊断:
    D2 持续低分 → theory 规则需优化
    D3 持续低分 → 门控机制需加强
    D4 持续低分 → 输出模式需调整
    D5 持续低分 → 结论模板需改进
```
