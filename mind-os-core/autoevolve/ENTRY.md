# AutoEvolve — 跨会话入口

> **用户说"继续 autoevolve"或"跑一轮迭代"时，AI 读此文件。**
>
> 核心原则：**一轮一会话，状态全在文件，上下文零假设。**

---

## AI 执行协议（每轮必须严格按此执行）

### Step 0：网络同步（可选，≤30秒）

```
IF state.yaml 中 network.sync_enabled == true:
  READ autoevolve/network-sync.md → 执行 Step 0-A（远程同步）
ELSE:
  跳过（默认行为）
```

### Step 1：读取状态（30秒）

```
READ autoevolve/state.yaml        ← 唯一真相源
READ autoevolve/results.tsv       ← 实验历史
READ autoevolve/program.md        ← 人类方向（不可变）
```

从 state.yaml 获取：
- `status`: running？继续。paused/done？报告状态。
- `next_action`: 本轮要做什么。
- `compliance_snapshot`: 当前各场景合规率。
- `failure_patterns`: 已知问题。

### Step 2：执行本轮迭代（主体）

根据 `next_action.type` 分支：

#### type: test_and_fix

```
1. 读取 next_action.target_scenario 对应的场景文件
   READ autoevolve/scenarios/{对应文件}.md
2. 读取相关的 Mind OS 规则文件
   READ schemas/default/protocols.md（或 meta.md、对应 theory）
3. 模拟执行场景（作为 executor）
4. 用 evaluator.md 的检查清单自评（作为 evaluator）
5. 如果发现失败项：
   a. 分析根因
   a-1. [可选] 若 network.web_search_enabled == true → 读 network-sync.md Step 2-N 执行网络增强分析
   b. 提出修改（修改 next_action.target_file）
   c. 执行修改
   d. 重新模拟验证
6. 记录结果到 results.tsv
```

#### type: regression

```
1. 对所有场景执行快速模拟
2. 检查是否有场景退化（比 compliance_snapshot 低）
3. 退化 → 回滚最近修改，记录为 RESET
4. 无退化 → 记录为 PASS
```

#### type: stress_test

```
1. 连续模拟 10 个随机场景
2. 全部 ≥ 目标 → 更新 status 为 done
3. 有失败 → 记录失败模式，生成下一轮 fix 指令
```

### Step 3：更新状态文件（必须！）

```
更新 autoevolve/state.yaml：
  - total_experiments += 1
  - compliance_snapshot: 更新变化的场景
  - weighted_average: 重新计算
  - next_action: 设置下一轮的目标
  - failure_patterns: 追加新发现的模式
  - history: 追加本轮摘要

追加 autoevolve/results.tsv：
  - 本轮实验记录
```

### Step 4：输出本轮报告 + 结束

```
输出格式：
═══════════════════════════════════════
AutoEvolve Round #{N} 完成
═══════════════════════════════════════
场景: {scenario}
结果: {KEEP/RESET/PASS}
合规率: {before} → {after}
修改: {简述}
下一轮: {next_action 摘要}
═══════════════════════════════════════

然后结束会话。不要继续其他工作。
```

### Step 5：网络备份（可选，≤15秒）

```
IF state.yaml 中 network.backup_enabled == true:
  READ autoevolve/network-sync.md → 执行 Step 5-B（结果远程备份）
ELSE:
  跳过（默认行为）
```

---

> 用户操作指南和设计理念见 [README.md](README.md)。
