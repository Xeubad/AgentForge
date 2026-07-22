# 仓库目标

- 本仓库是 **6 套面向不同 AI 工具的高效率配置方案合集**，用于沉淀跨工具的提示词工程与协作规则。
- 本文件**只给 AI 读**——用于让进入本仓库的 AI 快速路由到正确子目录，理解每个子目录的边界和定位。
- 给人看的操作说明在各子目录的 `README.md`。
- 默认输出语言为中文。

# 仓库定位

本仓库不是一个软件项目，而是一个**配置模板仓库**：

- 每个子目录是一套**独立的 AI 工具优化方案**，可单独复制到目标位置部署
- 子目录之间**不共享代码、不共享配置文件**，只在共同骨架（高效率原则）上语义对齐
- 子目录内的修改不会影响其他子目录——改 Claude Code 的人格不会同步到 Codex

# 子目录速查表

| 子目录 | 工具 | 部署形态 | 入口文件（AI 读） | 人格机制 |
|---|---|---|---|---|
| `Claude Code/` | Anthropic Claude Code CLI | 全局 `~/.claude/` + 项目级 `.claude/` | `Claude Code/CLAUDE.md`、`Claude Code/GLOBAL-CLAUDE.md` | **7 人格自动路由**（subagent + frontmatter 触发） |
| `CodeX/` | OpenAI Codex CLI | 全局 `~/.codex/` + 项目级 `.codex/` | `CodeX/AGENTS.md`、`CodeX/GLOBAL-AGENTS.md` | 6 子代理（toml 配置） |
| `HermesAgent/` | Nous Research Hermes Agent | 仅全局 `~/.hermes/`，多 Profile | `HermesAgent/HERMES.md` | 6 SOUL（希腊神话主题，SOUL.md 灵魂驱动） |
| `OpenClaw/` | OpenClaw 数字员工 | 仅全局 `~/.openclaw/`，跨任务唯一 | `OpenClaw/CLAW.md` | 6 人格（海洋主题，yaml 定义） |
| `cursor/` | Cursor IDE | 项目级 `.cursor/rules/*.mdc` | `cursor/Cursor 高效开发规则.md`、`cursor/.cursorrules` | 无人格机制 |
| `人格提示词/` | **独立于 AI 软件的第三方人格库** | 散件 prompt，由用户手动粘贴使用 | 单文件 prompt（如 `基金经理人.md`） | 散件领域人格（跨工具通用） |

# 共同骨架（6 套都遵循）

无论进入哪个子目录工作，以下原则始终生效——这是跨工具的语义底座：

## 原则优先级
- 安全性 > 正确性 > 效率 > 风格
- 人格 / 风格只影响协作语气，**不能覆盖**安全规则、正确性标准和验证要求

## 工作流
- **先收敛目标**：动手前明确做什么、不做什么、验收标准
- **先读后改**：修改前阅读相关文件，确认现状和已有约定
- **先查经验**：开工前检查该子目录的 `memory/lessons.md`（如有），不重蹈覆辙
- **最小闭环**：一次只推进一个明确功能，不顺手扩写
- **验证优先**：没有验证证据不算完成；`passing` 必须有可复查证据
- **完成判定**：`Accept / Revise / Block` 三档，证据不足不能给 Accept

## 文件分工（所有子目录通用）
- `tasks/` → 运行态进度、交接、in-flight（项目级，跨会话）
- `memory/` → 长期可复用经验（跨任务）
- `README.md` → 给人看的部署 / 操作说明
- `CLAUDE.md` / `AGENTS.md` / `CLAW.md` / `HERMES.md` → 给 AI 看的执行规则

## 不要做的事
- 不在没读现有配置时凭想象改文件
- 不把"看起来跑通"当成完成证据
- 不为完成当前任务破坏原有分层和边界
- 不在子目录之间复制规则——同一条规则只在一处维护

# 各子目录差异化要点

## Claude Code/
- **唯一具备「人格自动路由」机制的子目录**——通过 subagent + frontmatter `description` 字段触发，主线程会按任务类型自动启动对应人格的 subagent
- 7 人格：`mio`（前端）/ `rei`（后端）/ `nagi`（架构）/ `kanon`（审查）/ `yuki`（DevOps）/ `shion`（教学）/ `aoi`（PM）
- 双层部署：全局 `~/.claude/` 放 hooks/agents/memory，项目级 `.claude/` 放 persona-control / frontend-rules / commands
- 入口：`Claude Code/GLOBAL-CLAUDE.md`（全局规则模板）+ `Claude Code/CLAUDE.md`（项目规则模板）
- 详细路由表在 `Claude Code/.claude/persona-control.md`

## CodeX/
- 6 子代理通过 `.codex/agents/*.toml` 定义，不是自动路由——需要用户**显式调用**
- 主入口 `AGENTS.md`（项目级），全局模板 `GLOBAL-AGENTS.md` 部署到 `~/.codex/AGENTS.md`
- 项目级 `.codex/config.toml` 只在可信项目中加载——首次使用需信任确认
- 子代理：`rin / haru / en / yuzu / aura / kurohomura`

## HermesAgent/
- **仅全局部署**，无项目级——Hermes 是常驻数字使者，不绑定仓库
- **多 Profile 隔离**（coder / writer / ops），用 `profiles/_shared.yaml` 的 YAML anchor 复用公共片段
- 6 SOUL 通过专属 `SOUL.md` 文件激活，运行时可切换
- **独有风险点**：自创 Skill 投毒、跨平台 Gateway 注入、MEMORY 漂移
- 关键护栏：`shared/guards/skill-quarantine.md`（Skill 三阶段流转）、`shared/guards/gateway-security.md`、`shared/guards/memory-write-policy.md`

## OpenClaw/
- **仅全局部署**，**禁止**在任何项目目录里再放 `.openclaw/`——会导致两份 lessons / 白名单互相漂移
- 6 人格承载权限分层（`diver` 只读、`lighthouse` 一票否决）
- **独有风险点**：Skill 白名单投毒、Heartbeat / Cron 自动副作用、不可逆动作
- 任务串行：跨工作目录也只允许一条 `in_progress`，避免上下文撕裂

## cursor/
- **无人格机制**——纯规则驱动
- 推荐 `.cursor/rules/*.mdc` 分层（00-agent-workflow / 10-frontend / 20-backend / 90-quality-gate）
- 旧版 `.cursorrules` 仅作兼容入口，新规则不要堆进单文件
- `alwaysApply: true` 用于全局行为，`globs` 用于按文件路径精准命中

## 人格提示词/
- **独立于 AI 软件配置**——不属于上面任何工具的人格系统
- 是**散件领域人格库**：跨工具通用的第三方 prompt（金融 / 法务 / 翻译 / 行业专家等）
- 当前内容：`基金经理人.md`
- 使用方式：用户手动复制 prompt 粘贴到任意 AI 工具的对话或系统提示词中
- **不要**把这里的人格塞进 Claude Code / Codex / Hermes / OpenClaw 的人格配置——它们是两套体系

# 任务路由

收到任务时，按目标定位到对应子目录：

| 用户意图 | 去哪 |
|---|---|
| 改 Claude Code 配置 / 人格 / hooks | `Claude Code/` |
| 改 Codex 配置 / 子代理 | `CodeX/` |
| 改 Hermes SOUL / Profile / Skill 治理 | `HermesAgent/` |
| 改 OpenClaw 人格 / Skill 白名单 / Heartbeat | `OpenClaw/` |
| 改 Cursor 规则 | `cursor/` |
| 新增 / 编辑领域人格 prompt（跨工具） | `人格提示词/` |
| 跨工具共同规则（如统一"先读后改"措辞） | 本文件「共同骨架」段 |
| 新增一个 AI 工具的配置方案 | 本仓库根新建子目录，按现有 6 个子目录的形态写 |

# 维护原则

- **子目录内的人格、命令、配置只在该子目录内维护，不抽到根**——避免跨工具规则冲突
- **本根 CLAUDE.md 只做路由和共同骨架**，不重复任何子目录细节
- **现状人格机制不强行统一**：Claude Code 有自动路由、Codex/Hermes/OpenClaw 是不同形态的预设人格、Cursor 无人格、人格提示词是散件——按现状描述就行
- **新增工具时**：在「子目录速查表」加一行、在「各子目录差异化要点」加一段、在「任务路由」加一条；不要重写其他子目录的描述
- **删除工具时**：删除子目录后同步删除上述三处的对应条目，不要留死链接

# 仓库变更日志（强制）

本仓库根目录维护 `CHANGELOG.md`，记录**仓库级**演化。

## 写入边界（只记这 4 类）

1. **新增 / 删除子目录**（如以后加 `Gemini CLI/`）
2. **根 `CLAUDE.md` 自身规则变更**（如新增段落、调整路由表）
3. **跨多个子目录的同步性调整**（如统一改"先读后改"措辞）
4. **共同骨架原则调整**（如优先级顺序变更）

## 不要记的（属于子目录自己的 CHANGELOG）

- 子目录内部演化（如 Claude Code 新增人格、Codex 改子代理配置、Hermes 改 SOUL）
- 子目录内部 bug 修复、规则调整、文件重构
- 子目录的 README / 入口文件改动
- 任何只影响单个子目录、不上抛到根的变更

子目录内部改动各自在 `<子目录>/CHANGELOG.md` 维护，不上抛根 `CHANGELOG.md`，避免重复。

## 格式（与子目录 CHANGELOG 统一）

按版本倒序，每个版本结构如下：

```
## v<版本> — YYYY-MM-DD（一句话主线）

> 主线：……

### 变更（H 级）
- 高优先级：影响仓库级路由、子目录增删、共同骨架原则的变更

### 变更（M 级）
- 中优先级：根 CLAUDE.md 段落调整、跨子目录措辞统一

### 变更（L 级）
- 低优先级：文档措辞、表格补全、链接修正

### 验证（证据）
- 实际执行的检查命令和结果

### 未验证项（风险）
- 本轮未能验证的部分，下一步动作

### 事故记录（如有）
- 操作过程中的失误、回滚、教训
```

H/M/L 分级以"影响面 × 不可逆性"判定：影响仓库级路由或多个子目录 = H；只动根 CLAUDE.md 一段 = M；文档措辞 = L。

# 输出评估维度

- **正确性**：实现行为是否符合目标
- **验证**：要求的检查是否真的跑过，并留下证据
- **范围纪律**：是否保持在选定子目录内，没有顺手改别的子目录
- **可维护性**：代码和配置是否清楚到足以交给下一轮维护
- **交接准备度**：新会话是否能只靠仓库文件继续推进
- 评估结论使用 `Accept / Revise / Block`；证据不足不能给 `Accept`
