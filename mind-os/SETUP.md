# Mind OS 安装引导

> 预计耗时：3 分钟。

---

## 安装方式（选一种）

### 方式 A：零操作自动启动（推荐，Claude Code / Cowork）

把整个项目文件夹（包含 `CLAUDE.md` 和 `mind-os/`）设为工作目录。

**然后就没了。** 每次打开新会话，AI 自动读取 `CLAUDE.md` → 加载 `BOOT.md` → 完成启动。首次使用时会自动引导你完成配置。

### 方式 B：手动触发（所有 AI 工具通用）

| 你用的工具 | 怎么做 |
|-----------|-------|
| Claude Projects | 把 mind-os/ 添加为 Project Knowledge |
| Claude Code / Cowork | 将 mind-os/ 所在目录设为工作目录 |
| ChatGPT | 上传 mind-os/ 里的 BOOT.md 和 config.md |
| 其他 AI | 确保 AI 能读取 mind-os/ 里的文件 |

然后对 AI 说：

```
请读取 BOOT.md 并启动 Mind OS。
```

### 方式 C：作为 Skill 安装（Claude 生态）

把 `mind-os/` 文件夹放到 Claude 的 Skills 目录下，系统会自动识别 `SKILL.md`。之后说"启动 Mind OS"即可触发。

---

**无论哪种方式，AI 都会自动：**
- 检测到首次使用
- 创建你的个人数据目录
- 用对话问你几个问题（名字、角色、价值观、沟通风格）
- 帮你填好所有配置文件
- 启动系统

你不需要手动编辑任何文件。

---

## 常见问题

**Q: config.md 里的 data 路径要改吗？**
A: 默认路径是 mind-os/ 同级的 `../data`。如果你想放别的位置，改 config.md 里的 `data:` 一行。不改也能用。

**Q: 我不懂技术，能用吗？**
A: 能。你只需要会和 AI 对话。

**Q: 给别人用怎么办？**
A: 把 mind-os/ 文件夹发给他，让他从 Step 1 开始。你的数据在 data/ 里，不在 mind-os/ 里，不会被带走。

**Q: 想换一套方法论？**
A: 改 config.md 里的 `theory:` 一行。详见 theories/rational/README.md。
