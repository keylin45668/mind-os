# 模块迭代协议

> `/模块迭代 {模块名}` 触发。聚焦单模块内容质量，与 autoevolve（系统级合规测试）互补。

---

## 执行流程

### Step 1：定位模块

- 带参数 → 模糊匹配路由表，匹配到→读取，未匹配→弹选择菜单
- 不带参数 → 弹出 AskUserQuestion 选择模块

### Step 2：诊断（AI 自评）

检查项：
- 文件大小 ≤ 预算（theory 1000 / schema 2000 tokens）？
- 有明确的触发条件 + 执行步骤 + 产出定义？
- 与其他模块有重复/冲突？
- 上次修改距今多久？（git log）
- autoevolve results.tsv 中相关场景合规率？

输出诊断报告（✅正常 / ⚠️可改进 / ❌问题 + 建议方向）。

### Step 3：用户确认

AskUserQuestion：按建议改进 / 我指定方向 / 先不改

### Step 4：执行修改

1. AI 提出 diff 预览 → 用户确认 → 执行
2. 修改后检查：文件仍在预算内？与其他模块有新冲突？
3. 记录到 runtime/audits/backlog.md

### Step 5：验证

模拟一个典型场景 → 通过则完成 → 未通过则回滚

---

## `/模块列表` 命令

扫描所有模块，按类别展示：路径、合规率（✅ ≥ 95% / ⚠️ 未测试或 < 95% / 🔒 schema 只读）。

数据来源：autoevolve/results.tsv。

---

## 与 autoevolve 的关系

- autoevolve 发现模块合规率低 → backlog 标记 → 用户 `/模块迭代` 修复
- 修改后 → 下轮 autoevolve 自动回归测试
- 共享 results.tsv 作为质量基线

## 权限

- theory/ 模块：用户确认后 AI 可修改
- schema/ 模块：用户在 Step 3 明确授权才可修改
- evaluator.md / program.md / scenarios/：只有人能改
