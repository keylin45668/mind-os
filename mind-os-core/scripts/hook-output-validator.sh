#!/bin/bash
# hook-output-validator.sh — Stop hook: 输出质量验证器 v2
#
# 对应 autoresearch 的 prepare.py — 不可变的评估尺子
# v2: 增加语义深度启发式 + 意图分类执行 + 轮次标记检查
#
# 三层检查:
#   Layer 1: 结构存在性（关键词必须出现）
#   Layer 2: 语义深度启发式（最低深度门槛）
#   Layer 3: 流程完整性（轮次标记、意图分类）

INPUT=$(cat)
MARKER_FILE="mind-os-core/runtime/.must-run-active"
# Per-session 计数器和断路器
SESSION_ID="${CLAUDE_SESSION_ID:-$PPID}"
COUNTER_FILE="mind-os-core/runtime/sessions/.turn-counter-${SESSION_ID}"

# 防无限循环
if echo "$INPUT" | grep -q '"validator_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
fi

ISSUES=""
WARNINGS=""

# ══════════════════════════════════════════════════
# Layer 3: 流程完整性（每次都检查）
# ══════════════════════════════════════════════════

# 轮次来源：per-session 计数器文件（唯一权威来源，不从 AI 输出文本提取以避免误读讨论内容）
TURN=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
if [ "$TURN" -gt 2 ]; then
    if ! echo "$INPUT" | grep -qE '轮次|turn'; then
        WARNINGS="${WARNINGS}
⚠️ 缺少轮次标记 [轮次 ${TURN}/N]（建议但不阻断）"
    fi
fi

# 10 轮自检验证（当轮次是 10 的倍数时，检查自检内容不为空）
if [ "$TURN" -gt 0 ] && [ $((TURN % 10)) -eq 0 ]; then
    # 必须包含自检结论（"无漂移"或"检测到漂移"）
    if ! echo "$INPUT" | grep -qE '无漂移|未漂移|检测到漂移|漂移.*纠正|自检.*通过|drift'; then
        ISSUES="${ISSUES}
❌ [自检] 第 ${TURN} 轮须包含自检结论（\"无漂移\"或\"检测到漂移→纠正\"）"
    fi
    # 深度: 自检须对照宪法条目（至少提及 2 条）
    CONST_HIT=0
    echo "$INPUT" | grep -qE '第一条|Transform|认知活动|输入.*输出' && CONST_HIT=$((CONST_HIT+1))
    echo "$INPUT" | grep -qE '第二条|冻结指标|不篡改|指标' && CONST_HIT=$((CONST_HIT+1))
    echo "$INPUT" | grep -qE '第三条|复杂度|预算|上限' && CONST_HIT=$((CONST_HIT+1))
    echo "$INPUT" | grep -qE '第四条|本源|铁律|本质' && CONST_HIT=$((CONST_HIT+1))
    if [ "$CONST_HIT" -lt 2 ]; then
        ISSUES="${ISSUES}
❌ [深度] 第 ${TURN} 轮自检仅提及 ${CONST_HIT}/4 条宪法（须对照至少 2 条，非泛泛说\"无漂移\"）"
    fi
fi

# 断路器已移除 — 架构以文件为基准，不限制会话轮次
SKIP_MUST_RUN=false

# 检查语言锁定
# 读取 preferences 中的 language 设置
LANG_PREF=""
for PREF_PATH in "../data/identity/preferences.md" "mind-os-core/data-template/identity/preferences.md"; do
    if [ -f "$PREF_PATH" ]; then
        LANG_PREF=$(grep '^language:' "$PREF_PATH" 2>/dev/null | sed 's/^language:[[:space:]]*//' | tr -d '"' | head -1)
        break
    fi
done

if [ "$LANG_PREF" = "中文" ]; then
    # 剥离代码块、内联代码、文件路径声明行、协议术语后计算英文比例
    CLEAN_INPUT=$(echo "$INPUT" | sed '/```/,/```/d' | sed 's/`[^`]*`//g' | grep -vE '\.md|MUST_RUN|SHOULD|MAY|antifragile|iterative-engine|system-audit|think-index|bias-' | sed 's/\[B-[^]]*\]//g; s/\[R-[^]]*\]//g; s/\[SURVIVED:[^]]*\]//g; s/\[FALLEN:[^]]*\]//g; s/\[MODIFIED:[^]]*\]//g' | sed 's/\b[A-Z]\{2,5\}\b//g')
    TOTAL_CHARS=$(echo "$CLEAN_INPUT" | wc -c)
    ENGLISH_CHARS=$(echo "$CLEAN_INPUT" | grep -oE '[a-zA-Z]' | wc -l)
    if [ "$TOTAL_CHARS" -gt 100 ]; then
        RATIO=$((ENGLISH_CHARS * 100 / TOTAL_CHARS))
        # 阈值 30%（排除代码后，正常中文输出英文占比应 < 20%）
        if [ "$RATIO" -gt 30 ]; then
            ISSUES="${ISSUES}
❌ [语言锁] 输出英文占比 ${RATIO}%（去除代码块后，阈值 30%，language: 中文）"
        fi
    fi
fi

# ══════════════════════════════════════════════════
# Layer 1 + 2: MUST_RUN 协议检查（仅在标记存在时）
# ══════════════════════════════════════════════════

if [ -f "$MARKER_FILE" ] && [ "$SKIP_MUST_RUN" = false ]; then
    PROTOCOLS=$(cat "$MARKER_FILE" 2>/dev/null)

    # 如果 AI 显式声明了意图降级（修饰语→MAY），视为合规并清除对应协议
    if echo "$INPUT" | grep -qE '降级.*MAY|修饰语.*降级|背景.*降级|非任务核心|不适用|跳过.*协议|跳过.*分析|场景不匹配|非.*场景'; then
        # 降级声明存在 → 从 PROTOCOLS 中移除被降级的协议
        # 检查哪些被降级了
        echo "$INPUT" | grep -qE '投资.*修饰|投资.*降级|antifragile.*MAY|反脆弱.*降级|反脆弱.*不适用|antifragile.*不适用|跳过.*反脆弱|跳过.*antifragile|非.*投资.*场景' && PROTOCOLS=$(echo "$PROTOCOLS" | sed 's/antifragile//')
        echo "$INPUT" | grep -qE '分析.*修饰|分析.*降级|iterative.*MAY|迭代.*降级|迭代.*不适用|跳过.*迭代|非.*分析.*场景' && PROTOCOLS=$(echo "$PROTOCOLS" | sed 's/iterative-engine//')
        echo "$INPUT" | grep -qE '审计.*修饰|审计.*降级|audit.*MAY|审计.*不适用|跳过.*审计|非.*审计.*场景' && PROTOCOLS=$(echo "$PROTOCOLS" | sed 's/system-audit//')
        echo "$INPUT" | grep -qE '决策.*修饰|决策.*降级|think.*MAY|偏差.*降级|偏差.*不适用|跳过.*偏差|非.*决策.*场景' && PROTOCOLS=$(echo "$PROTOCOLS" | sed 's/think-index//')
        # 更新标记文件
        PROTOCOLS=$(echo "$PROTOCOLS" | tr -s ' ')
        if [ -z "$(echo "$PROTOCOLS" | tr -d ' ')" ]; then
            # 全部降级 → 清除标记，跳过后续检查
            rm -f "$MARKER_FILE"
            if [ -n "$WARNINGS" ]; then echo "$WARNINGS"; fi
            exit 0
        fi
    fi

    # ── Layer 1: 结构存在性 ──────────────────────

    # 1a. 门控声明
    if ! echo "$INPUT" | grep -q '匹配到'; then
        ISSUES="${ISSUES}
❌ [结构] 缺少门控声明（未找到\"匹配到:\"）"
    fi

    # 1b. 协作模式
    if ! echo "$INPUT" | grep -qE '协作模式|模式.*拓扑|×'; then
        ISSUES="${ISSUES}
❌ [结构] 缺少协作模式声明"
    fi

    # 1c. 意图分类执行（meta.md 规则 6）
    if ! echo "$INPUT" | grep -qE '任务核心|修饰语|降级.*MAY|意图验证|维持.*MUST'; then
        ISSUES="${ISSUES}
❌ [结构] 缺少意图分类声明（meta.md 规则 6 要求声明关键词是核心还是修饰语）"
    fi

    # 1d. 自检
    if ! echo "$INPUT" | grep -qE '自检|self.check|是否.*执行|☑|✅.*协议|✅.*执行'; then
        ISSUES="${ISSUES}
❌ [结构] 缺少自检步骤"
    fi

    # 1e. 多协议串行检查
    PROTO_COUNT=$(echo "$PROTOCOLS" | wc -w)
    if [ "$PROTO_COUNT" -ge 2 ]; then
        if ! echo "$INPUT" | grep -qE 'Step|步骤|分步|第.*步|串行'; then
            ISSUES="${ISSUES}
❌ [结构] 多协议(${PROTO_COUNT}个)未见分步执行标记（meta.md 规则 7 要求串行拆分）"
        fi
    fi

    # 1f. ≥3 协议强制拆分检查
    SPLIT_FILE="mind-os-core/runtime/.must-run-split"
    if [ -f "$SPLIT_FILE" ]; then
        if ! echo "$INPUT" | grep -qE '拆分.*会话|新.*会话.*处理|后续会话|分会话|下个会话'; then
            ISSUES="${ISSUES}
❌ [拆分] ≥3 个 MUST_RUN 但未建议拆分会话（必须建议用户开新会话处理剩余协议）"
        fi
        # 检查是否只执行了前2个（不是压缩3个）
        # 通过后清除
        if [ -z "$ISSUES" ] || ! echo "$ISSUES" | grep -q '拆分'; then
            rm -f "$SPLIT_FILE"
        fi
    fi

    # ── 多协议深度提升（≥3 协议时提高各协议门槛） ──
    MIN_QUESTIONS=2
    MIN_METHODS=2
    if [ "$PROTO_COUNT" -ge 3 ]; then
        MIN_QUESTIONS=3
        MIN_METHODS=3
    fi

    # ── 迭代引擎检查 ──────────────────────────────
    if echo "$PROTOCOLS" | grep -q 'iterative-engine'; then
        # 结构: 红方必须存在
        if ! echo "$INPUT" | grep -qE '红方|红队|red|质疑|反驳|挑战'; then
            ISSUES="${ISSUES}
❌ [结构] 迭代引擎: 未发现红方/质疑/反驳"
        fi
        # 结构: 本源检查
        if ! echo "$INPUT" | grep -qE '本源|本质|第一性|first.principle|铁律'; then
            ISSUES="${ISSUES}
❌ [结构] 迭代引擎: 未发现本源/第一性原理检查"
        fi
        # 深度: 输出中必须包含问号（真正的质疑/分析会提问）
        QUESTION_COUNT=$(echo "$INPUT" | grep -oE '？' | wc -l)
        QUESTION_COUNT2=$(echo "$INPUT" | grep -oE '\?' | wc -l)
        TOTAL_Q=$((QUESTION_COUNT + QUESTION_COUNT2))
        if [ "$TOTAL_Q" -lt "$MIN_QUESTIONS" ]; then
            ISSUES="${ISSUES}
❌ [深度] 迭代引擎: 输出中问号不足 ${TOTAL_Q} 个（需要至少 ${MIN_QUESTIONS} 个质疑问题）"
        fi
        # 深度: 蓝方和红方必须有不同观点
        if echo "$INPUT" | grep -qE '红方同意|红方认同|与蓝方一致'; then
            ISSUES="${ISSUES}
❌ [深度] 迭代引擎: 红方与蓝方一致=无对抗（红方必须有不同观点）"
        fi
        # 深度: 红方质疑须有严重性分级（防止泛泛"质疑"）
        if ! echo "$INPUT" | grep -qE '致命|严重|轻微|\[R-|攻击.*\[B-'; then
            ISSUES="${ISSUES}
❌ [深度] 迭代引擎: 红方质疑缺少严重性分级（需标注致命/严重/轻微或使用编号制）"
        fi
        # 结构: 裁决环节必须存在（蓝-红-裁决三步缺一不可）
        if ! echo "$INPUT" | grep -qE '裁决|verdict|SURVIVED|FALLEN|MODIFIED|存活|攻破|修正|结论'; then
            ISSUES="${ISSUES}
❌ [结构] 迭代引擎: 缺少裁决环节（蓝方-红方-裁决三步完整才算一轮）"
        fi
    fi

    # ── 反脆弱检查 ────────────────────────────────
    if echo "$PROTOCOLS" | grep -q 'antifragile'; then
        # 结构: 三元分类
        if ! echo "$INPUT" | grep -qE '脆弱|强韧|反脆弱|fragile|robust'; then
            ISSUES="${ISSUES}
❌ [结构] 反脆弱: 未发现三元分类"
        fi
        # 结构: 杠铃
        if ! echo "$INPUT" | grep -qE '杠铃|barbell|安全端|冒险端'; then
            ISSUES="${ISSUES}
❌ [结构] 反脆弱: 未发现杠铃策略检查"
        fi
        # 深度: 三元分类必须有量化或具体判断
        if ! echo "$INPUT" | grep -qE '[0-9]+%|高|中|低|不可逆|可逆|封顶|不封顶'; then
            ISSUES="${ISSUES}
❌ [深度] 反脆弱: 三元分类缺少量化判断（需要百分比、程度或可逆性评估）"
        fi
        # 结构: 否定法检查（"不做会怎样"）
        if ! echo "$INPUT" | grep -qE '不做|不投|不参与|不行动|否定法|via.negativa|维持现状|什么都不做'; then
            WARNINGS="${WARNINGS}
⚠️ [深度] 反脆弱: 未发现否定法/逆向检查（建议补充\"不做会怎样\"分析）"
        fi
    fi

    # ── 系统审计检查 ──────────────────────────────
    if echo "$PROTOCOLS" | grep -q 'system-audit'; then
        METHOD_COUNT=0
        echo "$INPUT" | grep -qE '方法.?A|形式化|数学|公式' && METHOD_COUNT=$((METHOD_COUNT+1))
        echo "$INPUT" | grep -qE '方法.?B|原子操作|分解|不可再分' && METHOD_COUNT=$((METHOD_COUNT+1))
        echo "$INPUT" | grep -qE '方法.?C|正反|对称|逆向|逆操作' && METHOD_COUNT=$((METHOD_COUNT+1))
        echo "$INPUT" | grep -qE '方法.?D|同构|同质|合并' && METHOD_COUNT=$((METHOD_COUNT+1))
        if [ "$METHOD_COUNT" -lt "$MIN_METHODS" ]; then
            ISSUES="${ISSUES}
❌ [结构] 系统审计: 仅检测到 ${METHOD_COUNT}/4 个方法（至少 ${MIN_METHODS} 个须有实质内容）"
        fi
    fi

    # ── 偏差扫描检查 ──────────────────────────────
    if echo "$PROTOCOLS" | grep -q 'think-index'; then
        if ! echo "$INPUT" | grep -qE '偏差|bias|过度自信|损失厌恶|锚定|WYSIATI|能力圈|确认偏误'; then
            ISSUES="${ISSUES}
❌ [结构] 偏差扫描: 未发现任何具体偏差检查"
        fi
        # 深度: 至少覆盖 2 种不同的具体偏差（防止只提"偏差"一词就通过）
        BIAS_HIT=0
        echo "$INPUT" | grep -qE '过度自信|overconfidence' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '损失厌恶|loss.aversion|沉没成本' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '锚定|anchor' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE 'WYSIATI|所见即全部|信息不足' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '能力圈|competence.circle|不熟悉' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '确认偏误|confirmation.bias' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '规划谬误|planning.fallacy' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '峰终定律|peak.end' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '一致性偏差|承诺升级|consistency' && BIAS_HIT=$((BIAS_HIT+1))
        echo "$INPUT" | grep -qE '推论阶梯|inference.ladder' && BIAS_HIT=$((BIAS_HIT+1))
        if [ "$BIAS_HIT" -lt 2 ]; then
            ISSUES="${ISSUES}
❌ [深度] 偏差扫描: 仅命中 ${BIAS_HIT} 种具体偏差（至少需覆盖 2 种不同偏差并分别分析）"
        fi
        # 深度: 偏差必须关联用户具体情境（升级为阻断）
        if ! echo "$INPUT" | grep -qE '你的|用户|这个|此次|本次|具体'; then
            ISSUES="${ISSUES}
❌ [深度] 偏差扫描: 未关联用户具体情境（不可为通用偏差列表，必须针对用户问题分析）"
        fi
        # 深度: 偏差扫描须包含行动建议（不能只诊断不开药）
        if ! echo "$INPUT" | grep -qE '建议|对策|应对|规避|可以|试试|方法|措施|做法|避免'; then
            ISSUES="${ISSUES}
❌ [深度] 偏差扫描: 仅列出偏差但缺少行动建议（须给出针对性的应对方法）"
        fi
    fi
fi

# ══════════════════════════════════════════════════
# 输出决策
# ══════════════════════════════════════════════════

if [ -n "$ISSUES" ]; then
    # 有硬性问题 → 阻断
    BLOCK_MSG="【输出验证器 v2】检测到合规问题，请补全后继续：${ISSUES}"
    if [ -n "$WARNINGS" ]; then
        BLOCK_MSG="${BLOCK_MSG}\n\n另外注意：${WARNINGS}"
    fi
    # 转义换行符，确保 JSON 合法
    BLOCK_MSG=$(printf '%s' "$BLOCK_MSG" | sed ':a;N;$!ba;s/\n/\\n/g')
    cat << EOF
{
  "decision": "block",
  "reason": "${BLOCK_MSG}"
}
EOF
else
    # 结构通过
    if [ -n "$WARNINGS" ]; then
        echo "$WARNINGS"
    fi
    # 验证通过，清除标记
    rm -f "$MARKER_FILE"
fi

exit 0
