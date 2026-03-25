# AutoEvolve — 网络同步协议

> 被 ENTRY.md Step 0 和 Step 5 调用。所有操作有超时，失败静默跳过。

---

## 原则

- 超时上限：10 秒/操作，总上限 30 秒
- 失败 = 跳过 + 在报告中标注 `[offline]`
- 不修改不可变文件（constitution.md、evaluator.md、program.md、scenarios/*.md）

---

## Step 0-A：远程同步（Pre-Iteration）

### 触发条件

state.yaml 中 `network.sync_enabled: true`（默认 false）

### 执行

```
1. git fetch origin --depth=1          ← timeout 10s
   失败 → sync_result: offline，跳到 Step 1

2. 对比 origin/main 与本地的以下路径：
   - autoevolve/scenarios/   （新场景）
   - theories/               （理论模块更新）
   - autoevolve/evaluator.md （评估标准版本号）

3. 有差异 → 列出变更文件，记录到 network.last_sync_diff

4. 合并规则：
   - 新增文件 → 自动拉取：git checkout origin/main -- {path}
   - 已有文件的修改 → 仅记录，不覆盖（避免破坏本地状态）
   - 不可变文件 → 仅记录版本差异，不操作

5. 更新 state.yaml：
   network.last_sync_round: {当前轮次}
   network.last_sync_result: success | offline
   network.last_sync_diff: [{变更文件列表}]
```

---

## Step 2-N：网络增强分析（Iteration 内）

### 触发条件

state.yaml 中 `network.web_search_enabled: true`（默认 false）
且 `next_action.type == test_and_fix`，且进入 ANALYZE 阶段

### 执行

```
1. 从失败项提取关键词：
   - failure check IDs + pattern description
   - 构造查询："LLM prompt engineering" + {failure_keywords}

2. WebSearch（timeout 10s）

3. 从结果提取：
   - 相关 prompt 工程技巧
   - 类似系统的解决方案

4. 摘要写入报告 external_knowledge 字段

5. 失败 → external_knowledge: "[offline] 使用本地知识"
```

---

## Step 5-B：结果远程备份（Post-Iteration）

### 触发条件

state.yaml 中 `network.backup_enabled: true`（默认 false）

### 执行

```
1. git add autoevolve/state.yaml autoevolve/results.tsv
2. git commit -m "autoevolve R{N}: {scenario} → {status} ({score})"
3. git push origin {current_branch}    ← timeout 15s
   - 失败 → backup_result: push_failed，不阻塞
   - 冲突 → backup_result: conflict，不强制推送
4. 更新 state.yaml：
   network.last_backup_round: {当前轮次}
   network.last_backup_result: success | push_failed | conflict
```
