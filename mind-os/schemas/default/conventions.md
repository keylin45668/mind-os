# 文件命名与格式约定

---

## 1. 文件命名

```
小写英文 + 连字符分隔
例：weekly-review-2026-03-23.md
```

---

## 2. 文件格式

- 所有可编辑文件使用 Markdown（.md）
- 结构化数据使用 YAML 代码块
- 每个文件顶部有一行注释说明文件用途

---

## 3. 目录约定

```
{schema}/    → 骨架规则，AI 只读（路径由 config.md 决定）
{theory}/    → 方法论，AI 只读，人可替换（路径由 config.md 决定）
domains/     → 任务域专属规则，AI 只读
{data}/      → 用户数据，独立目录，部分 AI 可写（路径由 config.md 决定）
runtime/     → 运行时状态，AI 可读写
```

---

## 4. 版本控制

- {schema}/ 和 {theory}/ 的修改必须记录在 runtime/reviews/ 中
- metrics.md 有独立的修改日志
- data/archive/ 按年归档

---

## 5. 文件大小约束

- 单个 schema/ 文件 ≤ 2000 tokens（确保 AI 上下文装得下）
- theory/ 单模块不设硬限，但鼓励拆分
- runtime/ 文件定期清理，完成的归 archive/
