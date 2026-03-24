#!/usr/bin/env bash
# Mind OS SessionStart Hook
# 在会话启动时注入强制启动指令到 AI 上下文

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "【Mind OS 提醒】如果 mind-os-boot skill 可用，请在系统初始化完成后调用它来执行启动协议。如果 skill 不可用，请读取 mind-os/BOOT.md 并执行 Phase 0 → Phase 5。"
  }
}
HOOK_JSON
