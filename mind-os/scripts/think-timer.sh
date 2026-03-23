#!/bin/bash
# think-timer.sh — 迭代思考计时器
#
# 用法:
#   ./think-timer.sh [超时秒数] [状态文件路径]
#   ./think-timer.sh 120 runtime/thinking/task-001/.wait_status
#
# 状态文件值:
#   waiting  — 等待用户输入中
#   answered — 用户已回答（外部写入）
#   skipped  — 用户主动跳过（外部写入）
#   timeout  — 超时自动继续（本脚本写入）
#
# 配合 /loop 使用:
#   /loop 30s 检查状态文件，timeout 时触发下一轮迭代

set -euo pipefail

TIMEOUT=${1:-120}
STATUS_FILE=${2:-"runtime/thinking/.wait_status"}

# 确保目录存在
mkdir -p "$(dirname "$STATUS_FILE")"

# 初始化状态
echo "waiting" > "$STATUS_FILE"

echo "⏱️  等待用户输入（${TIMEOUT}s 后自动继续）..."
echo "   状态文件: $STATUS_FILE"
echo "   回答方式: 直接输入 或 修改状态文件为 answered/skipped"

# 倒计时循环
ELAPSED=0
INTERVAL=5

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    # 检查是否已被外部更新（用户回答或跳过）
    CURRENT_STATUS=$(cat "$STATUS_FILE" 2>/dev/null || echo "waiting")

    if [ "$CURRENT_STATUS" = "answered" ]; then
        echo "✅ 用户已回答，继续迭代"
        exit 0
    fi

    if [ "$CURRENT_STATUS" = "skipped" ]; then
        echo "⏭️  用户跳过，按预设规则继续"
        exit 0
    fi

    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
    REMAINING=$((TIMEOUT - ELAPSED))

    if [ "$REMAINING" -gt 0 ]; then
        echo "   ⏳ 剩余 ${REMAINING}s..."
    fi
done

# 超时处理
CURRENT_STATUS=$(cat "$STATUS_FILE" 2>/dev/null || echo "waiting")
if [ "$CURRENT_STATUS" = "waiting" ]; then
    echo "timeout" > "$STATUS_FILE"
    echo "⏰ 超时（${TIMEOUT}s），按预设规则自动继续"
    echo "   未回答的问题将按 auto_reply_rules.timeout_fallback 处理"
    exit 0
fi
