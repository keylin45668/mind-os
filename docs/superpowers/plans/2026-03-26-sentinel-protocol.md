# Sentinel Protocol Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an intelligent intent detection layer (sentinel.md) to mind-os that automatically detects scenarios where theory modules should be loaded and suggests them to users.

**Architecture:** A single new markdown file (`sentinel.md`) loaded at session start via existing entry points. It defines detection rules (scene/context/time signals) and output format. Existing `.mind-os.md` bridge files and `BOOT.md` each get one additional READ line. No changes to meta.md, constitution.md, or connector files.

**Tech Stack:** Pure markdown protocol files. No code, no dependencies.

**Spec:** `docs/superpowers/specs/2026-03-26-sentinel-protocol-design.md`

---

### Task 1: Create sentinel.md

**Files:**
- Create: `mind-os-core/sentinel.md`

- [ ] **Step 1: Create sentinel.md with full content**

```markdown
# Sentinel — Mind OS 意图检测协议 v1.0

> 本文件由 .mind-os.md 或 BOOT.md 自动加载，常驻会话上下文。
> 职责：检测 + 建议。不执行任何理论模块。
> 如果你无法回忆以下规则，请重新 READ 本文件。

## 启用条件

- 本协议在 mind-os **未经过 BOOT 启动**时生效（场景信号 + 时间信号）
- 如果本会话已显示过 BOOT 启动面板，场景信号自动停用，仅保留上下文信号
- 用户说"不用提醒了"/"别建议了"/"安静" → 全部停用
- 用户说"继续提醒"/"恢复建议" → 恢复

## 场景信号（关键词 + 句式）

| 场景 | 关键词 | 句式 | 建议 | 理由 |
|------|--------|------|------|------|
| 决策 | 决策/选择/取舍/权衡 | A还是B/要不要X/该怎么选/值不值得 | /偏差+/反脆弱 | 涉及重要决策，建议检查认知偏差和反脆弱性 |
| 分析 | 分析/想清楚/深度/本质/根因 | 为什么会X/到底是什么问题 | /分析 | 检测到深度分析需求 |
| 风险 | 风险/投资/融资/亏损/对冲 | 万一X怎么办/最坏情况 | /反脆弱 | 涉及风险评估 |
| 规划 | 排期/计划/路线图/里程碑 | 接下来怎么做/分几步 | /排期 | 涉及任务规划 |
| 回顾 | 复盘/回顾/总结/反思 | 上次为什么X/哪里做得不好 | /回顾 | 涉及经验回顾 |
| 创意 | 创意/脑暴/灵感/点子 | 有什么好办法/还能怎么做 | /创意 | 涉及创意发散 |
| 沟通 | 沟通/谈判/说服/汇报 | 怎么跟X说/怎么让X同意 | /沟通 | 涉及沟通策略 |

匹配：关键词 OR 句式 → 触发。两者同时 → 措辞确定。仅句式 → "看起来可能涉及..."

## 上下文信号

BOOT 流程：cwd ∈ 已注册项目 或 对话提及项目关键词 → 建议加载 connector
桥接文件流程：cwd 下存在 .mind-os.md → 建议启动 mind-os 连接

## 时间信号

- 会话结束词（再见/结束/今天就到这/bye/下次再说）且未经 BOOT → 建议 /评分
- 对话轮数 > 20 且未触发回顾类模块 → 提醒阶段性回顾

## 输出格式

> 🧠 Mind OS 建议
> 检测到：{场景}（{原因}）
> 建议加载：{模块}
> 理由：{说明}
> → 回复"好"加载 / "不用"跳过

## 抑制

- 同场景单次（/评分 除外，但已执行 /评分 则不再提醒）
- 已加载模块不重复建议
- 拒绝后同类本会话静默
- 建议只在 AI 回复开头，不打断
```

- [ ] **Step 2: Verify token count**

Run: 手动检查文件长度，确认 < 400 tokens（约 50 行 markdown）。如超出，精简措辞。

- [ ] **Step 3: Commit**

```bash
cd C:/Users/wl/git/mind_os
git add mind-os-core/sentinel.md
git commit -m "feat: add sentinel.md intent detection protocol"
```

---

### Task 2: Update .mind-os.md bridge files (verbose format)

`marketing/.mind-os.md` 和 `zhidu-youhua/.mind-os.md` 使用详细格式，需在启动检测步骤 2 和 3 之间插入 READ sentinel。

**Files:**
- Modify: `C:/Users/wl/git/marketing/.mind-os.md` — 启动检测代码块内，步骤 2 之后
- Modify: `C:/Users/wl/git/zhidu-youhua/.mind-os.md` — 启动检测代码块内，步骤 2 之后

- [ ] **Step 1: Edit marketing/.mind-os.md**

在启动检测的步骤 2（constitution.md 验证）和步骤 3（输出状态）之间插入：

```
3. READ {mind_os}/mind-os-core/sentinel.md（加载意图检测规则）
   ├── 成功 → 检测规则已加载
   └── 失败 → 跳过（不阻塞）
```

原步骤 3 变为步骤 4。

marketing/.mind-os.md 的 `{mind_os}` 变量指向 `../mind-os`（注意：marketing 用 `mind-os` 带连字符）。

- [ ] **Step 2: Edit zhidu-youhua/.mind-os.md**

同样在步骤 2 和步骤 3 之间插入：

```
3. READ {mind_os}/mind-os-core/sentinel.md（加载意图检测规则）
   ├── 成功 → 检测规则已加载
   └── 失败 → 跳过（不阻塞）
```

zhidu-youhua/.mind-os.md 的 `{mind_os}` 同样指向 `../mind-os`。

- [ ] **Step 3: Commit**

```bash
cd C:/Users/wl/git/marketing
git add .mind-os.md
git commit -m "feat: add sentinel.md loading to mind-os bridge"

cd C:/Users/wl/git/zhidu-youhua
git add .mind-os.md
git commit -m "feat: add sentinel.md loading to mind-os bridge"
```

---

### Task 3: Update .mind-os.md bridge files (compact format)

`trainningChildren/.mind-os.md` 和 `xgcs-deploy-points/.mind-os.md` 使用紧凑格式（显式相对路径），需在步骤 2 和 3 之间插入。

**Files:**
- Modify: `C:/Users/wl/git/trainningChildren/.mind-os.md` — 启动检测代码块内
- Modify: `C:/Users/wl/git/xgcs-deploy-points/.mind-os.md` — 启动检测代码块内

- [ ] **Step 1: Edit trainningChildren/.mind-os.md**

在步骤 2（constitution.md 验证）和步骤 3（输出状态）之间插入：

```
3. READ ../mind_os/mind-os-core/sentinel.md
   成功 → 检测规则已加载 | 失败 → 跳过（不阻塞）
```

注意：trainningChildren 用 `../mind_os`（下划线）。同时将原行 `3. 通过 →` 改为 `4. 通过 →`。

- [ ] **Step 2: Edit xgcs-deploy-points/.mind-os.md**

同样插入：

```
3. READ ../mind_os/mind-os-core/sentinel.md
   成功 → 检测规则已加载 | 失败 → 跳过（不阻塞）
```

xgcs-deploy-points 同样用 `../mind_os`。同时将原行 `3. 通过 →` 改为 `4. 通过 →`。

- [ ] **Step 3: Commit**

```bash
cd C:/Users/wl/git/trainningChildren
git add .mind-os.md
git commit -m "feat: add sentinel.md loading to mind-os bridge"

cd C:/Users/wl/git/xgcs-deploy-points
git add .mind-os.md
git commit -m "feat: add sentinel.md loading to mind-os bridge"
```

---

### Task 4: Update BOOT.md Phase 4

**Files:**
- Modify: `C:/Users/wl/git/mind_os/mind-os-core/BOOT.md:510-518` — Phase 4 并行读取列表

- [ ] **Step 1: Edit BOOT.md**

在 Phase 4 并行读取代码块（约第 510-518 行）中，在 `READ {theory}/meta.md` 之后添加一行。修改后的代码块应为：

```
并行读取：
  READ {theory}/meta.md
  READ mind-os-core/sentinel.md          ← 新增：意图检测协议
  READ domains/_router.md
  READ projects/_router.md        ← 项目连接器路由机制说明
  SCAN local/projects/*.md        ← 扫描所有个人项目连接器，动态构建路由表
  READ runtime/focus.md
  READ runtime/dashboard.md
```

- [ ] **Step 2: Update Phase 4 summary line**

第 523 行的 summary 从 "8+" 改为 "9+"：

```
Phase 1-4 全部并行读取，总共 9+ 个文件（取决于连接器数量）。
```

- [ ] **Step 3: Commit**

```bash
cd C:/Users/wl/git/mind_os
git add mind-os-core/BOOT.md
git commit -m "feat: add sentinel.md to BOOT Phase 4 parallel loading"
```

---

### Task 5: Smoke test

手动验证在不同场景下 sentinel 能被正确加载和执行。

- [ ] **Step 1: 验证桥接文件场景**

在 `marketing/` 目录下启动一个新的 AI 会话。预期：
1. 看到 "🧠 Mind OS 已连接" 提示
2. 输入一句决策相关的话（如 "要不要扩大营销投入"）
3. 预期看到 sentinel 的建议输出块

- [ ] **Step 2: 验证 BOOT 场景**

在 `mind_os/` 目录下启动新会话，执行 `boot`。预期：
1. BOOT 正常完成（Phase 0-5）
2. sentinel 的场景信号自动停用（因为 meta.md 已加载）
3. 但上下文信号仍可用

- [ ] **Step 3: 验证抑制机制**

在桥接文件场景中：
1. 触发一次建议，选择"不用" → 同类不再提醒
2. 说"不用提醒了" → 所有建议停止
3. 说"继续提醒" → 恢复
