# Mind OS 安装引导

> 预计耗时：3 分钟。

## 安装方式（选一种）

### A：零操作自动启动（推荐首次）

把项目文件夹（含 `CLAUDE.md` 和 `mind-os-core/`）设为工作目录。每次新会话自动启动。首次使用自动引导配置。

### B：手动触发（所有 AI 工具通用）

| 工具 | 操作 |
|------|------|
| Claude Code / Cowork | mind-os-core/ 所在目录设为工作目录 |
| Claude Projects | 添加为 Project Knowledge |
| ChatGPT | 上传 BOOT.md 和 config-template.md |
| 其他 AI | 确保能读取 mind-os-core/ 文件 |

然后说：`请读取 BOOT.md 并启动 Mind OS。`

### C：作为 Skill 安装（Claude 生态）

把 `mind-os-core/` 放到 Skills 目录下，说"启动 Mind OS"即可触发。

### D：给已有项目装脑子（推荐日常）

在项目目录说：`安装 mind-os ../mind-os`

AI 自动：探测路径 → 问 2 个问题 → 生成连接文件 → 验证。之后说**「帮我想清楚」**激活深度分析。详见 [projects/INSTALL.md](projects/INSTALL.md)。

---

**无论哪种方式**：首次使用 → 自动创建目录 → 对话引导配置 → 启动。无需手动编辑文件。

---

## 常见问题

| 问题 | 回答 |
|------|------|
| data 路径要改吗？ | 默认 `../data`，不改也能用 |
| 不懂技术能用吗？ | 能，只需会和 AI 对话 |
| 给别人用？ | 发 mind-os-core/ 文件夹，你的数据在 data/ 和 local/ 里不会带走 |
| 换方法论？ | 改 `local/config.md` 的 `theory:` 一行 |
| 多项目装脑子？ | 每个项目目录说一次 `安装 mind-os`，互不影响 |
| 会改我项目文件？ | 只新增 `.mind-os.md` + CLAUDE.md 末尾加一行 |
