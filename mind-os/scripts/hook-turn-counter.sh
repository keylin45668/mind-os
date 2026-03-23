#!/bin/bash
# hook-turn-counter.sh — UserPromptSubmit hook: 轮次计数 + 自检/断路器触发
#
# 解决的问题: AI 无法可靠计数轮次（LLM 无原生计数器）
# 方案: 外部文件持久化计数，每次用户提交时 +1 并注入提醒
#
# 计数器文件: mind-os/runtime/.turn-counter
# 格式: 纯数字（当前轮次）

COUNTER_FILE="mind-os/runtime/.turn-counter"
SESSION_LIMIT=20  # 默认值，理想情况从 preferences.md 读取

# 尝试从 preferences.md 读取 session_length_limit
PREF_FILE="mind-os/runtime/../data-template/identity/preferences.md"
if [ -f "../data/identity/preferences.md" ]; then
    PREF_FILE="../data/identity/preferences.md"
fi
LIMIT_FROM_FILE=$(grep 'session_length_limit' "$PREF_FILE" 2>/dev/null | grep -o '[0-9]*' | head -1)
[ -n "$LIMIT_FROM_FILE" ] && SESSION_LIMIT=$LIMIT_FROM_FILE

# 读取或初始化计数器
if [ -f "$COUNTER_FILE" ]; then
    TURN=$(cat "$COUNTER_FILE" 2>/dev/null)
    # 验证是数字
    if ! echo "$TURN" | grep -qE '^[0-9]+$'; then
        TURN=0
    fi
else
    mkdir -p "$(dirname "$COUNTER_FILE")"
    TURN=0
fi

# +1
TURN=$((TURN + 1))
echo "$TURN" > "$COUNTER_FILE"

# ── 始终注入轮次标记 ──────────────────────────
echo "[轮次 ${TURN}/${SESSION_LIMIT}]"

# ── 10 轮自检提醒 ──────────────────────────────
if [ $((TURN % 10)) -eq 0 ] && [ "$TURN" -gt 0 ]; then
    echo ""
    echo "── 📋 第 ${TURN} 轮自检（每 10 轮强制触发）──"
    echo "请在本次回复中包含以下自检块:"
    echo "  □ 宪法第一条: 认知活动是否符合 Transform 范式？"
    echo "  □ 宪法第二条: 是否试图修改冻结指标？"
    echo "  □ 宪法第三条: 复杂度是否超预算？"
    echo "  □ 宪法第四条: 分析是否脱离本源？"
    echo "  结论: {无漂移 / 检测到漂移 → 纠正}"
    echo "──────────────────────────────────"
fi

# ── 漂移断路器 ──────────────────────────────────
if [ "$TURN" -ge "$SESSION_LIMIT" ]; then
    # 写标记文件供 output-validator 检查
    echo "circuit_breaker" > "mind-os/runtime/.circuit-breaker-active"
    echo ""
    echo "🛑 【硬性断路器】会话已达 ${TURN}/${SESSION_LIMIT} 轮。"
    echo "你必须在本次回复中:"
    echo "  1. 总结本会话的关键结论"
    echo "  2. 输出: ⚠️ 会话已达上限，请新建会话继续"
    echo "  3. 不得开启新任务或深度分析"
    echo "输出验证器将检查终止声明是否存在。"
fi

exit 0
