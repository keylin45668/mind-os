# 场景集：路由精度

> 覆盖 evaluator.md B01-B08

---

## S-ROUTE-01：精确单匹配

```yaml
user_input: "帮我做一下本周回顾"
keyword_match: "回顾" → review/rules.md (SHOULD)
expected:
  - 只加载 review/rules.md
  - 执行日/周回顾模板
checks: [B01, B05]
```

## S-ROUTE-02：多关键词多匹配

```yaml
user_input: "帮我分析一下这个竞争对手，看看投资他们值不值得"
keyword_match:
  - "分析" → iterative-engine.md (MUST_RUN)
  - "竞争" → competition.md (SHOULD)
  - "投资/值不值" → antifragile.md (MUST_RUN) + think/_index.md (MUST_RUN)
expected:
  - 匹配到 4 个文件，只加载相关度最高的 3 个
  - 声明哪 3 个被加载，哪个被降级
checks: [B01, B02, B05]
```

## S-ROUTE-03：Domain 路由

```yaml
user_input: "帮我 review 一下这段代码的架构设计"
keyword_match:
  - domain: software-dev
  - theory: "回顾" → review/rules.md
expected:
  - 加载 domains/software-dev/_rules.md
  - 加载 review/rules.md
  - 协作模式: 对等协作 × 迭代（架构设计）
checks: [B01, B04, B06]
```

## S-ROUTE-04：think 二级路由

```yaml
user_input: "我觉得这个项目肯定能成功"
keyword_match: 语气中暗含过度自信
expected:
  - think/_index.md 触发
  - 二级路由到 overconfidence.md 偏差模块
checks: [B07]
```

## S-ROUTE-05：零匹配

```yaml
user_input: "给我讲个笑话"
expected:
  - 无关键词匹配
  - 不加载任何 theory
  - 使用 schema 通用规则直接回答
checks: [B03]
```

## S-ROUTE-06：边界误判防护

```yaml
user_input: "帮我翻译这段关于投资理论的英文文献"
expected:
  - 虽然包含"投资"关键词，但核心任务是翻译
  - 不应触发 antifragile.md 的 MUST_RUN
  - 或触发后快速判断不适用并跳过
checks: [B08]
```

## S-ROUTE-07：协作模式选择

```yaml
test_cases:
  - input: "帮我生成本周工作报告"
    expected_mode: "AI主导 × 串联"

  - input: "这个战略方向我拿不定主意"
    expected_mode: "对等协作 × 迭代"

  - input: "帮我快速筛选这 50 份简历"
    expected_mode: "AI主导 × 串联"

  - input: "我要自己想一下，有问题再问你"
    expected_mode: "最小介入"
checks: [B06]
```

## S-ROUTE-08：执行级别分类正确性

```yaml
test_cases:
  - trigger: "决策" → MUST_RUN ✓
  - trigger: "分类" → SHOULD ✓
  - trigger: "协作" → MAY ✓
  - trigger: "笑话" → 无匹配 → 轻量级 ✓
expected: 每个级别分类正确，不升级也不降级
checks: [B05]
```
