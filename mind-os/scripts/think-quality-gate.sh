#!/bin/bash
# think-quality-gate.sh — 质量门控：从文档中 grep 计算评分，决定是否允许收敛
#
# Usage: ./think-quality-gate.sh <task-dir>
#
# 读取: manifest.md + verdict 文件 + comparison.md
# 输出: task-score.md + PASS/FAIL 判定
# FAIL 时: 输出改进建议 + 退出码 1

set -euo pipefail

TASK_DIR=${1:?"Usage: $0 <task-dir>"}
STATE_FILE="$TASK_DIR/state.yaml"
MANIFEST="$TASK_DIR/manifest.md"
COMPARISON="$TASK_DIR/comparison.md"
SCORE_FILE="$TASK_DIR/task-score.md"

read_yaml() { grep "^${2}:" "$1" 2>/dev/null | head -1 | sed "s/^${2}: *//" | tr -d '"'; }

MIN_SCORE=$(read_yaml "$STATE_FILE" "min_score")
MIN_SCORE=${MIN_SCORE:-0}
TASK_NAME=$(read_yaml "$STATE_FILE" "task")

# 如果 min_score=0，跳过评分
if [ "$MIN_SCORE" = "0" ]; then
    echo "GATE: skip (min_score=0)"
    exit 0
fi

echo "=== Quality Gate: $TASK_NAME (min_score=$MIN_SCORE) ==="

# ── D1 任务完成度：summary.md 或 comparison.md 是否存在且有结论 ──
D1=1
SUMMARY="$TASK_DIR/output/summary.md"
RECOMMEND=0; COMPARE=0
# 优先检查 output/summary.md（新模板），回退到 comparison.md（旧格式）
CHECK_FILE="$COMPARISON"
[ -f "$SUMMARY" ] && CHECK_FILE="$SUMMARY"
if [ -f "$CHECK_FILE" ]; then
    D1=3
    RECOMMEND=$(grep -ciE '推荐|recommend|一句话结论' "$CHECK_FILE" || true)
    [ "$RECOMMEND" -gt 0 ] && D1=4
    COMPARE=$(grep -c '方向' "$CHECK_FILE" || true)
    [ "$COMPARE" -ge 3 ] && D1=5
fi

# ── D2 分析深度：从所有 verdict 文件计算平均 confidence ──
TOTAL_S=0; TOTAL_F=0; TOTAL_M=0; ROUND_COUNT=0
for vf in "$TASK_DIR"/d*-verdict.md; do
    [ -f "$vf" ] || continue
    S=$(grep -c '\[SURVIVED:' "$vf" || true)
    F=$(grep -c '\[FALLEN:' "$vf" || true)
    M=$(grep -c '\[MODIFIED:' "$vf" || true)
    TOTAL_S=$((TOTAL_S + S))
    TOTAL_F=$((TOTAL_F + F))
    TOTAL_M=$((TOTAL_M + M))
    ROUND_COUNT=$((ROUND_COUNT + 1))
done

TOTAL_JUDGED=$((TOTAL_S + TOTAL_F + TOTAL_M))
if [ "$TOTAL_JUDGED" -gt 0 ]; then
    CONF_PCT=$((TOTAL_S * 100 / TOTAL_JUDGED))
else
    CONF_PCT=0
fi

# confidence% → D2 分数 (0-100% → 1-5)
D2=$(awk "BEGIN { d=int($CONF_PCT/20)+1; if(d>5)d=5; print d }")
# 多轮加分
[ "$ROUND_COUNT" -ge 4 ] && D2=$((D2 < 5 ? D2 + 1 : 5))

# ── D3 协议合规：检查文档结构 ──
D3_CHECKS=0
# 有蓝方编号
BLUE_IDS=$(grep -rlc '\[B-' "$TASK_DIR"/d*-blue.md 2>/dev/null | wc -l || true)
[ "$BLUE_IDS" -gt 0 ] && D3_CHECKS=$((D3_CHECKS + 1))

# 有红方 [NEW]/[REPEAT]
RED_MARKS=$(grep -rlc '\[NEW\]\|\[REPEAT:' "$TASK_DIR"/d*-red.md 2>/dev/null | wc -l || true)
[ "$RED_MARKS" -gt 0 ] && D3_CHECKS=$((D3_CHECKS + 1))

# 有本源检查
ORIGIN_CHECK=$(grep -rlc '本源检查\|本源裁决' "$TASK_DIR"/d*-red.md "$TASK_DIR"/d*-verdict.md 2>/dev/null | wc -l || true)
[ "$ORIGIN_CHECK" -gt 0 ] && D3_CHECKS=$((D3_CHECKS + 1))

# 有 SURVIVED/FALLEN 裁决
VERDICT_MARKS=$(grep -rlc '\[SURVIVED:\]\|\[FALLEN:\]' "$TASK_DIR"/d*-verdict.md 2>/dev/null | wc -l || true)
[ "$VERDICT_MARKS" -gt 0 ] && D3_CHECKS=$((D3_CHECKS + 1))

# 至少 1 轮完整蓝-红-裁决
BLUE_FILES=$(ls "$TASK_DIR"/d*-blue.md 2>/dev/null | wc -l || true)
RED_FILES=$(ls "$TASK_DIR"/d*-red.md 2>/dev/null | wc -l || true)
VERDICT_FILES=$(ls "$TASK_DIR"/d*-verdict.md 2>/dev/null | wc -l || true)
[ "$BLUE_FILES" -gt 0 ] && [ "$RED_FILES" -gt 0 ] && [ "$VERDICT_FILES" -gt 0 ] && D3_CHECKS=$((D3_CHECKS + 1))

# 输出模板合规（output/ 结构检查）
OUTPUT_DIR="$TASK_DIR/output"
TMPL_CHECKS=0
[ -f "$OUTPUT_DIR/summary.md" ] && TMPL_CHECKS=$((TMPL_CHECKS + 1))
SUMMARY_SIZE=0
[ -f "$OUTPUT_DIR/summary.md" ] && SUMMARY_SIZE=$(wc -c < "$OUTPUT_DIR/summary.md")
[ "$SUMMARY_SIZE" -gt 0 ] && [ "$SUMMARY_SIZE" -le 3000 ] && TMPL_CHECKS=$((TMPL_CHECKS + 1))  # ≤ ~800 tokens
DIR_FILES=$(ls "$OUTPUT_DIR"/direction-*.md 2>/dev/null | wc -l || true)
[ "$DIR_FILES" -gt 0 ] && TMPL_CHECKS=$((TMPL_CHECKS + 1))
[ -f "$OUTPUT_DIR/comparison.md" ] && TMPL_CHECKS=$((TMPL_CHECKS + 1))
# summary 有必选章节
[ -f "$OUTPUT_DIR/summary.md" ] && grep -q '一句话结论\|下一步行动' "$OUTPUT_DIR/summary.md" 2>/dev/null && TMPL_CHECKS=$((TMPL_CHECKS + 1))

D3_TOTAL=$((D3_CHECKS + TMPL_CHECKS))  # 总分 0-10
D3=$(awk "BEGIN { d=int($D3_TOTAL/2+0.5); if(d>5)d=5; if(d<1)d=1; print d }")  # 归一化到 1-5

# ── D4 效率：收敛轮次 ──
CURRENT_ROUND=$(read_yaml "$STATE_FILE" "current_round")
CURRENT_ROUND=${CURRENT_ROUND:-1}
D4=$(awk "BEGIN { d=5-($CURRENT_ROUND-1)*0.5; if(d<1)d=1; printf \"%.0f\", d }")

# ── D5 可行动性：summary 或 comparison 内容 ──
D5=1
D5_CHECK_FILE="$COMPARISON"
[ -f "$SUMMARY" ] && D5_CHECK_FILE="$SUMMARY"
D5_CHECKS=0
if [ -f "$D5_CHECK_FILE" ]; then
    grep -qiE '推荐|recommend' "$D5_CHECK_FILE" && D5_CHECKS=$((D5_CHECKS + 2))
    grep -qiE '下一步|next step|行动' "$D5_CHECK_FILE" && D5_CHECKS=$((D5_CHECKS + 2))
    grep -qiE '风险|risk|核心风险' "$D5_CHECK_FILE" && D5_CHECKS=$((D5_CHECKS + 1))
    D5=$D5_CHECKS
    [ "$D5" -gt 5 ] && D5=5
    [ "$D5" -lt 1 ] && D5=1
fi

# ── 计算总分 ──
TOTAL=$(awk "BEGIN { printf \"%.1f\", ($D1+$D2+$D3+$D4+$D5)/5 }")

# ── 写入评分文件 ──
cat > "$SCORE_FILE" << EOF
## 任务评分

task: "$TASK_NAME"
scored_at: "$(date -Iseconds)"
min_score: $MIN_SCORE

### 各维度（量化依据）
D1_completion: $D1 (comparison存在=${COMPARISON:+yes}, 推荐=${RECOMMEND:-0}处, 方向对比=${COMPARE:-0}处)
D2_depth: $D2 (confidence=${CONF_PCT}%, verdicts=$ROUND_COUNT个, survived=$TOTAL_S fallen=$TOTAL_F modified=$TOTAL_M)
D3_compliance: $D3 (编号=${BLUE_IDS:-0}, 标记=${RED_MARKS:-0}, 本源=${ORIGIN_CHECK:-0}, 裁决=${VERDICT_MARKS:-0}, 完整轮=${BLUE_FILES}b/${RED_FILES}r/${VERDICT_FILES}v)
D4_efficiency: $D4 (收敛轮次=$CURRENT_ROUND)
D5_actionability: $D5 (推荐=${D5_CHECKS:-0}项)

### 总分
total: $TOTAL
min_score: $MIN_SCORE
EOF

# ── 判定 ──
PASS=$(awk "BEGIN { print ($TOTAL >= $MIN_SCORE) ? 1 : 0 }")

if [ "$PASS" -eq 1 ]; then
    echo "verdict: PASS" >> "$SCORE_FILE"
    echo ""
    echo "GATE: PASS ($TOTAL >= $MIN_SCORE)"
    echo "  D1=$D1 D2=$D2 D3=$D3 D4=$D4 D5=$D5 → total=$TOTAL"
    exit 0
else
    # 找最低维度给改进建议
    IMPROVEMENTS=""
    [ "$D1" -le 2 ] && IMPROVEMENTS="${IMPROVEMENTS}\n  - D1(完成度=$D1): comparison 缺少对核心问题的直接回答"
    [ "$D2" -le 2 ] && IMPROVEMENTS="${IMPROVEMENTS}\n  - D2(深度=$D2): confidence=${CONF_PCT}% 过低，需加强红蓝对抗"
    [ "$D3" -le 2 ] && IMPROVEMENTS="${IMPROVEMENTS}\n  - D3(合规=$D3): 缺少编号/标记/本源检查，协议执行不规范"
    [ "$D5" -le 2 ] && IMPROVEMENTS="${IMPROVEMENTS}\n  - D5(可行动=$D5): 缺少明确推荐和下一步行动"

    echo "verdict: FAIL" >> "$SCORE_FILE"
    echo "improvements:$IMPROVEMENTS" >> "$SCORE_FILE"

    echo ""
    echo "GATE: FAIL ($TOTAL < $MIN_SCORE)"
    echo "  D1=$D1 D2=$D2 D3=$D3 D4=$D4 D5=$D5 → total=$TOTAL"
    echo -e "  改进建议:$IMPROVEMENTS"
    exit 1
fi
