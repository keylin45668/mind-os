# Mind OS 运行配置（模板）

> 首次启动时自动复制到 `local/config.md`。修改 `local/config.md` 切换配置，本文件不要直接改。

```yaml
version: 5.3
schema: schemas/default
theory: theories/rational

session_length_limit: 32    # 会话轮次上限（漂移断路器），超限提醒终止

data_profiles:
  - id: default
    name: ""                   # ← 首次启动时填写你的名字
    path: "../data"
    description: "主档案"
    default: true

  # 新增档案示例（取消注释即可用）：
  # - id: work
  #   name: "你的名字-工作"
  #   path: "../data-work"
  #   description: "工作专用档案"
```

## 配置说明

| 操作 | 怎么做 |
|------|-------|
| 换方法论 | 改 `theory: theories/{name}` |
| 换架构 | 改 `schema: schemas/{name}` |
| 加用户 | 在 `data_profiles` 新增条目 |
| 切换档案 | 多档案时启动自动弹选择；会话中说"切换到 {名}" |

**多档案规则**：`default: true` 自动选中；≥ 2 条时弹选择；schema/theory/runtime 共享，仅 data 独立。
