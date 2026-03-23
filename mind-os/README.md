# Mind OS

> 版本：见 config.md 的 `version` 字段 | 变更日志：[CHANGELOG.md](CHANGELOG.md)
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

三者正交，物理隔离。config.md 一行切换，零文件搬运。

## 一个闭环

```
审计 → 迭代 → 验证 → 审计 → …
```

人类冻结"什么算成功"，AI 在冻结标准下优化"怎么做到"。

## 一条底线

> 系统宁简勿繁。新增必须先减。

## 一个判据

> 协作结果必须系统性超越单独任何一方。做不到，不是工具问题，是结构问题。

## 文件索引

| 路径 | 读它回答 | 谁该读 |
|------|---------|--------|
| [../CLAUDE.md](../CLAUDE.md) | 会话自动启动入口 | AI（自动读取，用户无需操作） |
| [SKILL.md](SKILL.md) | Skill 生态触发入口 | AI（关键词触发时读取） |
| [BOOT.md](BOOT.md) | AI 怎么启动？ | AI（核心启动逻辑） |
| [config.md](config.md) | 当前用哪套配置？ | 想切换的人 |
| [schemas/default/](schemas/default/) | 系统怎么运转？ | 所有人 |
| [theories/rational/meta.md](theories/rational/meta.md) | 当前用了哪些方法论？ | 想改方法的人 |
| [domains/_router.md](domains/_router.md) | 任务怎么路由？ | 想扩展任务域的人 |
| [CHANGELOG.md](CHANGELOG.md) | 版本变了什么？ | 升级时必读 |
| [DESIGN-NOTES.md](DESIGN-NOTES.md) | 为什么这么设计？ | 想理解推导过程的人 |

## 阅读顺序

```
首次：README.md → config.md → schemas/default/constitution.md → 填写 data/identity/ → 开始使用
AI启动：BOOT.md（自动走完 Phase 0-5）
想切换配置：改 config.md 一行
想改方法论：theories/rational/meta.md → 对应模块
想扩展任务域：domains/_router.md → 创建新 domain
想理解设计推导：DESIGN-NOTES.md
```
