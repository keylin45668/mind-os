# Mind OS 运行配置

> AI 启动时第一个读取的文件。修改此文件 = 切换系统配置。

```yaml
version: 5.0
schema: schemas/default
theory: theories/rational
data: ../data                # 外部路径，独立于 mind-os/
```

---

## 切换说明

| 想做什么 | 改哪行 |
|---------|-------|
| 换一套方法论 | `theory: theories/{new-pack}` |
| 换一套架构 | `schema: schemas/{new-schema}` |
| 给别人用 | `data: /path/to/their/data` |
| 全换 | 三行都改 |

## 新增 theory pack 步骤

1. 在 `theories/` 下创建新目录
2. 创建 `meta.md`（路由表格式，参照 theories/rational/meta.md）
3. 创建各模块文件
4. 修改本文件 `theory:` 指向新 pack

## 新增 schema 步骤

1. 在 `schemas/` 下创建新目录
2. 必须包含 `constitution.md` 和 `protocols.md`
3. 其他文件按需
4. 修改本文件 `schema:` 指向新 schema
