# OpenClaw 配置仓库变更日志

> 本文件记录 **本配置仓库自身**的演化历史。
> 不要把"使用本配置后在真实部署里的运行进度"写到这里 —— 那归 `~/.openclaw/tasks/`。

按版本倒序记录。

---

## v1.2 — 2026-06-26（收敛阶段增强：主动提问机制）

> 主线：增强「收敛」和「侦察」阶段，让任务启动时主动确认关键信息，避免盲目执行。

### 变更（M 级）

- **M1 · 收敛阶段主动提问**：`CLAW.md`「2.1 收敛」段新增「主动提问机制」。当用户指令模糊或缺少关键信息时，`diver` 在侦察阶段主动确认（涉及代码/Skill/外部系统/定时任务/多工作目录五个维度）。用户说「跳过」可跳过。
- **M2 · 侦察阶段增强**：`CLAW.md`「2.2 侦察」段扩充为「先读、先问、不先写」。新增：不清楚范围的问用户确认、没文档的问用户提供、涉及 Skill 的查白名单。侦察发现记录到 `tasks/daily-log.md`。

### 验证（证据）

- `CLAW.md` 收敛段新增 5 个维度的提问示例
- `CLAW.md` 侦察段从 4 条扩充为 5 条，新增 Skill 白名单检查

### 未验证项（风险）

- 主动提问机制在实际 OpenClaw 会话中的执行效果需要验证。下一步：启动 OpenClaw 会话，观察 `diver` 是否会在侦察阶段主动提问。

---

## v1.1 — 2026-06-14（部署手册重写 + 官方文档对齐）

> 主线：基于 OpenClaw 官方文档重写 README.md 部署手册，覆盖 Win/Mac/Ubuntu 三平台的安装、配置、持久化服务（开机自启）、Gateway、日常运维。

### 变更（H 级）

- **H1 · `README.md` 全文重写**：从原版的"结构概览 + 安装映射 + 独家点说明"升级为完整部署手册。新增以下内容：
  - 三平台安装命令（PowerShell / bash），来源 [官方安装文档](https://docs.openclaw.ai/zh-CN/install)
  - 三平台持久化服务配置（Windows 计划任务 / macOS LaunchAgent / Linux systemd user service），含官方命令 + 手动备用方案
  - Linux `loginctl enable-linger` 关键步骤（否则 SSH 断开后服务停）
  - Gateway 配置（端口 / 绑定 / 认证 / 热重载 / 远程访问 / OpenAI 兼容端点）
  - 日常运维（更新 / 日志 / 诊断 / 备份 / 端口变更后操作）
  - 常见故障表（8 个症状 + 原因 + 解法）
  - 信息来源标注（官方文档链接 + 本仓库自定义配置）

### 变更（M 级）

- **M1 · 官方文档关键信息对齐**：
  - 确认 GitHub 仓库地址为 `github.com/openclaw/openclaw`（非 nicepkg）
  - 确认 Node 24 推荐 / Node 22.16+ 最低
  - 确认 Gateway 默认端口 18789（非自定义）
  - 确认持久化机制：macOS=LaunchAgent（`ai.openclaw.gateway`）/ Linux=systemd user service / Windows=Task Scheduler（被拒则回退启动文件夹）
  - 确认 `openclaw gateway install` / `openclaw doctor` / `openclaw logs --follow` 等运维命令

### 变更（L 级）

- 无

### 验证（证据）

- `README.md` 从原版 308 行重写为完整部署手册
- 所有安装命令、持久化命令、运维命令均来自 [官方文档](https://docs.openclaw.ai/zh-CN/install) 和 [Gateway 运行手册](https://docs.openclaw.ai/zh-CN/gateway)
- 现有 `.openclaw/` 配置文件（config.yaml / agents / guards / skills / schedules / memory / tasks）全部未动

### 未验证项（风险）

- 手动 systemd 用户服务文件（方式 B）和手动 plist 文件（方式 B）未在实际机器上验证——它们是标准 systemd/launchd 配置，理论上正确，但 ExecStart 路径需按实际 `which openclaw` 调整。
- Windows 手动计划任务创建命令（方式 B）未在实际 PowerShell 环境验证——使用标准 `Register-ScheduledTask` cmdlet，Windows 10+ 应兼容。
- Gateway OpenAI 兼容端点（`/v1/models` 等）的详细参数和返回格式未验证，仅引用官方文档描述。
- `openclaw update --channel dev/stable` 命令未验证——来自官方文档。

### 事故记录

- 无。

---

## v1.0 — 2026-05-19（初始配置）

> 主线：建立 OpenClaw 全局配置体系——6 人格、安全护栏、Skill 白名单、调度模板、记忆与任务系统。

### 变更

- 建立 `~/.openclaw/` 全局目录结构
- 创建 `CLAW.md` 全局宪法（9 段：优先级 / 数字员工守则 / 四阶段工作流 / Skill 纪律 / 调度纪律 / 记忆偏好 / 安全红线 / 输出风格 / 人格使用）
- 创建 `config.yaml` 全局配置（人格路由 / Skill 治理 / 调度 / 记忆 / 任务 / 安全 / 输出 / Agent Team）
- 创建 6 人格定义：`captain` / `diver` / `pincer` / `lighthouse` / `scribe` / `mender`
- 创建安全护栏：`irreversible-actions.md`（9 类不可逆 + 5 项准入闸门）/ `prompt-injection.md`（指令信任分级 + 注入模式识别）
- 创建 Skill 白名单：5 内置低风险 + 1 中风险 + 高风险模板 + 黑名单
- 创建调度模板：`heartbeat-rules.md`（合法用途 / 黑名单 / 节流 / 失败处理 / 主动汇报）/ `daily-digest.yaml` / `weekly-review.yaml`
- 创建记忆文件：`lessons.md`（3 条示例经验）/ `user-profile.md`（11 维偏好模板）/ `skill-graveyard.md`
- 创建任务文件：`inbox.md` / `in-flight.json` / `daily-log.md`（含示例）/ `handoff.md`

### 验证

- 全部文件结构与 CLAW.md 第 9 节「文件职责分工」对齐
- config.yaml 的 agents / skills / schedule / memory / tasks / guards / output / team 各段均有值

### 未验证项

- 全部为配置模板，未在真实 OpenClaw 运行环境中端到端验证

---
