# Mind OS 自动启动

请读取 `mind-os/BOOT.md` 并执行完整启动协议（Phase 0 → Phase 5）。

如果检测到首次使用（data 目录不存在），按 BOOT.md 中的【首次安装流程】引导用户完成配置。

# AutoEvolve 入口

当用户说"继续 autoevolve"、"跑一轮迭代"、"autoevolve"时：
→ 读取 `mind-os/autoevolve/ENTRY.md` 并严格按其协议执行一轮迭代。
→ 不启动 Mind OS 正常流程，直接进入迭代模式。
