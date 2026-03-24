#!/bin/bash
# think-rating-write.sh — 写入评分 + 滚动压缩
#
# Usage:
#   ./think-rating-write.sh <任务摘要> <H1> <H2> <H3> <H4> <H5>
#   ./think-rating-write.sh "换工作分析" 4 5 5 4 4
#   ./think-rating-write.sh "换工作分析" skip       # 仅 AI 评分
#
# 从 .pending-ai-score 读取 AI 评分，与人类评分加权合并
# 写入 current.md，超限时滚动压缩

set -euo pipefail

TASK_SUMMARY=${1:?"Usage: $0 <task-summary> <H1> <H2> <H3> <H4> <H5>"}
shift

MIND_OS="mind-os-core"
RATINGS_DIR="$MIND_OS/runtime/ratings"
CURRENT="$RATINGS_DIR/current.md"
PENDING="$RATINGS_DIR/.pending-ai-score"

mkdir -p "$RATINGS_DIR"

# ── 读取 AI 评分 ──

if [ ! -f "$PENDING" ]; then
    echo "ERROR: no pending AI score"
    exit 1
fi

# 提取值：取冒号后的数字（awk 精确提取，不误匹配字段名中的数字）
AI_D1=$(awk -F': ' '/^ai_d1:/{print $2}' "$PENDING" | tr -d '\r\n ')
AI_D2=$(awk -F': ' '/^ai_d2:/{print $2}' "$PENDING" | tr -d '\r\n ')
AI_D3=$(awk -F': ' '/^ai_d3:/{print $2}' "$PENDING" | tr -d '\r\n ')
AI_D4=$(awk -F': ' '/^ai_d4:/{print $2}' "$PENDING" | tr -d '\r\n ')
AI_D5=$(awk -F': ' '/^ai_d5:/{print $2}' "$PENDING" | tr -d '\r\n ')
TIMESTAMP=$(awk -F': ' '/^timestamp:/{print $2}' "$PENDING" | tr -d '\r\n')

# ── 读取人类评分 ──

HUMAN_SKIP=false
if [ "$1" = "skip" ] 2>/dev/null; then
    HUMAN_SKIP=true
    H1=$AI_D1; H2=$AI_D2; H3=$AI_D3; H4=$AI_D4; H5=$AI_D5
else
    H1=${1:-3}; H2=${2:-3}; H3=${3:-3}; H4=${4:-3}; H5=${5:-3}
fi

# ── 加权计算: final = human × 0.6 + ai × 0.4（用 awk 做浮点）──

calc_all() {
    awk -v h1="$H1" -v h2="$H2" -v h3="$H3" -v h4="$H4" -v h5="$H5" \
        -v a1="$AI_D1" -v a2="$AI_D2" -v a3="$AI_D3" -v a4="$AI_D4" -v a5="$AI_D5" \
    'BEGIN {
        f1 = h1*0.6 + a1*0.4; f2 = h2*0.6 + a2*0.4; f3 = h3*0.6 + a3*0.4
        f4 = h4*0.6 + a4*0.4; f5 = h5*0.6 + a5*0.4
        h_avg = (h1+h2+h3+h4+h5) / 5
        a_avg = (a1+a2+a3+a4+a5) / 5
        f_avg = (f1+f2+f3+f4+f5) / 5
        printf "%.1f %.1f %.1f %.1f %.1f %.1f %.1f %.1f", f1, f2, f3, f4, f5, h_avg, a_avg, f_avg
    }'
}

CALC=$(calc_all)
read F1 F2 F3 F4 F5 H_AVG AI_AVG F_AVG <<< "$CALC"

# ── 初始化评分表（如不存在）──

if [ ! -f "$CURRENT" ]; then
    cat > "$CURRENT" << EOF
# 会话评分表

> 创建时间: $(date '+%Y-%m-%d')
> 记录数: 0
> 历史均分: -

| 日期 | 任务摘要 | D1 | D2 | D3 | D4 | D5 | H均 | AI均 | 总分 |
|------|---------|----|----|----|----|-----|-----|------|------|
EOF
fi

# ── 追加记录 ──

if [ "$HUMAN_SKIP" = true ]; then
    H_DISPLAY="skip"
else
    H_DISPLAY="$H_AVG"
fi

echo "| $TIMESTAMP | $TASK_SUMMARY | $F1 | $F2 | $F3 | $F4 | $F5 | $H_DISPLAY | $AI_AVG | $F_AVG |" >> "$CURRENT"

# 更新记录数
OLD_COUNT=$(grep '> 记录数:' "$CURRENT" | grep -o '[0-9]*' || echo 0)
NEW_COUNT=$((OLD_COUNT + 1))
sed -i "s/> 记录数: $OLD_COUNT/> 记录数: $NEW_COUNT/" "$CURRENT"

# ── 滚动压缩检查 ──

FILE_SIZE=$(wc -c < "$CURRENT")
if [ "$FILE_SIZE" -gt 3000 ]; then
    echo "⚠️ 评分表达到 ${FILE_SIZE} bytes，执行滚动压缩..."

    # 计算所有记录的均分
    # 提取所有数据行（跳过表头和 header）
    DATA_LINES=$(grep '^|' "$CURRENT" | grep -v '日期\|---')
    TOTAL_RECORDS=$(echo "$DATA_LINES" | wc -l)

    if [ "$TOTAL_RECORDS" -gt 0 ]; then
        # 用 awk 计算各列均分
        AVGS=$(echo "$DATA_LINES" | awk -F'|' '{
            d1+=$4; d2+=$5; d3+=$6; d4+=$7; d5+=$8; n++
        } END {
            if(n>0) printf "%d %d %d %d %d %.1f", d1/n+0.5, d2/n+0.5, d3/n+0.5, d4/n+0.5, d5/n+0.5, (d1+d2+d3+d4+d5)/(n*5)
            else print "3 3 3 3 3 3.0"
        }')

        read AVG_D1 AVG_D2 AVG_D3 AVG_D4 AVG_D5 AVG_TOTAL <<< "$AVGS"

        # 归档原始数据
        ARCHIVE="$RATINGS_DIR/archive-$(date '+%Y-%m').md"
        echo "" >> "$ARCHIVE"
        echo "## 压缩归档 $(date '+%Y-%m-%d %H:%M') ($TOTAL_RECORDS 条)" >> "$ARCHIVE"
        grep '^|' "$CURRENT" >> "$ARCHIVE"

        # 重置 current.md
        cat > "$CURRENT" << EOF
# 会话评分表

> 创建时间: $(date '+%Y-%m-%d')
> 记录数: 0
> 历史均分: $AVG_TOTAL（基于 $TOTAL_RECORDS 条历史记录）
> 上次压缩: $(date '+%Y-%m-%d %H:%M')

| 日期 | 任务摘要 | D1 | D2 | D3 | D4 | D5 | H均 | AI均 | 总分 |
|------|---------|----|----|----|----|-----|-----|------|------|
| 历史均分 | ${TOTAL_RECORDS}条压缩 | $AVG_D1 | $AVG_D2 | $AVG_D3 | $AVG_D4 | $AVG_D5 | - | - | $AVG_TOTAL |
EOF
        echo "✅ 压缩完成: $TOTAL_RECORDS 条 → 均分行 | 原始数据归档到 $ARCHIVE"
    fi
else
    echo "✅ 评分已记录: $TASK_SUMMARY → 总分 $F_AVG (H=$H_AVG AI=$AI_AVG)"
fi

# 清理临时文件
rm -f "$PENDING"
