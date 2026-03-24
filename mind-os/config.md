# Mind OS 运行配置

> AI 启动时第一个读取的文件。修改此文件 = 切换系统配置。

```yaml
version: 5.1
schema: schemas/default
theory: theories/rational

# 数据档案（支持多份，启动时选择）
data_profiles:
  - id: wanglin
    name: "王麟"
    path: "../data"
    description: "主档案"
    default: true

  - id: test
    name: "测试用户"
    path: "../data-test"
    description: "测试档案（可删除）"

  # 新增档案示例（取消注释即可用）：
  # - id: work
  #   name: "王麟-工作"
  #   path: "../data-work"
  #   description: "工作专用档案"
  #
  # - id: teammate-a
  #   name: "张三"
  #   path: "../data-zhangsan"
  #   description: "团队成员张三"
```

---

## 切换说明

| 想做什么 | 怎么做 |
|---------|-------|
| 换一套方法论 | 改 `theory: theories/{new-pack}` |
| 换一套架构 | 改 `schema: schemas/{new-schema}` |
| 添加新用户/角色 | 在 `data_profiles` 中新增一条 |
| 启动时切换档案 | 启动时会弹出选择（仅多档案时） |
| 会话中切换档案 | 说"切换到 {档案名}" |

## 多档案规则

1. **`default: true`** 的档案 = 单档案时自动选中，不弹选择框
2. **多档案时**（≥2 条 profile）→ 启动时弹出 AskUserQuestion 让用户选
3. **新建档案**：添加 profile 条目 → 启动时选中 → 自动走首次安装流程创建目录
4. **schema 和 theory 共享**：所有档案共用同一套 schema + theory，只有 data 独立
5. **runtime/ 共享**：评分记录、审查记录等运行时数据全局共享（不按档案隔离）

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
