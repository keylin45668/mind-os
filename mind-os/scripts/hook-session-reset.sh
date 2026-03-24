#!/bin/bash
# hook-session-reset.sh — UserPromptSubmit hook: 会话开始时重置计数器
#
# 检测特征: 如果用户消息触发了 BOOT（包含启动关键词或首轮），重置计数器

INPUT=$(cat)

USER_MSG=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user_prompt', d.get('message','')))" 2>/dev/null || \
           echo "$INPUT" | grep -o '"user_prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$USER_MSG" ] && USER_MSG=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')

# 检测启动信号
if echo "$USER_MSG" | grep -qiE '启动.*Mind.*OS|Mind.*OS.*启动|BOOT|重新启动'; then
    echo "0" > "mind-os/runtime/.turn-counter"
    echo "🔄 轮次计数器已重置（检测到启动信号）"
fi

exit 0
