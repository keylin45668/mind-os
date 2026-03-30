# 场景集：动态 Hooks 聚合与质量门控

> 覆盖 protocols.md §4 Pre-Output Gate 4_depth_check 动态聚合规则
> 验证 frontmatter hooks 迁移后的门控行为正确性

---

## S-HOOK-01：单模块 depth_check 触发

```yaml
user_input: "帮我分析一下这三个方案"
加载模块: iterative-engine.md (MUST_RUN)
hooks.depth_check: "红方须与蓝方观点不同"
expected:
  - 红蓝对抗执行完毕后
  - Pre-Output Gate 4_depth_check 读取 iterative-engine.md frontmatter hooks
  - 检查: 红方观点是否与蓝方不同
  - 通过 → 继续输出
  - 未通过 → 标记"⚠️ 红蓝独立性不足"→ 要求重新执行红方
checks: [C03, C05, C06]
```

## S-HOOK-02：单模块 depth_check — antifragile 百分比验证

```yaml
user_input: "这个投资风险大不大"
加载模块: antifragile.md (MUST_RUN)
hooks.depth_check: "三元分类每类须有具体百分比和理由"
expected:
  - 三元分类执行后
  - 4_depth_check 检查:
    - 脆弱类有百分比 → ✅ 或 ❌
    - 强韧类有百分比 → ✅ 或 ❌
    - 反脆弱类有百分比 → ✅ 或 ❌
    - 每类有理由说明 → ✅ 或 ❌
  - 全部 ✅ → 输出
  - 任一 ❌ → 补充后再输出
checks: [C03, C05, C08]
```

## S-HOOK-03：单模块 depth_check — system-audit 实质产出

```yaml
user_input: "帮我审计一下这个流程"
加载模块: system-audit-method.md (MUST_RUN)
hooks.depth_check: "至少 2 个方法有实质产出"
expected:
  - 审计执行后
  - 4_depth_check 检查:
    - 方法 A/B/C/D 中至少 2 个有实质内容（非"不适用"）→ ✅
    - 只有 1 个或 0 个有实质 → ❌ → 补充
  - "不适用"的方法也必须声明原因
checks: [C03, C05, C09]
```

## S-HOOK-04：单模块 depth_check — 偏差关联情境

```yaml
user_input: "我该不该转行"
加载模块: think/_index.md (MUST_RUN)
hooks.depth_check: "偏差须关联用户具体情境"
expected:
  - 偏差扫描执行后
  - 4_depth_check 检查:
    - 偏差分析是否引用了用户的具体情境（"转行"）→ ✅
    - 泛泛而谈"这种情况下可能有锚定效应" → ❌（未关联具体情境）
    - 具体关联"你可能被当前薪资锚定了对新行业的期望值" → ✅
checks: [C03, C05, C07]
```

## S-HOOK-05：多模块 hooks 聚合

```yaml
user_input: "帮我深度分析这个投资的风险"
加载模块:
  - iterative-engine.md → hooks.depth_check: "红方须与蓝方观点不同"
  - antifragile.md → hooks.depth_check: "三元分类每类须有具体百分比和理由"
expected:
  Pre-Output Gate 4_depth_check 执行 2 条:
    ① "红方须与蓝方观点不同" → 检查 ✅/❌
    ② "三元分类每类须有具体百分比和理由" → 检查 ✅/❌
  - 两条都通过 → 输出
  - 任一失败 → 补充
  - 不执行未加载模块的 hooks（如 system-audit 的 hooks 不出现）
checks: [C03, C05, C06, C08]
```

## S-HOOK-06：三模块 hooks 聚合

```yaml
user_input: "帮我分析投资风险并审计决策系统"
加载模块:
  - iterative-engine.md → depth_check: "红方须与蓝方观点不同"
  - antifragile.md → depth_check: "三元分类每类须有具体百分比和理由"
  - system-audit-method.md → depth_check: "至少 2 个方法有实质产出"
expected:
  4_depth_check 聚合 3 条:
    ① "红方须与蓝方观点不同" ✅/❌
    ② "三元分类每类须有具体百分比和理由" ✅/❌
    ③ "至少 2 个方法有实质产出" ✅/❌
  - 三条全通过才输出
  - 执行顺序与串行拆分顺序一致（antifragile → system-audit → iterative-engine）
checks: [C03, C05, C06, C08, C09]
```

## S-HOOK-07：无 hooks 模块 — fallback 跳过

```yaml
user_input: "帮我快速收集一下今天的信息"
加载模块: capture/rules.md (SHOULD, hooks 全 null)
expected:
  Pre-Output Gate 4_depth_check:
    - capture/rules.md hooks.depth_check = null → 跳过 ✅
    - 不报错、不阻塞 ✅
    - 1_declare / 2_enforce / 3_self_check 正常执行
    - 输出不被 depth_check 阻挡
checks: [C01, C02, C04, C10]
```

## S-HOOK-08：post_check — 结晶三问验证

```yaml
任务完成后触发 review/crystallize.md
hooks.post_check: "三问全部执行且有结论（即使是'无信号'）"
expected:
  执行后检查:
    - 模式发现问: 有结论（"发现 X 模式" 或 "本次无模式信号"）→ ✅
    - 缺口发现问: 有结论（"发现缺口 Y" 或 "本次无缺口"）→ ✅
    - 可复用知识问: 有结论（"可复用 Z" 或 "本次无可复用知识"）→ ✅
  - 三问全部有结论 → 通过
  - 任一问缺失 → ❌ → 补充
checks: [C03, C05]
```

## S-HOOK-09：post_check — 会话审查依据验证

```yaml
触发: session-audit.md (MUST_RUN)
hooks.post_check: "审查清单每项有具体依据"
expected:
  审查输出中:
    - 每个检查项标注 ✅/⚠️/❌ → ✅
    - ✅ 项有依据（"第 N 轮执行了偏差检查"）→ ✅
    - ⚠️/❌ 项有具体说明（"未执行原因: ..."）→ ✅
  - 出现无依据的标注（如只写 ✅ 不说明）→ ❌
checks: [C03, C05, H02]
```

## S-HOOK-10：post_check — 评分客观依据验证

```yaml
触发: session-rating.md (MUST_RUN)
hooks.post_check: "每维度评分有文档中客观依据"
expected:
  评分输出中:
    - D1 任务完成度: 分数 + 依据（"核心问题已回答"）→ ✅
    - D2 分析深度: 分数 + 依据（"经过 2 轮红蓝对抗"）→ ✅
    - D3 协议合规: 分数 + 依据（"MUST_RUN 全部执行"）→ ✅
    - D4 效率: 分数 + 依据（"2 轮收敛"）→ ✅
    - D5 可行动性: 分数 + 依据（"有明确下一步"）→ ✅
  - 出现无依据的打分（如 "D2: 4分" 无说明）→ ❌
checks: [C03, C05, H04]
```

## S-HOOK-11：depth_check — creative 发散路径验证

```yaml
user_input: "/创意 帮我想几个产品方案"
加载模块: creative.md (MUST_RUN, 命令触发)
hooks.depth_check: "发散阶段至少用2种路径"
expected:
  发散阶段完成后:
    - 检查使用了哪些发散路径:
      - 类比迁移 ✅/❌
      - 逆向设计 ✅/❌
      - SCAMPER ✅/❌
      - 极端约束 ✅/❌
    - 至少 2 种 ✅ → 通过
    - 只用了 1 种 → ❌ → 补充第二种路径
checks: [C03, C05]
```

## S-HOOK-12：depth_check — task-iterate 完整性验证

```yaml
user_input: "/深度迭代 这个方案值不值得做"
加载模块: task-iterate.md (MUST_RUN)
hooks.depth_check: "至少1个方向完成完整蓝-红-裁决"
expected:
  迭代完成后:
    - 检查: 至少 1 个方向有完整的蓝方→红方→裁决记录
    - 完整 = 蓝方有论点 + 红方有质疑(含本源检查) + 裁决有 SURVIVED/FALLEN/MODIFIED
    - 只有蓝方没有红方 → ❌
    - 有蓝+红但没有裁决 → ❌
    - 至少 1 个完整 → ✅
checks: [C03, C05, F05, F06]
```

---

## 边界场景

## S-HOOK-13：hooks 与步间门控不重复

```yaml
user_input: "/分析 + /反脆弱 投资方案"
加载模块: iterative-engine.md + antifragile.md
expected:
  串行执行:
    Step 1: antifragile → 步间门控清单 [三元分类+百分比, 杠铃, 否定法]
    Step 2: iterative-engine → 步间门控清单 [蓝-红-裁决, 本源检查, 比较报告]
  Pre-Output Gate:
    4_depth_check（动态 hooks）:
      ① "三元分类每类须有具体百分比和理由" → 与步间门控检查内容类似
      ② "红方须与蓝方观点不同" → 与步间门控检查内容类似
  - 两者允许重叠但不应导致阻塞或冲突
  - 步间门控 = 每步完成后的过程检查
  - depth_check = 最终输出前的总体检查
  - 步间门控通过但 depth_check 更严格（如步间只查有无百分比，depth_check 还查是否有理由）
checks: [C03, C05, C06, C08]
```

## S-HOOK-14：新增模块自动纳入 hooks 聚合

```yaml
场景: 未来新增模块 theories/rational/think/new-method.md
前置:
  frontmatter:
    hooks:
      depth_check: "必须给出至少 3 个替代方案"
expected:
  - 该模块被路由匹配并加载后
  - Pre-Output Gate 4_depth_check 自动读取其 hooks.depth_check
  - 无需修改 protocols.md
  - 无需修改 meta.md 中的 gate 相关内容
验证点: 动态聚合机制支持新模块零配置接入
```
