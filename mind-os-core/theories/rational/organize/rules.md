---
name: organize-rules
command: /整理
keywords: [分类, 整理, 归档]
execution_level: SHOULD
type: checklist
domain: organize
summary: "PARA分流：Projects(有截止日期) / Areas(持续职责) / Resources(参考) / Archives(冷存储)"
context: default
hooks:
  pre_check: null
  post_check: null
  depth_check: null
---

## 摘要

- **PARA 分流**：inbox→Projects(有截止日)/Areas(持续责任)/Resources(参考)/Archives(冷存储)
- **2分钟规则**：2分钟内能完成→立即处理并归档，不进入分流树
- **判断树**：项目?→领域?→参考?→都不是→归档或删除

# 组织理论

---

## 分流规则

inbox 条目按以下维度分流到 data/ 结构中：

```yaml
organize_rules:
  有明确交付物+截止日:
    → data/content/{domain}/projects/{project_name}/
  持续维护的责任领域:
    → data/content/{domain}/{area}/
  可复用的参考资料:
    → data/knowledge/references/
  值得深度加工的知识:
    → data/knowledge/notes/（走知识管理流程）
  已完成或不再需要:
    → data/archive/{year}/
```

## 分流判断树

```
收到 inbox 条目
  ├── 可在 2 分钟内完成？ → 立即处理，归档
  ├── 是项目？（有截止日+交付物）→ projects/
  ├── 是领域？（持续责任）→ {area}/
  ├── 是参考？（未来可能有用）→ knowledge/
  └── 以上都不是 → archive/ 或删除
```
