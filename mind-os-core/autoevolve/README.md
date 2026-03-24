# AutoEvolve — Mind OS 自迭代引擎

> 灵感：[karpathy/autoresearch](https://github.com/karpathy/autoresearch)
> 核心：**一轮一会话 + 文件驱动状态 + 标量指标 + accept/reject**

## 文件结构

```
autoevolve/
├── ENTRY.md        ← AI 入口（"继续 autoevolve"时读此文件）
├── state.yaml      ← 跨会话状态（唯一真相源）
├── program.md      ← 人类元指令（只有人能改）
├── evaluator.md    ← 合规评估器（只有人能改）
├── loop.md         ← 迭代循环设计文档
├── results.tsv     ← 实验日志
├── module-evolve.md← 单模块迭代协议
└── scenarios/      ← 测试场景库（只有人能改）
```

## 使用

```bash
"继续 autoevolve"           # 跑一轮
"/loop 3m 继续 autoevolve"  # 全自动
"autoevolve 进度"           # 查看状态
"autoevolve 聚焦 S-GATE-07" # 调整方向
"autoevolve 暂停/继续"      # 暂停/恢复
```

## 与 autoresearch 的同构

| autoresearch | AutoEvolve |
|---|---|
| train.py (可变) | BOOT.md + protocols.md + meta.md + hooks |
| val_bpb | compliance_score (0-1000) |
| prepare.py (不可变) | evaluator.md + output-validator.sh |
| program.md | program.md |
| git commit/reset | accept/reject in state.yaml |
| 每轮独立实验 | 每轮独立会话 |

## 当前进度

详见 state.yaml。目标：**1000 次执行，999 次严格合规。**
