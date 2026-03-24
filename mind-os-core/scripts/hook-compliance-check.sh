#!/bin/bash
# hook-compliance-check.sh — Stop hook (与 stop-guard 并行): 合规性检查
#
# 检查 AI 最近输出是否包含必要的合规标记
# 仅在 MUST_RUN 命中时检查（通过检测 .must-run-active 标记文件）

MARKER_FILE="mind-os-core/runtime/.must-run-active"
COUNTER_FILE="mind-os-core/runtime/.turn-counter"

INPUT=$(cat)

# 防无限循环
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi
if echo "$INPUT" | grep -q '"compliance_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi

# 检查轮次标记是否存在（应该在每次输出中）
TURN=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
if [ "$TURN" -gt 0 ]; then
    # 只做轻量提醒，不阻断
    echo "提醒: 确保回复末尾包含 [轮次 ${TURN}/N] 标记。"
fi

# 如果有活跃的 MUST_RUN 匹配，检查门控声明
if [ -f "$MARKER_FILE" ]; then
    PROTOCOLS=$(cat "$MARKER_FILE")
    echo "合规检查: 本次有 MUST_RUN 协议匹配（${PROTOCOLS}）。"
    echo "请确认回复中包含:"
    echo "  1. ✅ 匹配声明（\"匹配到: ...\"）"
    echo "  2. ✅ 协作模式声明"
    echo "  3. ✅ 各 MUST_RUN 协议的执行产出"
    echo "  4. ✅ 自检（\"我是否按协议执行了？\"）"
    # 注意: 不删除标记文件！由 hook-output-validator.sh 验证通过后清除
    # 如果在此删除会导致验证器被绕过（race condition bug, AutoEvolve #18 发现）
fi

exit 0
