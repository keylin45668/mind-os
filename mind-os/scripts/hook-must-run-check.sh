#!/bin/bash
# hook-must-run-check.sh — UserPromptSubmit hook: MUST_RUN 关键词扫描 + 意图验证提醒
#
# v2: 增加意图验证提醒（meta.md 规则 6）+ 多协议串行提醒（规则 7）

INPUT=$(cat)

# 提取用户消息
USER_MSG=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user_prompt', d.get('message','')))" 2>/dev/null || \
           echo "$INPUT" | grep -o '"user_prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$USER_MSG" ] && USER_MSG=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$USER_MSG" ] && exit 0

MUST_RUN_COUNT=0
REMINDERS=""

# ── MUST_RUN 关键词检测 ──────────────────────────

# 1. 迭代引擎
if echo "$USER_MSG" | grep -qiE '帮我分析|深度思考|多方向|对比方案|利弊|帮我想想|分析一下'; then
    MUST_RUN_COUNT=$((MUST_RUN_COUNT + 1))
    REMINDERS="${REMINDERS}
⚠️ MUST_RUN[${MUST_RUN_COUNT}]: 迭代思考引擎（think/iterative-engine.md）
→ 意图验证: \"分析\"是任务核心还是修饰语？核心→执行，修饰→降级MAY
→ 执行要求: 至少 1 轮蓝-红-裁决（默认在对话中输出）"
fi

# 2. 决策偏差
if echo "$USER_MSG" | grep -qiE '要不要|该不该|值不值|决策|做决定|选择.*还是'; then
    MUST_RUN_COUNT=$((MUST_RUN_COUNT + 1))
    REMINDERS="${REMINDERS}
⚠️ MUST_RUN[${MUST_RUN_COUNT}]: 认知偏差检查（think/_index.md）
→ 意图验证: \"决策/选择\"是任务核心还是修饰语？
→ 执行要求: 输出中必须包含偏差扫描结果"
fi

# 3. 风险/投资/反脆弱
if echo "$USER_MSG" | grep -qiE '风险|投资|反脆弱|赌|押注|亏|赔'; then
    MUST_RUN_COUNT=$((MUST_RUN_COUNT + 1))
    REMINDERS="${REMINDERS}
⚠️ MUST_RUN[${MUST_RUN_COUNT}]: 反脆弱框架（decide/antifragile.md）
→ 意图验证: \"风险/投资\"是任务核心还是修饰语（如\"投资人\"\"投资理论\"）？
→ 执行要求: 三元分类 + 杠铃检查 + 否定法"
fi

# 4. 审计/系统检查
if echo "$USER_MSG" | grep -qiE '审计|系统检查|自检|诊断系统'; then
    MUST_RUN_COUNT=$((MUST_RUN_COUNT + 1))
    REMINDERS="${REMINDERS}
⚠️ MUST_RUN[${MUST_RUN_COUNT}]: 系统审计（think/system-audit-method.md）
→ 意图验证: \"审计\"是任务核心还是修饰语？
→ 执行要求: 方法 A/B/C/D（不适用须声明原因）"
fi

# ── 写入 MUST_RUN 标记文件（供 output-validator 使用）──

ACTIVE_PROTOCOLS=""

if [ -n "$REMINDERS" ]; then
    # 记录命中的协议（供验证器检查）
    echo "$USER_MSG" | grep -qiE '帮我分析|深度思考|多方向|对比方案|利弊|帮我想想|分析一下' && ACTIVE_PROTOCOLS="${ACTIVE_PROTOCOLS}iterative-engine "
    echo "$USER_MSG" | grep -qiE '要不要|该不该|值不值|决策|做决定|选择.*还是' && ACTIVE_PROTOCOLS="${ACTIVE_PROTOCOLS}think-index "
    echo "$USER_MSG" | grep -qiE '风险|投资|反脆弱|赌|押注|亏|赔' && ACTIVE_PROTOCOLS="${ACTIVE_PROTOCOLS}antifragile "
    echo "$USER_MSG" | grep -qiE '审计|系统检查|自检|诊断系统' && ACTIVE_PROTOCOLS="${ACTIVE_PROTOCOLS}system-audit "

    mkdir -p mind-os/runtime
    echo "$ACTIVE_PROTOCOLS" > "mind-os/runtime/.must-run-active"

    # ── 输出提醒 ──────────────────────────────────────
    echo "【Pre-Output Gate · Hook 注入】"
    echo "$REMINDERS"
    echo ""

    # 意图验证提醒
    echo "📋 意图验证（meta.md 规则 6）: 对每个 MUST_RUN 匹配，先判断关键词是任务核心还是修饰语/背景。修饰语→降级为 MAY。"

    # 多协议串行提醒
    if [ "$MUST_RUN_COUNT" -ge 2 ]; then
        echo ""
        echo "🔀 多协议串行（meta.md 规则 7）: 检测到 ${MUST_RUN_COUNT} 个 MUST_RUN。"
        echo "→ 必须分步执行，每步完成后用清单自检，全部 ✅ 才进入下一步。"
        echo "→ 排序: 清单型(antifragile/audit)先于生成型(iterative-engine)"
    fi

    if [ "$MUST_RUN_COUNT" -ge 3 ]; then
        echo ""
        echo "🛑 多协议拆分（强制）: 检测到 ${MUST_RUN_COUNT} 个 MUST_RUN，超过单会话深度容量。"
        echo "→ 你必须先执行前 2 个协议（意图验证通过的），完成后建议用户开新会话处理剩余协议。"
        echo "→ 不可在同一输出中压缩执行 3 个重量级协议。"
        echo "→ 输出验证器将检查: 是否声明了拆分 + 是否建议了后续会话。"
        # 写入拆分标记
        echo "split_required" > "mind-os/runtime/.must-run-split"
    fi

    echo ""
    echo "⚡ 输出验证器已激活: 回复完成后将自动检查门控声明、协议执行深度、自检步骤。不通过将被拦截。"
    echo "执行前先声明: \"本次匹配到: {文件列表}，协作模式: {模式×拓扑}\""
fi

exit 0
