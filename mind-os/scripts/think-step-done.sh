#!/bin/bash
# think-step-done.sh — mark current step [DONE], update context + log
#
# Usage:
#   ./think-step-done.sh <task-dir> <summary>
#   ./think-step-done.sh runtime/thinking/task-001 "d1 blue: origin=career, 3 points"

set -euo pipefail

TASK_DIR=${1:?"Usage: $0 <task-dir> <summary>"}
SUMMARY=${2:-"(no summary)"}
QUEUE_FILE="$TASK_DIR/queue.md"
LOG_FILE="$TASK_DIR/log.md"
CONTEXT_FILE="$TASK_DIR/context.md"

# find [DOING] step
STEP_LINE=$(grep -n '\[DOING\]' "$QUEUE_FILE" 2>/dev/null | head -1 | cut -d: -f1)

if [ -z "$STEP_LINE" ]; then
    echo "WARNING: no [DOING] step found"
    exit 1
fi

STEP_ID=$(sed -n "${STEP_LINE}p" "$QUEUE_FILE" | grep -o 'STEP-[0-9]*')

# mark [DOING] → [DONE]
sed -i "${STEP_LINE}s/\[DOING\]/[DONE]/" "$QUEUE_FILE"

# append log
echo "| $(date '+%H:%M') | $STEP_ID | $SUMMARY |" >> "$LOG_FILE"

# count remaining
REMAINING=$(grep -c '\[TODO\]' "$QUEUE_FILE" 2>/dev/null || echo 0)

# update context.md progress section
if [ -f "$CONTEXT_FILE" ]; then
    NEXT_TODO=$(grep '\[TODO\]' "$QUEUE_FILE" | head -1 | sed 's/.*### //')
    if [ "$REMAINING" -eq 0 ]; then
        PROGRESS="All steps done, generating comparison report"
    else
        PROGRESS="Next: $NEXT_TODO (remaining: $REMAINING)"
    fi
    # simple: append latest finding
    echo "- [$STEP_ID] $SUMMARY" >> "$CONTEXT_FILE"
fi

echo "OK $STEP_ID [DONE] | remaining: $REMAINING"
