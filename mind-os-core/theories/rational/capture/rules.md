---
name: capture-rules
command: /收集
keywords: [收集, inbox, 信息输入]
execution_level: SHOULD
type: checklist
domain: capture
summary: "GTD收集规则：全捕获→inbox→24h清空，蔡加尼克效应驱动"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **全捕获**：任何新信息/想法/任务→立即进入 runtime/inbox/，不分类不判断不处理
- **唯一入口**：inbox 是唯一入口，不允许直接写入 data/content/
- **24h清空**：inbox 积压 > 24h 触发清空流程，蔡加尼克效应驱动

# 收集理论

---

## 核心原则

大脑是用来产生想法的，不是用来存储想法的。未完成的事项占用认知资源（蔡加尼克效应），必须外化到可信赖的系统中。

## 收集规则

```yaml
capture_rules:
  1. 任何新信息/想法/任务 → 立即进入 runtime/inbox/
  2. inbox 是唯一入口，不允许直接写入 data/content/
  3. 收集时不分类，不判断，不处理
  4. 格式：一条一文件，标题 = 一句话概要
  5. 来源标记：手动输入 / AI抓取 / 外部导入
```

## 收集模板

```yaml
# runtime/inbox/YYYY-MM-DD-HH-MM-title.md
source: ""          # 来源
raw: ""             # 原始内容
captured_at: ""     # 时间戳
status: "pending"   # pending → processed → archived
```
