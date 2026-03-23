# 任务级质量循环（Quality Loop）

> 来源：AutoEvolve 跨会话迭代 → 任务内收敛
> 核心：Draft → 自评 → 修复 → 再评 → 交付。质量驱动收敛，非固定轮次。

---

## 触发与激活

```yaml
trigger:
  条件: 任务路由匹配 ≥1 MUST_RUN（经意图验证后仍为 MUST_RUN）
  提示: "本任务涉及 {协议名列表}，建议激活质量循环。激活？[Y/n]"
  激活: 用户回复 Y / 直接回车
  跳过: 用户回复 n → 正常 Pre-Output Gate 流程
```

---

## 动态检查清单

从匹配到的 MUST_RUN 协议的**步间门控清单**（meta.md 规则 7）中提取，加 2 项通用项：

```yaml
universal_checks:  # 固定 2 项
  - 结论是否指向本源（宪法第四条）
  - 输出是否回答了用户的核心问题

protocol_checks:  # 从 meta.md 步间门控提取
  antifragile: [三元分类+百分比, 杠铃策略, 否定法]
  system_audit: [路径选择+理由, 方法A/B/C/D各项]
  iterative_engine: [蓝-红-裁决完整, 红方首要=本源, 比较报告]
  think_index: [≥2种偏差, 关联用户情境, 行动建议]

checklist_cap: 10  # 超过则只取权重最高的协议
```

---

## 循环协议

```yaml
round_1:
  1_draft: AI 按 MUST_RUN 协议执行，生成内部初稿（不输出）
  2_evaluate: 逐条对照动态检查清单，标记 ✅/❌
  3_count: ISSUES = ❌ 数量

round_N:  # 仅 ISSUES > 0 时
  1_fix: 针对 ❌ 项逐条修复
  2_evaluate: 再次逐条检查
  3_count: ISSUES

converge:  # 任一触发 → 停止循环，交付
  - ISSUES == 0              # 全部通过
  - 连续 2 轮 ISSUES 不变    # plateau
  - 轮次 ≥ 5                 # emergency brake ⚠️
```

---

## 输出格式

```
{最终版本正文}

---
<details><summary>📋 质量循环摘要（{N}轮，{收敛原因}）</summary>

| 轮次 | ❌ 数 | 修复项 |
|------|-------|--------|
| 1    | 3     | —（初稿）|
| 2    | 1     | 修复: X, Y, Z |
| 3    | 0     | 修复: W |

动态清单: {列出检查项}
</details>
```

---

## 边界规则

- **断路器优先**：会话超限时不激活质量循环
- **位置**：在所有 MUST_RUN 串行执行完成后、最终输出前
- **不与 depth_check 重复**：质量循环聚焦步间门控清单，不重复 4_depth_check 的检查项
- **用户可中断**：循环中用户发消息 → 立即交付当前版本
