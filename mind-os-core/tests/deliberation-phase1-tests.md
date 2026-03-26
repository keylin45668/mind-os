# 多角色审议 Phase 1 测试用例

> 版本：v1.0 | 日期：2026-03-27
> 覆盖：文件完整性、token 预算、YAML 结构、路由表、编号制

---

## 一、文件完整性

### TC-001：deliberation/ 目录包含所有 Phase 1 理论文件

```yaml
前置: Phase 1 代码已完成
输入: 检查 theories/rational/deliberation/ 下文件列表
验证:
  - meta.md 存在
  - role-meta.md 存在
  - protocol.md 存在
  - scoring.md 存在
  - decision-levels.md 存在
预期: 5 个文件全部存在
优先级: P0
自动化: 是
```

### TC-002：每个理论文件不超过 1000 tokens

```yaml
前置: 所有文件已创建
输入: 对每个 .md 文件估算 token 数（words × 1.5 作为上界）
验证:
  - 每个文件 words × 1.5 ≤ 1000
预期: 所有文件通过 token 预算检查
优先级: P0
自动化: 是
```

## 二、结构完整性

### TC-003：role-meta.md 包含完整元模型结构

```yaml
前置: role-meta.md 存在
输入: 读取文件内容，检查 YAML 块
验证:
  - 包含 identity 键（含 name, code, perspective, stance_tendency）
  - 包含 evaluation_framework 键（含 focus_metrics, evaluation_dimensions, typical_objections, blind_spots）
  - 包含 behavior 键（含 communication_style, decision_weight_factors, interaction_rules）
预期: 三个顶级键及其子键完整
优先级: P0
自动化: 是
```

### TC-004：scoring.md 包含 5 个评分维度

```yaml
前置: scoring.md 存在
输入: 读取文件内容
验证:
  - 包含 feasibility 维度
  - 包含 benefit 维度
  - 包含 risk_control 维度
  - 包含 completeness 维度
  - 包含 consensus 维度
  - 每个维度包含 name, description, scale
预期: 5 个维度完整，结构正确
优先级: P0
自动化: 是
```

### TC-005：decision-levels.md 包含三级定义

```yaml
前置: decision-levels.md 存在
输入: 读取文件内容
验证:
  - 包含 small 级别定义
  - 包含 medium 级别定义
  - 包含 major 级别定义
  - 每级包含 convergence 策略
  - 包含 override 规则
预期: 三级定义完整，含收敛策略和调整规则
优先级: P0
自动化: 是
```

### TC-006：protocol.md 包含编号制和核心阶段

```yaml
前置: protocol.md 存在
输入: 读取文件内容
验证:
  - 包含 blind_review 阶段定义
  - 包含 synthesis 阶段定义
  - 包含编号制格式 [{RoleCode}-r{round}-{seq}]
  - 包含决策标记 ADOPTED/REJECTED/DEFERRED
预期: 盲审+合成阶段完整，编号制正确
优先级: P0
自动化: 是
```

## 三、路由表集成

### TC-007：根 meta.md 已追加审议入口

```yaml
前置: theories/rational/meta.md 已更新
输入: 读取根 meta.md
验证:
  - 包含 /审议 命令
  - 路由到 deliberation/meta.md
  - 关键词包含"多角色"或"审议"
预期: 路由条目存在且格式正确
优先级: P0
自动化: 是
```

## 四、兼容性

### TC-008：现有红蓝辩论协议未被修改

```yaml
前置: theories/rational/think/iterative-engine.md 存在
输入: 检查文件是否被修改（git diff）
验证:
  - iterative-engine.md 无变更
  - parallel-thinking.md 无变更
预期: 现有文件完好
优先级: P0
自动化: 是
```
