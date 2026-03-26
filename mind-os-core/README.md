# Mind OS

> 版本：v5.2 | 变更日志：[CHANGELOG.md](CHANGELOG.md) | 项目地址：[GitHub](https://github.com/keylin45668/mind-os)
>
> 一切认知活动 = `Transform(input, context) → output`

## 一个公式

```
context = schema ⊕ theory ⊕ data
```

| 维度 | 一句话 | 换它改什么 | 物理位置 |
|------|--------|-----------|---------|
| schema | 管道怎么连 | 改工作流 | schemas/{name}/ |
| theory | 用什么方法 | 改处理规则 | theories/{name}/ |
| data | 谁在用 | 改使用者 | 外部独立目录 |

三者正交，物理隔离。`local/config.md` 一行切换，零文件搬运。

## 一个闭环

```
审计 → 迭代 → 验证 → 审计 → …
```

人类冻结"什么算成功"，AI 在冻结标准下优化"怎么做到"。

## 一条底线

> 系统宁简勿繁。新增必须先减。

## 一个判据

> 协作结果必须系统性超越单独任何一方。做不到，不是工具问题，是结构问题。

---

## 快速开始

详见 [SETUP.md](SETUP.md)（4 种安装方式）。最简单：把项目文件夹设为工作目录，说"启动"。

---

## 核心能力

| 能力 | 说明 | 关键模块 |
|------|------|---------|
| 决策分析 | 识别认知偏差，多模型交叉验证 | think/_index.md · 9 种偏差检查 |
| 红蓝对抗 | 蓝方正向论证 → 红方质疑 → 裁决 | think/iterative-engine.md |
| 反脆弱分析 | 三元分类 + 杠铃策略 + 否定法 | decide/antifragile.md |
| 竞争策略 | 五事七计 + 博弈分析 | decide/competition.md |
| 系统审计 | 数学形式化 + 原子分解 + 正反检验 + 同构检验 | think/system-audit-method.md |
| 知识管理 | Zettelkasten 原子笔记 + 关联 | knowledge/rules.md |
| 复盘回顾 | 日/周/月/季/年回顾节奏 | review/rules.md |
| 协作增强 | 4 种模式 × 3 种拓扑 | schemas/default/protocols.md |
| 项目连接 | 给任何外部项目插一张卡就能用 Mind OS 的脑子 | projects/_router.md |
| 多角色审议 | 角色元模型 + 审议协议 + 评分体系 + 决策分级 | deliberation/meta.md |
| 自迭代引擎 | AutoEvolve 闭环优化 | autoevolve/ENTRY.md |

---

## 架构总览

```
mind-os-core/                    ← 系统内核（发行版，git tracked）
├── BOOT.md                      ← AI 启动协议（Phase 0-5）
├── config-template.md           ← 配置模板（首次启动时复制到 local/）
├── schemas/default/             ← 系统架构（宪法 + 协作协议）
│   ├── constitution.md          ← 四条宪法 + 冻结指标
│   ├── protocols.md             ← 协作模式 + 门控 + 管道 + 约定
│   └── output-template.md       ← 输出文档模板
├── theories/rational/           ← 方法论模块（19 条路由，按需加载）
│   ├── meta.md                  ← 路由表（关键词 → 文件 + 执行级别）
│   ├── think/                   ← 思考类（偏差扫描、迭代引擎、审计方法）
│   ├── decide/                  ← 决策类（排期、反脆弱、竞争、多模型）
│   ├── capture/                 ← 收集（GTD 规则）
│   ├── organize/                ← 分类（PARA 规则）
│   ├── knowledge/               ← 知识（Zettelkasten）
│   ├── review/                  ← 回顾（周期 + 会话评分）
│   ├── collaboration/           ← 协作（路由 + 动力学 + 学习型组织）
│   └── deliberation/            ← 多角色审议（角色元模型 + 协议 + 评分 + 决策分级）
├── domains/                     ← 领域专属规则
│   ├── _router.md               ← 领域路由表
│   ├── software-dev/            ← 代码/编程/开发
│   ├── finance/                 ← 投资/融资/财务
│   ├── people/                  ← 招聘/绩效/团队
│   ├── strategy/                ← 战略/竞争/市场
│   ├── writing/                 ← 写作/文档/报告
│   └── personal/                ← 家庭/健康
├── projects/                    ← 项目连接器机制
│   ├── _router.md               ← 路由机制说明
│   ├── _example.md              ← 连接器卡片模板
│   └── INSTALL.md               ← 一句话安装协议
├── autoevolve/                  ← 自迭代引擎
│   ├── ENTRY.md                 ← 迭代入口
│   ├── evaluator.md             ← 合规评估器（40 项检查）
│   └── scenarios/               ← 测试场景
├── runtime/                     ← 运行时状态（AI 可写，gitignored）
├── data-template/               ← 首次安装用的空白数据模板
├── scripts/                     ← Claude Code Hooks 脚本
└── tests/                       ← 架构测试 + 引擎测试

local/                           ← 个人实例（gitignored，不上传）
├── config.md                    ← 你的运行配置
└── projects/                    ← 你的项目连接器卡片
    └── {project-id}.md          ← 一张卡 = 一个项目连接

data/                            ← 用户数据（gitignored，不上传）
├── identity/                    ← 身份档案（profile + preferences + principles）
├── content/                     ← 按领域分类的内容
└── knowledge/                   ← 原子笔记 + 知识关联
```

---

## 项目连接器（v5.1）

给任何外部项目插一张卡，就能用 Mind OS 的思考能力。

```
Mind OS（脑子）                          外部项目（数据）
┌──────────────────┐                   ┌──────────────┐
│ local/projects/  │ ←── 读数据 ──→    │ .mind-os.md  │
│ {id}.md          │                   │ （桥接文件）   │
│                  │   一张卡=一个连接   │              │
└──────────────────┘                   └──────────────┘
```

| 操作 | 怎么做 |
|------|--------|
| 接入新项目 | 在项目目录说 `安装 mind-os` |
| 断开项目 | 删除 `local/projects/{id}.md` + 项目中的 `.mind-os.md` |
| 在项目中启用深度分析 | 说「帮我想清楚」或 `/think` |
| 查看连接器机制 | 读 `projects/_router.md` |

详见 [projects/_router.md](projects/_router.md)。

---

## 文件索引

| 路径 | 读它回答 | 谁该读 |
|------|---------|--------|
| [../CLAUDE.md](../CLAUDE.md) | 会话自动启动入口 | AI（自动读取） |
| [SKILL.md](SKILL.md) | Skill 生态触发入口 | AI（关键词触发时读取） |
| [BOOT.md](BOOT.md) | AI 怎么启动？ | AI（核心启动逻辑） |
| [config-template.md](config-template.md) | 配置模板（个人配置在 local/config.md） | 想切换的人 |
| [schemas/default/](schemas/default/) | 系统怎么运转？ | 所有人 |
| [theories/rational/meta.md](theories/rational/meta.md) | 当前用了哪些方法论？ | 想改方法的人 |
| [domains/_router.md](domains/_router.md) | 任务怎么路由？ | 想扩展任务域的人 |
| [projects/_router.md](projects/_router.md) | 项目怎么接入？ | 想连接外部项目的人 |
| [projects/INSTALL.md](projects/INSTALL.md) | 怎么给项目装脑子？ | 想在项目中用 Mind OS 的人 |
| [autoevolve/ENTRY.md](autoevolve/ENTRY.md) | 怎么跑自迭代？ | 想优化系统的人 |
| [CHANGELOG.md](CHANGELOG.md) | 版本变了什么？ | 升级时必读 |
| [DESIGN-NOTES.md](DESIGN-NOTES.md) | 为什么这么设计？ | 想理解推导过程的人 |

## 阅读顺序

```
首次使用：    README.md → 说"启动" → AI 自动引导
给项目装脑子：在项目目录说"安装 mind-os"
想切换配置：  改 local/config.md 一行
想改方法论：  theories/rational/meta.md → 对应模块
想扩展领域：  domains/_router.md → 创建新 domain
想接入项目：  复制 projects/_example.md 到 local/projects/ 并填写
想跑自迭代：  说"autoevolve"
想理解设计：  DESIGN-NOTES.md
```

---

## 理论基础

《思考，快与慢》/ 《穷查理宝典》/ 《反脆弱》/ 《黑天鹅》/ 《孙子兵法》/ 《道德经》/ 《系统之美》/ 《第五项修炼》/ 《原则》/ 《复杂》/ 《国富论》/ GTD / PARA / Zettelkasten / 延展心智论 / Licklider 人机共生 / 博弈论 / 比较优势

## 开源协议

MIT
