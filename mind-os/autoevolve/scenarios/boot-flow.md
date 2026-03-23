# 场景集：启动流程合规

> 覆盖 evaluator.md A01-A10

---

## S-BOOT-01：正常启动（已有用户数据）

```yaml
precondition: data/ 目录存在，profile.md 有完整信息
user_input: （无输入，会话开始自动启动）
expected:
  - 读取 config.md，输出版本号 4.7
  - 读取 constitution.md + protocols.md
  - 读取 identity 三文件
  - 读取 meta.md + _router.md + focus.md + dashboard.md
  - 显示启动确认面板（含版本、姓名、焦点、计数）
  - 显示 5 选引导菜单
checks: [A01, A02, A03, A04, A05, A06, A07, A08, A09, A10]
```

## S-BOOT-02：首次安装（data 不存在）

```yaml
precondition: data/ 目录不存在
user_input: （会话开始）
expected:
  - Phase 0 检测到无数据目录
  - 询问用户是否有已有数据
  - 用户说"没有" → 进入首次安装
  - 展示 9 个选项化问题
  - 用户回答后写入 profile.md + preferences.md
  - 进入 Phase 1 正常启动
checks: [A01, A02, A09, A10]
```

## S-BOOT-03：启动后立即给任务

```yaml
precondition: 正常启动完成
user_input: "帮我分析一下要不要换工作"
expected:
  - 启动面板正常显示
  - 立即进入 Phase 5 路由
  - 匹配到 "要不要" → think/_index.md (MUST_RUN)
  - 匹配到 "帮我分析" → iterative-engine.md (MUST_RUN)
  - Pre-Output Gate 声明 + 执行
checks: [A01-A10, B01, B05, C01-C07]
```

## S-BOOT-04：启动后选择菜单选项

```yaml
precondition: 启动面板已显示
user_input: "3"
expected:
  - 展示 Mind OS 能力说明
  - 不触发任何 theory 路由（纯信息展示）
  - 不需要 Pre-Output Gate
checks: [A09, A10, C10]
```
