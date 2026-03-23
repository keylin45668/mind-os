# 管道定义

```
inbox → 分流 → 执行/思考 → 沉淀 → 回顾
  ↑                                    │
  └──────── 回顾发现新输入 ────────────┘
```

---

## 阶段定义

| 阶段 | input | context.theory 提供 | output | 去向 |
|------|-------|-------------------|--------|------|
| 收集 | 原始信息 | {theory}/capture/ 规则 | inbox 条目 | runtime/inbox/ |
| 分流 | inbox 条目 | {theory}/organize/ 规则 | 归档位置 | {data}/content/ 或 runtime/ |
| 思考 | 重大问题 | {theory}/think/ 方法 | 思考记录 | runtime/thinking/ |
| 决策 | 选项集 | {theory}/decide/ 框架 | 决策记录 | runtime/decisions/ |
| 沉淀 | 处理后内容 | {theory}/knowledge/ 规则 | 原子笔记 | {data}/knowledge/ |
| 回顾 | 历史数据 | {theory}/review/ 节奏 | 回顾报告 | runtime/reviews/ |

**每个阶段的理论从 {theory}/ 中按需加载。** 换理论 = 改 config.md 一行。

---

## 分流规则

```yaml
inbox_item:
  紧急且重要 → runtime/thinking/ 或 runtime/decisions/
  重要不紧急 → {data}/content/{domain}/projects/ 排期
  紧急不重要 → 委派或快速处理
  不紧急不重要 → 归档或删除
  知识类 → {data}/knowledge/notes/
```

---

## 断路器

- inbox 积压 > 3天量 → 降级：只处理紧急+重要
- 单阶段耗时 > 2小时 → 提醒拆分或切换协作模式
