# Claude Code 部署手册

直接抄命令。两套环境分开写，不混。

---

## 一图看懂分层

```
~/.claude/                          ← 全局（一次部署，所有项目自动受益）
├── CLAUDE.md                       全局规则
├── settings.json                   ★ 只有 agent 字段（cc-switch 管）
├── settings.local.json             ★ hooks 注册 + 插件配置（cc-switch 不碰）
├── hooks/                          ★ 启动 / 收尾自动注入（全局生效）
│   ├── start.sh / start.ps1
│   └── stop.sh / stop.ps1
├── agents/                         7 个二次元少女工程师人格
└── memory/                         ★ 跨项目长期记忆（lessons / 偏好）

your-project/                       ← 项目级（每个项目各自维护，瘦身后只有少量）
├── CLAUDE.md                       项目效率宪法
├── PROJECT_STRUCTURE.md            ★ 完整架构快照（中大型项目推荐，AI 首选权威文档）
├── tasks/                          ★ 当前项目的进度 / 交接 / 工作日志
│   ├── project-context.md          ★ 轻量上下文（技术栈 / 规范 / 阶段，跨会话持久化）
│   ├── session-handoff.md          会话交接
│   ├── feature-list.json           功能清单
│   └── ...
└── .claude/                        项目私有配置（只剩 3 类）
    ├── persona-control.md          人格路由表（被 CLAUDE.md @ 引用）
    ├── frontend-rules.md           前端约束（被 CLAUDE.md @ 引用）
    └── commands/                   9 个 slash 命令
```

**核心分层原则**：
- **hooks** → 全局（在 `~/.claude/`），所有项目自动触发，无需每个项目重配
- **memory** → 全局，跨项目共享经验
- **tasks** → 项目级，各项目独立进度
- **settings.json** → 全局，只放 `agent` 字段（cc-switch 管）
- **settings.local.json** → 全局，放 hooks + 插件配置（cc-switch 不碰）
- **persona-control / frontend-rules / commands** → 项目级，每个项目可以个性化覆盖

---

## 环境要求

**Windows**：装 Git for Windows（自带 Git Bash） → https://git-scm.com/download/win
**macOS**：原生 Terminal 即可

---

## 🪟 Windows 部署（Git Bash 里执行）

### 第 1 步：全局配置（只做一次，所有项目自动受益）

```bash
mkdir -p ~/.claude

# ① settings.json（只有 agent 字段，cc-switch 管这个文件）
cp    "<本仓库路径>/Claude Code/global-claude/settings.json" ~/.claude/settings.json

# ② settings.local.json（hooks 配置，cc-switch 不碰这个文件）
#    Bash 用户：
cp    "<本仓库路径>/Claude Code/global-claude/settings.local.json" ~/.claude/settings.local.json
#    PowerShell 用户改用这行：
#    cp "<本仓库路径>/Claude Code/global-claude/settings.local.powershell.json" ~/.claude/settings.local.json

# ③ hooks / agents / memory 模板
cp -R "<本仓库路径>/Claude Code/global-claude/hooks"    ~/.claude/
cp -R "<本仓库路径>/Claude Code/global-claude/agents"   ~/.claude/
cp -R "<本仓库路径>/Claude Code/global-claude/memory"   ~/.claude/

# ④ 全局 CLAUDE.md
cp    "<本仓库路径>/Claude Code/GLOBAL-CLAUDE.md" ~/.claude/CLAUDE.md

# ⑤ Hook 脚本加可执行权限
chmod +x ~/.claude/hooks/*.sh
```

> **为什么拆成两个文件？**
> - `settings.json` 只放 `agent` 字段 —— `cc switch` 等工具会重写这个文件，放 hooks 进去会被覆盖
> - `settings.local.json` 放 hooks 配置 —— `cc switch` 不碰这个文件，hooks 安全
> - Claude Code 启动时会**自动合并**两个文件的配置，无需手动处理

### 第 2 步：项目级配置（每个新项目都要做一遍，但只剩很少东西）

```bash
cd /d/your-project        # 改成你的项目路径

# 复制项目级 .claude/ —— 只剩路由表 / 前端规则 / 9 个 commands
cp -R "<本仓库路径>/Claude Code/.claude" .claude

# 复制项目级 CLAUDE.md
cp    "<本仓库路径>/Claude Code/CLAUDE.md" CLAUDE.md

# 复制 tasks/ 模板（部署后含 <示例> 标注，删掉示例段再开工）
cp -R "<本仓库路径>/Claude Code/tasks" tasks

# （可选）如果是中大型项目，复制 PROJECT_STRUCTURE.md 模板到项目根目录
cp    "<本仓库路径>/Claude Code/PROJECT_STRUCTURE.md" PROJECT_STRUCTURE.md
```

> **开局问卷机制**：首次启动 Claude 时，它会自动问你 5-6 个问题（项目类型、技术栈、当前阶段、团队规范等），回答后 Claude 会协助填写 `tasks/project-context.md`。之后每次新会话只需回答 2 个问题（本次目标 + 约束），30 秒搞定。
>
> **架构快照机制**（中大型项目推荐）：项目根目录的 `PROJECT_STRUCTURE.md` 是 AI 的**首选权威文档**——它记录完整架构（路由表、API 表、Handler 模板、设计决策）。AI 每次开局会优先读它，比问卷式的 `project-context.md` 更强大。
> - 首次生成：`/generate-project-structure`（AI 扫描代码后生成初稿，你审核）
> - 后续同步：`/update-project-structure`（AI 检查代码差异，给出更新建议）
> - 何时用：项目 500 行以上 / 多模块 / 多技术栈 → 强烈推荐；小项目 / 脚本仓库 → 不需要

### 第 3 步：安装 claude-hud HUD 插件（强烈推荐，一次设置全局生效）

`claude-hud` 是 Jarrod Watts 开发的第三方 Claude Code 插件，给状态栏加多行可视化 HUD（context 进度条 / 活跃工具 / subagent 状态 / todo 进度）。它会**自动 merge 到 `~/.claude/settings.json` 的 `statusLine` 字段**，**不会破坏**我们已有的 `agent` 和 `hooks` 字段。

启动 `claude`，在对话里按顺序敲三条命令：

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
```

第三条命令会让你选 preset（**推荐选 Full** —— 完整 HUD 显示）+ 标签语言（中文 / 英文）。
确认后它会自动检测平台/Node/Bun/终端列数，写入 `~/.claude/settings.json`，无需手动维护版本号——插件升级时 statusLine 命令会自动指向新版本。

> **⚠️ 重要：`settings.local.json` 防覆盖机制**
>
> `cc switch` 等工具会重写 `~/.claude/settings.json`，导致 claude-hud 的 `statusLine` 配置丢失。
> **正确做法**：将 claude-hud 相关配置（`statusLine`、`enabledPlugins`）写入 `~/.claude/settings.local.json`。
> `settings.local.json` 不会被 `cc switch` 清理，且 Claude Code 会自动合并两个文件的配置。
>
> 安装完 claude-hud 后，手动确认 `settings.local.json` 包含以下内容（如没有则补上）：
>
> ```json
> {
>   "enabledPlugins": {
>     "claude-hud@claude-hud": true
>   },
>   "statusLine": {
>     "type": "command",
>     "command": "（claude-hud:setup 自动生成的命令，不要手动改）"
>   }
> }
> ```

---

## 🍎 macOS 部署（Terminal 里执行）

### 第 1 步：全局配置（只做一次，所有项目自动受益）

```bash
mkdir -p ~/.claude

# ① settings.json（只有 agent 字段，cc-switch 管这个文件）
cp    "<本仓库路径>/Claude Code/global-claude/settings.json" ~/.claude/settings.json

# ② settings.local.json（hooks 配置，cc-switch 不碰这个文件）
cp    "<本仓库路径>/Claude Code/global-claude/settings.local.json" ~/.claude/settings.local.json

# ③ hooks / agents / memory 模板
cp -R "<本仓库路径>/Claude Code/global-claude/hooks"    ~/.claude/
cp -R "<本仓库路径>/Claude Code/global-claude/agents"   ~/.claude/
cp -R "<本仓库路径>/Claude Code/global-claude/memory"   ~/.claude/

# ④ 全局 CLAUDE.md
cp    "<本仓库路径>/Claude Code/GLOBAL-CLAUDE.md" ~/.claude/CLAUDE.md

# ⑤ Hook 脚本加可执行权限
chmod +x ~/.claude/hooks/*.sh
```

> **为什么拆成两个文件？**
> - `settings.json` 只放 `agent` 字段 —— `cc switch` 等工具会重写这个文件，放 hooks 进去会被覆盖
> - `settings.local.json` 放 hooks 配置 —— `cc switch` 不碰这个文件，hooks 安全
> - Claude Code 启动时会**自动合并**两个文件的配置，无需手动处理

### 第 2 步：项目级配置（每个新项目都要做一遍）

```bash
cd ~/your-project          # 改成你的项目路径

# 复制项目级 .claude/ —— 只剩路由表 / 前端规则 / 9 个 commands
cp -R "<本仓库路径>/Claude Code/.claude" .claude

# 复制项目级 CLAUDE.md
cp    "<本仓库路径>/Claude Code/CLAUDE.md" CLAUDE.md

# 复制 tasks/ 模板（部署后含 <示例> 标注，删掉示例段再开工）
cp -R "<本仓库路径>/Claude Code/tasks" tasks

# （可选）如果是中大型项目，复制 PROJECT_STRUCTURE.md 模板到项目根目录
cp    "<本仓库路径>/Claude Code/PROJECT_STRUCTURE.md" PROJECT_STRUCTURE.md
```

> **开局问卷机制**：首次启动 Claude 时，它会自动问你 5-6 个问题（项目类型、技术栈、当前阶段、团队规范等），回答后 Claude 会协助填写 `tasks/project-context.md`。之后每次新会话只需回答 2 个问题（本次目标 + 约束），30 秒搞定。
>
> **架构快照机制**（中大型项目推荐）：项目根目录的 `PROJECT_STRUCTURE.md` 是 AI 的**首选权威文档**——它记录完整架构（路由表、API 表、Handler 模板、设计决策）。AI 每次开局会优先读它，比问卷式的 `project-context.md` 更强大。
> - 首次生成：`/generate-project-structure`（AI 扫描代码后生成初稿，你审核）
> - 后续同步：`/update-project-structure`（AI 检查代码差异，给出更新建议）
> - 何时用：项目 500 行以上 / 多模块 / 多技术栈 → 强烈推荐；小项目 / 脚本仓库 → 不需要

### 第 3 步：安装 claude-hud HUD 插件（强烈推荐，一次设置全局生效）

`claude-hud` 是 Jarrod Watts 开发的第三方 Claude Code 插件，给状态栏加多行可视化 HUD（context 进度条 / 活跃工具 / subagent 状态 / todo 进度）。它会**自动 merge 到 `~/.claude/settings.json` 的 `statusLine` 字段**，**不会破坏**我们已有的 `agent` 和 `hooks` 字段。

启动 `claude`，在对话里按顺序敲三条命令：

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
```

第三条命令会让你选 preset（**推荐选 Full** —— 完整 HUD 显示）+ 标签语言（中文 / 英文）。
确认后它会自动检测平台/Node/Bun/终端列数，写入 `~/.claude/settings.json`，无需手动维护版本号——插件升级时 statusLine 命令会自动指向新版本。

> **⚠️ 重要：`settings.local.json` 防覆盖机制**
>
> `cc switch` 等工具会重写 `~/.claude/settings.json`，导致 claude-hud 的 `statusLine` 配置丢失。
> **正确做法**：将 claude-hud 相关配置（`statusLine`、`enabledPlugins`）写入 `~/.claude/settings.local.json`。
> `settings.local.json` 不会被 `cc switch` 清理，且 Claude Code 会自动合并两个文件的配置。
>
> 安装完 claude-hud 后，手动确认 `settings.local.json` 包含以下内容（如没有则补上）：
>
> ```json
> {
>   "enabledPlugins": {
>     "claude-hud@claude-hud": true
>   },
>   "statusLine": {
>     "type": "command",
>     "command": "（claude-hud:setup 自动生成的命令，不要手动改）"
>   }
> }
> ```

---

## 验证部署成功

进入任意项目目录，启动 Claude Code：

```bash
cd your-project
claude
```

按顺序测 6 件事，全部通过 = 部署成功：

| 测试 | 输入 | 预期结果 |
|---|---|---|
| 1. 全局 Hooks 生效 | 启动后观察状态栏右侧统计区 | 显示 `2 钩子`；启动输出含 `[SESSION START CONTEXT INJECTION]` 段 |
| 2. 默认人格生效 | `你是谁？` | 自报"澪 (mio)" |
| 3. 显式切换生效 | `切到 rei 帮我设计用户表 schema` | 风格转为玲（病娇系后端） |
| 4. 自动路由生效 | `严格审查这段代码：function add(a,b) { return a+b }` | 自动切到 kanon（大小姐系审查官） |
| 5. 开局问卷生效 | 启动新会话（确保 `tasks/project-context.md` 为空） | Claude 主动问 5-6 个问题（项目类型、技术栈等） |
| 6. claude-hud 生效 | 启动后看状态栏底部 | 出现多行 HUD：模型 / 路径 / git 分支 / context 进度条 / usage 限额（若 Pro/Max 订阅） |

启动时输出里应该同时看到两段：
- `## [项目级] 当前项目运行态 (./tasks/)`
- `## [全局] 跨项目长期经验 (~/.claude/memory/)`

如果你换到 **没部署过 tasks/** 的项目（例如某个不需要 tasks 记录的小仓库），hook 会输出"本项目还没有 tasks/ 目录"——这是正常的，全局 hook 在任何项目都会触发，但只在有 tasks/ 的项目才有内容可注入。

---

## 7 个人格速查

| 短名 | 中文 | 岗位 | 怎么叫她 |
|---|---|---|---|
| `mio` | 澪 | 前端实现 | `用 mio 写一个登录组件` |
| `rei` | 玲 | 后端 / API | `切到 rei 帮我设计接口` |
| `nagi` | 凪 | 全栈架构 | `nagi 看下这个方案的取舍` |
| `kanon` | 花音 | 代码审查 | `kanon 审一下这个 PR` |
| `yuki` | 雪 | DevOps / 排障 | `yuki 帮我排一下为什么测试挂了` |
| `shion` | 紫苑 | 教学 / 文档 | `shion 讲一下 useEffect 的原理` |
| `aoi` | 葵 | 项目调研 / PM | `aoi 帮我把这个项目理一下需求` |

---

## Win ↔ Mac 切换

**全局部分**（`~/.claude/`）：直接把整个 `~/.claude/` 目录拷过去 → 跨项目记忆、hooks、人格无缝继承
然后跑一次：

```bash
chmod +x ~/.claude/hooks/*.sh
```

**项目部分**：把项目目录拷过去即可，项目级 `.claude/` 不再含 hook 脚本，所以不用重设权限

---

## 用了 Git Bash 还是跑不起来？

1. **检查 `bash.exe` 在 PATH 里**：在 PowerShell 跑 `where.exe bash`，应该能看到 `C:\Program Files\Git\bin\bash.exe`。看不到 → 把 Git 的 `bin` 目录加进系统环境变量 PATH。
2. **手动测试 hook 脚本**：在 Git Bash 里 cd 到**任意有 tasks/ 的项目目录**跑 `bash ~/.claude/hooks/start.sh`，能看到 `[SESSION START CONTEXT INJECTION]` 开头的输出 = 脚本本身没问题。

---

## claude-hud 常见坑

| 症状 | 原因 | 解决 |
|---|---|---|
| HUD 没出现，状态栏空白 | settings.json 没写入 statusLine 字段 | 重跑 `/claude-hud:setup`；或检查 `~/.claude/settings.json` 是否包含 `"statusLine"` 顶层字段 |
| 安装报 `EXDEV: cross-device link not permitted` | Linux 上 `/tmp` 与家目录在不同文件系统 | `mkdir -p ~/.cache/tmp && TMPDIR=~/.cache/tmp claude`，然后在新 session 里重跑 install |
| Windows 装完不显示 | 误用了 Bun 走 statusLine | Windows 必须用 Node，不要选 Bun；重跑 setup 时拒绝 Bun |
| HUD 显示了但 hooks 失效 | setup 命令是否覆盖了我们的 hooks/agent 字段 | 检查 `~/.claude/settings.json`：`statusLine` / `hooks` / `agent` 三个字段应该**共存**。若只剩 statusLine → setup 写入时 settings.json 是非法 JSON 被覆盖了，恢复后再跑 setup |
| HUD 显示 usage 报错 | Anthropic 代理 / 防火墙 | 设 `CLAUDE_HUD_USAGE_TIMEOUT_MS=30000` 延长超时；或临时设 `HTTPS_PROXY` |
| 插件升级后显示旧版本 | setup 写入时用了 `ls -d / sort` 自动找最新版，本来就该自动跟随升级 | 一般不用管；强制刷新可 `/claude-hud:setup` 再跑一次 |
| `cc switch` 后 HUD 消失 | `cc switch` 重写了 `settings.json`，statusLine 被覆盖 | 把 claude-hud 配置迁到 `settings.local.json`（见上方防覆盖机制说明） |

---

## 不用 Git Bash 的 PowerShell 兜底版

部署时第 1 步里用 PowerShell 版的 `settings.local.powershell.json` 覆盖 `settings.local.json` 即可（见第 1 步注释）。

PowerShell 不需要 `chmod`。

如果运行时报"无法加载，因为在此系统上禁止运行脚本"，跑一次：

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 维护原则（很重要）

- **hooks 在 `~/.claude/hooks/`**（全局），所有项目自动触发，不再每个项目重配
- **lessons 分两层**：跨项目仍成立的写 `~/.claude/memory/lessons.md`（全局）；只对当前项目成立的写项目根的 `tasks/lessons.md`（启动 hook 会注入）
- **tasks 永远写项目根的 `tasks/`**，不要塞进 `~/.claude/`
- Stop hook 触发的反思清单会自动提醒"写 lessons + 改项目 tasks"
- **Stop hook 会拦截收尾一次**（exit 2 + stderr 是官方文档中让模型真正读到清单的方式）：模型完成清单检查后第二次收尾会被放行（`stop_hook_active` 守卫），这是预期行为，不是死循环
- 启动时 hooks 会同时读两处（全局 memory + 项目 tasks），确保上下文完整
- **tasks/ 是开箱即用模板**——部署后是空的（含 `<示例，部署后请删>` 标注的格式示例），由你在真实使用中由 hooks 触发逐步填充。如果你看到示例段还在，删掉它们再开工
- **本仓库自身的版本演化**记在 `Claude Code/CHANGELOG.md`，不在 `tasks/`——`tasks/` 只为部署到的目标项目记账
