#!/bin/bash
# hook-stop-guard.sh — Stop hook: 阻止 AI 在有未完成任务时停止
#
# 检查项:
# 1. runtime/thinking/*/queue.md 中是否有 [TODO] 或 [DOING]
# 2. 如有 → 阻止停止，提示继续执行
#
# 防无限循环: stop_hook_active=true 时放行

INPUT=$(cat)

# 防无限循环（不依赖 jq）
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi

MIND_OS_DIR="mind-os"
THINKING_DIR="$MIND_OS_DIR/runtime/thinking"

# 检查是否有活跃的思考任务
PENDING=0
ACTIVE_TASK=""

if [ -d "$THINKING_DIR" ]; then
    for queue_file in "$THINKING_DIR"/*/queue.md; do
        [ -f "$queue_file" ] || continue
        TODO_COUNT=$(grep -c '\[TODO\]\|\[DOING\]' "$queue_file" 2>/dev/null || true)
        if [ "$TODO_COUNT" -gt 0 ]; then
            PENDING=$((PENDING + TODO_COUNT))
            ACTIVE_TASK=$(dirname "$queue_file" | xargs basename)
        fi
    done
fi

if [ "$PENDING" -gt 0 ]; then
    cat << EOF
{
  "decision": "block",
  "reason": "有 $PENDING 个待执行步骤（任务: $ACTIVE_TASK）。请读取 $THINKING_DIR/$ACTIVE_TASK/queue.md 继续执行，或读取 context.md 恢复上下文。"
}
EOF
    exit 0
fi

# 无待办任务，允许停止
exit 0
