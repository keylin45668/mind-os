# 今日焦点 — Top 3

> 每日回顾时更新。AI 在启动时读取此文件。
> **规则：每条焦点必须带日期戳。启动时只展示当天焦点，过期焦点归入历史。**

```yaml
# 当前焦点（仅当天有效）
current: []

# 历史焦点（自动归档，保留最近 30 天）
history:
  - task: "优化 Mind OS"
    status: "in_progress"
    domain: "software-dev"
    date: "2025-03-23"
  - task: "身体健康"
    status: "pending"
    domain: "personal"
    date: "2025-03-23"
  - task: "公司管理"
    status: "pending"
    domain: "strategy"
    date: "2025-03-23"
```

## AI 处理规则

1. **启动时对比日期**：`current` 中 `date ≠ 今天` 的条目 → 自动移入 `history`，保留原始 date 和 status
2. **未完成提醒**：历史焦点中 `status ≠ done` 的条目 → 启动面板中提醒用户
3. **新增焦点**：用户设定今日焦点时，`date` 自动填入当天日期
4. **查询历史**：用户说"历史焦点"/"过去的焦点" → 展示 `history` 列表，按日期倒序
5. **归档上限**：`history` 保留最近 30 天，超出自动删除
