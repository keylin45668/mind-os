#!/bin/bash
# hook-session-reset.sh — UserPromptSubmit hook: 会话开始时重置计数器
#
# 检测特征: 如果用户消息触发了 BOOT（包含启动关键词或首轮），重置计数器

INPUT=$(cat)

USER_MSG=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user_prompt', d.get('message','')))" 2>/dev/null || \
           echo "$INPUT" | grep -o '"user_prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$USER_MSG" ] && USER_MSG=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')

# 使用与 turn-counter 相同的会话标识
SESSION_ID="${CLAUDE_SESSION_ID:-$PPID}"
COUNTER_DIR="mind-os-core/runtime/sessions"
COUNTER_FILE="${COUNTER_DIR}/.turn-counter-${SESSION_ID}"

# 检测启动信号
if echo "$USER_MSG" | grep -qiE '启动.*Mind.*OS|Mind.*OS.*启动|BOOT|重新启动'; then
    mkdir -p "$COUNTER_DIR"
    echo "0" > "$COUNTER_FILE"
    echo "🔄 轮次计数器已重置（检测到启动信号）"
fi

exit 0
