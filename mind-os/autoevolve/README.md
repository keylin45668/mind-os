# AutoEvolve — Mind OS 自迭代引擎

> 灵感来源：[karpathy/autoresearch](https://github.com/karpathy/autoresearch)
> 核心理念：**一轮一会话 + 文件驱动状态 + 标量指标 + accept/reject**

## 架构

```
每轮迭代 = 一个独立会话（零上下文假设）
状态持久化 = 文件（state.yaml 是唯一真相源）
评估尺子 = evaluator.md（不可变）
方向控制 = program.md（人类独占）
```

## 文件结构

```
autoevolve/
├── ENTRY.md            ← AI 入口（"继续 autoevolve"时读此文件）
├── state.yaml          ← 跨会话状态（唯一真相源）
├── program.md          ← 人类元指令（方向盘，只有人能改）
├── evaluator.md        ← 合规评估器（尺子，只有人能改）
├── loop.md             ← 迭代循环协议（设计文档）
├── results.tsv         ← 实验日志（自动追加）
├── README.md           ← 本文件
└── scenarios/          ← 测试场景库（只有人能改）
    ├── boot-flow.md        ← 启动流程场景（4 个）
    ├── gate-enforcement.md ← 门控执行场景（8 个）
    ├── session-rules.md    ← 会话规则场景（10 个）
    └── routing-accuracy.md ← 路由精度场景（8 个）
```

## 使用方式

```bash
# 跑一轮迭代（每次新会话）
你: "继续 autoevolve"
AI: [读 state.yaml → 执行一轮 → 更新文件 → 报告 → 结束]

# 全自动（配合 /loop 每 3 分钟一轮）
/loop 3m 继续 autoevolve

# 查看进度
你: "autoevolve 进度"

# 调整方向
你: "autoevolve 聚焦 S-GATE-07"

# 暂停/恢复
你: "autoevolve 暂停" / "autoevolve 继续"
```

## 为什么一轮一会话

| 长会话 | 跨会话 |
|--------|--------|
| 注意力衰减 | 每轮全新上下文 |
| 上下文压力 | 只读本轮需要的文件 |
| 状态靠记忆 | state.yaml 唯一真相 |
| 崩溃丢进度 | 随时恢复 |
| 单线程 | 可并行跑不同场景 |

## 与 autoresearch 的同构

| autoresearch | AutoEvolve |
|---|---|
| train.py (唯一可变) | BOOT.md + protocols.md + meta.md + hooks |
| val_bpb | compliance_score (0-1000) |
| prepare.py (不可变) | evaluator.md + output-validator.sh |
| program.md (人类方向) | program.md |
| git commit/reset | accept/reject in state.yaml |
| results.tsv | results.tsv |
| 每轮独立实验 | 每轮独立会话 |

## 当前进度

**970/1000** (27 轮实验, 22 次 KEEP, 0 次 RESET)

| 阶段 | 轮次 | 结果 |
|------|------|------|
| Baseline | #1-5 | 识别 3 个致命缺陷 |
| 规则修复 | #6-10 | 53% → 86% |
| Hooks 注入 | #11-17 | 86% → 957/1000 |
| 输出验证器 | #18-23 | 957 → 970/1000 |
| 深度执行 | #24-27 | 970/1000 (current) |

## 目标

**1000 次执行，999 次严格合规。**
