# OpenClaw 部署手册

直接抄命令。三套平台分开写，不混。

> **信息来源**
> - 安装命令与持久化机制：[OpenClaw 官方文档](https://docs.openclaw.ai/zh-CN/install) + [Gateway 运行手册](https://docs.openclaw.ai/zh-CN/gateway)
> - 安全护栏、人格、Skill 治理、记忆体系：本仓库 `.openclaw/` 目录下的自定义配置
> - GitHub 仓库：[github.com/openclaw/openclaw](https://github.com/openclaw/openclaw)

---

## 一图看懂分层

```
~/.openclaw/                              ← 全局（一次部署，跨所有任务共享）
├─ CLAW.md                                全局执行宪法
├─ config.yaml                            运行参数（默认人格 / Skill 策略 / 调度 / 记忆）
├─ agents/                                6 人格定义（captain / diver / pincer / lighthouse / scribe / mender）
├─ skills/allowlist.yaml                  Skill 白名单（全局唯一）
├─ schedules/                             调度配置（Heartbeat 节制 / Cron 模板）
│  ├─ heartbeat-rules.md
│  ├─ daily-digest.yaml
│  └─ weekly-review.yaml
├─ guards/                                安全护栏
│  ├─ irreversible-actions.md
│  └─ prompt-injection.md
├─ memory/                                长期记忆（全局唯一，跨任务共享）
│  ├─ lessons.md
│  ├─ user-profile.md
│  └─ skill-graveyard.md
└─ tasks/                                 运行态（全局唯一）
   ├─ inbox.md
   ├─ in-flight.json
   ├─ daily-log.md
   └─ handoff.md
```

**核心原则**：OpenClaw 只有全局部署一种形态——**禁止**在任何项目目录里再放 `.openclaw/`，否则两份 lessons / 白名单互相漂移。

---

## 系统要求

| 项目 | 要求 |
|---|---|
| Node.js | **Node 24**（推荐）或 Node 22.16+（安装脚本会自动处理） |
| 操作系统 | macOS / Linux / Windows（原生或 WSL2，WSL2 更稳定） |
| 磁盘 | ~200MB（OpenClaw 本体 + 配置） |
| 网络 | 首次安装需要；运行时取决于 Skill 的网络策略 |

---

## 第 1 步：安装 OpenClaw

### Windows（PowerShell）

```powershell
# 推荐：官方安装脚本（自动检测 OS、安装 Node、安装 OpenClaw、启动引导）
iwr -useb https://openclaw.ai/install.ps1 | iex

# 跳过新手引导：
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

### macOS / Linux / WSL2（bash）

```bash
# 推荐：官方安装脚本
curl -fsSL https://openclaw.ai/install.sh | bash

# 跳过新手引导：
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

### 替代：npm 全局安装（已有 Node 环境）

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

### 验证安装

```bash
openclaw --version        # 确认 CLI 可用
openclaw doctor           # 检查配置问题
openclaw gateway status   # 确认 Gateway 运行状态
```

---

## 第 2 步：部署自定义配置

本仓库 `OpenClaw/` 下的配置文件需要映射到 `~/.openclaw/`。

### 映射表

| 仓库内 | 部署目标 |
|---|---|
| `OpenClaw/CLAW.md` | `~/.openclaw/CLAW.md` |
| `OpenClaw/.openclaw/config.yaml` | `~/.openclaw/config.yaml` |
| `OpenClaw/.openclaw/agents/*.yaml` | `~/.openclaw/agents/*.yaml` |
| `OpenClaw/.openclaw/skills/allowlist.yaml` | `~/.openclaw/skills/allowlist.yaml` |
| `OpenClaw/.openclaw/schedules/*` | `~/.openclaw/schedules/*` |
| `OpenClaw/.openclaw/guards/*` | `~/.openclaw/guards/*` |
| `OpenClaw/memory/*` | `~/.openclaw/memory/*` |
| `OpenClaw/tasks/*` | `~/.openclaw/tasks/*` |

### Windows（PowerShell）

```powershell
New-Item -ItemType Directory -Force "$HOME\.openclaw" | Out-Null
Copy-Item "OpenClaw\CLAW.md" "$HOME\.openclaw\CLAW.md" -Force
Copy-Item "OpenClaw\.openclaw\*" "$HOME\.openclaw\" -Recurse -Force
Copy-Item "OpenClaw\memory" "$HOME\.openclaw\memory" -Recurse -Force
Copy-Item "OpenClaw\tasks" "$HOME\.openclaw\tasks" -Recurse -Force
```

### macOS / Linux（bash）

```bash
mkdir -p ~/.openclaw
cp OpenClaw/CLAW.md ~/.openclaw/CLAW.md
cp -R OpenClaw/.openclaw/* ~/.openclaw/
cp -R OpenClaw/memory ~/.openclaw/memory
cp -R OpenClaw/tasks ~/.openclaw/tasks
```

---

## 第 3 步：个性化配置

### 3.1 编辑 `~/.openclaw/config.yaml`

至少改这 4 处：

```yaml
profile:
  user: "你的名字"              # 用于 daily-log 标识发起人
  timezone: "Asia/Shanghai"     # 改成你的实际时区

skills:
  network:
    domain_allowlist:            # 你允许 Skill 访问的域名
      - "docs.python.org"
      - "*.github.com"

schedule:
  heartbeat:
    enabled: true                # 按需开关
```

### 3.2 编辑 `~/.openclaw/memory/user-profile.md`

填写你的沟通风格、默认人格、安全偏好、不打扰时段。第一次只填能想到的部分，后续由 captain / scribe 自动追加。

### 3.3 审核 Skill 白名单

打开 `~/.openclaw/skills/allowlist.yaml`，逐条审核默认的内置 Skill。需要禁用的注释掉，需要加新的按格式追加（必须由 lighthouse 审过才进白名单）。

---

## 第 4 步：配置持久化服务（开机自启）

OpenClaw 的 Gateway 是常驻进程。**推荐用官方命令自动注册**，也提供手动方案备用。

### 🪟 Windows

#### 方式 A：官方命令（推荐）

```powershell
openclaw gateway install       # 注册计划任务（首选）；被拒绝时回退到启动文件夹
openclaw gateway status        # 确认注册成功
openclaw gateway restart       # 重启服务
openclaw gateway stop          # 停止服务
```

> 原生 Windows 使用**计划任务**（Task Scheduler），任务名 `OpenClaw Gateway`。
> 如果计划任务创建被拒绝（权限不足），OpenClaw 自动回退到**每用户启动文件夹**启动器（`shell:startup` 下的 `gateway.cmd`）。

#### 方式 B：手动注册计划任务（备用）

如果 `openclaw gateway install` 失败，手动创建：

```powershell
# 获取 openclaw 路径
$openclawPath = (Get-Command openclaw).Source

# 创建计划任务：开机触发、以当前用户运行
$action = New-ScheduledTaskAction -Execute $openclawPath -Argument "gateway --port 18789"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "OpenClaw Gateway" -Action $action -Trigger $trigger -Settings $settings -Description "OpenClaw Gateway 常驻服务"
```

#### 方式 C：启动文件夹快捷方式（最简）

```powershell
# 创建启动脚本
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\openclaw-gateway.cmd"
$openclawPath = (Get-Command openclaw).Path
Set-Content -Path $startupPath -Value "@echo off`n`"$openclawPath`" gateway --port 18789"
```

> **注意**：启动文件夹方式在用户注销后进程会终止，不如计划任务可靠。

#### 验证（Windows）

```powershell
openclaw gateway status --json    # 检查运行状态
openclaw doctor                   # 检查配置漂移
schtasks /query /tn "OpenClaw Gateway"  # 确认计划任务存在
```

---

### 🍎 macOS

#### 方式 A：官方命令（推荐）

```bash
openclaw gateway install       # 注册 LaunchAgent（ai.openclaw.gateway）
openclaw gateway status        # 确认注册成功
openclaw gateway restart       # 重启（用 restart，不要 stop+start）
openclaw gateway stop          # 停止（仅本次启动会话移除，KeepAlive 仍有效）
openclaw gateway stop --disable  # 持久禁止自动重生
```

> macOS 使用 **LaunchAgent**（用户级），标签 `ai.openclaw.gateway`。
> `KeepAlive` 机制确保崩溃后自动重启。
> `openclaw doctor` 会审计并修复服务配置漂移。

#### 方式 B：手动 plist 文件（备用）

```bash
cat > ~/Library/LaunchAgents/ai.openclaw.gateway.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.openclaw.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/openclaw</string>
        <string>gateway</string>
        <string>--port</string>
        <string>18789</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/openclaw-gateway.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw-gateway.err</string>
</dict>
</plist>
EOF

# 加载
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

#### 验证（macOS）

```bash
openclaw gateway status --deep   # 包含 launchd 服务扫描
openclaw doctor                  # 检查配置漂移
launchctl list | grep openclaw   # 确认 LaunchAgent 已加载
```

---

### 🐧 Ubuntu / Linux

#### 方式 A：官方命令（推荐）

```bash
openclaw gateway install                          # 注册 systemd 用户服务
systemctl --user enable --now openclaw-gateway    # 启用 + 立即启动
openclaw gateway status                           # 确认运行
```

> Linux 使用 **systemd 用户服务**（`~/.config/systemd/user/openclaw-gateway.service`）。

#### 登出后保持运行（关键）

```bash
# 启用用户驻留——否则注销后 systemd 用户服务会被杀
sudo loginctl enable-linger $(whoami)
```

> **不执行这一步，SSH 断开后 OpenClaw 就停了。**

#### 方式 B：手动用户服务文件（备用）

```bash
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/openclaw-gateway.service << 'EOF'
[Unit]
Description=OpenClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openclaw gateway --port 18789
Restart=always
RestartSec=5
TimeoutStopSec=30
TimeoutStartSec=30
SuccessExitStatus=0 143
KillMode=control-group
Environment=NODE_ENV=production

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now openclaw-gateway
```

#### 方式 C：系统级服务（多用户 / 服务器）

```bash
# 复制到系统目录
sudo cp ~/.config/systemd/user/openclaw-gateway.service /etc/systemd/system/openclaw-gateway.service
# 调整 ExecStart 路径（如果 openclaw 不在 /usr/local/bin）
sudo sed -i "s|/usr/local/bin/openclaw|$(which openclaw)|g" /etc/systemd/system/openclaw-gateway.service

sudo systemctl daemon-reload
sudo systemctl enable --now openclaw-gateway
```

> **注意**：不要同时用用户级和系统级服务管理同一个 Gateway——`openclaw doctor` 发现系统级服务时会拒绝自动安装用户级。

#### 验证（Linux）

```bash
openclaw gateway status --deep           # 包含 systemd 服务扫描
openclaw doctor                          # 检查配置漂移
systemctl --user status openclaw-gateway # 用户级服务状态
loginctl show-user $(whoami) | grep Linger  # 确认 linger 已启用
```

---

## 第 5 步：验证部署

三平台通用验证流程：

```bash
# 1. 确认 Gateway 运行
openclaw gateway status
# 预期：Runtime: running, Connectivity probe: ok

# 2. 确认配置加载正常
openclaw doctor
# 预期：无 ERROR，可能有 WARNING（可选修复）

# 3. 确认渠道就绪（如已配置 Telegram / Discord 等）
openclaw channels status --probe

# 4. 确认日志可读
openclaw logs --follow
# Ctrl+C 退出

# 5. 确认人格可用
openclaw status
```

---

## 第 6 步：Gateway 配置（可选）

Gateway 是 OpenClaw 的常驻网关进程，承载 WebSocket 控制、HTTP API（OpenAI 兼容）、渠道连接。

### 默认行为

| 配置 | 默认值 | 说明 |
|---|---|---|
| 端口 | 18789 | 可通过 `--port` / `OPENCLAW_GATEWAY_PORT` / `gateway.port` 覆盖 |
| 绑定 | loopback | 仅本机访问；改 `--bind lan` 开放局域网 |
| 认证 | 必需 | 共享密钥：`gateway.auth.token` 或 `OPENCLAW_GATEWAY_TOKEN` |
| 热重载 | hybrid | 安全时热应用，需要时自动重启 |

### 远程访问

```bash
# 首选：Tailscale / VPN
# 后备：SSH 隧道
ssh -N -L 18789:127.0.0.1:18789 user@host
# 客户端连接 ws://127.0.0.1:18789
```

> SSH 隧道不会绕过 Gateway 认证——客户端仍需发送 token/password。

### OpenAI 兼容端点

Gateway 提供 OpenAI 兼容 API，可接入 Open WebUI / LobeChat / LibreChat 等：

| 端点 | 用途 |
|---|---|
| `GET /v1/models` | 列出可用模型/Agent |
| `POST /v1/chat/completions` | Chat 补全 |
| `POST /v1/embeddings` | 嵌入向量 |
| `POST /v1/responses` | Agent 原生响应 |

---

## 日常运维

### 更新

```bash
openclaw update --channel stable    # 稳定版
openclaw update --channel dev       # 开发版
```

### 日志

```bash
openclaw logs --follow              # 实时日志
openclaw logs --since 1h            # 最近 1 小时
```

### 诊断

```bash
openclaw doctor                     # 配置自检 + 自动修复
openclaw doctor --fix               # 自动修复发现的问题
openclaw gateway status --deep      # 深度服务扫描（含 launchd/systemd/schtasks）
```

### 备份

```bash
# 关键目录备份（定期执行）
tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz \
  ~/.openclaw/CLAW.md \
  ~/.openclaw/config.yaml \
  ~/.openclaw/agents/ \
  ~/.openclaw/skills/ \
  ~/.openclaw/schedules/ \
  ~/.openclaw/guards/ \
  ~/.openclaw/memory/ \
  ~/.openclaw/tasks/

# 不备份的：sessions/（临时会话数据）、logs/（可再生）
```

### 端口变更后

```bash
# 更改 gateway.port 后必须同步服务注册
openclaw doctor --fix
# 或
openclaw gateway install --force
```

---

## 常见故障

| 症状 | 原因 | 解法 |
|---|---|---|
| `refusing to bind ... without auth` | 非 loopback 绑定但没配认证 | 设 `gateway.auth.token` 或改回 loopback |
| `EADDRINUSE` | 端口被占用 | `openclaw gateway --force` 强杀后重启 |
| `Gateway start blocked: set gateway.mode=local` | 配置损坏或远程模式 | 检查 config.yaml 的 `gateway.mode` |
| `unauthorized` 连接 | 认证不匹配 | 确认客户端与 Gateway 用同一个 token |
| 多用户/多渠道偶发集体不响应，日志有 `provider-transport-fetch ECONNRESET` + `stalled session age=NNNNs` | 模型 API 单次调用卡死阻塞事件循环 | 给每个 provider 配 `timeoutSeconds: 60`；同时收紧 `diagnostics.stuckSessionAbortMs` 到 `180000`（3 分钟）让卡死的 session 自动 abort |
| 内存 `rss_growth` 持续告警，多个 session 超 24h 仍驻留 | 老 direct session 在内存里没回收 | `openclaw sessions` 列出超 24h 无活动的 session，征得用户同意后清理；多渠道部署建议加日例行巡检 |
| doctor 提示 `the message tool is unavailable for that agent` | 新装的 IM 渠道插件需要 messaging 工具，但 agent 工具集没放行 | `openclaw config set tools.alsoAllow '["message"]'` 或 `tools.profile messaging` |
| `Plugin index includes unpinned npm specs` 警告 | 插件用 `@latest` 安装，未锁定版本 | `openclaw plugins list` 查实际版本号 → 用 `plugins.entries.<id>.spec` 锁回去 |
| Linux 登出后服务停了 | 没启用 linger | `sudo loginctl enable-linger $(whoami)` |
| Windows 重启后没自启 | 计划任务未注册 | `openclaw gateway install` 重注册 |
| macOS 崩溃后没自动重启 | KeepAlive 未生效 | `openclaw doctor --fix` 检查 LaunchAgent |
| `openclaw` 命令找不到 | 全局 bin 不在 PATH | `export PATH="$(npm prefix -g)/bin:$PATH"` 写入 shell rc |

---

## 不要做的事

- ❌ **不要**在项目目录里放 `.openclaw/`——两份 lessons / 白名单会互相漂移
- ❌ **不要**用 `openclaw gateway stop` + `openclaw gateway start` 代替 `openclaw gateway restart`
- ❌ **不要**同时用用户级和系统级 systemd 服务管理同一个 Gateway
- ❌ **不要**在 `~/.openclaw/memory/` 里放临时任务状态——那些归 `tasks/`
- ❌ **不要**把 `~/.openclaw/.env` 和 `auth.json` 加进 git 或云同步——它们含凭据

---

## 最小可用组合

如果只想快速试一下，保留这些就够：

```
~/.openclaw/
├─ CLAW.md
├─ config.yaml
├─ agents/captain.yaml
├─ agents/lighthouse.yaml
├─ skills/allowlist.yaml
├─ guards/irreversible-actions.md
├─ guards/prompt-injection.md
├─ memory/lessons.md
├─ memory/user-profile.md
└─ tasks/daily-log.md
```

跑顺了再启用其他人格、Cron、记忆细分文件。

---

## 维护原则

- **不要堆配置**：每条规则都要能回答"它防住了什么具体问题"
- **每月复盘一次**：哪条规则没起作用、哪个 Skill 一直没用、哪个人格从没被切到——该删就删
- **同类错误重复 → 沉淀进 `memory/lessons.md`**
- **memory ≠ tasks**：临时进度归 `tasks/`，长期经验归 `memory/`
- **全局唯一**：始终保持 `~/.openclaw/` 是唯一事实来源
