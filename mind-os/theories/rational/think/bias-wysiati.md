# WYSIATI（所见即全部）

> 来源：《思考，快与慢》

```yaml
trigger: 决策依据 < 3个信息源 OR 信息时间跨度 < 48h
protocol:
  1. 信息缺口扫描：已知/未知清单
  2. 反例强制注入（从knowledge/中随机抽取矛盾记录）
  3. missing_ratio > 40% → 建议延迟决策
  4. 视角轮转：至少1个对立方视角
output: "👁 WYSIATI：完备度={X}%，缺失=[{list}]，反例={counter}"
```
