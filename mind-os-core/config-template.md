# Mind OS 运行配置（模板）

> 首次启动时自动复制到 `local/config.md`。修改 `local/config.md` 切换配置，本文件不要直接改。

```yaml
version: 5.1
schema: schemas/default
theory: theories/rational

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

# 网络功能（可选，默认全部关闭）
network:
  sync_enabled: false        # 迭代前从 GitHub 同步新场景/理论
  web_search_enabled: false  # ANALYZE 阶段使用网络搜索增强分析
  backup_enabled: false      # 迭代后推送 state.yaml + results.tsv
  remote: "origin"           # git remote 名称
  timeout_sec: 10            # 单次网络操作超时（秒）
```

## 配置说明

| 操作 | 怎么做 |
|------|-------|
| 换方法论 | 改 `theory: theories/{name}` |
| 换架构 | 改 `schema: schemas/{name}` |
| 加用户 | 在 `data_profiles` 新增条目 |
| 切换档案 | 多档案时启动自动弹选择；会话中说"切换到 {名}" |
| 开启联网优化 | 改 `network.sync_enabled: true` 等，详见各字段注释 |

**多档案规则**：`default: true` 自动选中；≥ 2 条时弹选择；schema/theory/runtime 共享，仅 data 独立。
