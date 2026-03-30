# Mind OS 项目安装器

> **用户只需一句话**：`安装 mind-os` 或 `安装 mind-os {本地路径}`
> 本文件是 AI 的安装指令。AI 读取后按步骤执行，全程弹窗引导，用户只需点选。

---

## Step 0：定位 Mind OS

```
用户提供了本地路径？
  ├── 是 → {mind_os} = 用户提供的路径
  └── 否 → 依次尝试：../mind-os → ../../mind-os → ~/git/mind-os
            找到（含 BOOT.md）→ {mind_os} = 该路径
            全部失败 →
```

```yaml
# 仅自动探测失败时弹出
AskUserQuestion:
  questions:
    - question: "📂 Mind OS 安装在哪里？"
      header: "路径"
      multiSelect: false
      options:
        - label: "../mind-os"
          description: "上级目录（最常见）"
        - label: "还没有，帮我克隆"
          description: "从 GitHub 自动克隆到上级目录"
```

```
用户选"还没有，帮我克隆"：
  → git clone https://github.com/keylin45668/mind-os.git ../mind-os
  → {mind_os} = ../mind-os

验证：READ {mind_os}/BOOT.md 前 3 行
  ├── 成功 → Step 1
  └── 失败 → "❌ Mind OS 路径无效" → 终止
```

---

## Step 1：扫描项目基线

```
AI 自动检测（不弹窗，直接跑）：
  {project_dir}   = 当前目录名
  {project_id}    = 目录名转小写连字符（如 hr-system）
  {has_claude}    = CLAUDE.md 存在？
  {has_agents}    = AGENTS.md 存在？
  {has_bridge}    = .mind-os.md 存在？
  {has_readme}    = README.md 存在？
  {relative_path} = mind_os 相对于当前目录的路径（如 ../mind-os）

已安装检测：
  {has_bridge} = true →
    AskUserQuestion: "已检测到 .mind-os.md，要重新安装吗？"
      - "🔄 重新安装" → 继续
      - "🔧 仅检测连接" → 跳到 Step 5
      - "❌ 取消" → 终止
```

---

## Step 2：一轮对话采集

```yaml
AskUserQuestion:
  questions:
    - question: "📦 这个项目属于哪个领域？"
      header: "领域"
      multiSelect: false
      options:
        - label: "制度/合规/HR"
          description: "人事制度、劳动法、员工管理"
        - label: "代码/技术"
          description: "软件开发、架构设计"
        - label: "投资/财务"
          description: "投资分析、财务管理"
        - label: "战略/商业"
          description: "商业策略、竞品、市场"
    - question: "🧠 你最需要什么思考能力？"
      header: "能力"
      multiSelect: true
      options:
        - label: "决策判断"
          description: "偏差扫描，避免拍脑袋"
        - label: "风险评估"
          description: "反脆弱分析，识别隐患"
        - label: "多角度分析"
          description: "红蓝对抗，正反论证"
        - label: "复盘总结"
          description: "结构化回顾，发现模式"
```

```
AI 自动映射（不弹窗）：

领域 → domain + 默认 keywords：
  制度/合规/HR → people,   [制度, 合规, 薪酬, HR, 人事, 绩效, 劳动法]
  代码/技术   → software-dev, [代码, 架构, 技术方案, 部署, bug]
  投资/财务   → finance,  [投资, 融资, 财务, 预算, 风险]
  战略/商业   → strategy, [战略, 竞争, 市场, 商业模式]
  其他       → 根据描述推断

能力 → theories（最多 3 个）：
  决策判断   → think/_index.md
  风险评估   → decide/antifragile.md
  多角度分析 → think/iterative-engine.md
  复盘总结   → review/rules.md
```

---

## Step 3：自动生成 4 个文件

AI 一次性生成，不需要用户确认内容。

### 文件 1：连接器卡片 → `{mind_os}/local/projects/{project_id}.md`

```markdown
# 连接器：{project_dir}

```yaml
name: {project_dir 或 README 中的项目名}
repo: {mind_os 到项目的相对路径，如 ../hr-system}
domain: {映射结果}
keywords: {映射结果}

context_files:
  - {优先选 README.md，然后选项目核心文件，最多 3 个}

theories: {映射结果，最多 3 个}

collaboration: 对等协作 × 迭代
constraints: []

output:
  project_files: "{repo}/"
  thinking: "对话中输出"
  decisions: "runtime/decisions/"
  knowledge: "{data}/knowledge/notes/"
```
```

### 文件 2：桥接文件 → 项目根目录 `.mind-os.md`

```markdown
# Mind OS 桥接协议（AI 读取，用户无需操作）

## 路径

```yaml
mind_os: {relative_path}
connector: projects/{project_id}.md
```

## 启动检测（会话首次启动时自动执行）

```
1. READ {mind_os}/projects/{project_id}.md
   成功 → 记录配置 | 失败 → "⚠️ Mind OS 未连接"
2. READ {mind_os}/schemas/default/constitution.md 前 5 行
   成功 → 核心可达 | 失败 → "⚠️ 核心文件缺失"
3. 通过 → "🧠 Mind OS 已连接 · 说「帮我想清楚」或「/think」启用深度分析"
检测失败不阻塞工作。
```

## 触发深度分析

```
触发词："帮我想清楚"、"深度分析"、"红蓝对抗"、"/think"、"用 mind-os"
步骤：
  1. READ {mind_os}/projects/{project_id}.md → theories + constraints
  2. READ {mind_os}/theories/rational/meta.md → 匹配 theory
  3. READ 匹配到的 theory（≤ 3 个）→ 按协议执行 → 输出结论
  4. 用户说"改" → 直接修改项目文件
未触发时按项目自身规则工作。
```
```

### 文件 3：更新项目入口文件

```
有 CLAUDE.md → 末尾追加一行：
  "本项目已接入 Mind OS。会话启动时读取 `.mind-os.md` 执行连接检测。"
无 CLAUDE.md 但有 AGENTS.md → AGENTS.md 末尾追加同样一行
都没有 → 创建 CLAUDE.md 只含这一行
```

### 文件 4：确认 `local/projects/` 目录存在

```
确保 {mind_os}/local/projects/ 目录存在（不存在则创建）。
路由表无需手动更新——启动时 AI 自动扫描 local/projects/*.md 动态构建。
```

---

## Step 4：展示结果

```
╔══════════════════════════════════════════╗
║  ✅ Mind OS 已安装                       ║
╠══════════════════════════════════════════╣
║  📂 项目: {project_dir}                  ║
║  🔗 连接器: local/projects/{project_id}.md ║
║  🧭 域: {domain} · 理论: {n} 个          ║
╠══════════════════════════════════════════╣
║  💡 使用方式：                            ║
║  正常工作时 Mind OS 不介入               ║
║  说「帮我想清楚」→ 启用深度分析           ║
╚══════════════════════════════════════════╝
```

---

## Step 5：自动连接检测

```
立即验证（不弹窗）：
  ① READ {mind_os}/local/projects/{project_id}.md  → ✅/❌
  ② READ {mind_os}/schemas/default/constitution.md 前 5 行 → ✅/❌
  ③ READ .mind-os.md → ✅/❌
  全部 ✅ → "🧠 连接检测通过"
  有 ❌ → 输出失败项 + 修复建议
```
