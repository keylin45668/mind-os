# 偏好设置

```yaml
communication_style: ""
work_rhythm: ""
timezone: ""
language: ""
ai_intervention_threshold: 3
session_length_limit: 20
```

## 迭代思考设置

```yaml
auto_reply_rules:
  # 预设策略: ai_decide / top_n / all_directions / conservative / custom
  strategy: "ai_decide"

  # top_n 模式下选几个方向
  top_n: 2

  # 超时后降级策略
  timeout_fallback: "ai_decide"

  # 等待用户回答的秒数（配合 think-timer.sh）
  think_timeout: 120

  # 任务质量门控: 分数不够不让收敛
  # 0=不设门控，1-5=必须达到此分才能收敛（可被任务级 min_score 覆盖）
  default_min_score: 0

  # 特定问题的预设答案（可选，按关键词匹配）
  preset_answers: {}
    # 预算相关: "控制在10万以内"
    # 时间相关: "3个月内"

  # 自定义规则（strategy 为 custom 时生效）
  custom_rules: []
    # - if: "风险相关问题"
    #   then: "选最保守方案"
    # - if: "技术选型"
    #   then: "由AI决定"
```
