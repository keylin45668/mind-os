#!/bin/bash
# think-orchestrator.sh — queue-driven orchestrator with compression recovery
#
# Usage:  ./think-orchestrator.sh <task-dir>
# Stop hook: blocks stop if queue has [TODO] steps
# PostCompact hook: prompts to read context.md for recovery

set -euo pipefail

TASK_DIR=${1:?"Usage: $0 <task-dir>"}
STATE_FILE="$TASK_DIR/state.yaml"
QUEUE_FILE="$TASK_DIR/queue.md"
WAIT_FILE="$TASK_DIR/.wait_status"

read_yaml() { grep "^${2}:" "$1" 2>/dev/null | head -1 | sed "s/^${2}: *//" | tr -d '"'; }
log() { echo "[$(date '+%H:%M:%S')] $1"; }

# ─── pre-checks ──────────────────────────────────
[ ! -f "$STATE_FILE" ] || [ ! -f "$QUEUE_FILE" ] && { echo "ACTION: need_init"; exit 0; }

STATUS=$(read_yaml "$STATE_FILE" "status")
TASK_NAME=$(basename "$TASK_DIR")
AUTO_REPLY=$(read_yaml "$STATE_FILE" "auto_reply"); AUTO_REPLY=${AUTO_REPLY:-ai_decide}

# ─── terminal states ─────────────────────────────
if [ "$STATUS" = "converged" ]; then
    [ -f "$TASK_DIR/comparison.md" ] && { log "DONE: $TASK_DIR/comparison.md"; echo "ACTION: done"; exit 0; }
    echo "ACTION: run_comparison"; echo "TASK_DIR: $TASK_DIR"; exit 0
fi
[ "$STATUS" = "aborted" ] && { echo "ACTION: aborted"; exit 0; }

# ─── waiting state ────────────────────────────────
if [ "$STATUS" = "waiting" ]; then
    WS="waiting"; [ -f "$WAIT_FILE" ] && WS=$(cat "$WAIT_FILE")
    CR=$(read_yaml "$STATE_FILE" "current_round"); UI="$TASK_DIR/user-input-r${CR}.md"
    case "$WS" in
        answered) [ -f "$UI" ] || { echo "ACTION: still_waiting"; exit 0; }
                  sed -i 's/^status: waiting/status: running/' "$STATE_FILE" ;;
        skipped|timeout) echo "# $WS, strategy=$AUTO_REPLY" > "$UI"
                  sed -i 's/^status: waiting/status: running/' "$STATE_FILE" ;;
        *) echo "ACTION: still_waiting"; exit 0 ;;
    esac
fi

# ─── pick next step from queue ────────────────────
STEP_LINE=$(grep -n '\[DOING\]' "$QUEUE_FILE" | head -1 | cut -d: -f1 || true)

if [ -z "$STEP_LINE" ]; then
    TODO_LINE=$(grep -n '\[TODO\]' "$QUEUE_FILE" | head -1 | cut -d: -f1 || true)
    if [ -z "$TODO_LINE" ]; then
        log "queue empty"
        sed -i 's/^status: running/status: converged/' "$STATE_FILE"
        echo "ACTION: run_comparison"; echo "TASK_DIR: $TASK_DIR"; exit 0
    fi
    sed -i "${TODO_LINE}s/\[TODO\]/[DOING]/" "$QUEUE_FILE"
    STEP_LINE=$TODO_LINE
fi

# parse step block
STEP_ID=$(sed -n "${STEP_LINE}p" "$QUEUE_FILE" | grep -o 'STEP-[0-9]*')
END=$((STEP_LINE + 8))
BLOCK=$(sed -n "${STEP_LINE},${END}p" "$QUEUE_FILE")

# extract fields (try English then Chinese field names)
extract() { echo "$BLOCK" | grep -m1 "$1" | sed "s/.*$1 *//"; }
STEP_TYPE=$(extract "type:"); [ -z "$STEP_TYPE" ] && STEP_TYPE=$(extract "类型:")
STEP_DIR_ID=$(extract "direction:"); [ -z "$STEP_DIR_ID" ] && STEP_DIR_ID=$(extract "方向:")
STEP_ROUND=$(extract "round:"); [ -z "$STEP_ROUND" ] && STEP_ROUND=$(extract "轮次:")

# ─── dispatch ─────────────────────────────────────
case "$STEP_TYPE" in
    user_ask) log "[$TASK_NAME] $STEP_ID: ask user"
              sed -i 's/^status: running/status: waiting/' "$STATE_FILE"
              echo "waiting" > "$WAIT_FILE"
              echo "ACTION: ask_user" ;;
    blue)     log "[$TASK_NAME] $STEP_ID: BLUE $STEP_DIR_ID R$STEP_ROUND"
              echo "ACTION: run_blue" ;;
    red)      log "[$TASK_NAME] $STEP_ID: RED $STEP_DIR_ID R$STEP_ROUND"
              echo "ACTION: run_red" ;;
    verdict)  log "[$TASK_NAME] $STEP_ID: VERDICT $STEP_DIR_ID R$STEP_ROUND"
              echo "ACTION: run_verdict" ;;
    converge_check) log "[$TASK_NAME] $STEP_ID: converge check R$STEP_ROUND"
              echo "ACTION: converge_check" ;;
    comparison) log "[$TASK_NAME] $STEP_ID: comparison"
              echo "ACTION: run_comparison" ;;
    *)        log "unknown: $STEP_TYPE"; echo "ACTION: unknown" ;;
esac

echo "STEP: $STEP_ID"
echo "DIRECTION: ${STEP_DIR_ID:-none}"
echo "ROUND: ${STEP_ROUND:-0}"
echo "TASK_DIR: $TASK_DIR"
