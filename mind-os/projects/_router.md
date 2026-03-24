# 项目连接器路由表

> AI 在 Phase 4 读取本文件，Phase 5 任务路由时按关键词匹配项目。
> **项目连接器 = 轻量指针，不存储数据，只告诉 Mind OS 去哪里读、用什么方法想。**

---

## 机制说明

```
projects/
  _router.md          ← 本文件：索引 + 路由规则
  {project-id}.md      ← 连接器卡片：一张卡 = 一个项目
```

### 运行时路由（Phase 5 追加步骤）

```
用户描述任务
  ↓
① 查 domains/_router.md（现有逻辑不变）
② 查 projects/_router.md（本文件）
  ├── 关键词命中 → 读对应连接器卡片
  │     → 读 context_files 获取项目上下文
  │     → 加载指定 theories（受 meta.md 3文件上限约束）
  │     → 采用卡片中指定的协作模式
  └── 未命中 → 跳过，走通用路由
  ↓
③ domain 规则 + project 上下文 + theory 方法 → 合并进入 Pre-Output Gate
```

### 优先级

- **project 提供上下文（数据）**，不提供规则
- **domain 提供领域规则**，project 的 `domain` 字段决定挂载到哪个 domain
- **theory 提供思考方法**，由连接器卡片的 `theories` 字段指定或走通用路由
- 冲突时：domain 规则 > project 上下文 > 通用 theory

### 连接器卡片格式

```yaml
# {project-id}.md
name: 项目显示名
repo: 相对路径或绝对路径
domain: 挂载到哪个 domain（对应 domains/ 下的目录名）
keywords: [关键词1, 关键词2, ...]

# Mind OS 接入时读取这些文件获取上下文（相对于 repo 路径）
context_files:
  - path/to/key-file-1.md
  - path/to/key-file-2.md

# 指定哪些 theory 模块最相关（不写=走通用路由匹配）
theories: [think/_index.md, decide/rules.md]

# 默认协作模式
collaboration: 对等协作 × 迭代

# 项目专属约束（可选，叠加在 domain 规则之上）
constraints:
  - 约束描述

# 数据落盘规则（可选，不写则用默认值）
output:
  project_files: "{repo}/"                  # 项目文件修改 → 写回项目仓库
  thinking: "对话中输出"                     # 思考过程默认不落盘（可改为 {repo}/.mind-os/）
  decisions: "runtime/decisions/"            # 决策记录 → Mind OS 全局追踪
  knowledge: "{data}/knowledge/notes/"       # 个人认知沉淀 → 用户知识库
```

### 三种使用场景

```
场景 A（想）: 在 Mind OS 目录启动 → 连接器自动读取项目上下文 → 分析/决策 → 对话输出
场景 B（做）: 在项目目录启动 → 项目自己的 CLAUDE.md 生效 → 直接改文件
场景 C（边想边做）: 在 Mind OS 启动 → 分析完 → 通过 {repo} 路径修改项目文件
```

---

## 路由表

| 关键词 | 项目 ID | 连接器卡片 | Domain |
|--------|---------|-----------|--------|
| 制度/合规/薪酬/员工手册/劳动法/HR/人事 | zhidu-youhua | projects/zhidu-youhua.md | people |

---

## 插拔操作

| 操作 | 怎么做 |
|------|--------|
| 接入新项目 | ① 在 `projects/` 下新建 `{id}.md` ② 在上方路由表加一行 ③ 在项目仓库中放 `.mind-os.md` 桥接文件 |
| 断开项目 | 删除卡片文件 + 删除路由表对应行 + 删除项目中的 `.mind-os.md` |
| 调整接入深度 | 改卡片中的 `context_files` 和 `theories` |
| 临时禁用 | 在路由表行首加 `<!-- ... -->` 注释 |

## 双向连接

连接器是**双向**的：

```
Mind OS 侧（projects/{id}.md）        项目侧（{repo}/.mind-os.md）
┌─────────────────────┐              ┌─────────────────────┐
│ Mind OS → 读项目数据  │              │ 项目 → 调用 Mind OS  │
│                     │              │                     │
│ · context_files     │   ←─ 指向 ─→  │ · mind_os_root 路径  │
│ · theories          │              │ · 触发关键词         │
│ · constraints       │              │ · 激活步骤           │
│ · output 规则       │              │ · connector 指向     │
└─────────────────────┘              └─────────────────────┘

场景 A/C: 在 Mind OS 启动 → 卡片自动生效
场景 B:   在项目启动 → 用户说触发词 → .mind-os.md 激活
```

## 桥接文件模板（.mind-os.md）

接入新项目时，复制以下内容到项目根目录 `.mind-os.md`，只需改两处：`mind_os` 路径和 `connector` 名称。

同时在项目的 CLAUDE.md 或 AGENTS.md 末尾加一行：
`本项目已接入 Mind OS 思考能力。会话首次启动时读取 .mind-os.md 执行连接检测。`

````markdown
# Mind OS 桥接协议（AI 读取，用户无需操作）

## 路径

```yaml
mind_os: ../mind-os                    # ← 改成实际相对路径
connector: projects/{id}.md            # ← 改成实际连接器文件名
```

## 启动检测（会话首次启动时自动执行）

```
AI 读取本文件后，立即执行以下检测（不需要用户触发）：

1. 尝试读取 {mind_os}/{connector}
   ├── 成功 → 记录连接器配置（theories, constraints, collaboration）
   └── 失败 → 输出 "⚠️ Mind OS 未连接（路径不可达）"，后续按项目本地规则工作

2. 尝试读取 {mind_os}/schemas/default/constitution.md（只读前 5 行验证格式）
   ├── 成功 → Mind OS 核心可达
   └── 失败 → 输出 "⚠️ Mind OS 核心文件缺失"

3. 检测通过后输出一行状态：
   "🧠 Mind OS 已连接 · 说「帮我想清楚」或「/think」启用深度分析"

检测失败不阻塞工作——项目自身规则始终生效。
```

## 触发深度分析

```
用户的话中出现以下任意表达时，激活 Mind OS：
  - "帮我想清楚" / "想清楚"
  - "深度分析"
  - "红蓝对抗"
  - "/think"
  - "用 mind-os"

激活步骤：
  1. READ {mind_os}/{connector}                        → 获取 theories + constraints
  2. READ {mind_os}/theories/rational/meta.md           → 按任务关键词匹配 theory 文件
  3. READ 匹配到的 theory 文件（≤ 3 个）
  4. 按 theory 协议执行（MUST_RUN 匹配即执行）
  5. 输出结论
  6. 用户说"改" / "按这个改" → 直接在项目内修改文件

未触发时：正常按项目自身规则工作，Mind OS 不介入。
```
````
