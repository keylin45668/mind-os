# 连接器：{项目显示名}

> **这是连接器卡片模板。** 复制到 `local/projects/{project-id}.md` 后填写。

```yaml
name: 项目显示名
repo: ../project-repo              # 项目仓库相对于 mind-os 仓库根目录的路径
domain: strategy                   # 挂载到哪个 domain（对应 domains/ 下的目录名）
keywords: [关键词1, 关键词2, 关键词3]

# Mind OS 接入时读取这些文件获取上下文（相对于 repo 路径）
context_files:
  - README.md

# 指定哪些 theory 模块最相关（不写=走通用路由匹配）
theories:
  - think/_index.md
  - think/iterative-engine.md
  - review/rules.md

# 默认协作模式
collaboration: 对等协作 × 迭代

# 项目专属约束（可选，叠加在 domain 规则之上）
constraints: []

# 数据落盘规则（可选，不写则用默认值）
output:
  project_files: "{repo}/"                  # 项目文件修改 → 写回项目仓库
  thinking: "对话中输出"                     # 思考过程默认不落盘
  decisions: "runtime/decisions/"            # 决策记录 → Mind OS 全局追踪
  knowledge: "{data}/knowledge/notes/"       # 个人认知沉淀 → 用户知识库
```
