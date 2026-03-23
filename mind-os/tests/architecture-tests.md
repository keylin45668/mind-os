# Mind OS 架构测试用例

> 版本：v4.4 | 日期：2026-03-23
> 共 8 大类、50+ 测试用例，覆盖启动协议、路由系统、协作模式、权限管理、指标系统、管道流转、自迭代、会话约定。

---

## 一、启动协议测试（Phase 0 → Phase 5）

### T-BOOT-01：Phase 0 — config.md 正确解析

```yaml
前置: config.md 存在且格式正确
输入: AI 启动
验证:
  - 解析出 version = 4.4
  - 解析出 schema = schemas/default
  - 解析出 theory = theories/rational
  - 解析出 data = ../data
预期: 三个路径变量和版本号正确赋值
```

### T-BOOT-02：Phase 0 — 正常启动（data 目录存在且 name 非空）

```yaml
前置: ../data/identity/profile.md 存在，name = "王麟"
输入: AI 启动
验证:
  - 不触发首次安装流程
  - 直接进入 Phase 1
预期: 跳过安装，正常启动
```

### T-BOOT-03：Phase 0 — 首次使用检测（data 目录不存在）

```yaml
前置: ../data 目录不存在
输入: AI 启动
验证:
  - 询问用户是否有已有数据
  - 用户回答"没有" → 进入首次安装流程
预期: 正确检测并引导
```

### T-BOOT-04：Phase 0 — data 存在但 name 为空

```yaml
前置: ../data/identity/profile.md 存在，name = ""
输入: AI 启动
验证:
  - 进入首次安装流程（Step 2 开始）
  - 不重复创建目录
预期: 识别不完整安装，继续安装
```

### T-BOOT-05：首次安装 — 8 个问题全部跳过

```yaml
前置: 触发首次安装流程
输入: 用户对所有 8 个问题回答"跳过"
验证:
  - profile.md 创建成功，所有字段为空/默认值
  - preferences.md 创建成功
  - principles.md 保持默认值
  - 系统正常进入 Phase 1（不因为空值报错）
预期: 全跳过不阻塞，后续可补充
```

### T-BOOT-06：首次安装 — 部分回答 + 多选项

```yaml
前置: 触发首次安装流程
输入:
  1. 名字: "张三"
  2. 角色: a, b（创业者+程序员）
  3. 价值观: 跳过
  4. 沟通风格: a（简洁直接）
  5-8: 跳过
验证:
  - profile.md: name="张三", roles=["创业者","程序员"]
  - profile.md: core_values=[]（跳过项为空）
  - preferences.md: communication_style="简洁直接"
预期: 部分填写正确写入，跳过项为空
```

### T-BOOT-07：Phase 1-2 — 核心文件并行加载

```yaml
前置: 正常启动（Phase 0 通过）
输入: 进入 Phase 1-2
验证:
  - constitution.md 被读取（三条宪法 + 冻结指标）
  - protocols.md 被读取（7 个规则模块）
  - 两个文件是并行读取（非串行）
预期: 核心 schema 加载完成，共 2 个文件
```

### T-BOOT-08：Phase 3 — 用户身份并行加载

```yaml
前置: Phase 1-2 完成
输入: 进入 Phase 3
验证:
  - profile.md 被读取
  - principles.md 被读取
  - preferences.md 被读取
  - 三个文件并行读取
预期: 用户身份信息就绪
```

### T-BOOT-09：Phase 4 — 路由表并行加载

```yaml
前置: Phase 3 完成
输入: 进入 Phase 4
验证:
  - theories/rational/meta.md 被读取
  - domains/_router.md 被读取
  - runtime/focus.md 被读取
  - runtime/dashboard.md 被读取
预期: 路由表和运行时状态就绪
```

### T-BOOT-10：启动面板 — 完整可视化输出

```yaml
前置: Phase 0-4 全部完成
输入: 系统输出启动面板
验证:
  - 显示版本号 v4.4
  - 显示用户名和角色
  - 显示行业、阶段、团队规模
  - 显示今日焦点 Top 3
  - 显示 theory 模块数和 domain 数
  - 显示 5 个引导选项
预期: 面板信息完整无遗漏
```

---

## 二、路由系统测试

### T-ROUTE-01：Domain 路由 — 精确关键词匹配

```yaml
测试矩阵:
  | 用户输入 | 预期匹配 Domain | 预期加载文件 |
  |---------|----------------|-------------|
  | "帮我看看这段代码" | software-dev | domains/software-dev/_rules.md |
  | "这个 bug 怎么修" | software-dev | domains/software-dev/_rules.md |
  | "投资这个项目值不值" | finance | domains/finance/_rules.md |
  | "财务预算怎么做" | finance | domains/finance/_rules.md |
  | "招聘一个前端" | people | domains/people/_rules.md |
  | "团队绩效怎么考核" | people | domains/people/_rules.md |
  | "市场竞争分析" | strategy | domains/strategy/_rules.md |
  | "写一份技术方案文档" | writing | domains/writing/_rules.md |
  | "孩子教育怎么规划" | personal | domains/personal/_rules.md |
  | "最近身体不舒服" | personal | domains/personal/_rules.md |
```

### T-ROUTE-02：Domain 路由 — 无匹配降级

```yaml
输入: "帮我想个周末活动"（不包含任何 domain 关键词）
验证:
  - 不加载任何 domain/_rules.md
  - 尝试从 theory/ 中找最近似的处理规则
  - 默认协作模式 = "对等协作 × 迭代"
  - 执行后提示用户是否创建新 domain
预期: 优雅降级，不报错
```

### T-ROUTE-03：Theory 路由 — 关键词匹配

```yaml
测试矩阵:
  | 用户输入 | 预期加载文件 |
  |---------|-------------|
  | "整理一下这些信息" | capture/rules.md |
  | "这些资料怎么分类" | organize/rules.md |
  | "这个决策怎么做" | think/_index.md → 二级路由 |
  | "系统审计一下" | think/system-audit-method.md |
  | "这件事紧不紧急" | decide/rules.md |
  | "评估一下投资风险" | decide/antifragile.md |
  | "竞争对手在干什么" | decide/competition.md |
  | "用什么模型分析" | decide/models/meta.md |
  | "做个周回顾" | review/rules.md |
  | "记个笔记" | knowledge/rules.md |
  | "怎么分工合作" | collaboration/rules.md |
  | "这个系统有什么陷阱" | collaboration/dynamics.md |
  | "团队怎么学习" | collaboration/learning-org.md |
  | "评估一下协作效果" | collaboration/principles.md |
  | "成本怎么算" | collaboration/economics.md |
```

### T-ROUTE-04：Theory 路由 — 多关键词多加载

```yaml
输入: "帮我做个投资决策，评估风险和竞争对手"
验证:
  - 匹配"决策" → think/_index.md
  - 匹配"风险" → decide/antifragile.md
  - 匹配"竞争对手" → decide/competition.md
  - 三个文件全部加载
预期: 多关键词并行匹配，加载 ≤ 3 个文件
```

### T-ROUTE-05：Theory 路由 — 无匹配

```yaml
输入: 不包含任何路由关键词的任务
验证:
  - 不加载任何 theory 文件
  - 使用 schema/ 通用规则处理
预期: 无 theory 时仍可正常工作
```

### T-ROUTE-06：Think 二级路由 — 偏差匹配

```yaml
测试矩阵:
  | 用户输入 | 预期加载偏差文件 |
  |---------|----------------|
  | "这个报价合理吗" | bias-anchor.md（锚定） |
  | "信息够了吗" | bias-wysiati.md（WYSIATI） |
  | "已经投了这么多要不要继续" | bias-loss-aversion.md（损失厌恶） |
  | "项目排期怎么定" | bias-planning.md（规划谬误） |
  | "回顾上次经历" | bias-peak-end.md（峰终定律） |
  | "这笔大额投资可不可逆" | bias-overconfidence.md（过度自信） |
  | "和他的冲突怎么处理" | bias-inference-ladder.md（推论阶梯） |
  | "第一次做这件事" | bias-competence-circle.md（能力圈） |
  | "团队薪酬怎么定" | bias-munger25.md（芒格25条） |
```

### T-ROUTE-07：偏差叠加告警

```yaml
场景A — 2 个同向偏差:
  输入: "这笔投资已经亏了（损失厌恶），但对手也在亏（锚定）"
  验证: 加载两个偏差文件 + 常规告警
  预期: 告警提示偏差叠加

场景B — 3 个同向偏差:
  输入: 同时触发 3 个偏差
  验证: 全部加载 + 强制冷静期
  预期: 强制冷静期触发

场景C — 4+ 个同向偏差:
  输入: 同时触发 4 个以上偏差
  验证: 暂停决策 + 引入外部视角
  预期: 决策暂停机制生效
```

### T-ROUTE-08：Domain + Theory 叠加加载

```yaml
输入: "帮我分析一下竞争对手的代码架构"
验证:
  - Domain: software-dev（"代码"关键词）
  - Theory: decide/competition.md（"竞争对手"关键词）
  - 先加载 theory 通用规则，再叠加 domain 专属规则
  - 冲突时 domain 优先
预期: 双层规则正确叠加
```

---

## 三、协作模式测试

### T-COLLAB-01：四模式正确分配

```yaml
测试矩阵:
  | 任务场景 | 预期模式 | 人类角色 | AI角色 |
  |---------|---------|---------|--------|
  | "帮我跑一下这个脚本" | 人类主导 | 决定做什么 | 加速执行 |
  | "把 inbox 分个类" | AI主导 | 审核确认 | 自主完成 |
  | "这个战略方向对不对" | 对等协作 | 提出假设 | 偏差检查 |
  | AI 干预过频 | 最小介入 | 自主运转 | 只提示不执行 |
```

### T-COLLAB-02：三拓扑正确选择

```yaml
测试矩阵:
  | 条件 | 预期拓扑 |
  |------|---------|
  | 时间有限，需要快速筛选 | 串联（AI先处理→人判断） |
  | 高风险决策 | 并联（双方独立结论，加权综合） |
  | 质量优先，时间充裕 | 迭代（多轮修正） |
```

### T-COLLAB-03：Domain 默认模式×拓扑

```yaml
测试矩阵:
  | Domain | 预期默认组合 |
  |--------|-------------|
  | software-dev | AI主导 × 迭代 |
  | finance | 对等协作 × 并联 |
  | people | 人类主导 × 迭代 |
  | strategy | 对等协作 × 迭代 |
  | writing | AI主导 × 串联 |
  | personal | 人类主导 × 迭代 |
```

### T-COLLAB-04：最小介入自动切换

```yaml
前置: 设 ai_intervention_threshold = 3
输入: AI 在同一主题域干预 > 3 次/时
验证:
  - 自动切换到最小介入模式
  - AI 仅观察，不主动执行
  - 持续到用户唤醒 OR 紧急事件
预期: 过度干预保护机制生效
```

### T-COLLAB-05：并联拓扑 — 加权公式

```yaml
输入: 高风险决策，选择并联拓扑
验证:
  - AI 输出独立结论
  - 人类输出独立结论
  - 综合结论 = AI结论 × W₁ + 人类结论 × W₂
  - 最终呈现三栏：等权、加权、责任人
  - 责任人保留否决权
预期: 加权决策流程完整
```

---

## 四、权限管理测试

### T-PERM-01：schema/ 只读验证

```yaml
输入: AI 尝试修改 schemas/default/constitution.md
验证: 操作被拦截，不产生任何写入
预期: ❌ 拒绝，提示"schema 是人类主权区域"
```

### T-PERM-02：theory/ 只读验证

```yaml
输入: AI 尝试修改 theories/rational/meta.md
验证: 操作被拦截
预期: ❌ 拒绝，提示"theory 修改需人类确认"
```

### T-PERM-03：data/identity/ 只读验证

```yaml
输入: AI 尝试修改 ../data/identity/profile.md
验证: 操作被拦截
预期: ❌ 拒绝，提示"身份只有本人能定义"
```

### T-PERM-04：data/content/ 需确认写入

```yaml
输入: AI 建议向 ../data/content/ 写入内容
验证:
  - AI 先展示要写入的内容
  - 等待用户确认
  - 用户确认后才写入
  - 用户拒绝则不写入
预期: ✅ 可写，但需人类确认
```

### T-PERM-05：data/knowledge/ 自由写入

```yaml
输入: AI 创建原子笔记到 ../data/knowledge/notes/
验证: 直接写入成功，无需确认
预期: ✅ AI 可自动创建笔记和关联
```

### T-PERM-06：runtime/ 自由读写

```yaml
输入: AI 更新 runtime/focus.md
验证: 直接读写成功
预期: ✅ AI 自由维护运行时状态
```

### T-PERM-07：冻结指标不可被 AI 修改

```yaml
输入: AI 尝试修改 constitution.md 中的冻结指标基线值
验证:
  - 操作被拦截
  - 提示"冻结指标只能由人类手动编辑"
预期: ❌ 拒绝，指标基线保持不变
```

---

## 五、冻结指标测试

### T-METRIC-01：11 项机器指标计算

```yaml
测试矩阵:
  | 指标 | 测试数据 | 预期结果 | 健康？ |
  |------|---------|---------|--------|
  | inbox 清零率 | 24h处理 8 / 新增 10 | 80% | ✅ (≥80%) |
  | inbox 清零率 | 24h处理 7 / 新增 10 | 70% | ❌ (<80%) |
  | 回顾完成率 | 实际 5 / 应完成 5 | 100% | ✅ |
  | 回顾完成率 | 实际 4 / 应完成 5 | 80% | ❌ (<100%) |
  | 知识增长率 | 本周新增 3 条 | 3条/周 | ✅ (≥3) |
  | 知识增长率 | 本周新增 2 条 | 2条/周 | ❌ (<3) |
  | 决策回顾率 | 到期 9 / 应回顾 10 | 90% | ✅ (≥90%) |
  | focus 命中率 | 推进 2 / 3 | 66.7% | ✅ (≥2/3) |
  | focus 命中率 | 推进 1 / 3 | 33.3% | ❌ (<2/3) |
  | 知识活性比 | 引用 20 / 总 100 | 20% | ✅ (≥20%) |
  | 人类参与度 | 人发起 5 / 总 10 | 50% | ✅ (≥50%) |
  | 人类参与度 | 人发起 4 / 总 10 | 40% | ❌ (<50%) |
  | 指标基线偏移度 | 当前/初始 = 1.0 | 1.0 | ✅ (=1.0) |
  | 复杂度使用率 | 活跃 24 / 上限 30 | 80% | ✅ (≤80%) |
  | 复杂度使用率 | 活跃 25 / 上限 30 | 83% | ❌ (>80%) |
  | 协作增益率 | 协作 1.2 / max单方 1.0 | 1.2 | ✅ (>1.0) |
  | 协作增益率 | 协作 0.9 / max单方 1.0 | 0.9 | ❌ (≤1.0) |
  | 鲁棒性 | 极端场景稳定度 70% | 70% | ✅ (≥70%) |
```

### T-METRIC-02：协作增益率 ≤ 1.0 触发重构

```yaml
前置: 协作增益率 = 0.9（低于 1.0）
输入: AI 评估指标
验证:
  - 标记为不健康
  - 输出诊断："不是工具问题，是协作结构问题"
  - 建议重新设计模式×拓扑组合
预期: 触发协作结构反思
```

### T-METRIC-03：4 项人类自评指标

```yaml
输入: 每周回顾时
验证:
  - AI 提出 4 个问题（决策质量、精力分配、角色平衡、体验）
  - AI 不参与打分（只提问）
  - 用户给出 1-5 分
  - 分数记录到 dashboard.md
预期: AI 只提问不打分
```

### T-METRIC-04：指标修改日志

```yaml
输入: 人类修改冻结指标基线
验证:
  - 修改记录写入指标修改日志
  - 包含日期、修改内容、修改原因、修改人
预期: 修改可追溯
```

---

## 六、管道流转测试

### T-PIPE-01：完整管道 — 收集→分流→执行→沉淀→回顾

```yaml
输入: 用户说"我刚听到一个新的市场机会"
验证流程:
  1. 收集: 用 capture/rules.md → 生成 inbox 条目 → runtime/inbox/
  2. 分流: 用 organize/rules.md → 判断"重要不紧急" → 排期到 data/content/
  3. 执行: 按协作模式分析机会
  4. 沉淀: 用 knowledge/rules.md → 原子笔记 → data/knowledge/notes/
  5. 回顾: 下次回顾时出现在报告中
预期: 信息在管道中完整流转
```

### T-PIPE-02：分流规则 — 四象限

```yaml
测试矩阵:
  | 输入 | 类型 | 预期去向 |
  |------|------|---------|
  | "服务器宕机了" | 紧急且重要 | runtime/thinking/ 或 decisions/ |
  | "下季度产品规划" | 重要不紧急 | data/content/{domain}/projects/ |
  | "回复一封例行邮件" | 紧急不重要 | 委派或快速处理 |
  | "某个过期的通知" | 不紧急不重要 | 归档或删除 |
  | "看到一篇好文章" | 知识类 | data/knowledge/notes/ |
```

### T-PIPE-03：inbox 断路器

```yaml
前置: inbox 积压 > 3 天量
输入: 新的 inbox 条目进入
验证:
  - 触发降级模式
  - 只处理"紧急+重要"类
  - 其他暂缓
预期: 过载保护生效
```

### T-PIPE-04：单阶段超时断路器

```yaml
前置: 某个阶段已耗时 > 2 小时
输入: 继续该阶段
验证:
  - 提醒拆分任务
  - 或建议切换协作模式
预期: 超时提醒生效
```

### T-PIPE-05：回顾闭环

```yaml
输入: 回顾过程中发现新的 input
验证:
  - 新 input 回流到 inbox
  - 重新进入管道（收集→分流→...）
预期: 管道形成闭环
```

---

## 七、自迭代与系统动力学测试

### T-ITER-01：四层迭代周期

```yaml
测试矩阵:
  | 周期 | 审计内容 | 可能的迭代动作 |
  |------|---------|-------------|
  | 每日 | 机器指标快照 | 调整 runtime/focus.md |
  | 每周 | 指标趋势 + 人类自评 | 微调 theory/ 规则 |
  | 每月 | 全指标综合 | 决定是否替换 theory pack |
  | 每季 | 系统级审计 | 决定是否修改 schema/ |

验证: 每个周期正确触发对应审计和迭代动作
```

### T-ITER-02：AI 迭代权限边界

```yaml
场景A — AI 建议修改 theory/:
  输入: AI 发现 theory 规则可优化
  验证: AI 输出建议，等待人类确认
  预期: ✅ 可建议，❌ 不可自行修改

场景B — AI 尝试修改冻结指标:
  输入: AI 认为某指标基线不合理
  验证: 操作被拦截
  预期: ❌ 不可修改冻结指标

场景C — AI 自动调整 runtime/:
  输入: 日常更新 focus.md
  验证: 直接更新成功
  预期: ✅ 可自由维护
```

### T-ITER-03：经验→规则编译管道

```yaml
输入: 用户总结"以后谈判前先列底线"
验证流程:
  1_draft: 自然语言记录
  2_formalize: AI 转化为 if-then 规则："IF 谈判场景 THEN 先列底线清单"
  3_backtest: 用历史数据检验
  4_deploy: 写入 theory/ 对应模块（需人确认）
  5_monitor: 后续持续校准
预期: 5 步编译完成
```

### T-ITER-04：结构化失败记录

```yaml
输入: 用户标记"这个决策搞砸了"
验证:
  - 触发失败记录模板
  - 记录: event, cause, outcome, principle
  - 归档到 runtime/
  - 周回顾时汇总
  - 同一模式 ≥ 2 次 → 触发系统级修复建议
预期: 失败可追踪，重复问题可上升
```

### T-ITER-05：系统陷阱免疫

```yaml
场景A — 目标侵蚀:
  输入: 多次未达标，有人提议"降低基线算了"
  验证: 冻结指标拦截，修改须人类手动+记录原因
  预期: 基线不被绩效拖低

场景B — 转嫁负担:
  输入: 人类参与度降至 40%（< 50%）
  验证: 告警"人类参与度不足，存在转嫁负担风险"
  预期: 硬约束生效

场景C — 信息过载:
  输入: inbox 积压超阈值
  验证: 断路器触发，降级处理
  预期: 过载保护

场景D — 共演化锁定:
  输入: AI 输出和用户行为高度相似，长期无变化
  验证: 检测到"太有序"信号，增加探索性噪声
  预期: 僵化打破机制生效
```

### T-ITER-06：混沌边缘检测

```yaml
场景A — 太有序（僵化）:
  信号: AI输出相似度 > 阈值 + theory pack 长期零修改
  预期动作: 增加随机性，触发小压力源

场景B — 太混乱（失控）:
  信号: AI输出连续被否决 + 并行进程过多
  预期动作: 加强约束，回读 constitution，启用最小介入模式

场景C — 健康:
  信号: 两个信号均未触发
  预期动作: 维持现状
```

---

## 八、会话约定测试

### T-SESS-01：单会话单主题

```yaml
输入: 用户在讨论"代码架构"时突然切到"投资分析"
验证:
  - AI 检测到跨域切换
  - 提醒用户"建议拆成两个会话"
预期: 跨域检测生效
```

### T-SESS-02：漂移断路器 — 轮数超限

```yaml
前置: session_length_limit = 20
输入: 交互达到第 20 轮
验证:
  - AI 提示"已达会话上限"
  - 建议终止当前会话，新会话重载
预期: 自动断路
```

### T-SESS-03：漂移断路器 — 内容漂移

```yaml
输入: AI 输出开始与 schema 矛盾
验证:
  - 自检检测到漂移
  - 触发断路器
  - 建议新会话重载
预期: 内容漂移被捕获
```

### T-SESS-04：每 10 轮自检

```yaml
输入: 第 10 轮交互结束
验证:
  - AI 对照 constitution.md 进行自检
  - 检查是否有漂移迹象
  - 输出自检结果（正常/告警）
预期: 定期自检执行
```

### T-SESS-05：不确定性标记

```yaml
场景A — 有数据来源:
  输入: AI 引用具体数据
  验证: 标注来源
  预期: "根据[来源]..."

场景B — 推测性结论:
  输入: AI 做推测
  验证: 标注区间和可信度
  预期: "推测区间 X-Y（可信度 60-70%）"

场景C — 不确定:
  输入: AI 无法确定
  验证: 明确声明不确定
  预期: "这部分我不确定..."
```

### T-SESS-06：schema 会话只读

```yaml
输入: 会话中 AI 尝试修改 schema/ 或 data/identity/
验证: 操作被拦截
预期: 会话内不可修改核心文件
```

### T-SESS-07：AI 缺陷免疫

```yaml
场景A — 上下文控制:
  验证: schema 文件 ≤ 2000 tokens
  预期: 文件大小符合约束

场景B — 幻觉防护:
  输入: AI 无法确认的信息
  验证: 必须声明不确定
  预期: 不编造事实

场景C — 复杂推理降级:
  输入: 单任务 > 5 步
  验证: AI 提醒拆分
  预期: 自动拆分触发
```

---

## 九、正交性与可替换性测试

### T-ORTH-01：换 theory pack — schema/data 不变

```yaml
前置: 当前 theory = theories/rational
输入: config.md 改为 theory = theories/new-pack
验证:
  - schema/ 文件不受影响
  - data/ 文件不受影响
  - 新 theory 的 meta.md 被正确加载
  - 路由系统使用新 theory 的关键词
预期: 三层正交性成立
```

### T-ORTH-02：换 data — schema/theory 不变

```yaml
前置: 当前 data = ../data
输入: config.md 改为 data = /path/to/other-user/data
验证:
  - schema/ 不变
  - theory/ 不变
  - 新用户的 profile.md 被加载
  - 启动面板显示新用户信息
预期: 切换用户不影响系统架构
```

### T-ORTH-03：换 schema — theory/data 不变

```yaml
前置: 当前 schema = schemas/default
输入: config.md 改为 schema = schemas/minimal
验证:
  - theory/ 不变
  - data/ 不变
  - 新 schema 的 constitution.md 和 protocols.md 被加载
预期: 切换架构不影响方法论和用户数据
```

### T-ORTH-04：复杂度预算 — schema ≤ 30 规则

```yaml
前置: schema 当前有 30 条核心规则
输入: 尝试新增第 31 条规则
验证:
  - 宪法第三条拦截
  - 必须先删除/归档一条旧规则
预期: 复杂度预算硬上限
```

### T-ORTH-05：复杂度预算 — theory 运行时加载 ≤ 3 文件

```yaml
前置: 用户输入命中 4 个以上 theory 关键词
输入: AI 执行路由匹配
验证:
  - 只加载相关度最高的 3 个 theory 文件
  - 每个文件 ≤ 1000 tokens
  - 总 theory 上下文 ≤ 3000 tokens
预期: 运行时加载预算硬上限
```

---

## 十、边界与异常测试

### T-EDGE-01：config.md 格式异常

```yaml
输入: config.md 缺少 version 字段
验证: 启动报错，提示配置不完整
预期: 不会以空版本号启动
```

### T-EDGE-02：必要文件缺失

```yaml
场景A: constitution.md 不存在
场景B: protocols.md 不存在
场景C: meta.md 不存在
场景D: _router.md 不存在
验证: 每种场景都有明确错误提示
预期: 关键文件缺失不静默失败
```

### T-EDGE-03：空的 runtime/focus.md

```yaml
输入: focus.md 没有任何焦点项
验证:
  - 启动面板焦点区域显示"未设定"
  - 提示用户设定今日焦点
预期: 空值优雅处理
```

### T-EDGE-04：并发读写 runtime/

```yaml
输入: 多处同时更新 runtime/ 文件
验证:
  - 不出现写冲突
  - 最终状态一致
预期: 运行时状态一致性
```

### T-EDGE-05：超长用户输入

```yaml
输入: 用户输入包含多个 domain 关键词和多个 theory 关键词
验证:
  - 路由选择最相关的 1 个 domain
  - theory 加载不超过 3 个文件
  - 上下文可控
预期: 不会过度加载
```

---

## 测试覆盖率汇总

| 测试类别 | 用例数 | 覆盖模块 |
|---------|-------|---------|
| 启动协议 | 10 | BOOT.md, config.md, 首次安装 |
| 路由系统 | 8 | _router.md, meta.md, think/_index.md |
| 协作模式 | 5 | 4模式×3拓扑, 最小介入, 并联加权 |
| 权限管理 | 7 | 6层读写权限, 冻结指标保护 |
| 冻结指标 | 4 | 11项机器指标, 4项人类指标, 修改日志 |
| 管道流转 | 5 | 5阶段管道, 分流规则, 断路器, 闭环 |
| 自迭代 | 6 | 4层周期, 编译管道, 失败记录, 陷阱免疫, 混沌边缘 |
| 会话约定 | 7 | 单主题, 断路器, 自检, 不确定性, 缺陷免疫 |
| 正交性 | 5 | 三层替换, 复杂度预算 |
| 边界异常 | 5 | 格式异常, 文件缺失, 空值, 并发, 超长输入 |
| **合计** | **62** | — |
