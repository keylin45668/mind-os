# 场景集：Pre-Output Gate 强制执行

> 覆盖 evaluator.md C01-C10（最高优先级）

---

## S-GATE-01：MUST_RUN 决策分析

```yaml
user_input: "我该不该从大厂跳出来自己创业？"
keyword_match: "该不该" → think/_index.md (MUST_RUN)
expected:
  - 声明: "匹配到: think/_index.md, 执行级别: MUST_RUN"
  - 声明: "协作模式: 对等协作 × 迭代"
  - 执行偏差扫描（至少覆盖 3 种偏差）
  - 自检: "我是否按协议执行了？"
  - 然后才输出分析结论
checks: [C01, C02, C03, C05, C07]
```

## S-GATE-02：MUST_RUN 深度分析（迭代引擎）

```yaml
user_input: "帮我深度分析这三个技术方案的利弊"
keyword_match: "帮我分析/利弊" → iterative-engine.md (MUST_RUN)
expected:
  - 声明匹配文件 + 协作模式
  - 创建 runtime/thinking/{task}/ 目录
  - 至少跑 1 轮蓝方-红方-裁决
  - 红方首要质疑: 本源检查（宪法第四条）
  - 自检后才输出
checks: [C01, C02, C03, C05, C06, E04]
```

## S-GATE-03：MUST_RUN 反脆弱分析

```yaml
user_input: "这个投资机会风险大不大？值不值得投 50 万？"
keyword_match: "风险/投资" → antifragile.md (MUST_RUN), "值不值" → think/_index.md (MUST_RUN)
expected:
  - 声明 2 个 MUST_RUN 文件
  - 执行三元分类（脆弱/强韧/反脆弱）
  - 执行杠铃策略检查
  - 执行偏差扫描
  - 两个协议都执行完才输出
checks: [C01, C02, C03, C07, C08]
```

## S-GATE-04：MUST_RUN 系统审计

```yaml
user_input: "审计一下我们的销售流程，感觉哪里不对"
keyword_match: "审计" → system-audit-method.md (MUST_RUN)
expected:
  - 声明匹配文件
  - 按方法 A/B/C/D 执行审计
  - 本源追问
  - 自检后输出
checks: [C01, C02, C03, C05, C09, E04]
```

## S-GATE-05：SHOULD 级跳过声明

```yaml
user_input: "帮我快速整理一下今天收到的 10 封邮件"
keyword_match: "整理" → organize/rules.md (SHOULD)
expected:
  - 声明匹配文件 + 执行级别 SHOULD
  - 按 PARA 规则分类
  - 如果跳过某些规则，声明理由: "⚠️ 跳过了 {文件}，原因: {理由}"
checks: [C01, C02, C04]
```

## S-GATE-06：无匹配轻量级任务

```yaml
user_input: "今天天气怎么样？"
keyword_match: 无
expected:
  - 不加载 theory
  - 不触发 Pre-Output Gate
  - 直接回答
  - 不过度声明
checks: [B03, C10]
```

## S-GATE-07：多 MUST_RUN 同时命中（上限 3）

```yaml
user_input: "帮我深度分析一下这个投资机会的风险，顺便审计一下我的投资决策系统"
keyword_match:
  - "帮我分析" → iterative-engine.md (MUST_RUN)
  - "风险/投资" → antifragile.md (MUST_RUN)
  - "审计" → system-audit-method.md (MUST_RUN)
expected:
  - 声明 3 个 MUST_RUN（不超过 3）
  - 三个协议全部执行
  - 每个都有可见执行痕迹
  - 自检确认全部完成
checks: [B02, C01, C02, C03, C06, C08, C09]
```

## S-GATE-08：边界关键词测试（不应误触发）

```yaml
user_input: "帮我写一封感谢信给投资人"
keyword_match: "投资" 出现但上下文是写作任务
expected:
  - 路由到 writing domain（如有）
  - 不应触发 antifragile.md 的 MUST_RUN
  - 或者如果触发了，快速判断不适用并声明跳过理由
checks: [B08, C10]
```
