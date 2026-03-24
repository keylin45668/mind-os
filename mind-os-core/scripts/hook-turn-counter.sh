#!/bin/bash
# hook-turn-counter.sh — UserPromptSubmit hook: 轮次计数 + 自检提醒
#
# 解决的问题: AI 无法可靠计数轮次（LLM 无原生计数器）
# 方案: 外部文件持久化计数，每次用户提交时 +1 并注入提醒
# 设计: 仅提供轮次信息，不强制终止会话（架构以文件为基准，不依赖上下文）

# 使用 PPID 区分不同会话窗口，避免多窗口共享计数
SESSION_ID="${CLAUDE_SESSION_ID:-$PPID}"
COUNTER_DIR="mind-os/runtime/sessions"
mkdir -p "$COUNTER_DIR"
COUNTER_FILE="${COUNTER_DIR}/.turn-counter-${SESSION_ID}"

# 清理超过 24 小时的旧计数器文件（避免堆积）
find "$COUNTER_DIR" -name ".turn-counter-*" -mmin +1440 -delete 2>/dev/null
find "$COUNTER_DIR" -name ".circuit-breaker-*" -mmin +1440 -delete 2>/dev/null

# 读取或初始化计数器
if [ -f "$COUNTER_FILE" ]; then
    TURN=$(cat "$COUNTER_FILE" 2>/dev/null)
    if ! echo "$TURN" | grep -qE '^[0-9]+$'; then
        TURN=0
    fi
else
    TURN=0
fi

# +1
TURN=$((TURN + 1))
echo "$TURN" > "$COUNTER_FILE"

# ── 注入轮次标记（仅供参考，无硬性限制）──
echo "[轮次 ${TURN}]"

# ── 10 轮自检提醒 ──────────────────────────────
if [ $((TURN % 10)) -eq 0 ] && [ "$TURN" -gt 0 ]; then
    echo ""
    echo "── 📋 第 ${TURN} 轮自检（每 10 轮触发）──"
    echo "请在本次回复中包含以下自检块:"
    echo "  □ 宪法第一条: 认知活动是否符合 Transform 范式？"
    echo "  □ 宪法第二条: 是否试图修改冻结指标？"
    echo "  □ 宪法第三条: 复杂度是否超预算？"
    echo "  □ 宪法第四条: 分析是否脱离本源？"
    echo "  结论: {无漂移 / 检测到漂移 → 纠正}"
    echo "──────────────────────────────────"
fi

exit 0
