# 示例：第一次使用 Mind OS

> 以下是一个完整的首次会话示例，展示 AI 从启动到执行一个任务的全过程。

---

## 用户发送

```
请读取 BOOT.md 并按照其中的协议启动 Mind OS。这是我第一次使用。
```

## AI 启动过程

```
正在启动 Mind OS...

📖 Phase 0: 读取 config.md
   → schema: schemas/default
   → theory: theories/rational
   → data: /Users/zhang/mind-os-data

📖 Phase 1: 加载宪法
   → constitution.md ✅（三条宪法已读）
   → metrics.md ✅（11项机器指标 + 4项人类指标）

📖 Phase 2: 加载协作规则
   → symbiosis.md ✅（四模式 × 三拓扑）
   → pipeline.md ✅
   → iteration.md ✅
   → conventions.md ✅

📖 Phase 3: 识别用户
   → profile.md ✅
   → principles.md ✅
   → preferences.md ✅

📖 Phase 4: 加载路由表
   → theories/rational/meta.md ✅（15条路由）
   → domains/_router.md ✅（6个域）
   → runtime/focus.md ✅
   → runtime/dashboard.md ✅

✅ 配置：schema=schemas/default, theory=theories/rational, data=/Users/zhang/mind-os-data
✅ 宪法已读（三条）
✅ 冻结指标已读（11项机器层 + 4项人类层）
✅ 协作协议已读（四模式 × 三拓扑）
✅ 用户身份：张明，角色：[创业者, 父亲, 投资者]
✅ 今日焦点：（尚未设置）
✅ 路由表已就绪（theory: 15条路由, domains: 6个域）
🟢 Mind OS 已启动，等待任务输入。

💡 我注意到你的 focus.md 还是空的。要不要先设定今天的 Top 3？
```

---

## 示例任务 1：设定今日焦点

### 用户

```
好，帮我设定今日焦点。我今天要做三件事：
1. 决定是否投资一个朋友推荐的项目
2. 写完下周的产品路线图
3. 接孩子放学
```

### AI

```
📋 任务路由中...
  → 匹配 theory: decide/（投资决策）
  → 匹配 domain: software-dev/（产品路线图）
  → 无匹配（接孩子 = 个人事务，无需 theory）

已更新 runtime/focus.md：

  date: 2026-03-23
  top3:
    - task: "决定是否投资朋友推荐的项目"
      status: pending
      domain: finance
      collaboration: 对等协作 × 并联（高风险决策）
    - task: "写完下周产品路线图"
      status: pending
      domain: software-dev
      collaboration: AI主导 × 迭代
    - task: "接孩子放学"
      status: pending
      domain: personal
      collaboration: 纯人类

要从哪个任务开始？
建议先做 #1（投资决策），因为它需要最多的认知资源，适合精力最好的时段。
```

---

## 示例任务 2：投资决策（触发完整偏差检查）

### 用户

```
好，先看投资那个。朋友说有个AI教育公司要融资，Pre-A轮，估值3000万，让我投50万。
```

### AI

```
📋 任务路由：投资决策
  → 加载 theory: decide/rules.md（决策框架）
  → 加载 theory: decide/antifragile.md（风险评估）
  → 加载 theory: think/_index.md → 匹配偏差检查
  → 金额 50万 > large_amount_threshold → 触发深度检查

⚠️ 检测到：这是一笔重大不可逆投资决策，启动完整偏差检查流程。
协作模式：对等协作 × 并联（我独立分析，你独立判断，最后合并）

━━ 第一步：三元分类 ━━

这笔投资属于哪类？
- 损失：最多亏 50万（封顶）
- 收益：如果成功，Pre-A 到 B 轮可能 5-10x
- 可逆性：投出去不可撤回
→ 🟢 反脆弱（损失封顶 + 收益开放），但金额较大

━━ 第二步：能力圈检查 ━━

从你的 identity 和 archive 中检索...
→ 你在"AI行业"有记录（圈内），但"教育行业"无记录（圈外）
→ 🎯 能力圈：AI=圈内，教育=圈外
→ 建议：你需要对教育赛道有独立判断，或引入这个领域的专家意见

━━ 第三步：WYSIATI 检查 ━━

目前你的信息来源只有"朋友推荐"（1个来源）
→ 👁 完备度 < 30%
→ 建议延迟决策，至少补充：公司财务数据、团队背景、竞品分析

━━ 第四步：事前验尸 ━━

假设一年后这笔投资彻底失败了，最可能的原因是什么？
请你先想 3-5 个原因，然后我来补充遗漏的。

（等你回复后继续...）
```

---

## 要点总结

这个示例展示了 Mind OS 的核心运行模式：

1. **启动即引导**：AI 自动走完 5 个 Phase，报告状态
2. **任务自动路由**：根据关键词匹配 theory 和 domain
3. **按需加载**：只加载当前任务需要的偏差检查，不全量加载
4. **协作模式自动匹配**：投资决策 → 对等×并联，路线图 → AI主导×迭代
5. **偏差检查链式触发**：金额>阈值 → 三元分类 → 能力圈 → WYSIATI → 事前验尸
