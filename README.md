# Mind OS

**人机协作思维操作系统** — 让 AI 不只是回答问题，而是和你一起思考。

```
Transform(input, context) → output
context = schema ⊕ theory ⊕ data
```

Mind OS 是一套纯 Markdown 文件组成的认知框架。它不是代码，不需要安装运行环境——把文件夹给 AI 读，AI 就获得了一整套思维管道：收集、分流、思考、决策、沉淀、回顾，并且越用越聪明。

## 为什么需要它

直接和 AI 对话，AI 是被动的——你问什么它答什么。加载 Mind OS 后，AI 变成主动的协作者：它会检查你的认知偏差，会用多个思维模型交叉验证，会在大额决策前自动触发深度分析，会定期审计自己有没有跑偏，还会通过自迭代引擎不断进化。

## 核心特性

**三维正交架构** — schema（工作流）、theory（方法论）、data（用户数据）完全独立。换人改 data，换方法论改 theory，换工作流改 schema，互不影响。`local/config.md` 一行切换。

**按需加载** — 不把所有理论塞进上下文。通过路由表按任务关键词匹配，只加载需要的 1-3 个模块。

**认知偏差免疫** — 9 种常见偏差自动检查（锚定效应、WYSIATI、损失厌恶、过度自信、规划谬误、峰终效应、能力圈、推断阶梯、芒格 25 误判），内置于决策流程。

**红蓝对抗** — 蓝方正向论证 → 红方质疑本源 → 裁决收敛，多轮迭代直到论点经得起考验。

**多模型决策** — 反脆弱分析、第一性原理、贝叶斯更新、芒格多模型格栅、五事七计等 6+ 思维模型协同工作。

**协作拓扑** — 4 种协作模式（谁主导）× 3 种交互拓扑（串联/并联/迭代），动态匹配任务类型。

**人类冻结指标** — AI 优化"怎么做到"，但"什么算成功"由人类定义且不可被 AI 修改。

**自迭代引擎（AutoEvolve）** — 系统自我审计、迭代、验证的闭环。每次交互不只服务用户，同时训练系统——用 N 次比第 1 次更聪明。

**项目连接器** — 给任何外部项目插一张卡片，即可接入 Mind OS 的思考能力，项目零改动。

**多档案支持** — 一套系统支持多个用户档案，启动时选择，会话中切换。

**6 大领域** — 内置软件开发、财务、人事、战略、写作、个人生活的领域专属规则。

## 快速开始

```bash
git clone https://github.com/keylin45668/mind-os.git
cd mind-os   # 打开 Claude Code，说"启动"
```

AI 自动：检测首次使用 → 创建身份档案 → 引导配置 → 启动系统。

更多安装方式（手动触发、Skill 安装、给已有项目装脑子）详见 [SETUP.md](mind-os-core/SETUP.md)。

## 核心能力

| 能力 | 说明 | 关键模块 |
|------|------|---------|
| 决策分析 | 识别认知偏差，多模型交叉验证 | think/_index.md · 9 种偏差检查 |
| 红蓝对抗 | 蓝方正向论证 → 红方质疑 → 裁决 | think/iterative-engine.md |
| 反脆弱分析 | 三元分类 + 杠铃策略 + 否定法 | decide/antifragile.md |
| 竞争策略 | 五事七计 + 博弈分析 | decide/competition.md |
| 系统审计 | 数学形式化 + 原子分解 + 正反检验 | think/system-audit-method.md |
| 知识管理 | Zettelkasten 原子笔记 + 关联 | knowledge/rules.md |
| 复盘回顾 | 日/周/月/季/年回顾节奏 | review/rules.md |
| 协作增强 | 4 种模式 × 3 种拓扑 | schemas/default/protocols.md |
| 项目连接 | 给任何外部项目插一张卡就能用 Mind OS 的脑子 | projects/_router.md |
| 自迭代引擎 | AutoEvolve 闭环优化 | autoevolve/ENTRY.md |

## 目录结构

```
├── CLAUDE.md                # 自动启动入口
├── mind-os-core/            # 系统内核（发行版，分发给别人只需这个文件夹）
│   ├── BOOT.md              # AI 启动协议（Phase 0-5）
│   ├── config-template.md   # 配置模板（首次启动时复制到 local/）
│   ├── CHANGELOG.md         # 版本升级说明
│   ├── DESIGN-NOTES.md      # 设计推导（21 层剥洋葱）
│   ├── schemas/default/     # 系统架构（五条宪法 + 冻结指标 + 协作协议）
│   ├── theories/rational/   # 方法论模块（路由表 + 按需加载的认知模块）
│   │   ├── think/           #   思考类（偏差扫描、迭代引擎、审计方法）
│   │   ├── decide/          #   决策类（排期、反脆弱、竞争、多模型）
│   │   ├── capture/         #   收集（GTD）
│   │   ├── organize/        #   分类（PARA）
│   │   ├── knowledge/       #   知识（Zettelkasten）
│   │   ├── review/          #   回顾（周期 + 会话评分）
│   │   └── collaboration/   #   协作（动力学 + 学习型组织）
│   ├── domains/             # 领域专属规则（软件开发/财务/人事/战略/写作/个人）
│   ├── projects/            # 项目连接器机制
│   │   ├── _router.md       #   路由机制说明
│   │   ├── _example.md      #   连接器卡片模板
│   │   └── INSTALL.md       #   一句话安装协议
│   ├── autoevolve/          # 自迭代引擎
│   │   ├── ENTRY.md         #   迭代入口
│   │   ├── evaluator.md     #   合规评估器
│   │   └── scenarios/       #   测试场景
│   ├── runtime/             # 运行时状态（AI 可写，gitignored）
│   ├── scripts/             # Claude Code Hooks 脚本
│   ├── data-template/       # 首次安装用的空白身份模板
│   └── tests/               # 架构测试 + 引擎测试
├── local/                   # 个人实例（gitignored，不上传）
│   ├── config.md            #   你的运行配置（从 config-template.md 初始化）
│   └── projects/            #   你的项目连接器卡片
│       └── {id}.md          #   一张卡 = 一个项目连接
├── data/                    # 你的个人数据（gitignored，不上传）
└── archive/                 # 设计历史文档（gitignored，不上传）
```

## 设计哲学

整个系统从一个公式推导出来：`context = schema ⊕ theory ⊕ data`。经历了 v1 到 v5 共 21 层"审计→发现违反→重构"的剥洋葱过程，融合了多本经典和多套理论的核心方法论。详见 [DESIGN-NOTES.md](mind-os-core/DESIGN-NOTES.md)。

五条宪法：
1. **Transform 公式** — 三层正交分离，独立可替换
2. **冻结指标** — AI 不可修改成功标准的定义
3. **复杂度预算** — schema ≤ 30 条规则，theory 单文件 ≤ 1000 tokens
4. **本源铁律** — 一切分析必须指向事物本质，不可沦为套框架
5. **迭代即存在** — 系统的价值在于用了 N 次比第 1 次聪明了多少

## 协作与贡献

| 想做什么 | 参考 |
|---------|------|
| 创建 theory pack | [theories/rational/README.md](mind-os-core/theories/rational/README.md) |
| 新增领域 | [domains/_router.md](mind-os-core/domains/_router.md) |
| 接入外部项目 | [projects/INSTALL.md](mind-os-core/projects/INSTALL.md) |
| 切换配置 | 编辑 `local/config.md`（首次从 [config-template.md](mind-os-core/config-template.md) 生成） |
| 跑自迭代 | 说"autoevolve" |
| 理解设计推导 | [DESIGN-NOTES.md](mind-os-core/DESIGN-NOTES.md) |

## 理论基础

《思考，快与慢》/ 《穷查理宝典》/ 《反脆弱》/ 《黑天鹅》/ 《孙子兵法》/ 《道德经》/ 《系统之美》/ 《第五项修炼》/ 《原则》/ 《复杂》/ 《国富论》/ GTD / PARA / Zettelkasten / 延展心智论 / Licklider 人机共生 / 博弈论 / 比较优势

## 版本

当前版本：**v5.1**（见 [CHANGELOG.md](mind-os-core/CHANGELOG.md)）

## License

[MIT](LICENSE)
