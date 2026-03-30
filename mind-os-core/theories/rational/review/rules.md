---
name: review-rules
command: /回顾
keywords: [回顾, 复盘, 总结]
execution_level: SHOULD
type: framework
domain: review
summary: "GTD多层回顾：日(快照)/周(趋势)/月(全指标+适应度)/季(系统审计)/年(范式)"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **多层回顾**：日(快照)/周(趋势+人自评)/月(全指标+模块适应度)/季(系统审计+复杂度审计)/年(范式审视)
- **节奏递进**：频率越低→审视层级越高，日=参数调整，季=规则修改，年=目标修订
- **结晶联动**：回顾过程触发 crystallize.md 三问(模式/缺口/知识)

# 回顾理论

---

## 回顾节奏

| 周期 | 做什么 | 时长 | 输出 |
|------|--------|------|------|
| 每日 | inbox清零 + focus检查 | 15min | runtime/focus.md 更新 |
| 每周 | 全项目状态 + 人类自评 + 偏差检查 | 60min | runtime/reviews/weekly-YYYY-MM-DD.md |
| 每月 | 指标趋势 + theory效果 + 知识盘点 | 120min | runtime/reviews/monthly-YYYY-MM.md |
| 每季 | 系统审计 + schema检查 + 战略节奏 | 半天 | runtime/reviews/quarterly-YYYY-QN.md |
| 每年 | 愿景刷新 + identity更新 + 全归档 | 1天 | data/identity/ 更新 + archive/ |

## 每日回顾模板

```yaml
# 15分钟流程
1. inbox 清零：所有条目分流完毕？
2. focus 检查：今日 Top3 推进了几个？
3. 明日 focus：设定明天 Top3
4. 机器指标快照：异常标红
```

## 每周回顾模板

```yaml
# 60分钟流程
1. 机器指标趋势（AI生成）
2. 人类自评四问（参见 constitution.md 冻结指标-人类层）
3. 失败记录汇总（重复模式？）
4. 下周 focus 规划
5. 峰终定律检查：本周回顾是否被极端事件带偏？
```

## 每月回顾模板

```yaml
# 120分钟流程
1. 全指标月度趋势
2. theory 效果评估：哪些规则被频繁触发？哪些从未触发？
3. 知识盘点：新增笔记、跨域链接、孤岛笔记
4. 协作增益评估：本月协作质量 vs 单方
5. 否定法：可以删什么？
```
