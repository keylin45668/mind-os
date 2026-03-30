---
name: cross-session-audit
command: /跨审
keywords: [新窗口, 跨会话审计, self-review, 确认偏差, 独立复核, 二次推导]
execution_level: SHOULD
type: specification
domain: review
summary: "跨会话独立复审：新窗口重新推导→与原结论对比→标记分歧，深度思考/不可逆决策时升级MUST_RUN"
context: isolated
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **独立复审**：新窗口中不看原始结论，独立重新推导→与原结论对比→标记分歧
- **触发条件**：深度思考/不可逆决策时升级为 MUST_RUN，日常任务为 SHOULD
- **防确认偏差**：隔离上下文执行，避免被原会话结论锚定

# 跨会话审计协议

## 集成说明

```yaml
meta_integration:
  建议命令: /跨审
  建议关键词:
    - 新窗口
    - 跨会话审计
    - self-review
    - 确认偏差
    - 独立复核
    - 二次推导
  建议执行级别: SHOULD
  升级为_MUST_RUN:
    - 深度思考任务已完成且将给出最终建议
    - 输出包含不可逆决策建议
    - 用户主动要求新窗口复核
  不触发:
    - 轻量任务
    - 纯信息查询
    - 机械整理/翻译/格式化
```

> 作用：把 `_architecture` 的“新窗口 self-review”机制引入 Mind OS。核心不是“检查原结论”，而是**在新 session 中独立重推导**，用会话隔离削弱确认偏差。

---

## 定位

`cross-session-audit` 是 `session-audit` 的升级版，不是替代：

- `session-audit`：审查本次会话是否合规、有没有流程缺口
- `cross-session-audit`：在新 session 中挑战结论本身是否成立
- 推荐顺序：主思考 session 完成 → `cross-session-audit` → `session-audit` → `session-rating`

---

## 触发协议

```yaml
trigger:
  auto:
    - 深度思考任务完成时
    - 不可逆决策建议输出前
  manual:
    - 用户明确要求"再开新窗口审一下"

skip:
  - 轻量问答
  - 纯事实查询
  - 无决策后果的低成本任务
```

---

## Handoff 文档

主思考 session 结束后，只向审计 session 交付**最小必要输入**，避免把原推理路径一起灌过去。

```markdown
# Cross-Session Audit Handoff

## 原始问题
{只保留用户原始任务与客观约束；不带原 session 的框架语言}

## 最终结论
{只写结论/建议，不写推导过程}

## 关键假设清单
- A1: ...
- A2: ...
- A3: ...

## 审计重点挑战
- C1: 哪个假设最脆弱？
- C2: 结论是否过度依赖单一路径？
- C3: 是否存在更优替代方案？
- C4: 哪些情况下原结论会失效？
```

---

## 审计 Session 规则

```yaml
audit_rules:
  R1: 必须在新 session 执行，不继承原思考过程
  R2: 必须从"原始问题"重新推导，不能只做一致性检查
  R3: 可参考最终结论，但默认立场是可推翻
  R4: 必须优先攻击关键假设，而非修饰性细节
  R5: 如任务属于深度分析，审计 session 应重新运行 red-blue 对抗，而不是复述旧 verdict
```

审计输出格式：

```markdown
## 审计结论
状态：同意 / 不同意 / 部分修正

## 理由
- ...

## 修正后的建议
- ...
```

若与原结论不一致，必须追加对比表：

| 项目 | 原结论 | 审计结论 | 差异原因 |
|------|--------|----------|----------|
| 方案/判断 | ... | ... | ... |

---

## 与现有模块的关系

```yaml
dependencies:
  input:
    - session-audit 的过程记录可选读
    - crystallize 的模式沉淀可选读
    - iterative-engine 的结论可引用，但不能替代重推导
  output:
    - 一致: 作为结论可信度增强信号
    - 不一致: 交由用户基于对比表裁决
```

原则：`session-audit` 查“做得是否合规”，`cross-session-audit` 查“结论是否仍站得住”。
