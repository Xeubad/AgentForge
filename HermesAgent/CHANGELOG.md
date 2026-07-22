# HermesAgent 配置仓库变更日志

> 本文件记录 **本配置仓库自身**的演化历史。
> 不要把"使用本配置后在真实部署里的运行进度"写到这里 —— 那归 `~/.hermes/tasks/`。

按版本倒序记录。

---

## v1.2 — 2026-06-26（收敛阶段增强：主动提问机制）

> 主线：增强「收敛」和「侦察」阶段，让 Sphinx 在任务启动时主动确认关键信息，避免盲目执行。

### 变更（M 级）

- **M1 · 收敛阶段主动提问**：`HERMES.md`「3.1 收敛」段新增「主动提问机制」。当任务描述模糊或缺少关键信息时，Sphinx 在侦察阶段主动向用户确认（涉及代码/外部系统/Skill/多 Profile/Gateway 五个维度）。用户说「跳过」可跳过。
- **M2 · 侦察阶段增强**：`HERMES.md`「3.2 侦察」段扩充为「先读、先问、不先写」。新增：不清楚范围的问用户确认、没文档的问用户提供、涉及多 Profile 的确认上下文。侦察发现记录到 `tasks/daily-log.md`。

### 验证（证据）

- `HERMES.md` 收敛段新增 5 个维度的提问示例
- `HERMES.md` 侦察段从 4 条扩充为 5 条，新增多 Profile 上下文确认

### 未验证项（风险）

- 主动提问机制在实际 Hermes 会话中的执行效果需要验证。下一步：启动 Hermes 会话，观察 Sphinx 是否会在侦察阶段主动提问。

---

## v1.1 — 2026-06-14（接入外部记忆 backend 的护栏与候选 Skill 池）

> 主线：参考 2026 年 5-6 月中文社区三篇 Hermes 实战复盘（agentmemory / Hindsight 接入、8 Skill 清单），补两类配置：外部记忆 backend 接入护栏，Skill 评估候选池。**不改任何现有 SOUL / Profile / 三阶段流转规则**。

### 变更（H 级）

- **H1 · 新建 `shared/guards/memory-backend-policy.md`**：把外部记忆 backend 接入的 6 类真实踩坑转成护栏——retain/consolidation 必须轻量模型（已见 300+ 秒超时）、记忆 API 禁止进 Gateway command allowlist（已见 `hindsight_recall: command not found`）、后台工具白名单同步、端口漂移防护、weekly-audit 输出后端运维快照、provider 切换走 staging。明确"开箱即用对外部 backend 从不成立"，调优周期 2-3 周。

### 变更（M 级）

- **M1 · 新建 `shared/skills/skill-wishlist.md`**：建立 Skill 评估候选池。把第三方公众号文章的 8 Skill 转成候选清单（不写实现），每条标注主要风险，明确"候选 ≠ 白名单"，必须走完三阶段流转才能可用。其中 `personal-memory` 标记为 rejected（已被 Hermes 内置记忆体系覆盖），`browser-session-reuse` / `browser-automation` 标记为高风险默认 reject 倾向。
- **M2 · `README.md` 新增「记忆 provider 选型」段**：列 mem0 / agentmemory / hindsight 三种 provider，按数据主权 + 调优周期 + 适合场景对比，**不偏袒任一方案**。明确标注数据来源是公众号实测复盘非官方背书，并指向 memory-backend-policy.md 的 6 类必读踩坑。
- **M3 · `profiles/_shared.yaml` 改动**：
  - `_guards_default` 新增 `memory_backend_policy` 字段引用
  - `_memory_shared` 新增 `provider: "markdown"` 字段（默认值，可插拔）和 `backend:` 子段（retain_llm / consolidation_llm / port_file / fallback_to_markdown_on_unhealthy / weekly_audit_emit_backend_snapshot 五个配置点）
  - 块顶部注释列出 4 个候选 provider + 切换不可逆警告
- **M4 · `shared/guards/memory-write-policy.md` 新增第 11 节**：「接外部记忆 backend 时的衔接」——明确本文件管"写什么"，memory-backend-policy 管"backend 怎么跑"，两道闸都过才能写。
- **M5 · `HERMES.md` 第 5 节末尾追加一句**：指向 memory-backend-policy.md，让接外部 backend 时主线规则与 guards 联通。

### 变更（L 级）

- 无

### 验证（证据）

- `shared/guards/memory-backend-policy.md` 创建成功，含 8 节（适用范围 / LLM 后端分工 / 工具路由白名单 / 连接配置 / 整合成本观察 / Provider 切换流程 / 三大 provider 速查 / 反模式）
- `shared/skills/skill-wishlist.md` 创建成功，含 8 个候选条目 + 状态机（wishlist→quarantined→reviewing→promoted/rejected）
- `_shared.yaml` 改动只触及两个 anchor（`_guards_default` 加一行、`_memory_shared` 新增 provider + backend 子段），不破坏已有 YAML anchor 结构
- `memory-write-policy.md` / `HERMES.md` 改动均为追加，不删改原内容
- 全程未动 6 SOUL 文件、未动 `skill-quarantine.md` / `gateway-security.md` / `irreversible-actions.md` / `prompt-injection.md`、未动 Profile 结构

### 未验证项（风险）

- 三个 provider 实测部署未在本地验证——本轮所有规则来自二手公众号实测复盘，**不是官方文档背书**。`README.md` 第 7 节列出的具体百分比（mem0 68.5%/97% / agentmemory 95.2% / hindsight 91.4%）属单一案例，不能外推。
- `_shared.yaml` 的 `_memory_shared.backend` 子段是新增字段，Hermes runtime 是否识别这些字段名（`retain_llm` / `port_file` / `fallback_to_markdown_on_unhealthy` / `weekly_audit_emit_backend_snapshot`）需对照官方 schema 验证。如果 runtime 不识别，需改为 provider 各自的原生配置语法。下一步：参照 Hermes 官方 config schema 校准字段名。
- `skill-wishlist.md` 的 8 个候选 Skill 都未进入 `.quarantine/`，纯属"等用户明确诉求再评估"的登记表。
- `memory-backend-policy.md` 第 5 节定义的异常阈值（retain > 30s / consolidation > 120s / token 进出比 > 2.0 / 周失败率 > 5%）基于单一案例的数量级估算，需在 staging profile 跑 2-3 周后调整。

### 事故记录

- 无。本轮全部为新增 + 追加，未做删改。

---
