#!/bin/bash
# hook-post-compact.sh — PostCompact hook: 上下文压缩后注入恢复指令
#
# 扫描 runtime/thinking/ 找活跃任务，注入恢复提示

MIND_OS_DIR="mind-os"
THINKING_DIR="$MIND_OS_DIR/runtime/thinking"

# 找活跃任务
ACTIVE_TASK=""
CONTEXT_FILE=""

if [ -d "$THINKING_DIR" ]; then
    for state_file in "$THINKING_DIR"/*/state.yaml; do
        [ -f "$state_file" ] || continue
        STATUS=$(grep "^status:" "$state_file" | head -1 | sed 's/^status: *//' | tr -d '"')
        if [ "$STATUS" = "running" ] || [ "$STATUS" = "waiting" ]; then
            TASK_DIR=$(dirname "$state_file")
            ACTIVE_TASK=$(basename "$TASK_DIR")
            CONTEXT_FILE="$TASK_DIR/context.md"
            break
        fi
    done
fi

if [ -n "$ACTIVE_TASK" ] && [ -f "$CONTEXT_FILE" ]; then
    echo "上下文已压缩。你正在执行迭代思考任务「$ACTIVE_TASK」。请立即读取以下文件恢复工作状态："
    echo "1. $CONTEXT_FILE（关键发现和进度摘要）"
    echo "2. $THINKING_DIR/$ACTIVE_TASK/queue.md（工作队列，找 [TODO] 或 [DOING] 继续）"
    echo "3. $THINKING_DIR/$ACTIVE_TASK/state.yaml（完整状态）"
else
    echo "上下文已压缩。如有进行中的任务，请检查 mind-os/runtime/thinking/ 目录。"
fi

exit 0
