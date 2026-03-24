#!/bin/bash
# hook-session-rating.sh — Stop hook: 会话结束时触发评分
#
# 检查条件:
#   1. queue.md 无 [TODO]（思考任务已完成）或无活跃思考任务
#   2. 非 stop_hook_active（防循环）
#
# 输出:
#   AI 自评 5 维分数 + 提示用户评分
#   写入 runtime/ratings/current.md

INPUT=$(cat)

# 防循环
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi

MIND_OS="mind-os-core"
RATINGS_DIR="$MIND_OS/runtime/ratings"
CURRENT="$RATINGS_DIR/current.md"
RUNTIME="$MIND_OS/runtime"

# 如果有活跃思考任务且有待办，不触发评分（让 stop-guard 处理）
for qf in "$RUNTIME"/thinking/*/queue.md; do
    [ -f "$qf" ] || continue
    TODO=$(grep -c '\[TODO\]\|\[DOING\]' "$qf" 2>/dev/null || true)
    if [ "$TODO" -gt 0 ]; then
        exit 0  # 交给 stop-guard 处理
    fi
done

# ── AI 自评（基于可量化事实）──

AI_D1=3  # 默认中等
AI_D2=3
AI_D3=3
AI_D4=3
AI_D5=3

# D3 协议合规: 检查 .must-run-active 是否存在（有 MUST_RUN 被激活过）
MUST_RUN_FILE="$RUNTIME/.must-run-active"
if [ -f "$MUST_RUN_FILE" ]; then
    PROTOCOLS=$(cat "$MUST_RUN_FILE")
    # 检查是否有 thinking 目录（说明迭代引擎执行了）
    if echo "$PROTOCOLS" | grep -q "iterative-engine"; then
        THINKING_EXISTS=false
        for td in "$RUNTIME"/thinking/*/state.yaml; do
            [ -f "$td" ] && THINKING_EXISTS=true && break
        done
        if [ "$THINKING_EXISTS" = true ]; then
            AI_D3=5  # 执行了
        else
            AI_D3=2  # 匹配了但没执行
        fi
    fi
fi

# D2 深度: 检查是否有 verdict 文件（红蓝对抗执行了）
VERDICT_COUNT=0
for vf in "$RUNTIME"/thinking/*/d*-verdict.md; do
    [ -f "$vf" ] && VERDICT_COUNT=$((VERDICT_COUNT + 1))
done
if [ "$VERDICT_COUNT" -ge 3 ]; then
    AI_D2=5
elif [ "$VERDICT_COUNT" -ge 1 ]; then
    AI_D2=4
fi

# 计算 AI 均分（整数百分制避免浮点）
AI_SUM=$((AI_D1 + AI_D2 + AI_D3 + AI_D4 + AI_D5))
AI_AVG_X10=$((AI_SUM * 10 / 5))  # 乘10保留一位小数
AI_AVG_INT=$((AI_AVG_X10 / 10))
AI_AVG_DEC=$((AI_AVG_X10 % 10))

# ── 输出评分提示 ──

TIMESTAMP=$(date '+%m-%d %H:%M')

cat << EOF
────────────────────────────────────
📊 会话评分（Mind OS v5.0）

AI 自评: D1=$AI_D1 D2=$AI_D2 D3=$AI_D3 D4=$AI_D4 D5=$AI_D5 (均分 ${AI_AVG_INT}.${AI_AVG_DEC})

请为本次会话打分（每项 1-5 分）：
  D1 任务完成度:  核心诉求是否解决？
  D2 分析深度:    是否触及本源？
  D3 协议合规:    MUST_RUN 是否执行？
  D4 效率:        是否简洁直接？
  D5 可行动性:    结论是否可执行？

输入格式: 5 个数字空格分隔（如 "4 3 5 4 5"）
输入 skip 跳过人类评分（仅用 AI 评分）
────────────────────────────────────
EOF

# 写入 AI 评分到临时文件供后续合并
mkdir -p "$RATINGS_DIR"
cat > "$RATINGS_DIR/.pending-ai-score" << EOF2
timestamp: $TIMESTAMP
ai_d1: $AI_D1
ai_d2: $AI_D2
ai_d3: $AI_D3
ai_d4: $AI_D4
ai_d5: $AI_D5
ai_avg: ${AI_AVG_INT}.${AI_AVG_DEC}
EOF2

# 告诉 Claude 需要收集用户评分
echo ""
echo "ACTION: collect_human_rating"
echo "AI_SCORES: $AI_D1 $AI_D2 $AI_D3 $AI_D4 $AI_D5"

exit 0
