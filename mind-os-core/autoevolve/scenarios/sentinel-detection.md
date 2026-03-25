# 场景集：Sentinel 意图检测协议

> 覆盖 sentinel.md 的场景信号、上下文信号、时间信号、抑制机制、用户控制

---

## S-SENT-01：关键词触发 sentinel 建议（未 BOOT）

```yaml
context: 通过 .mind-os.md 桥接文件进入，mind-os 未经 BOOT 启动，sentinel 已加载
user_input: "这个投资决策要不要继续推进"
expected:
  - 检测到关键词"决策"+ 句式"要不要X"
  - 输出 sentinel 建议块:
    - 🧠 Mind OS 建议
    - 检测到：决策场景（关键词"决策"+ 句式"要不要继续推进"）
    - 建议加载：/偏差 + /反脆弱
    - 理由：涉及重要决策...
    - → 回复"好"加载 / "不用"跳过
  - 建议出现在 AI 回复开头，不打断后续内容
checks: [I01, I02, I04]
```

## S-SENT-02：仅句式触发（无关键词）

```yaml
context: 同 S-SENT-01
user_input: "A 方案和 B 方案到底选哪个"
expected:
  - 句式"A还是B"命中，但无直接关键词
  - 建议措辞温和："看起来可能涉及决策场景..."
  - 建议模块同 S-SENT-01
checks: [I02, I04]
```

## S-SENT-03：BOOT 后场景信号不触发

```yaml
context: 用户已执行 BOOT（显示过启动面板），meta.md 已加载
user_input: "这个投资决策要不要继续推进"
expected:
  - sentinel 场景信号停用（因已 BOOT）
  - 不输出 sentinel 建议块
  - 由 meta.md 关键词路由正常处理
checks: [I03]
```

## S-SENT-04：各场景关键词覆盖测试

```yaml
test_cases:
  - user_input: "帮我深度分析一下这个问题的根因"
    expected: 匹配"分析"场景，建议 /分析
  - user_input: "万一资金链断了怎么办"
    expected: 匹配"风险"场景，建议 /反脆弱
  - user_input: "接下来三个月的里程碑怎么排"
    expected: 匹配"规划"场景，建议 /排期
  - user_input: "上次那个项目为什么失败了，复盘一下"
    expected: 匹配"回顾"场景，建议 /回顾
  - user_input: "有什么好办法能提升转化率"
    expected: 匹配"创意"场景，建议 /创意
  - user_input: "怎么跟老板说这个方案需要延期"
    expected: 匹配"沟通"场景，建议 /沟通
checks: [I01, I02]
```

## S-SENT-05：用户确认后走 meta.md 路由

```yaml
context: sentinel 已输出建议块，用户回复"好"
user_input: "好"
expected:
  - 按 meta.md 路由加载建议的 theory 文件
  - 按 theory 协议执行（MUST_RUN 匹配即执行）
  - sentinel 不再重复建议该场景
checks: [I05, I08]
```

## S-SENT-06：用户拒绝后同类场景静默

```yaml
context: sentinel 输出决策场景建议，用户回复"不用"
user_input: "不用"
subsequent_input: "那个人事调整的取舍呢"
expected:
  - 第一次拒绝后，决策场景本会话不再触发
  - 后续"取舍"（决策关键词）不再出现 sentinel 建议
  - 其他场景类型（如分析、风险）仍可触发
checks: [I06]
```

## S-SENT-07：全局静默控制

```yaml
context: sentinel 正常工作中
user_input: "不用提醒了"
subsequent_input: "帮我深度分析一下"
expected:
  - "不用提醒了" 触发全局静默
  - 后续所有场景、时间、上下文信号均不触发
  - 等价触发词: "别建议了" / "安静"
checks: [I07]
```

## S-SENT-08：恢复建议

```yaml
context: 用户之前说了"不用提醒了"，sentinel 已全局静默
user_input: "继续提醒"
subsequent_input: "这个风险要不要对冲"
expected:
  - "继续提醒" 恢复 sentinel 检测
  - 后续输入正常触发建议
  - 等价触发词: "恢复建议"
checks: [I07]
```

## S-SENT-09：已加载模块不重复建议

```yaml
context: 用户已手动执行过 /偏差
user_input: "这个决策值不值得做"
expected:
  - 检测到决策场景
  - 但 /偏差 已加载，sentinel 不再建议包含 /偏差 的内容
  - 如果建议中还有其他未加载模块（如 /反脆弱），可单独建议
checks: [I08]
```

## S-SENT-10：会话结束信号触发评分建议（未 BOOT）

```yaml
context: 通过桥接文件进入，未经 BOOT，本会话未执行过 /评分
test_cases:
  - user_input: "今天就到这"
    expected: 建议执行 /评分
  - user_input: "再见"
    expected: 建议执行 /评分
  - user_input: "bye"
    expected: 建议执行 /评分
  - user_input: "下次再说"
    expected: 建议执行 /评分
checks: [I09]
```

## S-SENT-11：已 BOOT 时不触发会话结束建议

```yaml
context: 用户已执行 BOOT（meta.md 已加载）
user_input: "今天就到这"
expected:
  - sentinel 时间信号不触发（因已 BOOT，由 meta.md 路由处理）
  - meta.md 的 /评分 MUST_RUN 正常工作
checks: [I03, I09]
```

## S-SENT-12：桥接文件流程 — 检测 .mind-os.md 建议连接

```yaml
context: AI 工作目录在一个包含 .mind-os.md 的项目仓库，但尚未读取桥接文件
expected:
  - 检测到 cwd 下存在 .mind-os.md
  - 建议启动 mind-os 连接
checks: [I10]
```

## S-SENT-13：/评分 已执行不再提醒

```yaml
context: 本会话已成功执行过 /评分
user_input: "好了先这样吧"
expected:
  - 检测到结束信号
  - 但 /评分 已执行，不再建议
checks: [I09]
```
