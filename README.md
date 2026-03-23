# Mind OS

**人机协作思维操作系统** — 让 AI 不只是回答问题，而是和你一起思考。

```
Transform(input, context) → output
context = schema ⊕ theory ⊕ data
```

Mind OS 是一套纯 Markdown 文件组成的认知框架。它不是代码，不需要安装运行环境——把文件夹给 AI 读，AI 就获得了一整套思维管道：收集、分流、思考、决策、沉淀、回顾。

## 为什么需要它

直接和 AI 对话，AI 是被动的——你问什么它答什么。加载 Mind OS 后，AI 变成主动的协作者：它会检查你的认知偏差，会用多个思维模型交叉验证，会在大额决策前自动触发深度分析，会定期审计自己有没有跑偏。

## 核心特性

**三维正交架构** — schema（工作流）、theory（方法论）、data（用户数据）完全独立。换人改 data，换方法论改 theory，换工作流改 schema，互不影响。`config.md` 一行切换。

**按需加载** — 不把所有理论塞进上下文。通过路由表按任务关键词匹配，只加载需要的 1-3 个模块。

**认知偏差免疫** — 9 种常见偏差自动检查（锚定效应、WYSIATI、损失厌恶、过度自信等），内置于决策流程。

**多模型决策** — 反演思维、第一性原理、贝叶斯更新、芒格多模型格栅等 6+ 思维模型协同工作。

**反脆弱分析** — 三元分类、杠铃策略、压力注入，来自塔勒布的核心方法论。

**协作拓扑** — 4 种协作模式（谁主导）× 3 种交互拓扑（串联/并联/迭代），动态匹配任务类型。

**人类冻结指标** — AI 优化"怎么做到"，但"什么算成功"由人类定义且不可被 AI 修改。

## 快速开始

### 方式一：自动启动（推荐）

如果你用的是 Claude Code 或 Cowork：

1. 把本仓库 clone 到本地
2. 将文件夹设为工作目录
3. 开始对话——AI 会自动启动 Mind OS

根目录的 `CLAUDE.md` 会在每次会话开始时自动触发启动协议。

### 方式二：手动启动

对任何 AI 说：

```
请读取 mind-os/BOOT.md 并启动 Mind OS。
```

首次使用时，AI 会自动引导你完成身份配置（名字、角色、价值观、沟通风格），无需手动编辑任何文件。

### 方式三：作为 Skill 安装

把 `mind-os/` 放到 Claude 的 Skills 目录下，之后说"启动 Mind OS"即可触发。

## 目录结构

```
├── CLAUDE.md              # 自动启动入口
├── mind-os/               # 系统核心（分发给别人只需这个文件夹）
│   ├── BOOT.md            # AI 启动协议
│   ├── SKILL.md           # Skill 生态入口
│   ├── config.md          # 配置开关（version, schema, theory, data 路径）
│   ├── CHANGELOG.md       # 版本升级说明
│   ├── schemas/default/   # 系统架构（宪法、指标、管道、协作规则等 7 文件）
│   ├── theories/rational/ # 方法论模块（路由表 + 26 个按需加载的模块）
│   ├── domains/           # 领域专属规则（软件开发等）
│   ├── data-template/     # 首次安装用的空白身份模板
│   ├── runtime/           # 会话运行时状态
│   └── examples/          # 示例对话
├── data/                  # 你的个人数据（.gitignore，不上传）
└── archive/               # 设计历史文档（.gitignore，不上传）
```

## 设计哲学

整个系统从一个公式推导出来：`context = schema ⊕ theory ⊕ data`。经历了 v1 到 v4 共 19 轮"审计→发现违反→重构"的剥洋葱过程，融合了 11 本书和 6 套理论的核心方法论。详见 [DESIGN-NOTES.md](mind-os/DESIGN-NOTES.md)。

三条宪法：
1. Transform 公式 + 三层正交分离
2. 冻结指标 — AI 不可修改成功标准的定义
3. 复杂度预算 — schema ≤ 30 条规则，theory ≤ 15 个模块

## 版本

当前版本：**v4.3**（见 [CHANGELOG.md](mind-os/CHANGELOG.md)）

## 协作与贡献

如果你想创建自己的 theory pack（比如用斯多葛哲学替换当前的理性决策框架），或者新增一个 domain（比如医疗、教育），参考：

- [theories/rational/README.md](mind-os/theories/rational/README.md) — 如何创建 theory pack
- [domains/_router.md](mind-os/domains/_router.md) — 如何新增领域
- [config.md](mind-os/config.md) — 如何切换配置

## License

[MIT](LICENSE)
