#!/usr/bin/env bash
# Mind OS v4.4 — 全系统自动化测试脚本
# 用法: bash mind-os/test.sh
# 纯脚本验证，不依赖 AI 判断，确保每次执行结果一致。

set -euo pipefail

MIND_OS_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$(cd "$MIND_OS_DIR/.." && pwd)/data"
PASS=0
FAIL=0
WARN=0

# ── 工具函数 ──

pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }
warn() { WARN=$((WARN+1)); echo "  ⚠️  $1"; }

assert_file() {
  if [ -f "$MIND_OS_DIR/$1" ]; then pass "$1 存在"
  else fail "$1 缺失"; fi
}

assert_content() {
  # $1=文件 $2=正则 $3=描述
  if grep -qE "$2" "$MIND_OS_DIR/$1" 2>/dev/null; then pass "$3"
  else fail "$3（在 $1 中未找到 '$2'）"; fi
}

assert_no_content() {
  # $1=文件 $2=正则 $3=描述
  if grep -qE "$2" "$MIND_OS_DIR/$1" 2>/dev/null; then fail "$3（在 $1 中发现残留 '$2'）"
  else pass "$3"; fi
}

assert_count() {
  # $1=文件 $2=正则 $3=期望数量 $4=描述
  local count
  count=$(grep -cE "$2" "$MIND_OS_DIR/$1" 2>/dev/null || echo 0)
  if [ "$count" -ge "$3" ]; then pass "$4（$count 处）"
  else fail "$4（期望≥$3，实际 $count）"; fi
}

section() { echo ""; echo "━━ $1 ━━"; }

# ══════════════════════════════════════
# T1: 文件完整性
# ══════════════════════════════════════
section "T1: 文件完整性检查"

# BOOT.md 引用的核心文件
for f in \
  config.md \
  BOOT.md \
  schemas/default/constitution.md \
  schemas/default/protocols.md \
  theories/rational/meta.md \
  domains/_router.md \
  runtime/focus.md \
  runtime/dashboard.md \
  data-template/identity/profile.md \
  data-template/identity/preferences.md \
  data-template/identity/principles.md; do
  assert_file "$f"
done

# theory 模块（无预存上限，按需加载≤3个）
for f in \
  theories/rational/capture/rules.md \
  theories/rational/organize/rules.md \
  theories/rational/think/_index.md \
  theories/rational/think/system-audit-method.md \
  theories/rational/decide/rules.md \
  theories/rational/decide/antifragile.md \
  theories/rational/decide/competition.md \
  theories/rational/decide/models/meta.md \
  theories/rational/review/rules.md \
  theories/rational/knowledge/rules.md \
  theories/rational/collaboration/rules.md \
  theories/rational/collaboration/dynamics.md \
  theories/rational/collaboration/learning-org.md \
  theories/rational/collaboration/principles.md \
  theories/rational/collaboration/economics.md; do
  assert_file "$f"
done

# 9 个偏差模块
for f in \
  theories/rational/think/bias-anchor.md \
  theories/rational/think/bias-wysiati.md \
  theories/rational/think/bias-loss-aversion.md \
  theories/rational/think/bias-planning.md \
  theories/rational/think/bias-peak-end.md \
  theories/rational/think/bias-overconfidence.md \
  theories/rational/think/bias-inference-ladder.md \
  theories/rational/think/bias-competence-circle.md \
  theories/rational/think/bias-munger25.md; do
  assert_file "$f"
done

# 6 个 domain 规则
for f in \
  domains/software-dev/_rules.md \
  domains/finance/_rules.md \
  domains/people/_rules.md \
  domains/strategy/_rules.md \
  domains/writing/_rules.md \
  domains/personal/_rules.md; do
  assert_file "$f"
done

# ══════════════════════════════════════
# T2: 旧文件残留检查
# ══════════════════════════════════════
section "T2: 旧文件残留检查"

for f in \
  schemas/default/metrics.md \
  schemas/default/symbiosis.md \
  schemas/default/pipeline.md \
  schemas/default/iteration.md \
  schemas/default/conventions.md \
  schemas/default/dynamics.md; do
  if [ -f "$MIND_OS_DIR/$f" ]; then fail "旧文件 $f 未删除"
  else pass "旧文件 $f 已清理"; fi
done

# 检查代码中是否残留旧文件名引用（排除 CHANGELOG）
for pattern in "metrics\.md" "symbiosis\.md" "pipeline\.md" "iteration\.md" "conventions\.md"; do
  count=$(grep -rl "$pattern" "$MIND_OS_DIR" --include="*.md" 2>/dev/null | { grep -v CHANGELOG || true; } | wc -l)
  if [ "$count" -eq 0 ]; then pass "无残留引用: $pattern"
  else fail "残留引用 $pattern（$count 个文件）"; fi
done

# ══════════════════════════════════════
# T3: 宪法完整性
# ══════════════════════════════════════
section "T3: 宪法完整性"

assert_count "schemas/default/constitution.md" "^\*\*第.*条\*\*" 3 "三条宪法完整"
assert_content "schemas/default/constitution.md" "冻结指标" "冻结指标部分存在"
assert_content "schemas/default/constitution.md" "协作增益率" "协作增益率指标存在"
assert_content "schemas/default/constitution.md" "鲁棒性" "鲁棒性指标存在"
assert_content "schemas/default/constitution.md" "schema ≤ 30" "schema 复杂度预算"
assert_content "schemas/default/constitution.md" "单次加载 ≤ 3" "theory 运行时加载预算"

# 机器层指标数（11项）
machine_metrics=$(grep -cE "^\|.*\|.*\|.*\|$" "$MIND_OS_DIR/schemas/default/constitution.md" 2>/dev/null || echo 0)
if [ "$machine_metrics" -ge 11 ]; then pass "机器层指标行数充足（$machine_metrics）"
else fail "机器层指标行数不足（$machine_metrics）"; fi

# 人类层指标数（4项）
assert_count "schemas/default/constitution.md" "决策质量|精力分配|角色平衡|系统使用" 4 "人类层四项指标完整"

# ══════════════════════════════════════
# T4: 协议文件完整性
# ══════════════════════════════════════
section "T4: protocols.md 完整性"

assert_content "schemas/default/protocols.md" "四种模式" "四种协作模式"
assert_content "schemas/default/protocols.md" "三种拓扑" "三种拓扑"
assert_content "schemas/default/protocols.md" "AI 读写权限" "读写权限表"
assert_content "schemas/default/protocols.md" "管道定义" "管道定义"
assert_content "schemas/default/protocols.md" "自迭代协议" "自迭代协议"
assert_content "schemas/default/protocols.md" "混沌边缘" "混沌边缘检测"
assert_content "schemas/default/protocols.md" "会话管理" "会话管理规则"
assert_content "schemas/default/protocols.md" "schema.*❌" "schema 只读约束"
assert_content "schemas/default/protocols.md" "identity.*❌" "identity 只读约束"

# ══════════════════════════════════════
# T5: BOOT.md 结构检查
# ══════════════════════════════════════
section "T5: BOOT.md 启动协议完整性"

assert_content "BOOT.md" "Phase 0" "Phase 0 存在"
assert_content "BOOT.md" "Phase 1-2" "Phase 1-2 合并存在"
assert_content "BOOT.md" "Phase 3" "Phase 3 存在"
assert_content "BOOT.md" "Phase 4" "Phase 4 存在"
assert_content "BOOT.md" "Phase 5" "Phase 5 存在"
assert_content "BOOT.md" "首次安装流程" "首次安装流程"
assert_content "BOOT.md" "可视化面板" "可视化面板"
assert_content "BOOT.md" "引导菜单" "引导菜单"
assert_content "BOOT.md" "1️⃣.*直接描述" "菜单选项1"
assert_content "BOOT.md" "3️⃣.*了解.*Mind OS" "菜单选项3"
assert_content "BOOT.md" "5️⃣.*关于项目" "菜单选项5"

# 首次安装问题数（9个）
question_count=$(grep -cE "^[0-9]️⃣" "$MIND_OS_DIR/BOOT.md" 2>/dev/null || echo 0)
if [ "$question_count" -ge 9 ]; then pass "首次安装问题数（$question_count 个）"
else fail "首次安装问题数不足（期望≥9，实际 $question_count）"; fi

# 语言选项
assert_content "BOOT.md" "系统输出语言" "语言选项存在"
assert_content "BOOT.md" "语言锁定" "语言锁定规则存在"

# ══════════════════════════════════════
# T6: 路由表完整性
# ══════════════════════════════════════
section "T6: 路由表完整性"

# theory 路由条数（15）
theory_routes=$(grep -cE "^\|.*\|.*\|.*\|$" "$MIND_OS_DIR/theories/rational/meta.md" 2>/dev/null || echo 0)
if [ "$theory_routes" -ge 15 ]; then pass "theory 路由条数（$theory_routes）"
else fail "theory 路由条数不足（期望≥15，实际 $theory_routes）"; fi

# domain 路由条数（6）
domain_routes=$(grep -cE "^\|.*domains/" "$MIND_OS_DIR/domains/_router.md" 2>/dev/null || echo 0)
if [ "$domain_routes" -ge 6 ]; then pass "domain 路由条数（$domain_routes）"
else fail "domain 路由条数不足（期望≥6，实际 $domain_routes）"; fi

# 路由表引用的文件都存在
section "T6.1: theory 路由→文件映射验证"
while IFS='|' read -r _ keywords file desc _; do
  file=$(echo "$file" | xargs)  # trim
  [[ "$file" == "加载文件" ]] && continue  # skip header
  [[ -z "$file" ]] && continue
  # 处理二级路由标记
  file=$(echo "$file" | sed 's/ →.*//; s/^ *//; s/ *$//')
  full_path="$MIND_OS_DIR/theories/rational/$file"
  if [ -f "$full_path" ]; then pass "路由 $file → 文件存在"
  else fail "路由 $file → 文件缺失"; fi
done < <(grep "^|" "$MIND_OS_DIR/theories/rational/meta.md" | tail -n +3)

# ══════════════════════════════════════
# T7: Theory 模块内容验证
# ══════════════════════════════════════
section "T7: Theory 模块内容质量"

# 每个偏差模块必须有 trigger + protocol + output
for f in \
  bias-anchor.md \
  bias-wysiati.md \
  bias-loss-aversion.md \
  bias-planning.md \
  bias-peak-end.md \
  bias-overconfidence.md \
  bias-inference-ladder.md \
  bias-competence-circle.md \
  bias-munger25.md; do
  base="theories/rational/think/$f"
  has_trigger=$(grep -c "trigger:" "$MIND_OS_DIR/$base" 2>/dev/null || echo 0)
  has_protocol=$(grep -c "protocol:" "$MIND_OS_DIR/$base" 2>/dev/null || echo 0)
  has_output=$(grep -c "output:" "$MIND_OS_DIR/$base" 2>/dev/null || echo 0)

  if [ "$has_trigger" -ge 1 ] && [ "$has_protocol" -ge 1 ] && [ "$has_output" -ge 1 ]; then
    pass "$f: trigger+protocol+output 完整"
  else
    fail "$f: trigger=$has_trigger protocol=$has_protocol output=$has_output"
  fi
done

# 多偏差叠加规则
assert_content "theories/rational/think/_index.md" "多偏差叠加" "多偏差叠加规则存在"
assert_content "theories/rational/think/_index.md" "强制冷静期" "3偏差强制冷静期"

# 核心 theory 模块有 trigger
for f in \
  "decide/antifragile.md:三元分类" \
  "decide/competition.md:五事" \
  "decide/rules.md:艾森豪威尔" \
  "review/rules.md:回顾节奏" \
  "knowledge/rules.md:原子笔记"; do
  file="${f%%:*}"
  keyword="${f##*:}"
  if grep -q "$keyword" "$MIND_OS_DIR/theories/rational/$file" 2>/dev/null; then
    pass "$file: 关键内容 '$keyword' 存在"
  else
    fail "$file: 关键内容 '$keyword' 缺失"
  fi
done

# ══════════════════════════════════════
# T8: Domain 规则内容验证
# ══════════════════════════════════════
section "T8: Domain 规则内容质量"

for f in \
  "domains/software-dev/_rules.md:协作模式" \
  "domains/finance/_rules.md:协作模式" \
  "domains/people/_rules.md:协作模式" \
  "domains/strategy/_rules.md:协作模式" \
  "domains/writing/_rules.md:协作模式" \
  "domains/personal/_rules.md:协作模式"; do
  file="${f%%:*}"
  keyword="${f##*:}"
  if grep -q "$keyword" "$MIND_OS_DIR/$file" 2>/dev/null; then
    pass "$file: '$keyword' 配置存在"
  else
    fail "$file: '$keyword' 配置缺失"
  fi
done

# ══════════════════════════════════════
# T9: 数据模板验证
# ══════════════════════════════════════
section "T9: 数据模板字段完整性"

# profile.md 模板必须包含的字段
for field in "name:" "roles:" "core_values:" "industry:" "team_size:" "current_stage:" "skills:"; do
  if grep -q "$field" "$MIND_OS_DIR/data-template/identity/profile.md" 2>/dev/null; then
    pass "profile 模板: $field 存在"
  else
    fail "profile 模板: $field 缺失"
  fi
done

# preferences.md 模板必须包含的字段
for field in "communication_style:" "language:" "session_length_limit:"; do
  if grep -q "$field" "$MIND_OS_DIR/data-template/identity/preferences.md" 2>/dev/null; then
    pass "preferences 模板: $field 存在"
  else
    fail "preferences 模板: $field 缺失"
  fi
done

# preferences.md 不应包含已废弃字段
assert_no_content "data-template/identity/preferences.md" "large_amount_threshold" "preferences 模板: 已移除 large_amount_threshold"

# ══════════════════════════════════════
# T10: 会话规则验证
# ══════════════════════════════════════
section "T10: 会话规则完整性"

assert_content "BOOT.md" "语言锁定" "规则1: 语言锁定"
assert_content "BOOT.md" "单会话单主题" "规则2: 单会话单主题"
assert_content "BOOT.md" "漂移断路器" "规则3: 漂移断路器"
assert_content "BOOT.md" "不确定性标记" "规则4: 不确定性标记"
assert_content "BOOT.md" "schema 只读" "规则5: schema 只读"
assert_content "BOOT.md" "每 10 轮自检" "规则6: 每10轮自检"
assert_content "BOOT.md" "按需加载" "规则7: 按需加载"

# ══════════════════════════════════════
# T11: 任务路由关键词→domain 映射
# ══════════════════════════════════════
section "T11: 任务路由关键词匹配"

for mapping in \
  "代码:software-dev" \
  "投资:finance" \
  "招聘:people" \
  "战略:strategy" \
  "写作:writing" \
  "家庭:personal"; do
  keyword="${mapping%%:*}"
  domain="${mapping##*:}"
  if grep -q "$keyword.*$domain" "$MIND_OS_DIR/domains/_router.md" 2>/dev/null; then
    pass "关键词 '$keyword' → domain '$domain'"
  else
    fail "关键词 '$keyword' → domain '$domain' 映射失败"
  fi
done

# 降级策略
assert_content "domains/_router.md" "no_match" "无匹配降级策略存在"

# ══════════════════════════════════════
# T12: config.md 版本与路径
# ══════════════════════════════════════
section "T12: 配置文件验证"

assert_content "config.md" "version:" "版本号字段存在"
assert_content "config.md" "schema:" "schema 路径存在"
assert_content "config.md" "theory:" "theory 路径存在"
assert_content "config.md" "data:" "data 路径存在"

# ══════════════════════════════════════
# T13: 引导菜单内容
# ══════════════════════════════════════
section "T13: 引导菜单内容"

assert_content "BOOT.md" "决策分析" "选项3: 决策分析能力"
assert_content "BOOT.md" "信息管理" "选项3: 信息管理能力"
assert_content "BOOT.md" "知识沉淀" "选项3: 知识沉淀能力"
assert_content "BOOT.md" "王麟" "选项5: 开发者信息"
assert_content "BOOT.md" "keylin45668" "选项5: GitHub 地址"
assert_content "BOOT.md" "MIT" "选项5: 开源协议"
assert_content "BOOT.md" "试试说这些" "体验示例引导"

# ══════════════════════════════════════
# T14: 质量循环（Quality Loop）完整性
# ══════════════════════════════════════
section "T14: 质量循环完整性"

# T14.1: 文件存在
assert_file "theories/rational/think/quality-loop.md"

# T14.2: quality-loop.md 核心内容
assert_content "theories/rational/think/quality-loop.md" "触发.*激活" "质量循环: 触发条件存在"
assert_content "theories/rational/think/quality-loop.md" "动态检查清单" "质量循环: 动态检查清单章节"
assert_content "theories/rational/think/quality-loop.md" "converge" "质量循环: 收敛条件存在"
assert_content "theories/rational/think/quality-loop.md" "ISSUES.*==.*0" "质量循环: 全通过收敛条件"
assert_content "theories/rational/think/quality-loop.md" "连续.*2.*轮" "质量循环: plateau 收敛条件"
assert_content "theories/rational/think/quality-loop.md" "≥.*5" "质量循环: emergency brake（5轮）"
assert_content "theories/rational/think/quality-loop.md" "断路器" "质量循环: 断路器优先规则"
assert_content "theories/rational/think/quality-loop.md" "用户可中断" "质量循环: 用户中断权"
assert_content "theories/rational/think/quality-loop.md" "universal_checks" "质量循环: 通用检查项"
assert_content "theories/rational/think/quality-loop.md" "本源" "质量循环: 本源检查(宪法第四条)"
assert_content "theories/rational/think/quality-loop.md" "checklist_cap.*10" "质量循环: 检查项上限10"

# T14.3: quality-loop.md 包含所有 MUST_RUN 协议的检查项引用
assert_content "theories/rational/think/quality-loop.md" "antifragile" "质量循环: antifragile 检查项"
assert_content "theories/rational/think/quality-loop.md" "system_audit" "质量循环: system_audit 检查项"
assert_content "theories/rational/think/quality-loop.md" "iterative_engine" "质量循环: iterative_engine 检查项"
assert_content "theories/rational/think/quality-loop.md" "think_index" "质量循环: think_index 检查项"

# T14.4: quality-loop.md 输出格式
assert_content "theories/rational/think/quality-loop.md" "details" "质量循环: 折叠摘要格式"
assert_content "theories/rational/think/quality-loop.md" "质量循环摘要" "质量循环: 摘要标题"

# T14.5: protocols.md 集成
assert_content "schemas/default/protocols.md" "6_quality_loop" "protocols: 质量循环步骤存在"
assert_content "schemas/default/protocols.md" "quality-loop.md" "protocols: 引用 quality-loop.md"
assert_content "schemas/default/protocols.md" "激活.*质量循环" "protocols: 深度级提示激活"
assert_content "schemas/default/protocols.md" "断路器.*不触发" "protocols: 断路器禁止质量循环"

# T14.6: meta.md 路由条目
assert_content "theories/rational/meta.md" "quality-loop" "meta路由: quality-loop 条目存在"
assert_content "theories/rational/meta.md" "质量循环.*MAY" "meta路由: 执行级别为 MAY"

# T14.7: token 预算（quality-loop.md ≤ 1000 tokens ≈ 750 words ≈ 4000 字符）
ql_chars=$(wc -c < "$MIND_OS_DIR/theories/rational/think/quality-loop.md" 2>/dev/null || echo 99999)
if [ "$ql_chars" -le 4000 ]; then pass "quality-loop.md 大小合规（${ql_chars} 字符）"
else fail "quality-loop.md 超出预算（${ql_chars} 字符，上限 4000）"; fi

# T14.8: 质量循环不与 depth_check 重复
assert_content "theories/rational/think/quality-loop.md" "不与.*depth_check.*重复|不重复.*depth_check" "质量循环: 声明不与 depth_check 重复"

# ══════════════════════════════════════
# T15: 质量循环 — Validator 集成验证
# ══════════════════════════════════════
section "T15: Validator 与质量循环兼容性"

# T15.1: validator 断路器 SKIP_MUST_RUN 标志（质量循环依赖此机制）
assert_content "scripts/hook-output-validator.sh" "SKIP_MUST_RUN" "validator: SKIP_MUST_RUN 标志存在"
assert_content "scripts/hook-output-validator.sh" "BREAKER_ACTIVE.*true" "validator: 断路器激活逻辑"
assert_content "scripts/hook-output-validator.sh" "SKIP_MUST_RUN.*false" "validator: SKIP_MUST_RUN 条件守卫"

# T15.2: validator 降级识别覆盖（质量循环 MAY 级别不应触发 MUST_RUN 检查）
assert_content "scripts/hook-output-validator.sh" "不适用|跳过.*协议" "validator: 扩展降级模式"

# T15.3: validator 各协议深度检查存在（质量循环的检查清单与此互补）
assert_content "scripts/hook-output-validator.sh" "BIAS_HIT" "validator: 偏差计数检查"
assert_content "scripts/hook-output-validator.sh" "METHOD_COUNT" "validator: 审计方法计数"
assert_content "scripts/hook-output-validator.sh" "TOTAL_Q" "validator: 问号计数检查"
assert_content "scripts/hook-output-validator.sh" "裁决|verdict" "validator: 裁决环节检查"

# ══════════════════════════════════════
# T16: 质量循环 — 场景模拟验证
# ══════════════════════════════════════
section "T16: 质量循环场景模拟"

# T16.1: MUST_RUN 任务应触发质量循环提示
#   模拟: "帮我分析这三个方案" → iterative-engine MUST_RUN → 应提示
assert_content "theories/rational/meta.md" "帮我分析.*MUST_RUN" "场景: '帮我分析'命中 MUST_RUN"

# T16.2: 非 MUST_RUN 任务不应触发质量循环
#   模拟: "帮我整理邮件" → organize SHOULD → 不触发
#   验证: organize 的执行级别是 SHOULD 而非 MUST_RUN
if grep -E "整理.*MUST_RUN" "$MIND_OS_DIR/theories/rational/meta.md" > /dev/null 2>&1; then
  fail "场景: '整理'不应为 MUST_RUN（质量循环会误触发）"
else
  pass "场景: '整理'为 SHOULD，不触发质量循环"
fi

# T16.3: 边界关键词不应触发质量循环
#   模拟: "写封信给投资人" → 投资=修饰语 → 降级 MAY → 不触发
assert_content "theories/rational/meta.md" "意图验证|意图检查|两遍路由" "场景: 意图验证规则存在（防边界误触发）"

# T16.4: 断路器激活时不触发质量循环
#   验证: protocols.md 明确声明断路器禁止质量循环
assert_content "schemas/default/protocols.md" "断路器.*不触发|断路器.*质量循环" "场景: 断路器禁止质量循环"

# T16.5: 手动触发路径
#   模拟: 用户说"帮我打磨一下" → quality-loop MAY → 可手动加载
if grep -E "打磨.*quality-loop" "$MIND_OS_DIR/theories/rational/meta.md" > /dev/null 2>&1; then
  pass "场景: '打磨'关键词命中 quality-loop"
else
  fail "场景: '打磨'关键词未命中 quality-loop"
fi

# T16.6: 多 MUST_RUN 时质量循环在全部执行后触发
assert_content "schemas/default/protocols.md" "所有.*MUST_RUN.*完成后|串行执行完成后" "场景: 质量循环在多协议完成后"

# T16.7: 检查清单上限
assert_content "theories/rational/think/quality-loop.md" "上限.*10|cap.*10|checklist_cap.*10" "场景: 检查清单不超过 10 项"

# ══════════════════════════════════════
# 汇总
# ══════════════════════════════════════
# T17: 迭代引擎 — mandatory_ask 完整性
# ══════════════════════════════════════
section "T17: mandatory_ask 规则完整性"

# T17.1: mandatory_ask 存在且为 MUST_RUN
assert_content "theories/rational/think/iterative-engine.md" "mandatory_ask" "mandatory_ask 规则存在"
assert_content "theories/rational/think/iterative-engine.md" "触发条件" "mandatory_ask: 触发条件定义"
assert_content "theories/rational/think/iterative-engine.md" "模糊" "mandatory_ask: 信息模糊检测"

# T17.2: 质量要求询问（min_score）
assert_content "theories/rational/think/iterative-engine.md" "min_score 未设置" "mandatory_ask: min_score 未设置触发"
assert_content "theories/rational/think/iterative-engine.md" "你要求多严格" "mandatory_ask: 质量要求询问模板"
assert_content "theories/rational/think/iterative-engine.md" "快速参考" "mandatory_ask: 快速参考选项"
assert_content "theories/rational/think/iterative-engine.md" "标准分析" "mandatory_ask: 标准分析选项"
assert_content "theories/rational/think/iterative-engine.md" "严格深挖" "mandatory_ask: 严格深挖选项"

# T17.3: 不可跳过规则
assert_content "theories/rational/think/iterative-engine.md" "不得自行推测" "mandatory_ask: 不得自行推测"
assert_content "theories/rational/think/iterative-engine.md" "不得跳过质量要求" "mandatory_ask: 不得跳过质量要求"
assert_content "theories/rational/think/iterative-engine.md" "用户的选择" "mandatory_ask: min_score 必须是用户选择"

# ══════════════════════════════════════
# T18: 迭代引擎 — 编号制红蓝对抗
# ══════════════════════════════════════
section "T18: 编号制红蓝对抗"

# T18.1: 编号格式定义
assert_content "theories/rational/think/iterative-engine.md" "\[B-.*r.*-" "编号制: 蓝方编号格式 [B-dXrX-XX]"
assert_content "theories/rational/think/iterative-engine.md" "\[R-.*r.*-" "编号制: 红方编号格式 [R-dXrX-XX]"
assert_content "theories/rational/think/iterative-engine.md" "\[NEW\]" "编号制: 红方 [NEW] 标记"
assert_content "theories/rational/think/iterative-engine.md" "\[REPEAT:" "编号制: 红方 [REPEAT] 标记"
assert_content "theories/rational/think/iterative-engine.md" "\[RESP:" "编号制: 蓝方 [RESP] 回应标记"
assert_content "theories/rational/think/iterative-engine.md" "\[NO-RESP:" "编号制: 蓝方 [NO-RESP] 标记"

# T18.2: 裁决编号
assert_content "theories/rational/think/iterative-engine.md" "\[SURVIVED:" "编号制: 裁决 [SURVIVED] 标记"
assert_content "theories/rational/think/iterative-engine.md" "\[FALLEN:" "编号制: 裁决 [FALLEN] 标记"
assert_content "theories/rational/think/iterative-engine.md" "\[MODIFIED:" "编号制: 裁决 [MODIFIED] 标记"
assert_content "theories/rational/think/iterative-engine.md" "\[OPEN-" "编号制: 遗留问题 [OPEN] 标记"

# T18.3: 信心度公式
assert_content "theories/rational/think/iterative-engine.md" "survived.*fallen.*modified" "编号制: confidence 计算公式"

# ══════════════════════════════════════
# T19: 输出模式与生命周期
# ══════════════════════════════════════
section "T19: 输出模式与生命周期"

# T19.1: 默认对话模式
assert_content "theories/rational/think/iterative-engine.md" "default: conversation" "输出模式: 默认对话输出"

# T19.2: 落盘触发条件
assert_content "theories/rational/think/iterative-engine.md" "persist_trigger" "输出模式: persist_trigger 定义"
assert_content "theories/rational/think/iterative-engine.md" "用户明确要求" "输出模式: 用户要求触发"
assert_content "theories/rational/think/iterative-engine.md" "跨会话" "输出模式: 跨会话触发"

# T19.3: 清理规则
assert_content "theories/rational/think/iterative-engine.md" "persist_cleanup" "生命周期: persist_cleanup 定义"
assert_content "theories/rational/think/iterative-engine.md" "沉淀到 {data}" "生命周期: 结论沉淀到 data"
assert_content "theories/rational/think/iterative-engine.md" "删除 runtime" "生命周期: 删除 runtime 过程文件"

# T19.4: protocols.md 思考阶段更新
assert_content "schemas/default/protocols.md" "对话中输出" "protocols: 思考阶段对话优先"
assert_content "schemas/default/protocols.md" "thinking_lifecycle" "protocols: thinking_lifecycle 规则"

# T19.5: .gitignore 忽略 runtime
if [ -f "$MIND_OS_DIR/.gitignore" ]; then
  if grep -q "runtime/" "$MIND_OS_DIR/.gitignore"; then pass ".gitignore: runtime/ 被忽略"
  else fail ".gitignore: runtime/ 未被忽略"; fi
else
  fail ".gitignore: 文件不存在"
fi

# ══════════════════════════════════════
# T20: 输出模板完整性
# ══════════════════════════════════════
section "T20: 输出模板完整性"

# T20.1: output-template.md 存在（检查两个可能位置）
if [ -f "$MIND_OS_DIR/theories/rational/think/output-template.md" ] || \
   [ -f "$MIND_OS_DIR/schemas/default/output-template.md" ]; then
  pass "output-template.md 存在"
else
  fail "output-template.md 缺失（theories 或 schemas 都没找到）"
fi

# T20.2: 总纲必选章节
OT_FILE=""
if [ -f "$MIND_OS_DIR/theories/rational/think/output-template.md" ]; then
  OT_FILE="theories/rational/think/output-template.md"
elif [ -f "$MIND_OS_DIR/schemas/default/output-template.md" ]; then
  OT_FILE="schemas/default/output-template.md"
fi

if [ -n "$OT_FILE" ]; then
  assert_content "$OT_FILE" "一句话结论" "输出模板: 一句话结论章节"
  assert_content "$OT_FILE" "推荐方案" "输出模板: 推荐方案章节"
  assert_content "$OT_FILE" "各方向速览" "输出模板: 各方向速览章节"
  assert_content "$OT_FILE" "下一步行动" "输出模板: 下一步行动章节"
  assert_content "$OT_FILE" "详细章节" "输出模板: 详细章节链接"
  assert_content "$OT_FILE" "800" "输出模板: 总纲 800 tokens 限制"
  assert_content "$OT_FILE" "1500" "输出模板: 章节 1500 tokens 限制"
  assert_content "$OT_FILE" "分析溯源" "输出模板: 分析溯源章节"
fi

# T20.3: iterative-engine 引用 output-template
assert_content "theories/rational/think/iterative-engine.md" "output-template" "迭代引擎: 引用 output-template"

# ══════════════════════════════════════
# T21: 质量门控（scoring agent）
# ══════════════════════════════════════
section "T21: 质量门控完整性"

# T21.1: scoring agent 定义
assert_content "theories/rational/think/iterative-engine.md" "scoring_agent" "质量门控: scoring_agent 定义"
assert_content "theories/rational/think/iterative-engine.md" "min_score" "质量门控: min_score 字段"

# T21.2: 五维评分
assert_content "theories/rational/think/iterative-engine.md" "任务完成度" "质量门控: D1 任务完成度"
assert_content "theories/rational/think/iterative-engine.md" "分析深度" "质量门控: D2 分析深度"
assert_content "theories/rational/think/iterative-engine.md" "协议合规" "质量门控: D3 协议合规"
assert_content "theories/rational/think/iterative-engine.md" "D4.*效率" "质量门控: D4 效率"
assert_content "theories/rational/think/iterative-engine.md" "可行动性" "质量门控: D5 可行动性"

# T21.3: 门控判定
assert_content "theories/rational/think/iterative-engine.md" "PASS" "质量门控: PASS 判定"
assert_content "theories/rational/think/iterative-engine.md" "FAIL" "质量门控: FAIL 判定"
assert_content "theories/rational/think/iterative-engine.md" "total.*min_score" "质量门控: total vs min_score 比较"

# T21.4: 用户设置 min_score 方式
assert_content "theories/rational/think/iterative-engine.md" "任务级" "质量门控: 任务级设置方式"
assert_content "theories/rational/think/iterative-engine.md" "全局默认" "质量门控: 全局默认设置方式"

# ══════════════════════════════════════
# T22: protocols.md — 本次改动验证
# ══════════════════════════════════════
section "T22: protocols.md 本次改动"

# T22.1: MUST_RUN 描述更新（不再要求"必须创建目录"）
assert_no_content "schemas/default/protocols.md" "必须创建 thinking 目录" "protocols: 已移除强制创建目录要求"

# T22.2: depth_check 存在
assert_content "schemas/default/protocols.md" "4_depth_check" "protocols: depth_check 步骤"
assert_content "schemas/default/protocols.md" "红方是否提出" "protocols: 红方深度检查"

# T22.3: session_cap 存在
assert_content "schemas/default/protocols.md" "5_session_cap" "protocols: session_cap 步骤"
assert_content "schemas/default/protocols.md" "≤ 2 个为常规" "protocols: MUST_RUN 上限2个"

# ══════════════════════════════════════
echo ""
echo "══════════════════════════════════════"
echo "  测试结果汇总"
echo "══════════════════════════════════════"
echo "  ✅ 通过: $PASS"
echo "  ❌ 失败: $FAIL"
echo "  ⚠️  警告: $WARN"
echo "══════════════════════════════════════"

if [ "$FAIL" -eq 0 ]; then
  echo "  🟢 全部通过！"
  exit 0
else
  echo "  🔴 有 $FAIL 项失败，请修复。"
  exit 1
fi
