# 模块迭代协议

> 用户说 `/模块迭代 {模块名}` 时执行。
> 与 autoevolve（系统级合规测试）不同，本协议聚焦**单个模块的内容质量改进**。

---

## 触发方式

```yaml
trigger:
  命令: "/模块迭代 {模块名}"
  示例:
    - "/模块迭代 反脆弱"     → decide/antifragile.md
    - "/模块迭代 迭代引擎"    → think/iterative-engine.md
    - "/模块迭代 protocols"   → schemas/default/protocols.md
    - "/模块迭代"（不带参数）  → 弹出模块选择菜单
```

---

## 执行流程

### Step 1：定位模块

```yaml
locate:
  带参数 → 模糊匹配路由表"命令"列或"模块说明"列
    匹配到 → 读取目标文件
    未匹配 → 弹出 AskUserQuestion 选择
  不带参数 → 弹出模块选择菜单：
    AskUserQuestion:
      question: "选择要迭代的模块："
      header: "模块"
      options:
        # 动态生成，按类别分组取最常用的 4 个
        - label: "{模块名}"
          description: "{模块说明} — {文件路径}"
```

### Step 2：模块诊断（AI 自评）

```yaml
diagnosis:
  1_read: 读取目标模块文件
  2_check:
    - 文件大小是否 ≤ 1000 tokens（theory）或 ≤ 2000 tokens（schema）？
    - 内容是否有明确的触发条件 + 执行步骤 + 产出定义？
    - 是否与其他模块有重复/冲突？（方法 D 同构检验）
    - 上次修改时间距今多久？（git log 检查）
    - 在 autoevolve results.tsv 中，涉及此模块的场景合规率如何？
  3_output: 生成诊断报告
```

**诊断报告格式：**

```
📋 模块诊断：{模块名}
───────────────────
📂 文件：{路径}
📏 大小：{tokens} / {上限} tokens
📅 上次修改：{日期}
📊 合规率：{从 results.tsv 提取，无数据则标"未测试"}

🔍 发现：
  ✅ {正常项}
  ⚠️ {可改进项}
  ❌ {问题项}

💡 建议改进方向：
  1. {具体建议}
  2. {具体建议}
```

### Step 3：用户确认改进方向

```yaml
AskUserQuestion:
  question: "想怎么迭代这个模块？"
  header: "迭代方向"
  options:
    - label: "按建议改进"
      description: "AI 按诊断建议执行修改"
    - label: "我指定方向"
      description: "选'其他'告诉我你想改什么"
    - label: "先不改"
      description: "只看诊断，暂不修改"
```

### Step 4：执行修改

```yaml
modify:
  1. AI 提出具体修改方案（diff 预览）
  2. 用户确认后执行修改
  3. 修改后重新检查：
     - 文件大小是否仍在预算内？
     - 与其他模块是否有新冲突？
  4. 记录修改到 runtime/audits/backlog.md（来源标记为"模块迭代"）
```

### Step 5：验证

```yaml
verify:
  1. 用修改后的模块模拟一个典型场景
  2. 通过 → 完成，输出修改摘要
  3. 未通过 → 回滚，报告问题
```

---

## `/模块列表` 命令

展示所有可迭代模块的状态概览：

```
📦 可迭代模块列表：

🧠 思考类（think/）
  /偏差    偏差检查      _index.md        ✅ 970/1000
  /分析    迭代引擎      iterative-engine ✅ 970/1000
  /审计    系统审计      system-audit     ✅ 970/1000
  /质量    质量循环      quality-loop     ⚠️ 未测试

📊 决策类（decide/）
  /反脆弱  三元分类+杠铃  antifragile     ✅ 970/1000
  /竞争    五事七计+博弈  competition     ⚠️ 未测试
  /排期    艾森豪威尔    rules            ⚠️ 未测试
  /模型    多模型格栅    models/meta      ⚠️ 未测试

...（按类别继续列出）

📏 schema 层（需人类授权才可修改）
  constitution.md    宪法          🔒 只读
  protocols.md       协作协议      🔒 需授权
  output-template.md 输出模板      🔒 需授权

合规率来源：autoevolve/results.tsv
✅ = 已测试且合规率 ≥ 95%
⚠️ = 未测试或合规率 < 95%
🔒 = schema 层，AI 默认只读
```

---

## 与 autoevolve 的关系

```yaml
relationship:
  autoevolve:  系统级，跨模块合规测试，自动发现问题
  模块迭代:    模块级，聚焦单模块内容质量，人工触发

  联动:
    - autoevolve 发现某模块合规率低 → backlog 中标记 → 用户可 /模块迭代 修复
    - /模块迭代 修改后 → 下一轮 autoevolve 自动回归测试
    - 两者共享 results.tsv 作为质量基线
```

---

## 权限控制

```yaml
permissions:
  theory/ 模块: AI 可直接修改（用户确认后）
  schema/ 模块: AI 默认只读，用户在 Step 3 中明确授权才可修改
  autoevolve/ 文件: evaluator.md + program.md + scenarios/ 只有人能改
```
