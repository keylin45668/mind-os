#!/bin/bash
# think-loop-check.sh — 配合 /loop 轮询的状态检查脚本
#
# 用法（在 Claude Code 中）:
#   /loop 30s ./mind-os-core/scripts/think-loop-check.sh runtime/thinking/task-001
#
# 功能:
#   检查指定任务目录下的 .wait_status 文件
#   输出当前状态供 /loop 捕获并触发对应动作

set -euo pipefail

TASK_DIR=${1:-"runtime/thinking"}
STATUS_FILE="$TASK_DIR/.wait_status"

if [ ! -f "$STATUS_FILE" ]; then
    echo "📋 无活跃的迭代任务"
    exit 0
fi

STATUS=$(cat "$STATUS_FILE")
TASK_NAME=$(basename "$TASK_DIR")

case "$STATUS" in
    waiting)
        echo "⏳ [$TASK_NAME] 等待用户输入中..."
        ;;
    answered)
        echo "✅ [$TASK_NAME] 用户已回答 → 触发下一轮迭代"
        echo "ACTION: continue_with_answer"
        ;;
    skipped)
        echo "⏭️  [$TASK_NAME] 用户跳过 → 按预设规则继续"
        echo "ACTION: continue_with_preset"
        ;;
    timeout)
        echo "⏰ [$TASK_NAME] 已超时 → 按 timeout_fallback 继续"
        echo "ACTION: continue_with_fallback"
        ;;
    converged)
        echo "🎯 [$TASK_NAME] 已收敛 → 生成比较报告"
        echo "ACTION: generate_comparison"
        ;;
    *)
        echo "❓ [$TASK_NAME] 未知状态: $STATUS"
        ;;
esac
