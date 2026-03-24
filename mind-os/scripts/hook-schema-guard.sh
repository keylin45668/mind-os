#!/bin/bash
# hook-schema-guard.sh — PreToolUse hook: 拦截对 schema/identity 文件的写入
#
# 阻止 AI 修改:
# - schemas/default/*.md (宪法、协议)
# - {data}/identity/*.md (用户身份)
# - autoevolve/evaluator.md (不可变评估器)
# - autoevolve/program.md (人类元指令)
#
# 仅拦截 Edit/Write 操作，Read 操作放行

INPUT=$(cat)

# 提取工具名
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')

# 只检查写入操作
case "$TOOL_NAME" in
    Edit|Write|NotebookEdit)
        ;;
    *)
        exit 0
        ;;
esac

# 提取文件路径
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$FILE_PATH" ] && exit 0

# 检查是否命中保护路径
BLOCKED=""
case "$FILE_PATH" in
    *schemas/default/constitution.md*)
        BLOCKED="constitution.md（宪法不可修改）"
        ;;
    *schemas/default/protocols.md*)
        # protocols.md 允许 AutoEvolve 修改，但会话中 AI 不可修改
        # AutoEvolve 通过设置 AUTOEVOLVE_ACTIVE=true 环境变量来绕过此检查
        if [ "${AUTOEVOLVE_ACTIVE:-}" != "true" ]; then
            BLOCKED="protocols.md（协议文件会话中只读，仅 AutoEvolve 可修改）"
        fi
        ;;
    *identity/profile.md*|*identity/preferences.md*|*identity/principles.md*)
        BLOCKED="identity/ 文件（人类主权区域）"
        ;;
    *autoevolve/evaluator.md*)
        BLOCKED="evaluator.md（不可变评估器）"
        ;;
    *autoevolve/program.md*)
        BLOCKED="program.md（人类元指令）"
        ;;
    *autoevolve/scenarios/*)
        BLOCKED="scenarios/（测试用例不可被 AI 修改）"
        ;;
esac

if [ -n "$BLOCKED" ]; then
    cat << EOF
{
  "decision": "block",
  "reason": "【Schema 守卫】拦截写入 ${BLOCKED}\nschema/、identity/、evaluator 为人类主权区域，AI 只读不写。\n请引导用户自行修改。"
}
EOF
fi

exit 0
