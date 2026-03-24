# 任务路由表

> AI 在 Phase 5 读取本文件，按关键词匹配加载对应 domain 规则。
> 未匹配到任何 domain → 使用通用 theory/ 规则。

---

## 路由规则

| 关键词 | Domain | 加载文件 | 协作模式建议 |
|--------|--------|---------|-------------|
| 代码/编程/开发/bug/部署 | software-dev | domains/software-dev/_rules.md | AI主导 × 迭代 |
| 投资/融资/财务/预算 | finance | domains/finance/_rules.md | 对等协作 × 并联 |
| 招聘/绩效/团队/HR | people | domains/people/_rules.md | 人类主导 × 迭代 |
| 战略/竞争/市场 | strategy | domains/strategy/_rules.md | 对等协作 × 迭代 |
| 写作/文档/报告 | writing | domains/writing/_rules.md | AI主导 × 串联 |
| 家庭/孩子/健康 | personal | domains/personal/_rules.md | 人类主导 × 迭代 |
| 切换档案/切换身份/换个身份/switch | （系统指令） | BOOT.md 会话中切换档案协议 | — |

---

## 无匹配时的降级策略

```yaml
no_match:
  1. 尝试从 theory/ 中找到最近似的处理规则
  2. 确定协作模式：默认"对等协作 × 迭代"
  3. 执行完毕后提示用户：是否需要为此类任务创建专属 domain？
```

---

## 添加新 Domain 的步骤

```
1. 在 domains/ 下创建 {domain-name}/ 目录
2. 创建 {domain-name}/_rules.md（任务域专属规则）
3. 在本文件的路由表中添加关键词映射
4. 检查复杂度预算（theory 单文件 ≤ 1000 tokens，单次加载 ≤ 3 个；domain 需保持精简）
```

---

## 项目连接器

Domain 匹配后，还会查 `projects/_router.md` 匹配具体项目。项目连接器提供**上下文数据**，domain 提供**领域规则**，两者叠加。

- 一个 domain 下可以挂多个 project（如 strategy 域下挂制度优化、竞品分析等多个项目）
- project 不替代 domain，只补充具体项目的数据和约束
- 详见 `projects/_router.md`

---

## 注意

- Domain 规则是对 theory/ 的补充，不替代 theory/
- 执行顺序：先加载 theory/ 通用规则，再叠加 domain/ 专属规则，再叠加 project/ 上下文
- Domain 规则与 theory/ 冲突时，domain/ 优先（更具体的规则覆盖通用规则）
