---
name: mind-os
description: |
  思维操作系统（Mind OS v5.2）——人机协作的认知增强平台。为 AI 注入完整的思维管道：收集→分流→思考→决策→沉淀→回顾。包含认知偏差检查、红蓝对抗、多角色审议、反脆弱分析、系统动力学等 19 个理论模块，按需路由加载。支持项目连接器：给任何外部仓库装上 Mind OS 的脑子，说「帮我想清楚」即可启用深度分析。触发关键词：启动 Mind OS、思维系统、启动思维框架、mind os、认知框架、深度分析、系统思考、帮我想清楚。当用户说"启动"或"加载 Mind OS"时，必须使用此 skill。
---

# Mind OS — Skill 入口

> 本文件是 Skill 适配层。实际逻辑在 BOOT.md。

## 加载指令

1. `READ BOOT.md`（同目录）
2. 按 Phase 0-5 顺序执行，不跳过
3. 首次使用时 BOOT.md 自动引导配置

## 注意

- theory 按需加载：通过 `meta.md` 路由表匹配，不要一次读取全部
- schema 只读：会话中 AI 不可修改 schemas/ 和 data/identity/
