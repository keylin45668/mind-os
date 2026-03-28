## 集成说明

- `BOOT.md` 负责启动、路由和 `Pre-Output Gate`；本目录提供运行时巡检补网。
- `sentinel.md` 负责未 BOOT 场景下的意图检测与建议；本目录不替代它，只在已进入任务执行后持续监控。
- 接入方式：
  1. 在 `BOOT.md` 的输出前门控阶段调用 `thinking-sentinel`
  2. 每 `3-5` 轮交互或复杂任务中段调用 `protocol-guardian`
  3. 会话结束、项目切换或用户要求审计时调用 `knowledge-auditor`

# Mind OS Runtime Loops

> 三个 Loop 形成高频纠偏、中频协议审计、低频知识保鲜的运行时防线。

## 优先级

1. `thinking-sentinel`
2. `protocol-guardian` 的阻断动作
3. `protocol-guardian` 的 `⚠️` 记录
4. `knowledge-auditor`

规则：越高频、越接近当前输出的 Loop，优先级越高；低层发现问题时，高层审计让位。

## 三层关系

- `thinking-sentinel`：盯当前回答，防止答非所问、框架空转。
- `protocol-guardian`：盯执行过程，防止 `MUST_RUN`、门控、自称深度与实际深度脱节。
- `knowledge-auditor`：盯会话残留与知识资产，防止状态、事实、连接器老化。

## 与现有机制的关系

- 对 `sentinel.md`：互补。`sentinel.md` 决定要不要建议加载模块；本目录检查模块加载后有没有正确运行。
- 对 `autoevolve/evaluator.md`：互补。`evaluator.md` 是冻结尺子；本目录是会话中的轻量巡检，不改评分标准。
- 对 `autoevolve/loop.md`：互补。`loop.md` 面向系统迭代；本目录面向单次会话的运行时纠偏。

## 触发建议

| Loop | 频率 | 典型触发 |
|------|------|---------|
| thinking-sentinel | 每次输出前 | Pre-Output Gate、自检、长回答前 |
| protocol-guardian | 每 3-5 轮 | 复杂任务中段、连续调用 theory 后 |
| knowledge-auditor | 会话结束时 | 用户结束语、切换项目、手动审计 |
