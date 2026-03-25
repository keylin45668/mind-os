# Theory Pack: rational — 来源映射表

> 目的：给 README / meta / 模块头部提供统一索引，避免入口文档与模块来源漂移。
> 约定：外部来源优先写书、理论、方法；纯内部派生协议标注为“内部：...”

---

## 模块来源总表

| 模块 | 来源 |
|------|------|
| think/_index.md | 《思考，快与慢》 + 《穷查理宝典》 + 《第五项修炼》 |
| think/system-audit-method.md | 内部：《AI 协作思维框架 v2.0》 |
| think/quality-loop.md | 内部：AutoEvolve 跨会话迭代 |
| think/iterative-engine.md | 发散-收敛模型 + 信息论 + 红蓝对抗 + Mind OS 协作拓扑 |
| think/task-iterate.md | 内部：AutoEvolve 跨会话迭代 + 红蓝对抗 + 收敛判定 |
| think/task-iterate-signals.md | 内部：AutoEvolve 度量框架 + 收敛判定 |
| think/creative.md | SCAMPER + 类比迁移 + 约束创造力 + 发散-收敛模型 |
| think/bias-anchor.md | 《思考，快与慢》 |
| think/bias-wysiati.md | 《思考，快与慢》 |
| think/bias-loss-aversion.md | 《思考，快与慢》 |
| think/bias-planning.md | 《思考，快与慢》 |
| think/bias-peak-end.md | 《思考，快与慢》 |
| think/bias-overconfidence.md | 《思考，快与慢》 + 《穷查理宝典》 |
| think/bias-inference-ladder.md | 《第五项修炼》 |
| think/bias-competence-circle.md | 《穷查理宝典》 |
| think/bias-munger25.md | 《穷查理宝典》 |
| decide/rules.md | 艾森豪威尔矩阵 + 反转思维（《穷查理宝典》） |
| decide/antifragile.md | 《反脆弱》 + 《道德经》 |
| decide/competition.md | 《孙子兵法》 + 博弈论 + 《国富论》 |
| decide/models/meta.md | 《穷查理宝典》 |
| capture/rules.md | GTD + 蔡加尼克效应 |
| organize/rules.md | PARA |
| organize/execute.md | OKR + 关键路径法 + 最小可行步骤 + PDCA |
| knowledge/rules.md | Zettelkasten + 跨学科链接 + 《国富论》 |
| knowledge/learning.md | 费曼技巧 + 刻意练习 + 能力圈理论 + T 型知识结构 |
| review/rules.md | GTD Review |
| review/crystallize.md | 内部：宪法第五条（迭代即存在） + _architecture 经验沉淀规则 |
| review/session-audit.md | 内部：协作量化框架 + AutoEvolve 评估器 |
| review/session-rating.md | 内部：协作量化框架 |
| collaboration/rules.md | 延展心智论 + Licklider 人机共生 + 协作量化框架 |
| collaboration/dynamics.md | 《系统之美》 + 《第五项修炼》 + 《复杂》 |
| collaboration/learning-org.md | 《第五项修炼》 |
| collaboration/principles.md | 《原则》 + 协作量化框架 |
| collaboration/economics.md | 《国富论》 + 比较优势（Ricardo） |
| collaboration/evolution.md | 《物种起源》 + 适应性景观 + 生态位分化 |
| collaboration/communication.md | 《金字塔原理》 + BATNA-ZOPA + 《非暴力沟通》 + STAR 法 |

---

## 维护规则

1. 新增模块时，先写模块头部 `> 来源：`，再补本表。
2. `README.md`、`mind-os-core/README.md`、`meta.md` 只保留核心外部来源，不强行展开所有细粒度方法。
3. 内部派生协议必须标明“内部：”前缀，避免和外部理论混淆。

---

## 来源书写规范

模块头部统一使用一行：

```md
> 来源：...
```

具体规则：

1. 多个并列来源统一用 ` + ` 连接，不使用 `/`、顿号或无分隔连写。
2. 明确书名统一使用书名号，如 `《思考，快与慢》`、`《金字塔原理》`。
3. 内部派生协议统一以 `内部：` 开头，如 `内部：协作量化框架 + AutoEvolve 评估器`。
4. 若是“方法 + 出处说明”，保留方法名在前、出处放括号中，如 `反转思维（《穷查理宝典》）`。
5. 缩写方法可直接保留英文缩写，如 `GTD`、`PARA`、`OKR`、`PDCA`、`BATNA-ZOPA`。
6. 模块头部写细粒度来源；`README.md`、`meta.md` 只写核心外部来源，不承担完整索引职责。
7. 新增或修改来源时，同步检查本文件中的“模块来源总表”是否需要更新。
