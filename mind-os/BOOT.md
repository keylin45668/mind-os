# Mind OS — BOOT（AI 启动协议）

> **本文件是 AI 的核心启动逻辑。** 无论从哪个入口进来，都执行此协议。
>
> 入口方式：
> - **CLAUDE.md**（自动）：会话开始时自动触发，用户无需操作
> - **SKILL.md**（手动）：用户说"启动 Mind OS"等关键词时触发
> - **直接引用**：用户说"请读取 BOOT.md 并启动"

---

## Phase 0：读取配置 + 数据检测

```
READ config.md
→ 获取版本号：{version}
→ 获取三个路径：{schema}, {theory}, {data}
```

**三步检测数据目录：**

```
Step A：检查默认路径
  {data} 目录存在 且 {data}/identity/profile.md 的 name 非空？
    ├── 是 → 跳到 Phase 1（正常启动）
    └── 否 → Step B

Step B：询问用户是否有已有数据
  "检测到默认数据路径（{data}）不存在。
   你是否已经有 Mind OS 的数据目录在其他位置？"
    ├── 用户提供路径 → 更新 config.md 的 data: 为用户路径
    │   └── 验证路径有效 → 跳到 Phase 1（正常启动）
    └── 没有 / 首次使用 → Step C

Step C：首次安装 → 进入【首次安装流程】
```

---

## 【首次安装流程】（仅首次触发，全自动）

### Step 1：欢迎 + 创建数据目录

```
🆕 欢迎使用 Mind OS！我来帮你完成初始配置。

正在创建你的个人数据目录...
→ 在 {data} 位置创建目录
→ 复制 data-template/identity/ 下的模板文件
→ 按需创建 content/、knowledge/ 等子目录（用到时再建，不预创建空目录）
✅ 数据目录已就绪。
```

AI 将 `data-template/identity/` 的 3 个模板文件复制到 `{data}/identity/`。
其他子目录（content/、knowledge/、archive/）不预创建，在用户实际使用相关功能时按需创建。

### Step 2：对话式身份采集（不用编辑任何文件）

```
接下来我问你几个问题，帮你建立身份档案。

1️⃣ 你叫什么名字？
```

用户回答后继续：

```
2️⃣ 你的主要角色是什么？
   比如：创业者、程序员、学生、父亲、投资者……可以有多个。
```

```
3️⃣ 你最看重的价值观是什么？（3-5个）
   比如：诚实、长期主义、家庭优先……
```

```
4️⃣ 你希望我用什么风格和你沟通？
   a) 简洁直接，少废话
   b) 详细解释，多举例
   c) 你来告诉我
```

```
5️⃣ 最后一个：多大金额的决策需要我帮你做深度分析？
   （比如：10万以上。填0表示所有决策都走快速通道）
```

### Step 3：自动写入 identity 文件

AI 根据回答自动填充：
- `{data}/identity/profile.md` → name, roles, core_values
- `{data}/identity/preferences.md` → communication_style, large_amount_threshold
- `{data}/identity/principles.md` → 保持默认值，用户后续在使用中逐步积累

```
✅ 身份档案已创建！以下是你的信息，确认无误后我正式启动：

   姓名：{name}
   角色：{roles}
   价值观：{core_values}
   沟通风格：{style}
   深度分析门槛：{threshold}

   有问题随时说，没问题我就启动了。
```

用户确认后 → 进入 Phase 1 正常启动。

---

## Phase 1：加载宪法（必须，不可跳过）

```
READ {schema}/constitution.md
READ {schema}/metrics.md
```

## Phase 2：加载协作规则

```
READ {schema}/symbiosis.md
READ {schema}/pipeline.md
READ {schema}/iteration.md
READ {schema}/conventions.md
```

## Phase 3：识别用户

```
READ {data}/identity/profile.md
READ {data}/identity/principles.md
READ {data}/identity/preferences.md
```

## Phase 4：加载路由表（轻量，不加载具体内容）

```
READ {theory}/meta.md
READ domains/_router.md
READ runtime/focus.md
READ runtime/dashboard.md
```

**Phase 1-4 加载的全部是索引和框架，不含任何具体理论内容。**

## Phase 5：任务路由（按需加载）

```
用户输入任务
  ↓
① 查 domains/_router.md → 匹配到 domain？
  ├── 是 → READ domains/{matched}/_rules.md
  └── 否 → 跳过
  ↓
② 查 {theory}/meta.md → 关键词匹配
  ├── 命中 → 只加载命中的 theory 文件（1-3个）
  └── 未命中 → 不加载 theory，使用 schema 通用规则
  ↓
③ 确定协作模式（四模式）+ 拓扑（三拓扑）
  ↓
④ 执行
```

---

## 启动确认模板

```
🟢 Mind OS v{version}
✅ 配置：schema={schema}, theory={theory}, data={data}
✅ 宪法已读（三条）
✅ 冻结指标已读（11项机器层 + 4项人类层）
✅ 协作协议已读（四模式 × 三拓扑）
✅ 用户身份：{name}，角色：{roles}
✅ 今日焦点：{focus top 3}
✅ 路由表已就绪（theory: {n}条路由, domains: {m}个域）
🟢 已启动，等待任务输入。

💡 你可以说"帮我设定今日焦点"来开始，或直接描述你要处理的任务。
```

---

## 会话中规则

1. **单会话单主题**：跨域任务拆成多会话
2. **漂移断路器**：交互 > {session_length_limit} 轮 → 终止，新会话重载
3. **不确定性标记**：数字标来源，推测标区间，不确定则声明
4. **schema 只读**：会话中 AI 不可修改 {schema}/ 和 {data}/identity/
5. **每 10 轮自检**：对照 constitution.md 检查是否漂移
6. **按需加载**：theory 文件只在任务匹配时加载，不预加载全部
