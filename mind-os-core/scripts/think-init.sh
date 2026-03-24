#!/bin/bash
# think-init.sh — 初始化迭代思考任务（创建 state.yaml + manifest.md）
#
# 用法:
#   ./think-init.sh <任务名> [completeness] [strategy] [timeout]
#   ./think-init.sh "换工作分析" 0.5 ai_decide 120
#
# 由初始化 Agent 调用，或用户手动创建任务

set -euo pipefail

TASK_NAME=${1:?"用法: $0 <任务名> [completeness] [strategy] [timeout] [min_score]"}
COMPLETENESS=${2:-0.5}
STRATEGY=${3:-ai_decide}
TIMEOUT=${4:-120}
MIN_SCORE=${5:-0}   # 0=不设门控，1-5=必须达到此分才能收敛

# 计算校准参数（纯 awk，不依赖 bc）
# directions = ceil(5 × (1 - completeness))，min=1 max=5
DIRECTIONS=$(awk "BEGIN {
    v = 5 * (1 - $COMPLETENESS);
    c = int(v) + (v > int(v) ? 1 : 0);
    if (c < 1) c = 1;
    if (c > 5) c = 5;
    print c
}")

# max_rounds = 2 + ceil(2 × (1 - completeness))，min=2 max=4
MAX_ROUNDS=$(awk "BEGIN {
    v = 2 * (1 - $COMPLETENESS);
    c = int(v) + (v > int(v) ? 1 : 0);
    r = 2 + c;
    if (r > 4) r = 4;
    print r
}")

# 创建任务目录（锚定到脚本所在目录的上级，即 mind-os-core/）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASK_DIR="$SCRIPT_DIR/../runtime/thinking/$TASK_NAME"
mkdir -p "$TASK_DIR"

# 写 state.yaml
cat > "$TASK_DIR/state.yaml" << EOF
task: "$TASK_NAME"
created: "$(date -Iseconds)"
status: running

completeness: $COMPLETENESS
directions_count: $DIRECTIONS
emergency_brake: 50
min_score: $MIN_SCORE
quality_scores: []

directions: []
# 方向由首轮蓝方 Agent 填充，格式:
#   - id: d1
#     label: "方向描述"
#     status: active       # active / converged / excluded
#     phase: blue          # blue / red / verdict / done
#     current_round: 1
#     confidence: 0
#     confidence_history: []
#     red_novelty_history: []
#     blue_delta_history: []
#     open_issues: 0
#     fatal_unresolved: 0
#     converge_reason: ""   # red_exhausted / blue_exhausted / confidence_plateau / fatal_deadlock / user_confirm / no_open_issues / emergency_brake

current_round: 1
rounds_completed: 0

pending_questions: []
user_responses: {}

auto_reply: "$STRATEGY"
timeout: $TIMEOUT
EOF

# 写 manifest.md
cat > "$TASK_DIR/manifest.md" << EOF
# $TASK_NAME

## 任务参数

- 信息完整度: $COMPLETENESS
- 方向数: $DIRECTIONS
- 收敛方式: 质量驱动（安全阀: 50轮）
- 预设策略: $STRATEGY
- 超时: ${TIMEOUT}s

## 原始输入

> （由初始化 Agent 写入用户原始问题）

## 方向定义

> （由第一轮 Agent 写入各方向描述）
EOF

# 生成初始 queue.md（仅 Round 1，后续轮次由收敛检查动态追加）
STEP=1
{
echo "## 工作队列"
echo ""
echo "> 后续轮次由 converge_check 动态追加，不预生成（因为不知道要跑几轮）"
echo ""
echo "### STEP-$(printf '%03d' $STEP) [TODO]"
echo "- type: user_ask"
echo "- round: 1"
STEP=$((STEP + 1))

# 蓝方——同层并行
for d in $(seq 1 "$DIRECTIONS"); do
  echo ""
  echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: blue-r1}"
  echo "- type: blue"
  echo "- direction: d$d"
  echo "- round: 1"
  echo "- output: d${d}-round-1-blue.md"
  STEP=$((STEP + 1))
done

# 红方——同层并行（依赖蓝方完成）
for d in $(seq 1 "$DIRECTIONS"); do
  echo ""
  echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: red-r1}"
  echo "- type: red"
  echo "- direction: d$d"
  echo "- round: 1"
  echo "- input: d${d}-round-1-blue.md"
  echo "- output: d${d}-round-1-red.md"
  STEP=$((STEP + 1))
done

# 裁决——同层并行（依赖蓝+红完成）
for d in $(seq 1 "$DIRECTIONS"); do
  echo ""
  echo "### STEP-$(printf '%03d' $STEP) [TODO] {parallel: verdict-r1}"
  echo "- type: verdict"
  echo "- direction: d$d"
  echo "- round: 1"
  echo "- input: d${d}-round-1-blue.md + d${d}-round-1-red.md"
  echo "- output: d${d}-round-1-verdict.md"
  STEP=$((STEP + 1))
done

# 收敛检查
echo ""
echo "### STEP-$(printf '%03d' $STEP) [TODO]"
echo "- type: converge_check"
echo "- round: 1"
echo "- note: check quality metrics in verdicts; if not converged, append round 2 steps"
} > "$TASK_DIR/queue.md"

# 写 context.md（压缩恢复用）
cat > "$TASK_DIR/context.md" << EOF
## 压缩恢复上下文

> 上下文被压缩时，读此文件 + state.yaml + queue.md 即可恢复。

### 任务
$TASK_NAME（completeness=$COMPLETENESS → ${DIRECTIONS}方向 × 质量驱动收敛 × 红蓝对抗）

### 当前进度
刚初始化，Round 1 尚未开始

### 关键发现
（执行过程中由 Agent 更新）

### 下一步
读取 queue.md，执行第一个 [TODO] 步骤
EOF

# 写 log.md
cat > "$TASK_DIR/log.md" << EOF
## 执行日志

| 时间 | 步骤 | 结果摘要 |
|------|------|---------|
| $(date '+%H:%M') | init | 任务创建: ${DIRECTIONS}方向, 质量驱动收敛, 策略=$STRATEGY |
EOF

echo "✅ 任务已创建: $TASK_DIR"
echo "   方向数=$DIRECTIONS  收敛=质量驱动  策略=$STRATEGY"
echo "   queue: $(grep -c 'TODO' "$TASK_DIR/queue.md") steps"
echo "   下一步: 读取 $TASK_DIR/queue.md 开始执行"
