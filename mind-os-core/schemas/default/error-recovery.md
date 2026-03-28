# 错误恢复协议

> 定义系统关键文件损坏、缺失或不一致时的恢复行为。
> 原则：**静默降级，不阻塞用户；显式告知，不隐藏故障。**

---

## 1. 配置文件故障

| 场景 | 检测时机 | 恢复动作 |
|------|---------|---------|
| `local/config.md` 不存在 | Phase 0 | 从 `config-template.md` 复制 → 提示用户填写 |
| `local/config.md` 格式损坏 | Phase 0 | 告警 + 展示损坏内容 → 用户选择：修复 / 重置为模板 |
| `config-template.md` 也缺失 | Phase 0 | 告警："配置模板缺失，请检查 mind-os-core 完整性" → 使用硬编码默认值启动 |

### 硬编码默认值（最后防线）

```yaml
fallback_defaults:
  version: "unknown"
  schema: "schemas/default"
  theory: "theories/rational"
  data_profiles: []  # 空 → 触发 Phase 0 首次安装流程
```

---

## 2. 身份数据故障

| 场景 | 检测时机 | 恢复动作 |
|------|---------|---------|
| `{data}/identity/profile.md` 缺失 | Phase 3 | 从 `data-template/identity/profile.md` 复制 → 引导用户填写 |
| `{data}/identity/` 整个目录缺失 | Phase 3 | 创建目录 + 从 data-template 复制全部 → 提示"检测到空档案，已初始化" |
| `{data}` 路径不存在 | Phase 0 | 告警："档案路径 {data} 不存在" → 用户选择：创建 / 选其他档案 |

---

## 3. Theory 文件故障

| 场景 | 检测时机 | 恢复动作 |
|------|---------|---------|
| `meta.md` 缺失 | Phase 4 | 告警："路由表缺失，theory 模块不可用" → 降级为 schema-only 模式 |
| 路由匹配的 theory 文件不存在 | Pre-Input Gate (#1) | 告警："模块 {file} 不存在，跳过" → 降级该模块为不可用，继续其他模块 |
| theory 文件内容为空 | 加载时 | 告警："模块 {file} 内容为空" → 跳过，记录到 `runtime/audits/backlog.md` |

### 降级模式

```yaml
degraded_mode:
  schema_only:
    触发: meta.md 缺失 或 theory/ 目录不存在
    行为: 只使用 protocols.md 通用规则，不加载任何 theory 模块
    告知: "⚠️ 当前为降级模式（仅 schema），theory 模块不可用"
    限制: 无偏差检查、无迭代引擎、无反脆弱分析
```

---

## 4. Runtime 状态故障

| 场景 | 检测时机 | 恢复动作 |
|------|---------|---------|
| `runtime/` 目录不存在 | Phase 4 | 创建完整 runtime 目录结构（见下方） |
| `runtime/audits/current.md` 缺失 | session-audit 执行时 | 创建空文件，从当前会话开始记录 |
| `runtime/ratings/current.md` 缺失 | session-rating 执行时 | 创建空文件（含表头），从当前会话开始记录 |
| `runtime/focus.md` 缺失 | Phase 5 启动面板 | 创建空焦点文件（current: []） |
| `runtime/dashboard.md` 缺失 | 启动面板 | 从当前可用数据重建 |

### Runtime 目录结构（自动创建）

```
runtime/
├── audits/
│   ├── current.md      # 当前审查记录
│   └── backlog.md      # 改进待办
├── ratings/
│   └── current.md      # 评分记录
├── evolution/
│   └── fitness.md      # 模块适应度
├── focus.md            # 今日焦点
└── dashboard.md        # 全局状态面板
```

---

## 5. AutoEvolve 状态故障

| 场景 | 检测时机 | 恢复动作 |
|------|---------|---------|
| `state.yaml` 缺失 | `/迭代` 命令 | 告警 + 从 ENTRY.md 默认值重建 |
| `state.yaml` 与 `results.tsv` 不同步 | `/迭代` 命令 | 以 `state.yaml` 为准（source of truth），重建 results.tsv 尾部 |
| `results.tsv` 缺失 | `/迭代` 命令 | 从 state.yaml 当前状态重建（仅最新条目） |
| `evaluator.md` 缺失 | autoevolve loop | 告警："评估器缺失，无法执行迭代" → 暂停 autoevolve |

### 同步检查规则

```yaml
sync_check:
  触发: 每次 /迭代 命令开始时
  检查: state.yaml.current_round == results.tsv 最后一行的 round
  不一致时:
    - state.yaml.round > results.tsv.last_round → 补记缺失轮次为 "skipped"
    - state.yaml.round < results.tsv.last_round → 以 results.tsv 更新 state.yaml
  记录: 不一致事件写入 runtime/audits/backlog.md
```

---

## 6. Pre-Output Gate 失败

| 场景 | 恢复动作 |
|------|---------|
| MUST_RUN 协议在执行中途出错 | 标记该协议为"执行失败" → 告知用户 → 继续其他协议 |
| self_check 发现 MUST_RUN 未执行 | 补执行（现有逻辑）→ 补执行也失败 → 降级为 SHOULD 并显式声明 |
| 所有 MUST_RUN 均失败 | 告警："所有强制协议执行失败" → 输出原始分析（无门控增强）→ 建议新会话重试 |

---

## 通用原则

1. **不静默失败**：任何恢复动作必须在输出中告知用户
2. **不阻塞启动**：单个文件故障不应阻止整个 BOOT 流程
3. **优先降级而非停止**：功能缺失时降级运行，而非拒绝服务
4. **记录一切**：所有故障和恢复动作写入 `runtime/audits/backlog.md`（P0 优先级）
5. **人工兜底**：连续 3 次同类故障 → 提示用户手动检查文件完整性
