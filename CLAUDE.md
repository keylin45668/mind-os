# Mind OS

当用户说"启动 mind-os"、"启动"、"boot"时：
→ 读取 `mind-os-core/BOOT.md` 并执行完整启动协议（Phase 0 → Phase 5）。

当用户说"继续 autoevolve"、"跑一轮迭代"、"autoevolve"、"/迭代"时：
→ 读取 `mind-os-core/autoevolve/ENTRY.md` 并严格按其协议执行一轮迭代。

当用户说"/迭代进度"、"/迭代暂停"、"/迭代继续"、"/迭代聚焦 {X}"时：
→ 读取 `mind-os-core/autoevolve/state.yaml` 执行对应操作。

当用户说"/模块迭代"、"/模块迭代 {X}"时：
→ 读取 `mind-os-core/autoevolve/module-evolve.md` 并按其协议执行。

当用户说"/模块列表"时：
→ 读取 `mind-os-core/autoevolve/module-evolve.md` 中 `/模块列表` 部分，扫描并展示模块状态。

当用户说"/深度迭代"、"/深度迭代 {任务描述}"时：
→ 读取 `mind-os-core/theories/rational/think/task-iterate.md` 并按三层架构执行。

当用户说"安装 mind-os"、"安装 mind-os {路径}"、"install mind-os"时：
→ 读取 `mind-os-core/projects/INSTALL.md` 并按其安装协议执行。
→ 如果当前不在 mind-os 父目录，按以下顺序找 INSTALL.md：
  1. 用户提供的路径/projects/INSTALL.md
  2. ../mind-os/projects/INSTALL.md
  3. 从 https://github.com/keylin45668/mind-os 克隆后读取
