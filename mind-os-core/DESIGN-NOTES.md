# Mind OS — 设计笔记（推导过程，不进运行时）

> **版本**：v5.3 | **日期**：2026-03-30 | **变更日志**：[CHANGELOG.md](CHANGELOG.md)
> **本文件是什么**：Mind OS 的设计推导记录。包含剥洋葱记录、同构证明、神经科学证据等。
> **不进运行时**：这些是"为什么这么设计"的论证，不是"系统怎么运行"的规则。

---

## 1. 剥洋葱记录（v1→v4）

```
Layer 0 (v1): 文件管理系统 → 审计：只是PARA+GTD贴标签，不是"操作系统"
Layer 1 (v2): 认知架构类比 → 审计：AI仍是被动工具，理论和数据耦合
  ↓ 用户注入宪法约束："理论+架构+数据必须分离"
Layer 2 (v3): 本源追溯 → 方法A: Transform(input, context) → output
  ↓ 方法D: 六种认知活动同构为一个元操作
  ↓ 方法B: context = schema ⊕ theory ⊕ data
  ↓ 方法C: 三层均有完整正逆闭环
Layer 3 (v3): 到达本源 → 自迭代机制注入
Layer 4 (v3.1): 自迭代 → autoresearch同构
Layer 5 (v3.2): 系统动力学 → Meadows反馈回路
Layer 6 (v3.3): 偏差检查 → Kahneman六大偏差操作化
Layer 7 (v3.4): AI能力边界 → 人-AI偏差同构
Layer 8 (v3.5): 芒格决策 → 多模型格栅+Lollapalooza
Layer 9 (v3.6): 反脆弱 → 塔勒布五规则
Layer 10 (v3.7): 竞争策略 → 孙子五事七计
Layer 11 (v3.8): 道德经 → 宪法第三条+无为模式
Layer 12 (v3.9): 复杂适应系统 → 混沌边缘+涌现
Layer 13 (v3.10): 第五项修炼 → 推论阶梯+创造性张力+团队协作
Layer 14 (v3.11): 达利欧原则 → BWDM+痛苦日志+原则编译器
Layer 15 (v3.12): 博弈论 → 博弈识别+重复博弈策略
Layer 16 (v3.13): 国富论 → 比较优势+自组织三重同构
Layer 17 (v4.0): 三层分离审计 → 文档本身违反最高法则 → 拆分为schema/theory/data三文件
Layer 18 (v4.1): 协作量化整合 → 注入协作拓扑(串联/并联/迭代)、五维评估、协作增益率冻结指标、人-AI本质差异
  ↓ 方法D：并联加权 ≡ BWDM可信度加权（同构，统一为权重框架）
  ↓ 方法B：协作的两个正交维度——"谁主导"(4模式) × "怎么交互"(3拓扑)
  ↓ 新冻结指标：协作增益率 > 1.0（协作须系统性超越单方）
  ↓ 嵌入不新增模块，维持15/15
Layer 19 (v4.2): 系统落地 → 四文档拆分为可执行文件系统
  ↓ 新增 BOOT.md：AI唯一入口，5阶段启动协议
  ↓ schema/ 拆为7个独立文件（constitution/metrics/pipeline/symbiosis/dynamics/iteration/conventions）
  ↓ theory/ 拆为11个模块文件，meta.md 作为注册表
  ↓ 新增 domains/_router.md：任务关键词→domain映射，支持动态扩展
  ↓ data/identity/ 三文件模板（profile/principles/preferences）
  ↓ data/content/ 预设 personal/ 和 business/ 两个用户领域
  ↓ runtime/ 初始化 focus.md + dashboard.md
  ↓ 方法C验证：BOOT→schema→identity→focus→router→domain→execute 正向链完整
  ↓ 文件总数 ~25，每个文件独立可读，AI上下文友好（≤2000 tokens/文件）
```

Layer 20 (v5.0): 架构升级 → 多档案+组织协作+AutoEvolve入口统一+会话审查
  ↓ 审计发现：系统只能"想"不能跨项目"做"——脑子和数据耦合在同一工作目录
Layer 21 (v5.1): 项目连接器 → 给任何外部仓库装脑子
  ↓ 本源问题：Mind OS 的价值 = 思考能力，不是存储能力
  ↓ 方法B：拆分为两层——projects/(指针+配置) vs 外部仓库(数据)
  ↓ 双向桥接：Mind OS 侧放连接器卡片（读数据），项目侧放 .mind-os.md（调能力）
  ↓ 三种场景：想（在 Mind OS）、做（在项目）、边想边做（Mind OS 分析→项目修改）
  ↓ 一句话安装：用户说"安装 mind-os" → AI 自动探测+采集+生成+验证
  ↓ 数据归属原则：谁的数据回谁家，Mind OS 只存"想"的痕迹
Layer 22 (v5.2): 多角色审议 → 从单模型自我辩论到多角色结构化审议
  ↓ 本源问题：单模型红蓝辩论的结构性趋同缺陷——共享权重无法产生真正独立视角
  ↓ 方法B：拆分为 6 个正交原语——角色定义 × 审议协议 × 决策分级 × 评分维度 × 数字分身 × 进化反馈
  ↓ 方法C：角色+协议=多方讨论 ✓ | 协议+分级=分级收敛 ✓ | 评分+反馈=质量闭环 ✓
  ↓ 与 iterative-engine 互补：审议处理多角色多方，红蓝辩论处理二元对抗
  ↓ 编号制扩展：[B/R] → [{RoleCode}-r{round}-{seq}]，支持任意数量角色
Layer 23 (v5.3): 模块自描述 + 渐进加载 → 借鉴 Claude Code Skills 工程化治理
  ↓ 本源问题：模块元数据集中在 meta.md（单点维护），模块自身无自描述能力；加载粒度只有全量一级；质量门控硬编码在 protocols.md 而非跟随模块
  ↓ 方法D：Claude Code Skills 的 SKILL.md = Mind OS theory 模块（自描述 + 按需加载 + 专业化 + 可组合——同构）
  ↓ 引入三个模式：
    ① Frontmatter 自描述 — 每个模块用 YAML frontmatter 声明 name/command/keywords/execution_level/hooks
    ② 三级渐进披露 — Level 1 metadata(~50 tokens) / Level 2 摘要(~200 tokens) / Level 3 全文
    ③ 模块级 Hooks — depth_check/post_check 从 protocols.md 硬编码迁移到各模块 frontmatter
  ↓ 方法B：加载深度与任务分级正交——🟢 summary_only / 🟡🔴 full，互不干扰
  ↓ 方法C：frontmatter 写入 ↔ frontmatter 读取（Pre-Output Gate 动态聚合 hooks）→ 正逆闭环
  ↓ 附带改进：context: isolated 声明（5 个重量级模块），支撑 subagent / 独立 API 调用隔离执行
  ↓ 规范文件：schemas/default/module-frontmatter-spec.md
  ↓ 44 个模块全覆盖，37 个有 ## 摘要，7 个 tiny checklist 用 frontmatter summary 替代

每一层都是上一层审计倒逼出来的。

---

## 2. 五重同构证明

方法D揭示的核心同构——五个系统运行同一底层算法：

| 神经科学 | autoresearch | Mind OS | Senge | Dalio |
|---------|-------------|---------|-------|-------|
| 预期奖赏 | val_bpb目标 | 冻结指标 | 愿景 | 理想结果 |
| 实际奖赏 | 当前val_bpb | 实际表现 | 现实 | 实际结果 |
| 预测误差 | 目标-实际 | 偏差信号 | 创造性张力 | 痛苦 |
| 突触更新 | 修改代码 | 修改theory | 学习-行动 | 反思→原则 |
| 元认知 | Keep/Discard | reviews/ | 双环学习 | 5步流程 |

共同本质：在不可篡改的评估标准下，通过"预测→行动→误差→更新"循环趋向最优。

---

## 3. 三重同构

斯密"看不见的手" ≡ 道德经"无为" ≡ CAS"自组织"

| 条件 | 斯密 | 道德经 | CAS |
|------|------|--------|-----|
| 触发条件 | 自由竞争+充分信息+可退出 | "无为"的前提=系统已具自稳 | 涌现条件=简单规则+足够互动 |
| 行为 | 不可见的手自动调配 | 无为而无不为 | 自组织 |
| 失败时 | 市场失灵→政府干预 | "有为"矫正 | 外部扰动打破锁定 |

---

## 4. 神经科学证据（支撑自迭代机制）

**证据一：多巴胺奖赏预测误差**
Schultz, Dayan & Montague (1997)：中脑多巴胺编码"预期-实际"差值。正误差→激增，负误差→下降。作用：调整突触权重直到预测匹配现实。= Mind OS的"冻结指标评估→theory更新"。

**证据二：自由能原理**
Friston (2010)：大脑持续生成预测模型，通过两种方式最小化预测误差——更新模型(=修改theory/)或行动改变世界(=执行runtime/)。

**证据三：元认知前额叶回路**
Fleming & Dolan (2012)：前额叶负责对自己思维的监控和评估 = reviews/回顾机制。

---

## 5. v4.0 审计报告

### 审计方法
使用人机协作思维框架v2.0的方法A/B/C/D对v3.13文档做正交性检验。

### 核心发现
**文档本身违反了自己的最高法则。**

方法A测试：换theory（卡尼曼→贝叶斯），需改§10/§12/§14/§15/§16全部 → 不正交。
方法A测试：换data（CEO→学生），需改十几处"CEO场景" → 不是O(1)。
方法C测试：换theory→schema不变？不通过。schema和theory深度缠绕。
方法D测试：迭代循环被解释5次；调用矩阵有新旧两版冗余。

### 修复方案
拆分为四个文件：
- Schema（纯架构，~350行）
- Theory-Pack（可替换方法论，~600行）
- Data-Template（角色无关模板，~100行）
- Design-Notes（本文件，推导记录）

### 压缩效果

| 指标 | v3.13 | v4.0 |
|------|-------|------|
| 总行数 | 2330 | ~1200（schema+theory+data） |
| 正交性 | ❌ 三层耦合 | ✅ 三文件独立 |
| 换人操作 | O(n)改十几处 | O(1)改Data-Template |
| 换理论操作 | O(n)改多章节 | O(1)改Theory-Pack |
| 角色绑定 | "CEO"出现30+次 | 0次（全部抽象化） |
| 参考文献 | 90行学术格式 | 1段书名列表 |
| 冗余 | 迭代循环5次解释 | 1次定义+引用 |

---

## 6. 设计方法论

本系统遵循《从模糊意图到精确实现：AI 协作思维框架 v2.0》。
路径 B（方案先行，本源后追）— 经 v1→v4 四轮审计剥洋葱。
