#!/bin/bash
# think-converge-check.sh — 质量驱动收敛检查（精确量化，grep 编号计算）
#
# 从 blue/red/verdict 文件中 grep 编号标签，计算精确指标
# 不依赖 AI 自报数字，所有指标由文档结构机械可数
#
# Usage: ./think-converge-check.sh <task-dir> <round>

set -euo pipefail

TASK_DIR=${1:?"Usage: $0 <task-dir> <round>"}
ROUND=${2:-1}

STATE_FILE="$TASK_DIR/state.yaml"
QUEUE_FILE="$TASK_DIR/queue.md"
LOG_FILE="$TASK_DIR/log.md"

read_yaml() { grep "^${2}:" "$1" 2>/dev/null | head -1 | sed "s/^${2}: *//" | tr -d '"'; }

EMERGENCY=$(read_yaml "$STATE_FILE" "emergency_brake")
EMERGENCY=${EMERGENCY:-10}
DIRECTIONS=$(read_yaml "$STATE_FILE" "directions_count")
DIRECTIONS=${DIRECTIONS:-1}

echo "=== Converge Check: Round $ROUND (grep-based metrics) ==="
echo ""

ACTIVE_DIRECTIONS=""
CONVERGED_COUNT=0
NEXT_ROUND=$((ROUND + 1))
NEED_NEXT_ROUND=false

for d in $(seq 1 "$DIRECTIONS"); do
    BLUE="$TASK_DIR/d${d}-round-${ROUND}-blue.md"
    RED="$TASK_DIR/d${d}-round-${ROUND}-red.md"
    VERDICT="$TASK_DIR/d${d}-round-${ROUND}-verdict.md"

    # 跳过非活跃方向（无本轮文件）
    if [ ! -f "$RED" ] && [ "$ROUND" -gt 1 ]; then
        echo "  d$d: SKIP (no round $ROUND files)"
        continue
    fi

    # ── grep 计算指标 ──

    RED_NEW=0; RED_REPEAT=0; FATAL_TOTAL=0
    BLUE_RESP=0; BLUE_NO_RESP=0; BLUE_POINTS=0
    SURVIVED=0; FALLEN=0; MODIFIED=0; OPEN=0

    [ -f "$RED" ] && RED_NEW=$(grep -c '\[NEW\]' "$RED" || true)
    [ -f "$RED" ] && RED_REPEAT=$(grep -c '\[REPEAT:' "$RED" || true)
    [ -f "$RED" ] && FATAL_TOTAL=$(grep -c '\[致命\]' "$RED" || true)

    [ -f "$BLUE" ] && BLUE_POINTS=$(grep -c '\[B-' "$BLUE" || true)
    [ -f "$BLUE" ] && BLUE_RESP=$(grep -c '\[RESP:' "$BLUE" || true)
    [ -f "$BLUE" ] && BLUE_NO_RESP=$(grep -c '\[NO-RESP:' "$BLUE" || true)

    [ -f "$VERDICT" ] && SURVIVED=$(grep -c '\[SURVIVED:' "$VERDICT" || true)
    [ -f "$VERDICT" ] && FALLEN=$(grep -c '\[FALLEN:' "$VERDICT" || true)
    [ -f "$VERDICT" ] && MODIFIED=$(grep -c '\[MODIFIED:' "$VERDICT" || true)
    [ -f "$VERDICT" ] && OPEN=$(grep -c '\[OPEN-' "$VERDICT" || true)

    # confidence = survived / (survived + fallen + modified)
    TOTAL_JUDGED=$((SURVIVED + FALLEN + MODIFIED))
    if [ "$TOTAL_JUDGED" -gt 0 ]; then
        # 用整数百分比避免浮点
        CONFIDENCE_PCT=$((SURVIVED * 100 / TOTAL_JUDGED))
    else
        CONFIDENCE_PCT=0
    fi

    # fatal_unresolved: 致命质疑中未被 RESP 的
    FATAL_UNRESOLVED=0
    if [ -f "$RED" ] && [ "$FATAL_TOTAL" -gt 0 ]; then
        # 提取致命质疑的 ID
        FATAL_IDS=$(grep '\[致命\]' "$RED" | grep -o '\[R-[^]]*\]' || true)
        for fid in $FATAL_IDS; do
            CLEAN_ID=$(echo "$fid" | tr -d '[]')
            if [ -f "$BLUE" ]; then
                RESP_FOUND=$(grep -c "\[RESP:$CLEAN_ID\]" "$BLUE" || true)
            else
                RESP_FOUND=0
            fi
            [ "$RESP_FOUND" -eq 0 ] && FATAL_UNRESOLVED=$((FATAL_UNRESOLVED + 1))
        done
    fi

    # 上轮 confidence（用于 plateau 检测）
    PREV_CONF_PCT="-1"
    if [ "$ROUND" -gt 1 ]; then
        PREV_VERDICT="$TASK_DIR/d${d}-round-$((ROUND - 1))-verdict.md"
        if [ -f "$PREV_VERDICT" ]; then
            PS=$(grep -c '\[SURVIVED:' "$PREV_VERDICT" || true)
            PF=$(grep -c '\[FALLEN:' "$PREV_VERDICT" || true)
            PM=$(grep -c '\[MODIFIED:' "$PREV_VERDICT" || true)
            PT=$((PS + PF + PM))
            [ "$PT" -gt 0 ] && PREV_CONF_PCT=$((PS * 100 / PT)) || PREV_CONF_PCT=0
        fi
    fi

    # ── 输出指标 ──

    echo "  d$d metrics:"
    echo "    red:    new=$RED_NEW repeat=$RED_REPEAT fatal=$FATAL_TOTAL fatal_unresolved=$FATAL_UNRESOLVED"
    echo "    blue:   points=$BLUE_POINTS resp=$BLUE_RESP no_resp=$BLUE_NO_RESP"
    echo "    verdict: survived=$SURVIVED fallen=$FALLEN modified=$MODIFIED open=$OPEN"
    echo "    confidence: ${CONFIDENCE_PCT}% (prev: ${PREV_CONF_PCT}%)"

    # ── 收敛判定（优先级：排除 > 收敛）──

    CONVERGE_REASON=""

    # 1. blue_no_defense（优先：蓝方完全放弃 = 方向淘汰）
    if [ "$BLUE_NO_RESP" -gt 0 ] && [ "$BLUE_RESP" -eq 0 ]; then
        CONVERGE_REASON="blue_no_defense(no_resp=$BLUE_NO_RESP,resp=0)"
    fi

    # 2. fatal_deadlock（致命质疑未回应 = 方向淘汰，第2轮起）
    if [ -z "$CONVERGE_REASON" ] && [ "$FATAL_UNRESOLVED" -gt 0 ] && [ "$ROUND" -gt 1 ]; then
        CONVERGE_REASON="fatal_deadlock(fatal_unresolved=$FATAL_UNRESOLVED)"
    fi

    # 3. red_exhausted（红方无新弹药 = 经受住检验）
    if [ -z "$CONVERGE_REASON" ] && [ "$RED_NEW" -eq 0 ] && [ "$ROUND" -gt 0 ]; then
        CONVERGE_REASON="red_exhausted(red_new=0)"
    fi

    # 4. confidence_plateau: |current - prev| < 5%（连续2轮）
    if [ -z "$CONVERGE_REASON" ] && [ "$PREV_CONF_PCT" -ge 0 ] && [ "$ROUND" -gt 1 ]; then
        CONF_DELTA=$((CONFIDENCE_PCT - PREV_CONF_PCT))
        [ "$CONF_DELTA" -lt 0 ] && CONF_DELTA=$((-CONF_DELTA))
        if [ "$CONF_DELTA" -lt 5 ]; then
            CONVERGE_REASON="confidence_plateau(delta=${CONF_DELTA}%<5%)"
        fi
    fi

    # 5. all_resolved: open==0 且 fatal_unresolved==0 且 red_new==0（第2轮起）
    if [ -z "$CONVERGE_REASON" ] && [ "$OPEN" -eq 0 ] && [ "$FATAL_UNRESOLVED" -eq 0 ] && [ "$RED_NEW" -eq 0 ] && [ "$ROUND" -gt 1 ]; then
        CONVERGE_REASON="all_resolved(open=0,fatal=0,red_new=0)"
    fi

    # 6. emergency_brake
    if [ -z "$CONVERGE_REASON" ] && [ "$ROUND" -ge "$EMERGENCY" ]; then
        CONVERGE_REASON="emergency_brake(round=$ROUND>=$EMERGENCY)"
    fi

    # ── 判定输出 ──

    if [ -n "$CONVERGE_REASON" ]; then
        if echo "$CONVERGE_REASON" | grep -q "deadlock\|no_defense"; then
            echo "    → EXCLUDED: $CONVERGE_REASON"
        else
            echo "    → CONVERGED: $CONVERGE_REASON"
        fi
        CONVERGED_COUNT=$((CONVERGED_COUNT + 1))
    else
        echo "    → ACTIVE (continuing to round $NEXT_ROUND)"
        ACTIVE_DIRECTIONS="${ACTIVE_DIRECTIONS} d$d"
        NEED_NEXT_ROUND=true
    fi
    echo ""
done

echo "Summary: converged=$CONVERGED_COUNT/$DIRECTIONS"

# ── 动态追加下一轮 ──

if [ "$NEED_NEXT_ROUND" = true ]; then
    echo "→ Appending Round $NEXT_ROUND for:$ACTIVE_DIRECTIONS"

    LAST_STEP=$(grep -o 'STEP-[0-9]*' "$QUEUE_FILE" | tail -1 | grep -o '[0-9]*' | sed 's/^0*//')
    [ -z "$LAST_STEP" ] && LAST_STEP=0
    STEP=$((LAST_STEP + 1))

    {
    echo ""
    echo "## --- Round $NEXT_ROUND (dynamic) ---"

    for d in $ACTIVE_DIRECTIONS; do
        echo ""
        echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: blue-r${NEXT_ROUND}}"
        echo "- type: blue"
        echo "- direction: $d"
        echo "- round: $NEXT_ROUND"
        STEP=$((STEP + 1))
    done

    for d in $ACTIVE_DIRECTIONS; do
        echo ""
        echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: red-r${NEXT_ROUND}}"
        echo "- type: red"
        echo "- direction: $d"
        echo "- round: $NEXT_ROUND"
        STEP=$((STEP + 1))
    done

    for d in $ACTIVE_DIRECTIONS; do
        echo ""
        echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: verdict-r${NEXT_ROUND}}"
        echo "- type: verdict"
        echo "- direction: $d"
        echo "- round: $NEXT_ROUND"
        STEP=$((STEP + 1))
    done

    echo ""
    echo "### STEP-$(printf '%03d' $STEP) [TODO]"
    echo "- type: converge_check"
    echo "- round: $NEXT_ROUND"
    } >> "$QUEUE_FILE"

    echo "| $(date '+%H:%M') | converge-r$ROUND | Active:$ACTIVE_DIRECTIONS → R$NEXT_ROUND |" >> "$LOG_FILE"
else
    echo "→ All converged! Appending comparison step."

    LAST_STEP=$(grep -o 'STEP-[0-9]*' "$QUEUE_FILE" | tail -1 | grep -o '[0-9]*' | sed 's/^0*//')
    [ -z "$LAST_STEP" ] && LAST_STEP=0

    echo "" >> "$QUEUE_FILE"
    echo "### STEP-$(printf '%03d' $((LAST_STEP + 1))) [TODO]" >> "$QUEUE_FILE"
    echo "- type: comparison" >> "$QUEUE_FILE"

    echo "| $(date '+%H:%M') | converge-r$ROUND | All converged → comparison |" >> "$LOG_FILE"
fi
