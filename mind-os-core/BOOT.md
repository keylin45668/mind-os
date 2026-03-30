# Mind OS — BOOT（AI 启动协议）

> **本文件是 AI 的核心启动逻辑。** 无论从哪个入口进来，都执行此协议。
>
> 入口方式：
> - **CLAUDE.md**：用户说"启动 mind-os"/"启动"/"boot"时触发
> - **直接引用**：用户说"请读取 BOOT.md 并启动"

---

## Pre-Boot：版本更新检查

```
① 读取本地版本
  READ local/config.md（不存在则 fallback config-template.md）→ 提取 version 字段 → {local_version}

② 获取远程版本（静默，失败不阻塞）
  执行: curl -s --max-time 5 https://raw.githubusercontent.com/keylin45668/mind-os/main/mind-os/config.md
  ├── 成功 → 提取 version 字段 → {remote_version}
  └── 失败（网络不通/超时）→ 跳过检查，直接进入 Phase 0

③ 比较版本
  {remote_version} > {local_version}？
  ├── 是 → 弹窗提示用户
  └── 否（相等或本地更新）→ 跳过，直接进入 Phase 0
```

```yaml
# 仅远程版本更新时弹出
AskUserQuestion:
  questions:
    - question: "🔄 Mind OS 有新版本 v{remote_version}（当前 v{local_version}），是否更新？"
      header: "版本更新"
      multiSelect: false
      options:
        - label: "✅ 立即更新"
          description: "从 GitHub 拉取最新版本"
        - label: "⏭️ 跳过"
          description: "使用当前版本继续启动"
```

```
用户选"✅ 立即更新"：
  执行: git -C mind-os/ pull origin main（或在 mind-os 所在目录执行 git pull）
  ├── 成功 → "✅ 已更新到 v{remote_version}" → 重新读取 config.md → 进入 Phase 0
  └── 失败（冲突等）→ "⚠️ 自动更新失败，请手动执行 git pull" → 继续启动当前版本

用户选"⏭️ 跳过"：
  → 直接进入 Phase 0
```

**设计原则：**
- 网络失败静默跳过，不阻塞启动
- curl 超时 5 秒，不影响启动体验
- 只读远程 config.md 的 version 字段，不拉全部内容
- 用户有选择权，不强制更新

---

## Phase 0：读取配置 + 档案选择 + 数据检测

```
READ local/config.md
  ├── 存在 → 使用该文件
  └── 不存在 → READ config-template.md → 复制到 local/config.md → 提示用户填写
→ 获取版本号：{version}
→ 获取 {schema}, {theory}
→ 获取 data_profiles 列表
```

> **配置分层**：`config-template.md` 是发行版模板（tracked），`local/config.md` 是个人实例（gitignored）。
> 首次启动时自动从模板创建本地配置。

### 档案选择

```
data_profiles 条目数：
  ├── 0 条 → 报错："config.md 中缺少 data_profiles，请添加至少一条"
  ├── 1 条 → 自动选中，{data} = 该条目的 path，不弹选择框
  └── ≥2 条 → 调用 AskUserQuestion 让用户选择：
```

```yaml
# 仅 ≥2 条档案时弹出
AskUserQuestion:
  question: "👤 选择本次使用的档案："
  header: "档案选择"
  multiSelect: false
  options:
    # 动态生成，default=true 的排第一，每条格式：
    - label: "{name}（默认）"
      description: "{description} — {path}"
    - label: "{name}"
      description: "{description} — {path}"
    # 最后一条固定：
    - label: "➕ 新建档案"
      description: "创建新的身份档案"
```

```
用户选择已有档案 → {data} = 选中条目的 path → 进入【数据检测】
用户选择"➕ 新建档案" → 提示输入名称和路径 → 写入 config.md → {data} = 新路径 → 进入【数据检测】
```

### 数据检测 + 类型识别

```
{data} 目录不存在？
  └── 调用 AskUserQuestion 询问：
```

```yaml
AskUserQuestion:
  question: "📂 未检测到数据目录，你是？"
  header: "数据检测"
  multiSelect: false
  options:
    - label: "🆕 首次使用"
      description: "创建新的身份档案"
    - label: "📁 已有数据"
      description: "选'其他'输入已有数据路径"
```

```
  用户选"🆕 首次使用" → 进入【首次安装流程】
  用户选"📁 已有数据"并提供路径 → 更新配置 → 继续类型识别
```

```
{data} 目录存在 → 检测目录类型：

  有 org.md + members/ 目录？
  ├── 是 → 【协作组织】
  │     → 读取 org.md 获取 {org} 信息
  │     → 扫描 members/ 子目录，列出成员列表
  │     → 调用 AskUserQuestion 让用户选择身份：
  │
  │     AskUserQuestion:
  │       question: "👤 你是谁？"
  │       header: "成员选择"
  │       options:
  │         - label: "{member_name_1}"          # 从各成员 profile.md 读取
  │           description: "{member_roles}"
  │         - label: "{member_name_2}"
  │           description: "{member_roles}"
  │         - label: "➕ 我是新成员"
  │           description: "创建我的身份档案"
  │
  │     选择已有成员 → {data} = {原路径}/members/{selected}/ → 进入【已有数据确认流程】
  │     选择"新成员" → 在 members/ 下创建新目录 → 进入【首次安装流程（个人部分）】
  │
  ├── 有 org.md 无 members/ → 【独立组织】
  │     → 读取 org.md 获取 {org} 信息
  │     → {data}/identity/profile.md 的 name 非空？
  │       ├── 是 → 进入【已有数据确认流程】
  │       └── 否 → 进入【首次安装流程（个人部分）】
  │
  └── 无 org.md → 【个人档案】
        → {data}/identity/profile.md 的 name 非空？
          ├── 是 → 进入【已有数据确认流程】
          └── 否 → 进入【首次安装流程】
```

---

## 【已有数据确认流程】（每次启动触发）

读取 `{data}/identity/profile.md` 和 `{data}/identity/preferences.md`。
如果是组织档案（存在 org.md），同时读取 org.md。

**按档案类型展示不同摘要：**

**个人档案：**
```
📋 当前身份档案（个人）：
  👤 姓名：{name}
  🎭 角色：{roles}
  💎 价值观：{core_values}
  💬 沟通风格：{communication_style}
  🛠️ 专业技能：{skills}
  🌐 语言：{language}
```

**组织档案（独立/协作）：**
```
📋 当前身份档案（组织）：
  🏢 组织：{org_name} | {industry} · {team_size} · {current_stage}
  👥 协作模式：{是（N人）/ 否}
  ───
  👤 姓名：{name}
  🎭 角色：{roles}
  💎 价值观：{core_values}
  💬 沟通风格：{communication_style}
  🛠️ 专业技能：{skills}
  🌐 语言：{language}
```

然后**立即调用 `AskUserQuestion`** 让用户点击确认：

```yaml
AskUserQuestion:
  question: "📋 以上身份档案是否正确？"
  header: "身份确认"
  multiSelect: false
  options:
    - label: "✅ 确认无误"
      description: "档案正确，直接进入系统"
    - label: "✏️ 需要修改"
      description: "告诉我要改哪项，如'角色改成程序员'"
  # 用户选"其他"时可自由输入修改内容
```

**展示规则：**
- 值为空的字段显示为 `（未设置）`，不隐藏
- 用户点击"✅ 确认无误" → 跳到 Phase 1
- 用户点击"✏️ 需要修改"或选"其他"输入具体修改 → AI 更新对应字段 → 写入文件 → 跳到 Phase 1
- 不重新走完整问卷，只针对性修改

---

## 【首次安装流程】（仅首次触发）

### Step 0：选择档案类型

```yaml
AskUserQuestion:
  question: "📂 这份档案是什么类型？"
  header: "档案类型"
  multiSelect: false
  options:
    - label: "👤 个人档案"
      description: "纯个人使用，不涉及组织"
    - label: "🏢 组织档案"
      description: "以组织/公司/团队身份使用"
```

```
用户选"👤 个人档案" → 进入【个人档案安装】
用户选"🏢 组织档案" → 进入【组织档案安装】
```

---

### 【个人档案安装】

#### Step 1：创建数据目录

```
正在创建你的个人数据目录...
→ 在 {data} 位置创建 identity/、content/、knowledge/ 目录
→ 复制空白模板文件到 identity/（profile.md、preferences.md、principles.md）
→ 不创建 org.md（标记为个人档案）
✅ 数据目录已就绪。
```

#### Step 2：个人信息采集（2 轮，无组织相关问题）

AI 输出欢迎语 `🆕 欢迎使用思维操作系统！接下来通过几个问题帮你建立身份档案（都可以跳过，后续再补）。`

**第 1 轮：基本信息（4 题）**

```yaml
AskUserQuestion:
  questions:
    - question: "👤 你叫什么名字？"
      header: "姓名"
      multiSelect: false
      options:
        - label: "暂时跳过"
          description: "之后再设置"
        - label: "直接输入"
          description: "选'其他'输入你的名字"
    - question: "🎭 你的主要角色？"
      header: "角色"
      multiSelect: true
      options:
        - label: "创业者"
          description: "正在创业或准备创业"
        - label: "程序员"
          description: "软件开发相关"
        - label: "管理者"
          description: "团队或项目管理"
        - label: "投资者"
          description: "投资决策相关"
    - question: "💎 最看重的价值观？"
      header: "价值观"
      multiSelect: true
      options:
        - label: "诚实"
          description: "真诚透明"
        - label: "长期主义"
          description: "延迟满足，着眼长远"
        - label: "家庭优先"
          description: "家庭是第一位"
        - label: "效率"
          description: "追求高效产出"
    - question: "💬 希望我用什么风格沟通？"
      header: "沟通风格"
      multiSelect: false
      options:
        - label: "简洁直接"
          description: "不废话，直奔主题"
        - label: "详细解释"
          description: "多给背景和推理过程"
        - label: "风趣幽默"
          description: "轻松愉快的交流方式"
```

**第 2 轮：技能与语言（2 题）**

```yaml
AskUserQuestion:
  questions:
    - question: "🛠️ 你的专业技能？"
      header: "技能"
      multiSelect: true
      options:
        - label: "技术"
          description: "编程、架构、运维等"
        - label: "管理"
          description: "团队管理、项目管理"
        - label: "营销"
          description: "市场推广、品牌运营"
        - label: "产品"
          description: "产品设计、需求分析"
    - question: "🌐 系统输出语言？"
      header: "语言"
      multiSelect: false
      options:
        - label: "中文"
          description: "简体中文"
        - label: "英文"
          description: "English"
        - label: "日文"
          description: "日本語"
```

#### Step 3：写入文件

```
写入：
  {data}/identity/profile.md → name, roles, core_values, skills
  {data}/identity/preferences.md → communication_style, language
  {data}/identity/principles.md → 默认值
注意：个人档案的 profile.md 中 industry/team_size/current_stage 字段留空
✅ 个人身份档案已创建！
```

→ 进入 Phase 1 正常启动。

---

### 【组织档案安装】

#### Step 1：创建数据目录

```
正在创建组织数据目录...
→ 在 {data} 位置创建目录
✅ 目录已就绪，开始采集组织信息。
```

#### Step 2：组织信息采集（1 轮）

```yaml
AskUserQuestion:
  questions:
    - question: "🏢 组织/公司名称？"
      header: "组织名"
      multiSelect: false
      options:
        - label: "直接输入"
          description: "选'其他'输入组织名称"
        - label: "暂时跳过"
          description: "之后再设置"
    - question: "🏭 组织所在行业？"
      header: "行业"
      multiSelect: false
      options:
        - label: "互联网／科技"
          description: "软件、互联网、人工智能等"
        - label: "制造业"
          description: "生产制造相关"
        - label: "教育"
          description: "教育培训相关"
        - label: "金融"
          description: "金融投资相关"
    - question: "👥 团队规模？"
      header: "团队"
      multiSelect: false
      options:
        - label: "小团队"
          description: "5 人以下"
        - label: "中型团队"
          description: "10-50 人"
        - label: "大型团队"
          description: "50 人以上"
    - question: "📍 当前阶段？"
      header: "阶段"
      multiSelect: false
      options:
        - label: "创业初期"
          description: "从 0 到 1 阶段"
        - label: "成长扩张"
          description: "快速发展期"
        - label: "成熟稳定"
          description: "业务已稳定"
        - label: "转型探索"
          description: "寻找新方向"
```

#### Step 3：协作模式选择

```yaml
AskUserQuestion:
  question: "👥 是否需要与他人协作？"
  header: "协作"
  multiSelect: false
  options:
    - label: "👤 独立使用"
      description: "只有我一个人用这份组织档案"
    - label: "👥 团队协作"
      description: "团队成员共享此档案，各自认领身份"
```

```
用户选"👤 独立使用" →
  创建结构：
    {data}/
    ├── org.md                    ← 写入组织信息（collaborative: false）
    ├── identity/                 ← 个人身份
    ├── content/
    └── knowledge/
  → 进入【个人信息采集】（Step 4）

用户选"👥 团队协作" →
  创建结构：
    {data}/
    ├── org.md                    ← 写入组织信息（collaborative: true）
    ├── members/                  ← 成员目录
    │   └── {member_id}/          ← 当前用户的空间
    │       ├── identity/
    │       ├── content/
    │       └── knowledge/
    └── shared/                   ← 共享内容区
        ├── content/
        └── knowledge/
  → {data} 重定向到 members/{member_id}/
  → 进入【个人信息采集】（Step 4）
```

#### Step 4：个人信息采集（组织成员版，2 轮）

与【个人档案安装】的 Step 2 完全相同，采集：姓名、角色、价值观、沟通风格、技能、语言。

#### Step 5：写入文件

```
写入：
  {data 或 members/{id}}/identity/profile.md → name, roles, core_values, skills
  {data 或 members/{id}}/identity/preferences.md → communication_style, language
  {data 或 members/{id}}/identity/principles.md → 默认值
  {原始路径}/org.md → org_name, industry, team_size, current_stage, collaborative
✅ 组织档案已创建！{协作模式 ? "其他成员启动时选择'我是新成员'即可加入。" : ""}
```

→ 进入 Phase 1 正常启动。

---

### org.md 文件格式

```yaml
# 组织信息（共享，所有成员可见）
org_name: "{名称}"
industry: "{行业}"
team_size: "{规模}"
current_stage: "{阶段}"
collaborative: true/false    # true=团队协作，false=独立使用
```

---

## Phase 1-2：加载核心（并行读取）

```
并行读取：
  READ {schema}/constitution.md     ← 宪法 + 冻结指标
  READ {schema}/protocols.md        ← 协作协议 + 管道 + 迭代 + 约定 + 动力学
  READ {schema}/output-template.md  ← 输出文档模板（总纲+分章节规范）
```

**仅 2 个文件，并行加载。**

## Phase 3：识别用户（并行读取）

```
并行读取：
  READ {data}/identity/profile.md
  READ {data}/identity/principles.md
  READ {data}/identity/preferences.md
  READ {data_root}/org.md             ← 仅组织档案时读取（{data_root} = 档案根路径）
```

> **路径说明**：协作组织下，{data} 指向 members/{id}/，{data_root} 指向上层（含 org.md 的目录）。
> 个人档案和独立组织下，{data} = {data_root}。

## Phase 4：加载路由表 + 项目连接器 + 焦点处理 + Loops 初始化（并行读取）

```
并行读取：
  READ {theory}/meta.md
  READ mind-os-core/sentinel.md          ← 意图检测协议
  READ mind-os-core/loops/README.md      ← 运行时三层监控（thinking-sentinel / protocol-guardian / knowledge-auditor）
  READ domains/_router.md
  READ projects/_router.md        ← 项目连接器路由机制说明
  SCAN local/projects/*.md        ← 扫描所有个人项目连接器，动态构建路由表
  READ runtime/focus.md
  READ runtime/dashboard.md
```

> **项目连接器分层**：`projects/_router.md` 定义路由机制，`local/projects/*.md` 存放个人连接器卡片。
> 启动时扫描 `local/projects/` 下所有 `.md` 文件，读取每个卡片的 `keywords` 字段，动态构建路由表。

**Phase 1-4 全部并行读取，总共 9+ 个文件（取决于连接器数量）。**

### 焦点日期处理（Phase 4 完成后立即执行）

```
读取 runtime/focus.md 后：
  ① 对比 current 中每条焦点的 date 与今天日期
     ├── date = 今天 → 保留在 current
     └── date ≠ 今天 → 移入 history（保留原 date + status）
  ② 扫描 history 中 status ≠ "done" 的条目 → 记录待提醒列表
  ③ 写回 runtime/focus.md
```

---

## Phase 5：任务路由（命令优先 + 关键词匹配 + 强制执行门）

```
用户输入
  ↓
⓪ 命令检测：输入以 / 开头？
  ├── 是 → 命令路由（见 meta.md 命令路由规则）
  │     → 直接加载对应 theory 文件，执行级别强制 MUST_RUN
  │     → 跳到 ③ 确定协作模式
  ├── 是，但匹配到系统命令（/理论 /切换 /焦点 /面板）
  │     → 执行系统命令，不进入任务流程
  ├── 是，但匹配到迭代命令（/迭代 /迭代进度 /迭代聚焦 /迭代暂停 /迭代继续 /模块迭代 /模块列表）
  │     → 执行迭代协议（见 CLAUDE.md 入口映射），不进入任务流程
  └── 否 → 进入关键词路由（①②）
  ↓
① 查 domains/_router.md → 匹配到 domain？
  ├── 是 → READ domains/{matched}/_rules.md
  └── 否 → 跳过
  ↓
①½ 查 Phase 4 动态构建的项目路由表 → 匹配到项目？
  ├── 是 → READ local/projects/{matched}.md（连接器卡片）
  │     → 按 context_files 读取项目上下文（受 3 文件上限约束）
  │     → 项目 iron_rules 作为不可违反红线（优先级 > theory > domain）
  │     → 项目 constraints 叠加到本次任务约束
  │     → 声明: "📂 已接入项目: {name}（{repo}）"
  └── 否 → 跳过
  ↓
② 查 {theory}/meta.md → 关键词匹配
  ├── 命中 → 只加载命中的 theory 文件（1-3个）
  └── 未命中 → 不加载 theory，使用 schema 通用规则
  ↓
②½ 任务分级 + Pre-Input Gate（见 task-grading.md）
  a) 根据路由命中结果判定任务级别：🟢轻量 / 🟡标准 / 🔴深度
  b) 执行 Pre-Input Gate 检查（🟢检3项、🟡🔴检全部7项）
  c) 全部通过 → 继续；任一失败 → 阻断，报告未通过项
  ↓
③ 确定协作模式（四模式）+ 拓扑（三拓扑 + 并行分治）
  ↓
③½ 路径选择（复杂任务时）：
  用户能在一句话内说清这件事的本质？
  ├── 能 → Top-Down（先分析后执行：/偏差 → /分析 → /执行）
  └── 不能 / "大概知道想要什么" → Bottom-Up（先做一版再迭代：/创意 → 快速方案 → /分析 审计 → 修正）
  轻量任务（无 MUST_RUN）→ 跳过此步
  ↓
④ ⚠️ 输出前门控（Pre-Output Gate）— 匹配即执行，无例外
  ※ 此阶段同时激活 thinking-sentinel（loops/thinking-sentinel.md）进行输出质量巡检
  AI 必须在输出前声明并执行：
  a) "本次匹配到: {文件列表}，协作模式: {模式×拓扑}"
     命令触发时声明: "命令触发: /{cmd} → {文件}，MUST_RUN"
  b) 逐条检查匹配到的文件是否有强制执行要求（见 meta.md 执行级别）
     MUST_RUN → 必须按协议执行，不执行不得输出
     SHOULD   → 应执行，跳过须声明理由
     MAY      → 可选参考
  c) 自检: "我是否按匹配到的 theory 协议执行了？"
     否 → 不得输出，先执行协议
  ↓
⑤ 执行（通过门控后才可输出）
```

**设计原则：**
- **命令路由**：用户主动触发 = 明确意图，无需意图验证，直接 MUST_RUN
- **关键词路由**：AI 被动匹配 = 需要意图验证，防误触发
- 两种路由最终汇入同一个门控流程，确保执行质量一致

---

## 启动确认（可视化面板 + 交互菜单）

先用文本输出状态面板（按档案类型选择对应格式）：

**个人档案面板：**
```
╔══════════════════════════════════════════╗
║  🟢 思维操作系统 v{version}              ║
╠══════════════════════════════════════════╣
║  👤 {name} | {roles}                    ║
╠══════════════════════════════════════════╣
║  📋 今日焦点（{today_date}）             ║
║  {focus_list_or_"暂无，选择'设定焦点'"}   ║
╠══════════════════════════════════════════╣
║  ⚠️ 未完成的历史焦点                     ║
║  {pending_history_or_"无"}               ║
╠══════════════════════════════════════════╣
║  🧭 可用理论：{theory_pack_name}         ║
║     {n}条路由 · {m}个领域 · 渐进加载     ║
╠══════════════════════════════════════════╣
║  📂 已接入项目                           ║
║  {project_list_or_"无（projects/ 下无卡片）"} ║
╚══════════════════════════════════════════╝
```

**组织档案面板：**
```
╔══════════════════════════════════════════╗
║  🟢 思维操作系统 v{version}              ║
╠══════════════════════════════════════════╣
║  🏢 {org_name} | {industry} · {stage}   ║
║  👤 {name} | {roles}                    ║
║  👥 {collaborative ? "协作（N人）" : "独立使用"} ║
╠══════════════════════════════════════════╣
║  📋 今日焦点（{today_date}）             ║
║  {focus_list_or_"暂无，选择'设定焦点'"}   ║
╠══════════════════════════════════════════╣
║  ⚠️ 未完成的历史焦点                     ║
║  {pending_history_or_"无"}               ║
╠══════════════════════════════════════════╣
║  🧭 可用理论：{theory_pack_name}         ║
║     {n}条路由 · {m}个领域 · 渐进加载     ║
╠══════════════════════════════════════════╣
║  📂 已接入项目                           ║
║  {project_list_or_"无（projects/ 下无卡片）"} ║
╚══════════════════════════════════════════╝
```

然后**立即调用 `AskUserQuestion`** 弹出可点击的操作菜单：

```yaml
AskUserQuestion:
  question: "🧭 你想做什么？"
  header: "操作"
  multiSelect: false
  options:
    - label: "📝 描述任务"
      description: "直接告诉我你要做什么"
    - label: "🎯 设定今日焦点"
      description: "设置今天要专注的事项"
    - label: "💡 了解系统能力"
      description: "查看系统功能介绍和应用场景"
    - label: "⚙️ 更多选项"
      description: "关于项目、历史焦点、切换理论包"
  # 用户选"其他"时可直接输入任务
```

**如果用户选择"⚙️ 更多选项"**，再弹出二级菜单：

```yaml
AskUserQuestion:
  question: "⚙️ 选择操作："
  header: "更多"
  multiSelect: false
  options:
    - label: "📚 查看可用理论命令"
      description: "列出所有 /命令，可直接触发理论模块"
    - label: "📅 查看历史焦点"
      description: "查看和管理过去的焦点记录"
    - label: "📦 添加／切换理论包"
      description: "管理可用的理论模块"
    - label: "ℹ️ 关于项目"
      description: "版本信息、开发者、理论基础"
```

**面板必填字段**：
- **通用**：版本号、姓名+角色、今日焦点（含日期）、未完成历史焦点提醒、可用理论包名+计数
- **组织档案额外**：组织名+行业+阶段、协作状态
- **个人档案**：不展示组织相关字段（行业、团队规模、阶段）
- 任何必填字段缺失 = 面板不完整，须补全后输出。

---

## 引导菜单内容

### /理论 命令（查看可用理论命令）

```
📚 可用理论命令（输入 /命令名 直接触发）：

🧠 思考类
  /偏差    — 认知偏差检查（决策前必扫）
  /分析    — 迭代引擎，红蓝对抗深度分析
  /审计    — 系统审计方法 A/B/C/D
  /创意    — 发散-收敛创造力引擎（设计/方案/点子）
  /质量    — 质量循环，输出打磨

📊 决策类
  /反脆弱  — 三元分类 + 杠铃策略 + 否定法
  /竞争    — 五事七计 + 博弈 + 不战而胜
  /排期    — 艾森豪威尔矩阵 + 反转思维
  /模型    — 多模型格栅（跨学科）

📥 信息与知识
  /收集    — GTD 收集规则
  /整理    — PARA 分流归档
  /执行    — 目标分解 + 第一步锚定（决策→行动桥梁）
  /知识    — Zettelkasten 原子笔记
  /学习    — 费曼技巧 + 刻意练习 + 能力圈扩展
  /回顾    — 日/周/月/季/年复盘

🤝 协作类
  /协作    — 任务路由 + 拓扑选择
  /沟通    — 受众分析 + 说服/谈判/汇报策略
  /动力学  — 系统陷阱识别 + 创造性张力
  /团队    — 深度汇谈 + 双环学习
  /原则    — 五维评估 + 鲁棒性测试
  /经济    — 比较优势 + 认知资本
  /进化    — 模块适应度评分 + 淘汰归档 + 生态位分化

⚙️ 系统命令
  /理论    — 查看本列表
  /切换    — 切换数据档案
  /焦点    — 查看/设置今日焦点
  /面板    — 刷新状态面板
  /评分    — 手动触发会话评分

🔄 迭代命令
  /迭代         — 跑一轮 autoevolve 系统迭代
  /迭代进度     — 查看系统迭代进度和合规率
  /迭代聚焦 {X} — 指定下一轮聚焦的场景
  /迭代暂停     — 暂停系统迭代
  /迭代继续     — 恢复系统迭代
  /深度迭代 {X} — 任务级多轮自动迭代（如 /深度迭代 要不要转型）
  /模块迭代 {X} — 对单个模块执行改进（如 /模块迭代 反脆弱）
  /模块列表     — 列出所有模块及合规状态

💡 用法示例：
  /反脆弱 这个投资机会值不值得做
  /分析 三个技术方案的利弊
  /偏差（不带描述会问你要分析什么）
  /深度迭代 要不要从制造业转型（AI自动跑N轮红蓝对抗）
  /模块迭代 迭代引擎（诊断并改进特定模块）
  /迭代（跑一轮系统级自动迭代）
```

---

### 选项 3：系统能做什么

```
思维操作系统 — 一套人机协作的思维增强平台，核心能力：

🧠 决策分析 — 识别认知偏差，多模型交叉验证，避免拍脑袋
📥 信息管理 — 收集整理 + 分类归档，信息不再爆炸
📝 知识沉淀 — 原子笔记法，知识越用越活
🔄 复盘迭代 — 日／周／月／季／年回顾节奏，持续进化
🤝 协作增强 — 四种协作模式 × 三种拓扑，人机各取所长

💡 想快速体验？试试说这些：
  • "帮我分析一下要不要换工作"（决策分析）
  • "整理一下我最近的想法"（知识管理）
  • "回顾一下这周做了什么"（复盘迭代）
  • "这个投资机会值得做吗"（风险评估）
```

### 选项 4：具体应用场景

```
按角色看思维操作系统怎么用：

👨‍💻 程序员
  • 技术方案评审（多模型分析利弊）
  • 项目排期优化（艾森豪威尔矩阵）
  • 代码知识沉淀（原子笔记关联）

🚀 创业者
  • 战略决策（五事七计 + 博弈分析）
  • 竞争分析（不战而胜策略）
  • 团队管理（协作模式自动路由）

💰 投资者
  • 投资决策（反脆弱 + 杠铃策略）
  • 风险评估（事前验尸 + 偏差扫描）
  • 组合管理（定期回顾 + 能力圈检测）

👨‍👩‍👧‍👦 家庭角色
  • 角色平衡（多角色精力分配）
  • 重要决策（教育、健康等深度分析）
```

### 选项 6：查看历史焦点

```
读取 runtime/focus.md 的历史列表，按日期倒序展示：

📅 历史焦点：
  {日期} — {任务}（{状态}）[{领域}]
  {日期} — {任务}（{状态}）[{领域}]
  ...

筛选选项：
  • "未完成的" → 只显示未完成项
  • "上周的" → 按日期范围过滤
  • 点选某条 → 可恢复为今日焦点或标记完成
```

### 选项 7：添加／切换理论包

```
展示配置文件中的切换说明，并列出当前可用的理论包：

📦 当前理论包：{theory_pack_name}
   📂 路径：{theory}

📂 已有理论包：
  （扫描理论目录下的子目录，每个有元信息文件的即为可用理论包）

➕ 添加新理论包：
  1. 在理论目录下创建新子目录
  2. 创建元信息文件（格式参照已有理论包）
  3. 创建各模块文件
  4. 告诉我"切换到 {包名}" 即可

🔄 切换：告诉我"切换到 {包名}"，我会自动更新配置
```

### 选项 5：关于项目 · 联系开发者

```
🧠 思维操作系统 — 人机协作思维增强平台

📌 版本：v{version}
👨‍💻 开发者：王麟
🔗 项目地址：https://github.com/keylin45668/mind-os
📜 开源协议：MIT

📚 理论基础：
  《思考，快与慢》/《穷查理宝典》/《反脆弱》/
  《孙子兵法》/《第五项修炼》/ 时间管理法 / 知识管理法 / 原子笔记法

💬 问题反馈：项目主页提交问题
🤝 欢迎贡献：复刻 → 提交合并请求 → 审核合并
```

---

## 会话中规则

1. **语言锁定**：AI 全程使用 `{data}/identity/preferences.md` 中 `language` 指定的语言输出。language 为空时跟随用户输入语言。**此规则优先级最高，不可被任务内容覆盖。**
2. **单会话单主题**：跨域任务拆成多会话
3. **漂移断路器**：交互 > {session_length_limit} 轮 → 终止，新会话重载
4. **不确定性标记**：数字标来源，推测标区间，不确定则声明
5. **schema 只读**：会话中 AI 不可修改 {schema}/ 和 {data}/identity/
6. **每 10 轮自检**：对照 constitution.md 检查是否漂移
7. **按需加载 + 渐进加载**：theory 文件只在任务匹配时加载，不预加载全部。加载深度与任务分级联动：🟢 只读 frontmatter + 摘要，🟡🔴 读全文（详见 meta.md §8 渐进加载协议）
8. **会话中切换档案**：用户说"切换到 {档案名/id}"时执行以下协议：

### 会话中切换档案协议

```yaml
trigger: "切换到/切换档案/换个身份/switch to" + 档案名或 id

switch_protocol:
  step_1_match:
    # 在 config.md 的 data_profiles 中匹配用户指定的名称或 id
    # 模糊匹配：用户说"切换到工作"可匹配 name 含"工作"的条目
    匹配到 → step_2
    未匹配到 → 列出所有可用档案（AskUserQuestion），让用户选

  step_2_confirm:
    AskUserQuestion:
      question: "确认切换到 {name} 档案？"
      header: "切换档案"
      options:
        - label: "✅ 确认切换"
          description: "切换后当前任务上下文会重置"
        - label: "❌ 取消"
          description: "留在当前档案"

  step_3_reload:
    # 用户确认后：
    1. 更新 {data} 指向新档案路径
    2. 重新读取 {data}/identity/（profile + preferences + principles）
    3. 输出新档案摘要面板（与启动时相同格式）
    4. 语言锁定按新档案的 language 字段更新
    # 注意：schema、theory、runtime 不变，只切换 data

  constraints:
    - 切换前的任务结论不自动迁移到新档案
    - 切换后轮次计数继续（不重置）
    - 建议切换后开始新任务，避免上下文混淆
```
