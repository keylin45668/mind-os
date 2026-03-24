# 场景集：会话生命周期（审查 + 评分 + 档案切换）

> 覆盖 session-audit、session-rating（点击式）、多档案、身份类型

---

## S-LIFE-01：会话结束触发审查 + 评分（串行）

```yaml
context: 用户完成了一个任务
user_input: "先到这里"
expected:
  - 识别会话结束信号（"先到这里" = 结束）
  - 路由匹配: review/session-audit.md → review/session-rating.md (MUST_RUN)
  - 先执行审查（session-audit）:
    - AI 自审 4 部分（路由门控/宪法/执行质量/改进发现）
    - 每条给 ✅/⚠️/❌/➖ 标记
    - 调用 AskUserQuestion 让用户确认审查结果
    - 结果落盘到 runtime/audits/current.md
    - ⚠️/❌ 项写入 runtime/audits/backlog.md
  - 再执行评分（session-rating）:
    - AI 自评 5 维度
    - 第 1 轮 AskUserQuestion: D1 D2 D3（点击选项，非手动输入）
    - 第 2 轮 AskUserQuestion: D4 D5（点击选项）
    - 加权计算（人×0.6 + AI×0.4）
    - 结果落盘到 runtime/ratings/current.md
  - 顺序: 审查 → 评分，不可跳过审查直接评分
checks: [H01, H02, H03, H04, H05]
```

## S-LIFE-02：评分必须用 AskUserQuestion 点击式

```yaml
context: 进入评分环节
expected:
  - 人类评分不得使用"输入数字"形式
  - 必须分两轮 AskUserQuestion:
    - 第 1 轮: D1(完成度) D2(深度) D3(合规) — 每题 4 个选项
    - 第 2 轮: D4(效率) D5(可行动性) — 每题 4 个选项
  - 每个选项含星级（⭐⭐⭐⭐⭐=5）和描述
  - 星级到分数的映射正确
checks: [H04, H05]
```

## S-LIFE-03：各种结束信号都能触发

```yaml
test_cases:
  - user_input: "今天先这样"
    expected: 触发审查+评分
  - user_input: "先到这里吧"
    expected: 触发审查+评分
  - user_input: "下次继续"
    expected: 触发审查+评分
  - user_input: "好的谢谢"
    expected: 不一定触发（可能是任务中途的感谢，需上下文判断）
  - user_input: "/评分"
    expected: 命令触发，直接进入审查+评分
checks: [H01]
```

## S-LIFE-04：多档案启动 — 选择已有档案

```yaml
context: config.md 有 2+ 个 data_profiles
expected:
  - Phase 0 弹出 AskUserQuestion 档案选择
  - 选项包含所有档案（default 排第一）+ "➕ 新建档案"
  - 选择后 {data} 正确指向对应 path
  - 后续流程正常（身份确认 → 加载核心 → 面板）
checks: [H06]
```

## S-LIFE-05：档案类型检测 — 个人档案

```yaml
context: data 目录无 org.md
expected:
  - 识别为个人档案
  - 启动面板不显示组织相关行（行业、团队规模、阶段）
  - 身份确认只展示个人字段
checks: [H07]
```

## S-LIFE-06：档案类型检测 — 协作组织

```yaml
context: data 目录有 org.md（collaborative: true）+ members/ 目录
expected:
  - 识别为协作组织档案
  - 弹出 AskUserQuestion "你是谁？" 列出成员
  - 选择成员后 {data} 指向 members/{selected}/
  - org 信息从 org.md 读取
  - 面板显示组织名 + 协作状态 + 个人信息
checks: [H07, H08]
```

## S-LIFE-07：协作组织 — 新成员加入

```yaml
context: S-LIFE-06 中用户选"我是新成员"
expected:
  - 在 members/ 下创建新目录
  - 进入首次安装流程（个人部分，不重复问组织信息）
  - 组织信息继承 org.md
  - 完成后正常启动
checks: [H08]
```

## S-LIFE-08：首次安装 — 个人 vs 组织分支

```yaml
context: 全新 data 目录，首次安装
expected:
  - Step 0 弹出 AskUserQuestion 选择档案类型（个人/组织）
  - 选"个人":
    - 不问组织信息（行业、团队规模、阶段）
    - 只问个人信息（2 轮）
    - 不创建 org.md
  - 选"组织":
    - 先采集组织信息（1 轮）
    - 再问协作模式（独立/协作）
    - 最后采集个人信息（2 轮）
    - 创建 org.md
checks: [H09]
```

## S-LIFE-09：会话中切换档案

```yaml
context: 已启动主档案，会话进行中
user_input: "切换到测试用户"
expected:
  - 匹配路由: 切换档案/切换身份 → BOOT.md 切换协议
  - 在 config.md data_profiles 中模糊匹配"测试用户"
  - 弹出 AskUserQuestion 确认切换
  - 确认后:
    - {data} 更新
    - 重新读取 identity 三文件
    - 输出新档案摘要面板
    - 语言锁定按新档案更新
checks: [H10]
```

## S-LIFE-10：审查发现问题 → 写入 backlog

```yaml
context: 会话中有路由遗漏或协议跳过
expected:
  - 审查时 AI 如实标记 ⚠️ 或 ❌（不掩盖问题）
  - ⚠️/❌ 项自动写入 runtime/audits/backlog.md
  - backlog 格式正确: 日期/来源/问题/建议/状态/优先级
  - 连续 3 次同项 ⚠️/❌ → 升级为 P0
checks: [H02, H03]
```
