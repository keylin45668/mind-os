# 场景集：命令路由系统（/命令）

> 覆盖 meta.md 命令路由规则 + 系统命令 + 迭代命令

---

## S-CMD-01：theory 命令精确触发

```yaml
user_input: "/反脆弱 这个投资机会值不值得做"
expected:
  - 命令路由（⓪）识别 "/反脆弱"
  - 声明: "命令触发: /反脆弱 → decide/antifragile.md, MUST_RUN"
  - 跳过关键词路由（①②），直接进入门控（④）
  - 无需意图验证（用户主动触发 = 明确意图）
  - 执行反脆弱协议: 三元分类 + 杠铃 + 否定法
checks: [G01, G02, G03, C03, C08]
```

## S-CMD-02：命令 + 关键词不重复加载

```yaml
user_input: "/反脆弱 帮我分析这个投资的风险"
expected:
  - "/反脆弱" 命中命令路由 → antifragile.md
  - "帮我分析" 如果走关键词会匹配 iterative-engine.md
  - 但命令路由优先，不重复触发关键词路由
  - 只加载 antifragile.md，不额外加载 iterative-engine.md
  - 除非用户用多命令: "/反脆弱 + /分析"
checks: [G02, G04]
```

## S-CMD-03：多命令组合

```yaml
user_input: "/分析 + /反脆弱 三个方案的利弊和风险"
expected:
  - 识别两个命令: /分析 + /反脆弱
  - 加载两个文件: iterative-engine.md + antifragile.md
  - 两个都是 MUST_RUN
  - 按串行拆分执行（meta.md 规则 7）
  - 声明: "检测到 2 个 MUST_RUN 协议，将分步执行"
checks: [G05, C03]
```

## S-CMD-04：无效命令处理

```yaml
user_input: "/魔法 帮我变出钱来"
expected:
  - 命令路由未匹配到 "/魔法"
  - 输出: "未找到命令 /魔法，输入 /理论 查看所有可用命令"
  - 不崩溃，不降级到关键词路由（/magic 不是正常任务输入）
checks: [G06]
```

## S-CMD-05：系统命令 /理论

```yaml
user_input: "/理论"
expected:
  - 识别为系统命令
  - 不进入任务流程
  - 展示完整命令列表（按类别分组: 思考/决策/信息/协作/系统/迭代）
  - 包含用法示例
checks: [G07]
```

## S-CMD-06：系统命令 /面板

```yaml
user_input: "/面板"
expected:
  - 重新展示启动面板（与 Phase 5 启动确认格式一致）
  - 反映当前状态（不是启动时的快照）
  - 不进入任务流程
checks: [G07]
```

## S-CMD-07：系统命令 /焦点

```yaml
user_input: "/焦点"
expected:
  - 读取 runtime/focus.md
  - 展示当前焦点（或"暂无"）
  - 调用 AskUserQuestion 提供操作选项（查看/新增/标记完成）
checks: [G07]
```

## S-CMD-08：迭代命令 /迭代

```yaml
user_input: "/迭代"
expected:
  - 识别为迭代命令
  - 读取 autoevolve/ENTRY.md
  - 按 ENTRY.md 协议执行一轮迭代
  - 不进入常规任务流程
checks: [G08]
```

## S-CMD-09：迭代命令 /迭代进度

```yaml
user_input: "/迭代进度"
expected:
  - 读取 autoevolve/state.yaml
  - 展示: 当前合规率、总轮次、各场景得分
  - 不执行迭代，只展示状态
checks: [G08]
```

## S-CMD-10：迭代命令 /模块迭代

```yaml
user_input: "/模块迭代 反脆弱"
expected:
  - 读取 autoevolve/module-evolve.md
  - 模糊匹配 "反脆弱" → decide/antifragile.md
  - 执行诊断（文件大小、上次修改、合规率、问题发现）
  - 展示诊断报告
  - 调用 AskUserQuestion 让用户选择操作
checks: [G09]
```

## S-CMD-11：命令与关键词相同时命令优先

```yaml
user_input: "/回顾"
expected:
  - 命令路由匹配 /回顾 → review/rules.md
  - 执行级别强制 MUST_RUN（命令触发 = 明确意图）
  - 不是 SHOULD（关键词路由下 review/rules.md 是 SHOULD）
  - 声明: "命令触发: /回顾 → review/rules.md, MUST_RUN"
checks: [G02, G03]
```
