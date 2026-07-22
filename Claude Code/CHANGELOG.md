# Claude Code 配置仓库变更日志

> 本文件记录 **本配置仓库自身**的演化历史。
> 不要把"使用本配置后在真实项目里的进展"写到这里 —— 那归 `<your-project>/tasks/`。

按版本倒序记录。

---

## v2.13 — 2026-07-15（技能调用集成：skill-manifest + init-skills + 技能链命令）

> 主线：cc-switch 管理的技能库与模板集成，建立「人格路由 + 技能推荐 + 命令编排」三层机制。

### 变更（H 级）

- **H1 · skill-manifest 系统**：新增 `tasks/skill-manifest.md` 项目级技能清单模板 + `.claude/commands/init-skills.md` 初始化命令。项目启动时 `/init-skills` 扫描 cc-switch 技能库，分析项目技术栈，生成包含技能列表、按项目类型推荐、按场景技能链、按人格推荐的完整 manifest。后续开发中 agent 每次开工先读 manifest 按场景选择技能。

### 变更（M 级）

- **M1 · 人格技能推荐表**：`.claude/persona-control.md` 速查表后新增「技能推荐（按人格）」段，7 人格各配推荐技能和使用场景。作为默认推荐基线，实际项目以 skill-manifest.md 覆盖。
- **M2 · start-session 技能感知**：`.claude/commands/start-session.md` 新增步骤 4——读取 skill-manifest.md 并按当前任务类型推荐适用技能。

### 变更（L 级）

- **L1 · fullstack-feature 技能链命令**：新增 `.claude/commands/fullstack-feature.md`，标准全栈功能开发流程。每一步标注人格、技能调用、触发条件和跳过条件，覆盖需求澄清 → 架构设计 → 实现 → 审查 → 验证 5 阶段。

### 设计说明

**三层架构**：
- 人格路由（persona-control.md）决定「谁来做」
- 技能推荐（skill-manifest.md）决定「用什么方法做」
- 命令编排（fullstack-feature.md）标准化「按什么顺序做」

**Skill 工具的触发原则**：Skill 不会自动加载，必须显式调用。模板通过「人格推荐基线 + 项目级 manifest + 命令编排」三层机制确保正确的技能在正确的时机被调用。

**cc-switch 集成点**：`init-skills.md` 提供 3 种扫描方式适配不同 cc-switch 版本，待用户确认实际路径后收紧。

### 验证（证据）

- `.claude/persona-control.md` 新增「技能推荐（按人格）」段，7 行，格式与速查表一致
- `tasks/skill-manifest.md` 模板 7 节完整，含技能列表、按项目类型推荐、5 种场景技能链、按人格推荐、排除项
- `.claude/commands/` 新增 2 个文件（init-skills.md、fullstack-feature.md），从 9 个增至 11 个
- `.claude/commands/start-session.md` 步骤从 7 步增至 8 步

### 未验证项（风险）

- `/init-skills` 的 cc-switch 扫描逻辑需用户确认实际路径结构后验证
- `skill-manifest.md` 在真实项目上的生成质量需要验证
- `fullstack-feature.md` 的完整流程执行效果需要在真实功能开发中验证

---

> 主线：融合 PersonalHub 项目实战经验，引入「完整架构快照」模式。让 AI 在中大型项目里能按项目自己的模式贴地干活，而不是给泛泛建议。

### 变更（H 级）

- **H1 · PROJECT_STRUCTURE.md 模板**：新增 `PROJECT_STRUCTURE.md` 项目根级模板，10 段完整架构快照（项目概述 / 技术栈 / 目录结构 / 后端架构 / 前端架构 / 环境变量 / 构建运行 / 模块开发规范 / 已知问题 / 设计决策）。这是从 PersonalHub 实战文档抽象出来的**跨技术栈通用模式**，比问卷式 `project-context.md` 更强大——它记录路由表、API 表、Handler 模板、设计决策等具体到「怎么在这个项目里写代码」的知识。
- **H2 · 文件读取优先级**：`CLAUDE.md`「开局问卷」段新增三级判断——`PROJECT_STRUCTURE.md`（权威） > `project-context.md`（轻量） > 完整问卷。有权威文档时只问 2 个会话级问题，没有时走完整问卷并询问是否生成 PROJECT_STRUCTURE.md。
- **H3 · 架构快照维护机制**：`CLAUDE.md` 新增「架构快照维护（强制）」段，定义 9 类变更（API / 表 / 模块 / 页面 / 环境变量 / 设计决策 / 已知问题 / CSS 变量 / JS 工具）对应的更新段和触发时机。防止 AI 完成变更后忘记同步文档。

### 变更（M 级）

- **M1 · 新增命令 `/generate-project-structure`**：AI 扫描项目代码后生成 PROJECT_STRUCTURE.md 初稿。硬约束：不编造、找不到证据的段留空、用户逐段审核后才落盘。
- **M2 · 新增命令 `/update-project-structure`**：AI 检查代码与快照的差异，生成新增/删除/修改/需决策四类差异报告。硬约束：不直接改文件，逐条经用户确认后再应用。
- **M3 · project-context.md 定位澄清**：`tasks/project-context.md` 头部新增与 `PROJECT_STRUCTURE.md` 的分工说明——本文件轻量（技术栈+偏好），PROJECT_STRUCTURE.md 完整（架构+决策），两者可共存。
- **M4 · README 更新**：分层图加入 PROJECT_STRUCTURE.md 一行；部署命令加入可选的 PROJECT_STRUCTURE.md 复制；新增「架构快照机制」使用说明段。commands 数从 7 更新为 9。

### 变更（L 级）

- L1：project-context.md 维护说明段新增与 PROJECT_STRUCTURE.md 的分工小节。

### 设计说明

**为什么需要 PROJECT_STRUCTURE.md**：用户实际使用 `project-context.md` 后发现「问卷式」的填空信息不够——AI 知道你用 React + Node，但不知道你的 API 命名约定、错误响应格式、Handler 骨架、CSS 变量名。在 500 行以下的小项目可以忽略，但 500 行以上就会出现「AI 每次都要重新猜项目模式」的问题。PROJECT_STRUCTURE.md 用「完整架构快照」解决这个问题。

**为什么放项目根而不是 tasks/**：PROJECT_STRUCTURE.md 是项目权威文档，与 README 同级，属于「给协作者看的架构说明」。放 tasks/ 会误认为它是运行态文件。

**为什么两个文件都保留**：
- 小项目只需 `project-context.md`（10 分钟填完）
- 中大型项目主用 `PROJECT_STRUCTURE.md`（自动生成 + 用户审核）
- 两个都存在时，AI 优先读 PROJECT_STRUCTURE.md，project-context.md 补充团队偏好等结构化不好放的信息

### 验证（证据）

- `PROJECT_STRUCTURE.md` 模板 10 段结构完整，与 PersonalHub 参考文档对齐
- `CLAUDE.md` 「开局问卷」段三级判断逻辑清晰，「架构快照维护」段 9 类变更映射完整
- `.claude/commands/` 新增 2 个命令文件，从 7 个增至 9 个
- `README.md` 分层图、部署命令、说明段三处同步更新
- `tasks/project-context.md` 定位澄清后不再与 PROJECT_STRUCTURE.md 职责重叠

### 未验证项（风险）

- `/generate-project-structure` 在真实项目上的生成质量需要验证——AI 是否会编造不存在的表 / 接口。下一步：在有 PROJECT_STRUCTURE.md 的项目（如 PersonalHub）里删除快照后重新生成，对比差异。
- 「架构快照维护」段的强制提示在实际会话中是否会被 Claude 遵守，需要验证。下一步：在部署了本配置的项目里做一次 API 新增，观察 Claude 是否主动提示更新第 5.5 段。
- `PROJECT_STRUCTURE.md` 模板对非 Web 项目（如纯 CLI、纯脚本）的适用性未验证——第 4/5 段可能大量留空。可能需要为不同项目类型准备不同模板变体。

---

## v2.11 — 2026-06-26（开局问卷 + 运维/审查触发词优化）

> 主线：解决「建议太泛」「不了解规范」「人格路由不准」「中后期遗忘」四个痛点，新增开局问卷机制和项目上下文持久化。

### 变更（H 级）

- **H1 · 开局问卷机制**：`CLAUDE.md`「先收敛目标」段新增「开局问卷（强制）」子节。每次新会话 Claude 必须先问 3-6 个问题再开工；已有 `project-context.md` 时只问 2 个会话级问题（本次目标 + 约束）。用户可说「跳过」跳过。
- **H2 · 项目上下文持久化**：新增 `tasks/project-context.md` 模板，存储项目类型、技术栈、当前阶段、团队规范等跨会话信息。首次问卷回答协助填写，后续会话直接读取，避免重复问基础问题。
- **H3 · 上下文保持机制**：`CLAUDE.md`「任务管理」段新增「上下文保持（强制）」子节。执行超过 3 步的任务时，每完成关键步骤主动更新 `session-handoff.md`，防止做到后面丢失开局信息。

### 变更（M 级）

- **M1 · 运维触发词扩充**：`persona-control.md`「排障 / 推进类」新增 10 个运维细分触发词（Docker / Nginx / 数据库运维 / 监控告警 / 性能调优 / 线上事故 / 服务器配置等）。
- **M2 · 审查触发词扩充**：`persona-control.md`「审查 / 把关类」新增 8 个审查细分触发词（前端品味 / 性能审查 / 依赖审查 / API 契约 / 配置审查 / 全面审查等）。
- **M3 · 运维类细分路由**：`persona-control.md`「任务补充路由」新增「运维类细分」段，覆盖 CI/CD / Docker / Nginx / 数据库 / 监控 / 服务器 / 部署策略 / 故障排查 / 安全运维 / 成本优化 10 个场景。
- **M4 · 混合场景路由规则**：`persona-control.md`「任务补充路由」新增「混合场景路由规则」段，5 条规则处理多类型任务：主类型优先、阶段切换、不确定先问、运维特殊处理、审查特殊处理。

### 变更（L 级）

- L1：`tasks/` 目录新增 `project-context.md` 模板文件。

### 验证（证据）

- `CLAUDE.md` 新增内容位置正确：开局问卷在「先收敛目标」段内，上下文保持在「任务管理」段内。
- `persona-control.md` 触发词扩充后，排障类从 3 条增至 13 条，审查类从 3 条增至 11 条，新增运维类细分 10 条、混合场景规则 5 条。
- `tasks/project-context.md` 模板结构完整，含项目基本信息、技术栈、当前阶段、团队规范四个核心段。

### 未验证项（风险）

- 开局问卷在真实会话中的执行效果需要验证——Claude 是否会真的先问问题再开工。下一步：在新项目中部署后启动会话，观察是否触发问卷。
- `project-context.md` 的跨会话持久化效果需要验证——下次会话是否能正确读取并跳过基础问题。下一步：填写一份真实 project-context.md 后重启会话验证。

---

## v2.10 — 2026-06-12（v2.9 审查问题修复）

> 主线：修复 v2.9 全仓审查发现的 4 高 / 6 中 / 6 低问题，并修复验证过程中新发现的 PowerShell 编码问题。

### 变更（H 级）

- **H4 · Stop hook 可见性**：`hooks/stop.sh` / `stop.ps1` 重构——官方文档中 Stop hook 退出码 0 的 stdout 不注入给模型，改为 **stderr 输出清单 + exit 2**；新增 `stop_hook_active` 守卫（hook 输入里该字段为 true 时直接 exit 0 放行），防止死循环。行为变化：每轮收尾会被拦截一次完成反思清单后再放行，属预期。
- **H2 · hooks 注册配置**：`settings.local.powershell.json` 的 `command` 从 `powershell.exe` + 非官方 `args` 数组合并为单字符串（路径用 `%USERPROFILE%`，不再依赖 PowerShell 变量展开）；两个 settings 文件移除非官方字段 `args` / `shell` / `statusMessage` / `async`，只保留 `type` / `command` / `timeout`。
- **H3 · lessons 分层统一**：`stop.sh` / `stop.ps1` / `README.md` 的"只写全局 lessons 铁律"统一为两层模型——跨项目成立写 `~/.claude/memory/lessons.md`，仅本项目成立写 `tasks/lessons.md`（与 CLAUDE.md / start hook 注入逻辑一致）。
- **H1 · `_archived` 假引用**：`persona-control.md` 改为"旧人格已于 v2.0 删除"；本文件 v2.0 条目处追加更正注记（保留历史原文）。

### 变更（M 级）

- **M1**：删除根目录遗留孤儿 `memory/`（内容为通用初始化原则，已被 GLOBAL-CLAUDE.md 覆盖；user-preferences.md 为 0 字节空文件）。
- **M2**：`CLAUDE.md` 新增"模板仓库豁免（仅本仓库适用）"节——本仓库改动只记 CHANGELOG，work-log / lessons 强制规则在本仓库内不执行。
- **M3**：`GLOBAL-CLAUDE.md`"自动记忆增强"改标"（设想，未实现）"，删除无官方依据的 `autoMemoryEnabled` / `autoDreamEnabled` 字段推荐（该推荐还与 v2.4"settings.json 只放 agent"矛盾）。
- **M4**：`tasks/feature-list.json` owner 枚举、`global-claude/memory/user-preferences.md` 人格路由偏好补 `aoi`。
- **M5**：4 个 hook 脚本头部注释从项目级相对路径部署改为全局 `~/.claude/hooks/` 绝对路径部署。
- **M6**：删除 `start.sh` / `start.ps1` 中永不命中的 `tasks/in-flight.json` 死分支（概念已由 feature-list 的 single_in_flight 承担），区块重新编号为 1-7；README 分层图同步去掉 in-flight。

### 变更（L 级）

- L1：README 验证表"按顺序测 4 件事"改 5，并去掉对已删除 `statusMessage` 闪现文案的预期。
- L2：claude-hud 表述从"官方插件"改"第三方插件"（两处）。
- L3：`start.sh` / `start.ps1` 全局 lessons 注入超过 150 行时输出合并提醒（保留 v2.7 全量注入，不截断）。
- L4：`stop.ps1` 双引号 here-string 改单引号 here-string，反引号不再需要双写转义，消除 `$` 插值风险。
- L6：`tasks/work-log.md` 示例日期 2026-06-01 → 2026-06-02，与 v2.4 对齐。
- **L5 判定为误报，未修**：已部署副本与仓库 `GLOBAL-CLAUDE.md` 同样使用中文弯引号（diff 验证除本轮 M3 改动外完全一致），不存在不一致。

### 新增（验证过程中新发现的问题）

- **PowerShell 5.1 编码三连修**（v2.9 审查未覆盖，实测 `start.ps1` 解析失败后定位）：
  - 两个 `.ps1` 加 UTF-8 BOM——无 BOM 时 PS 5.1 按 ANSI/GBK 解析含中文源码，多字节序列破坏引号/花括号结构，报"意外的标记"且行号错位；
  - 脚本开头强制 `[Console]::OutputEncoding = UTF8`——默认 OEM 代码页输出中文乱码；
  - `start.ps1` 全部 8 处 `Get-Content` 加 `-Encoding UTF8`——PS 5.1 默认按 ANSI 读无 BOM 的 markdown 文件。
- 维护注意：`.ps1` 文件重新保存时必须保留 BOM，否则解析回归。

### 验证（证据）

- `bash -n` 两个 sh 脚本通过。
- `stop.sh`：`echo '{}' |` → exit 2、stdout 0 字节、清单完整走 stderr；`'{"stop_hook_active": true}'` → exit 0。`stop.ps1` 同样四项全部通过。
- `start.sh` 实跑 exit 0，区块 1-7 输出齐全；`start.ps1` 实跑 exit 0，中文输出正常无乱码。
- 4 个 JSON（settings ×3 + feature-list）`python -m json.tool` 校验通过。
- 全仓 grep 确认无 `in-flight` / `_archived` / 旧 statusMessage 文案残留（CHANGELOG 历史记录除外）。

### 未验证项（风险）

- hooks 在真实 Claude Code 会话中的端到端行为（SessionStart stdout 注入、Stop exit 2 反馈给模型、`%USERPROFILE%` 在 hook 执行环境中的展开）需要重启 `claude` 会话观察，本轮无法执行。下一步：按 README 第 1 步重新部署 `~/.claude/hooks/` 与 `settings.local.json`，重启会话验证状态栏 `2 钩子` 与收尾拦截行为。

### 事故记录

- 修复 L5 时曾用 `sed 's/[“”]/"/g'` 处理 `GLOBAL-CLAUDE.md`，Git Bash 的 sed 按字节匹配字符类，损坏了全文多字节字符；已从部署副本 `~/.claude/CLAUDE.md` 整文件恢复并 diff 验证一致后重做改动。教训：含 CJK 文件的批量替换禁用 sed 字符类，改用 Edit 工具或 perl -CSD。

---

## v2.9 — 2026-06-12（全仓审查记录 · 只记录未修复）

> 主线：对全部 44 个文件做一次性配置审查（kanon 执行，主线程核实），结论 **Revise**。本版本只落盘审查发现，未修改任何被审查文件。

### 审查结论

总体：**Revise**——架构分层（全局/项目、settings 拆分、双份 agents 同步）正确，未发现安全隐患；但存在 4 个高级别问题，其中 2 个意味着核心机制可能从未真正生效。

### 高（必须修）

- **H1 · `agents/_archived/` 不存在**：`.claude/persona-control.md` 与本文件 v2.0"归档（不删）"均声称旧六人格归档到 `agents/_archived/`，实际该目录不存在（已核实，`agents/` 下仅 7 个现役人格）。修复：补建目录放回旧人格，或两处文案改为"已删除"。
- **H2 · PowerShell 版 hooks 配置疑似无效**：`global-claude/settings.local.powershell.json` 使用 `args` 数组传参，但官方 hooks schema 的 `command` 是单字符串、无 `args` 字段（`shell`/`statusMessage`/`async` 同样非官方字段，bash 版也用了后两者）。预期后果：实际只执行裸 `powershell.exe` 直到超时，脚本从未运行。修复：command 合并为单字符串并实测留证据。
- **H3 · lessons 写入位置规则自相矛盾**：`stop.sh`/`stop.ps1`/`README.md` 说"铁律：只写全局、不写项目 lessons"；而 `CLAUDE.md`/`GLOBAL-CLAUDE.md`/`tasks/lessons.md` 模板/`start.sh`（注入 `tasks/lessons.md`）采用两层模型。两套规则每次会话同时注入，行为分叉。修复：拍板保留两层模型，改掉 stop 脚本与 README 的"全局 only"表述。
- **H4 · Stop hook 反思清单可能从未被模型读到**：官方文档中 Stop hook 退出码 0 的 stdout 不注入给 Claude（仅 transcript 模式可见）；要让模型看到需 exit 2 + stderr 或 `{"decision":"block"}` JSON。v2.0/v2.7 声称的"强制反思/强制写经验"缺真实验证证据。修复：先实测可见性，再改造输出方式。

### 中

- **M1**：根目录 `memory/` 是 v1.x 遗留孤儿目录，与 `global-claude/memory/` 内容漂移（`memory/user-preferences.md` 为 0 字节空文件），README/部署命令均不认识它。建议删除或合并。
- **M2**：CLAUDE.md"每次对话必须更新 work-log"与 README"本仓库演化记 CHANGELOG、tasks/ 保持模板纯净"互斥，本仓库内干活必违反其一。建议在 CLAUDE.md 加模板仓库豁免条款。
- **M3**：`GLOBAL-CLAUDE.md`"自动记忆增强"节：`autoMemoryEnabled`/`autoDreamEnabled` 非官方 settings 字段；"settings.json 推荐开启"与 v2.4"settings.json 只放 agent 字段"矛盾；描述的 `UserPromptSubmit` 记忆 hook 实际不存在。建议删除或标注"未实现设想"。
- **M4**：v2.3 加 aoi 后两处枚举漏同步——`tasks/feature-list.json` 的 `owner` 字段说明、`global-claude/memory/user-preferences.md` 人格路由偏好均缺 aoi。
- **M5**：4 个 hook 脚本头部注释仍写项目级相对路径部署方式，与 v2.1 全局化及 lessons.md 中 [2026-05-28] 绝对路径经验相悖。
- **M6**：`start.sh`/`start.ps1` 读取的 `tasks/in-flight.json` 在模板和所有文档中均未定义，是永不命中的死分支，且与 feature-list 的 single_in_flight 概念重复。

### 低

- README"按顺序测 4 件事"实为 5 行（v2.2 加项后数字未改）。
- README 称 claude-hud 为"官方插件"，实为第三方社区插件。
- `start.sh` 全量注入全局 lessons.md 无体积上限，长期会膨胀吃上下文预算。
- `stop.ps1` 用双引号 here-string 包含大量反引号，易碎且有 `$` 插值风险，建议改单引号 here-string。
- `GLOBAL-CLAUDE.md` 多处中文弯引号与已部署版本不一致。
- `tasks/work-log.md` 示例日期（2026-06-01）与对应 v2.4 日期（2026-06-02）不一致。

### 已确认无问题

- `agents/` 与 `global-claude/agents/` 7 个人格文件逐一 diff 完全一致，frontmatter 完整。
- 7 个 `.claude/commands/` 命令文件齐全且与 v1.1 清单一致。
- 安全面干净：hook 脚本无注入面、settings 无过宽权限、`-ExecutionPolicy Bypass` 限于指定脚本属常规做法。
- `tasks/` 模板结构清晰，feature-list 为空数组，无假 passing。

### 修复优先级

H4（实测 Stop hook 可见性）→ H2 → H3 → H1 → M 级按序 → L 级。本次会话按用户要求仅更新 CHANGELOG.md，所有问题留待后续版本修复。

---

## v2.8 — 2026-06-08（编码纪律 + 记忆质量管理）

> 主线：融合 karpathy-guidelines 和 memory skill 的思路到 CLAUDE.md，让优化规则自动生效。

### 背景

用户安装了 40+ 个 cc-switch skills，发现"优化类型"的 skill 没有被调用的感觉。分析后发现：
- Skills 只注册 description 到 system prompt，完整内容不会自动注入
- 需要 `/skill-name` 显式触发，且每次对话只管一次
- memory-audit/evolution/intake 依赖 NeuralMemory 插件 API，与用户的 lessons.md 文件系统不兼容

### 新增

**`GLOBAL-CLAUDE.md` + `CLAUDE.md`**：

- **编码纪律（Karpathy 准则）**——5 条行为约束：
  - 先说不：主动推回不合理需求
  - 外科手术式修改：只碰必须改的，匹配现有风格
  - 200→50 原则：能简化就重写
  - 验证-循环：改完 → 验证 → 没过 → 再改
  - 每行可追溯：每行改动都能追溯到用户需求

- **记忆质量管理**——6 条 lessons.md 维护规则：
  - 写之前查重
  - 分类标注（纠正/踩坑/规则/偏好）
  - 具体 > 模糊
  - 带原因
  - 定期审计（90 天未引用 → 审视）
  - 不堆砌（5 弱 → 2 强）

### 为什么不直接集成 skills

- Skills 触发机制是 `/skill-name` 手动触发，不会自动生效
- memory-* skills 依赖 NeuralMemory 插件（nmem_recall 等），用户的记忆系统是文件
- 把核心规则写进 CLAUDE.md = 每次会话自动加载，不需要手动触发

---

## v2.7 — 2026-06-02（反馈循环闭环：经验检索 + 纠正强制沉淀）

> 主线：解决"开发过程中细节一直犯错、说了一直不检索修复"的问题。

### 问题分析

反馈循环断裂：用户纠正 → 模型口头确认 → 下次会话不记得 → 再犯同样的错。

| 断点 | 原因 |
|---|---|
| start.sh 只注入 lessons.md 最新 30 行 | 早期经验被截断，模型看不到 |
| start.sh 不注入 work-log.md | 上次做了什么、学到什么，模型不知道 |
| stop.sh 只"提醒"写经验 | 不强制，模型可能跳过 |
| 模型执行任务前不查经验 | 没有"先查再做"的习惯 |

### 变更

**`hooks/start.sh`**：
- lessons.md 从"最新 30 行"改为**全量注入**
- 新增 work-log.md 注入（最新 30 行）
- 新增项目级 lessons.md 注入
- 硬规则提醒新增：执行任务前先检查经验列表、用户纠正必须写经验

**`hooks/stop.sh`**：
- 新增"用户纠正检查"（最高优先级）：检测"不对/不要/别这样/错了"等表达，必须写经验
- 新增"工作日志更新"要求：每次对话必须更新 work-log.md
- 强化硬规则：用户纠正 → 必须写经验，不能省略

**`CLAUDE.md`**：
- 新增"先查经验再动手"步骤（工作流第 2 步）
- 强调：执行任务前检查 lessons.md 和 work-log.md

**`GLOBAL-CLAUDE.md`**：
- 默认工作习惯新增：执行前检查经验、纠正必须写经验、重复错误必须沉淀

### 效果

- 用户纠正 → stop.sh 强制写经验 → lessons.md 落盘
- 下次会话 → start.sh 全量注入 lessons.md → 模型看到相关经验
- 执行任务 → CLAUDE.md 要求先查经验 → 不重蹈覆辙
- 反馈循环闭环：纠正 → 沉淀 → 注入 → 检索 → 遵守

---

## v2.6 — 2026-06-02（工作日志 + 持久化记忆）

> 主线：让智能体越用越顺手——每次对话记录工作日志，每次会话沉淀经验。

### 新增

- **`tasks/work-log.md`**：工作日志模板，每次对话必须更新
  - 格式：时间倒序，每条有"做了什么 / 改了哪些文件 / 学到什么 / 下次注意"
  - 不写流水账，只写结论和收获
  - 超过 30 天的旧条目归档到 `progress.md`
- **`CLAUDE.md`**：新增"工作日志（强制）"和"持久化记忆（强制）"两段
  - 工作日志：每次对话必须更新 work-log.md
  - 持久化记忆：用户纠正过的经验必须落盘，同类错误第二次出现必须沉淀为规则
- **`GLOBAL-CLAUDE.md`**：同步新增两段

### 设计意图

- 工作日志 = 下一轮会话的上下文入口，不用重新猜
- 持久化记忆 = 越用越顺手，每次会话都在积累
- 两者互补：work-log 记"做了什么"，lessons 记"学到什么"

---

## v2.5 — 2026-06-02（人格自动路由强制指令）

> 主线：解决"人格不能自动根据需求切换"的问题。

### 问题

- `agent: "mio"` 让主线程默认是 mio，但用户说"写后端接口"时 mio 不会自动变成 rei
- persona-control.md 有路由规则，但只是"参考文档"，没有强制执行
- 模型不会主动判断"当前任务是否匹配当前人格"

### 新增

- **`CLAUDE.md`**：新增"人格自动路由（强制）"段，要求模型收到任务时先判断类型，不匹配就用 Agent 工具启动对应人格的 subagent
- **`GLOBAL-CLAUDE.md`**：同步新增相同指令

### 机制说明

- 路由判断基于 `.claude/persona-control.md` 的速查表（7 个岗位 → 7 个人格）
- 用户显式说"切到 X"时直接启动，不做额外判断
- 任务模糊时先澄清再决定，不强行路由

---

## v2.4 — 2026-06-02（hooks 配置拆分到 settings.local.json）

> 主线：把 hooks 配置从 `settings.json` 拆到 `settings.local.json`，防 `cc switch` 覆盖。

### 变更

- **`global-claude/settings.json`**：只保留 `{"agent": "mio"}`，不再放 hooks
- **`global-claude/settings.local.json`**：hooks 配置移到这里（bash 版）
- **`global-claude/settings.local.powershell.json`**：hooks 配置移到这里（PowerShell 版）
- **`README.md`**：
  - 第 1 步全局配置拆成 5 个子步骤，明确区分 `settings.json`（agent 字段）和 `settings.local.json`（hooks 配置）
  - 新增"为什么拆成两个文件"说明块
  - 一图看懂分层更新：`settings.powershell.json` → `settings.local.json`
  - 核心分层原则更新：`settings.json` 只放 agent，`settings.local.json` 放 hooks + 插件
  - PowerShell 兜底部分简化（不再需要覆盖 settings.json）

### 为什么拆

- `cc switch` 等工具会重写 `~/.claude/settings.json`
- hooks 配置放在里面会被覆盖，导致启动/收尾 hook 失效
- `settings.local.json` 不会被 `cc switch` 清理，Claude Code 自动合并两个文件

### 验证

- `settings.json` 只有 agent 字段，JSON 校验通过
- `settings.local.json` 只有 hooks 字段，JSON 校验通过
- `settings.local.powershell.json` 只有 hooks 字段，JSON 校验通过

---

## v2.3 — 2026-06-01（新增第 7 人格 aoi · 葵）

> 主线：团队从 6 人扩到 7 人，覆盖项目调研 / 需求澄清 / 方案推进岗位。

### 新增

- **`aoi`（葵 · 总管+侦探系 · 项目调研官）**
  - 文件：`agents/aoi.md`（含完整 YAML frontmatter）
  - 同步到 `global-claude/agents/aoi.md`（双份保持一致）
  - 106 行，含：角色定位 / 反差萌设定 / 核心气质 / 说话方式 / 方法论偏好 / 工作偏好 / 协作方式 / 危险操作 / 边界与禁忌 / 适合场景 / 不适合场景 / 示例台词
  - description 字段触发关键词：调研 / 需求澄清 / WBS / 里程碑 / RACI / 风险矩阵 / 周报 / 交接 / ADR / PM / 立项 / 干系人 等

### 变更

- **`GLOBAL-CLAUDE.md`**：全局人格段从"6 个角色"升级为"7 个角色"，新增 aoi 行 + 切换人格列表补 aoi
- **`.claude/persona-control.md`**：完整重写为 7 人格版（165 行），新增：
  - 调研类"调研/推进"路由段（aoi 主场）
  - 调研类细分路由（立项 / 竞品摸底 / 需求问卷 / 方案模板 / ADR / 周报）
  - 显式触发示例加 3 条 aoi 变体
  - 协作模式表加 3 条 aoi 路径（新项目从需求到上线 / 事后 ADR / 新人接手交接）
  - 岗位边界段：aoi vs nagi（做什么 vs 怎么做）/ aoi vs kanon（节奏门 vs 质量门）
- **`README.md`**：速查表已是 7 行版本（含 aoi）；一图看懂分层注释从"6 个"改为"7 个"

### aoi 与现有 6 人格的边界划分

| 维度 | aoi | 其他人格 |
|---|---|---|
| 需求澄清 | ✅ 主理 | — |
| 架构技术决策 | ❌ 切 nagi | nagi 主理 |
| 上线决策 | ❌ 切 kanon + 用户 | kanon 主理 |
| 写代码 | ❌ 切 mio / rei | 实现岗主理 |
| 排障 | ❌ 切 yuki | yuki 主理 |
| 交接文档 | ✅ 主理 | shion 辅助讲解 |
| WBS / 里程碑 / 风险 | ✅ 主理 | — |
| 周报 / 状态同步 | ✅ 主理 | — |

---

## v2.2 — 2026-06-01（集成 claude-hud HUD 插件）

> 主线：引入 [jarrodwatts/claude-hud](https://github.com/jarrodwatts/claude-hud) 给 Claude Code 状态栏加多行可视化 HUD。

### 新增

- **README 部署流程第 3 步**：装完我们的配置后跑三条命令安装 HUD 插件
  - `/plugin marketplace add jarrodwatts/claude-hud`
  - `/plugin install claude-hud`
  - `/claude-hud:setup`（推荐选 Full preset）
- **HUD 显示验证项**（README 验证表第 5 条）
- **claude-hud 常见坑表**：EXDEV、Windows 不用 Bun、字段冲突、usage 超时等 6 类

### 共存设计（关键决策）

- 我们的 `settings.json` 字段：`agent` + `hooks.SessionStart` + `hooks.Stop`
- claude-hud 写入的字段：`statusLine`
- **三者顶层并列，互不覆盖** —— `/claude-hud:setup` 会读现有 JSON 做 merge，只追加 statusLine 块
- 如果 settings.json 是非法 JSON 才会被全量覆盖（这是 claude-hud 的安全策略，会先报错不写）

### 为什么不预写 statusLine 到 global-claude/settings.json

- claude-hud setup 会做**运行时检测**：平台 / Node 或 Bun / 终端列数 / 已安装插件版本路径
- 我们硬编码这些值会僵化，插件升级后路径过期
- 让 setup 自己写是官方推荐路径，自动跟随升级

### 验证

- README 部署流程更新后，新用户走完三步即拥有完整 HUD
- settings.json schema 不变（我们的字段不动）
- 全局 hooks 与 statusLine 同时显示在状态栏（`2 钩子` + 多行 HUD）

### 与其他状态栏插件的对比（未集成，仅参考）

- `claude-powerline`（Owloops）：vim-style powerline 风格
- `yet-another-statusline`（tmck-code）：另一种 statusline 实现

如果你想换插件，把 `/claude-hud:setup` 改为对应插件的 setup 命令即可。本套 hooks/agent 配置与具体 statusLine 实现无关。

---

## v2.1 — 2026-05-28（hooks 全局化）

> 主线：把 hooks 从"项目级重复部署"升级到"全局一次部署、所有项目自动受益"。

### 变更（架构调整）

- **`.claude/hooks/` 整体搬到 `~/.claude/hooks/`**（全局）
  - 之前：每个新项目都要 `cp` 4 个脚本 + 1 个 settings.json 并 chmod +x
  - 之后：全局部署一次，任意项目里 `claude` 启动都自动触发
- **`.claude/settings.json` 搬到 `~/.claude/settings.json`**（全局，注册全局 hook）
- **hook 命令路径从相对改绝对**：`.claude/hooks/start.sh` → `$HOME/.claude/hooks/start.sh`（Windows PowerShell 版用 `$env:USERPROFILE\.claude\hooks\start.ps1`）

### 仓库结构调整

- 新增 `Claude Code/global-claude/` 目录，模拟 `~/.claude/` 完整布局
  - 包含：`hooks/`（4 脚本）+ `settings.json` + `settings.powershell.json` + `agents/`（6 人格）+ `memory/`（含 lessons.md 和 user-preferences.md 模板）
  - 部署时一行 `cp -R global-claude/. ~/.claude/` 完成全局部分
- `Claude Code/.claude/` 瘦身：只保留 `persona-control.md` + `frontend-rules.md` + `commands/`（7 个 slash 命令）
- 项目级部署从"5 行 cp + chmod"简化为"3 行 cp"（无 chmod，因为脚本不在项目里）

### 关键设计点

- **hook 脚本本体未改**：原脚本读 `tasks/` 用相对路径（`if [ -d "tasks" ]`），全局 hook 触发时 `pwd` 就是项目根，自动相对正确目录
- **memory 路径本来就是绝对**（`$HOME/.claude/memory/`），跨场景一致
- **新增 `~/.claude/memory/user-preferences.md` 模板**：跨项目共享用户偏好（默认人格、技术栈、协作风格等）

### 影响

- 新项目接入成本从"5 步"降到"3 步"
- 所有项目自动获得"启动注入 + 收尾反思"能力，不再需要意识到"这个项目部署 hook 没"
- "hook 没生效但又找不到原因"的故障面消失（之前可能是项目里 `.claude/settings.json` 漏 cp 或 `chmod` 漏跑）

### 验证

- `settings.json` schema 校验通过（`$HOME/.claude/hooks/xxx` 是合法 command 值）
- `settings.powershell.json` schema 校验通过
- 状态栏 `2 钩子` 显示成功识别全局 hook
- 跨项目切换无需重新部署 hook

---

## v2.0 — 2026-05-27（活 Agent 化重构）

> 主线：从"靠模型自觉读规则"升级到"靠机器触发自动注入"。

### 新增

- **Hooks 系统**（核心独家点）
  - `.claude/hooks/start.sh` + `.claude/hooks/start.ps1`：会话启动时自动注入 `tasks/`（项目级）+ `~/.claude/memory/`（全局）上下文
  - `.claude/hooks/stop.sh` + `.claude/hooks/stop.ps1`：会话结束前自动弹出反思清单，强制提醒落盘 lessons / handoff / progress
  - `.claude/settings.json`：注册两个 hooks，默认 agent: mio
  - `.claude/settings.powershell.json`：PowerShell 用户备用版

- **二次元少女全栈开发工程师团队**（替换旧六人格）
  - `mio` 澪（冰山系）→ 前端实现
  - `rei` 玲（病娇系）→ 后端 / API
  - `nagi` 凪（三无系）→ 全栈架构
  - `kanon` 花音（大小姐系）→ 代码审查
  - `yuki` 雪（元气系）→ DevOps / 排障
  - `shion` 紫苑（学姐系）→ 教学讲解

- **全局/项目分层架构**
  - 全局：`~/.claude/memory/` 跨项目共享长期经验
  - 项目级：`<project>/tasks/` 各项目独立运行态
  - Hook 启动时自动**同时**读两处

### 变更

- `GLOBAL-CLAUDE.md` @ 引用：`kuudere-engineer.md` → `mio.md`
- `.claude/persona-control.md` 完整重写，含 6 人格路由表 + 协作流水线
- `.claude/settings.json` 默认 agent：`kuudere-engineer` → `mio`
- README 重写为纯部署手册（Win Git Bash / Mac 双环境，1 行 `cp -R .claude/` 一步部署）

### 归档（不删）

- 旧六人格（rin / haru / en / yuzu / aura / kurohomura）→ `agents/_archived/`
  - **[v2.10 更正]** 实际执行时未保留归档目录，旧人格已直接删除；`agents/_archived/` 从未存在。相关引用已在 v2.10 修正。

### 删除

- `hooks_setup/` 中转目录 —— 早期因为以为 `.claude/` 写保护建的，后来发现 bash 工具可直接写，已合并进 `.claude/` 消除冗余

### 验证

- 6 人格 frontmatter schema 校验通过（name / description / tools / model 字段完整）
- settings.json schema 校验通过（agent 字段官方支持）
- hooks 脚本 bash 与 PowerShell 两套并行，跨平台覆盖
- 新人格 description 关键词触发可被 Subagent 自动路由识别

---

## v1.2 — 2026-05-19（人格生效链路修复）

> 主线：发现"配置部署了但人格完全没生效"的 4 个断点，全部修复。

### 诊断的根因（4 个断点）

1. **agents/ 在项目根**：Claude Code 只识别 `.claude/agents/` 或 `~/.claude/agents/`
2. **人格文件缺 YAML frontmatter**：纯 Markdown 文件不会被注册为 Subagent
3. **`.claude/settings.json` 的 `"agent"` 字段被误判为不合法**（实际官方 schema 支持）
4. **`.claude/persona-control.md` 不会自动加载**：必须靠 CLAUDE.md 显式 `@` 引用

### 修复

- 6 人格全部补 `name / description / tools / model` frontmatter
- `CLAUDE.md` 加 `@.claude/persona-control.md` 和 `@.claude/frontend-rules.md` 引用
- `GLOBAL-CLAUDE.md` 加 `@~/.claude/agents/kuudere-engineer.md` 默认人格注入
- `.claude/settings.json` 保留 `"agent"` 字段（已校验合法）

---

## v1.1 — 2026-05-01（Harness 工作法集成）

> 主线：把 https://walkinglabs.github.io/learn-harness-engineering/zh/ 完整方法论融进配置体系。

### 新增

- `CLAUDE.md` / `GLOBAL-CLAUDE.md` 加入：仓库唯一事实来源、五子系统、冲刺合同、三层完成检查、可观测性、冷启动审计、清洁状态、harness 简化
- 7 个 slash 命令：`/start-session` `/finish-session` `/evaluate` `/cold-start-audit` `/clean-state-check` `/observability-contract` `/quality-snapshot`
- `tasks/` 模板：`progress.md` `session-handoff.md` `feature-list.json` `quality.md`

### 已知风险（v1.1 当时未解决，v2 才彻底解决）

- 命令模板未经真实任务校准（v2 通过 hooks 强制注入解决）
- tasks/ 模板有"过期化石化"风险（v2 通过 Stop hook 反思清单解决）

---

## v1.0 — 2026-04（仓库初始化）

> 主线：建立 Claude Code 配置仓库的基础结构。

### 新增

- `CLAUDE.md`（项目效率宪法）
- `GLOBAL-CLAUDE.md`（全局模板）
- `.claude/persona-control.md`（人格路由）
- `.claude/frontend-rules.md`（前端约束）
- 第一版六人格（rin / haru / en / yuzu / aura / kurohomura）

---

## 维护原则

- 每个版本号下分 4 个子段：**新增 / 变更 / 归档 / 删除**（可选）+ **验证 / 已知风险**
- 版本号语义：`大版本.小版本`，大版本 = 架构级变化（如 v1→v2 引入 hooks），小版本 = 功能增量
- 新版本追加到**顶部**
- 不删除历史版本条目，旧版本作为演进档案保留

---

## 与 tasks/ 的边界（重要）

| 内容 | 写到哪 |
|---|---|
| 本配置仓库自身的版本演化 | **CHANGELOG.md（本文件）** |
| 部署到真实项目后那个项目的开发进度 | 那个项目的 `tasks/` |
| 跨项目通用的踩坑经验 | `~/.claude/memory/lessons.md`（全局） |
| 仅对某个具体项目成立的经验 | 那个项目的 `tasks/lessons.md` |

不要混。
