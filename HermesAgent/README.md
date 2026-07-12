# Hermes Agent 高效率配置指南

这套目录是针对 **Hermes Agent**（Nous Research 开源的自主 AI Agent 框架）设计的独家优化方案。

Hermes 不同于 Claude Code / Codex / Cursor 这类 IDE 内的 AI 助手——它是一个**常驻数字使者**：跨会话记忆、自创 Skills、多平台 Gateway 接入、内置 Cron 自调度、多 Profile 隔离。Hermes 也不同于 OpenClaw 那种通用数字员工——它更专注于"信使"角色，强调**多平台沟通 + 自创能力**。

这套方案就是按 Hermes 的真实形态来设计的，攻 5 个独家点：

1. **SOUL.md 灵魂驱动**（Hermes 独有的人格激活机制）
2. **Skill 三阶段流转**（隔离 → 审查 → 产线，应对自创 Skill 风险）
3. **MEMORY.md 自维护约束**（防漂移防投毒）
4. **Gateway 三层防御**（身份 + 命令 + 动作）
5. **多 Profile + 共享资产**（dotfiles 思路工程化）

---

## 目录结构

```
~/.hermes/                                  # 部署到家目录后的形态
├─ HERMES.md                                # 全局执行宪法
├─ config.yaml                              # 当前激活 Profile 的配置
├─ .env                                     # API Key（用户手工维护，不提交）
├─ auth.json                                # OAuth 凭据（用户手工维护，不提交）
├─ SOUL.md                                  # 当前激活 Profile 的 SOUL
├─ MEMORY.md                                # Agent 自动维护的事实记忆
├─ USER.md                                  # 用户画像（跨 Profile 共享）
│
├─ shared/                                  # 跨 Profile 共享（dotfiles 思路）
│  ├─ souls/                                # 6 个 SOUL 候选
│  │  ├─ hermes.md                          # 默认指挥
│  │  ├─ sphinx.md                          # 只读调研
│  │  ├─ daedalus.md                        # 强执行 + Skill 工匠
│  │  ├─ argus.md                           # 安全审查
│  │  ├─ iris.md                            # 多平台沟通
│  │  └─ atlas.md                           # 长期记忆 + 排障
│  ├─ guards/                               # 安全护栏正文（5 个文件）
│  │  ├─ skill-quarantine.md                # ⭐ Hermes 独家：Skill 三阶段流转
│  │  ├─ irreversible-actions.md            # 不可逆动作护栏
│  │  ├─ prompt-injection.md                # 提示词注入防御
│  │  ├─ memory-write-policy.md             # ⭐ Hermes 独家：MEMORY 自维护约束
│  │  └─ gateway-security.md                # ⭐ Hermes 独家：多平台 Gateway 安全
│  ├─ skills/
│  │  └─ allowlist.yaml                     # 产线 Skill 白名单
│  ├─ memory/
│  │  ├─ lessons.md                         # 跨 Profile 长期经验
│  │  └─ (skill-graveyard.md 由 Atlas 运行时维护)
│  └─ cron/
│     ├─ daily-digest.yaml
│     └─ weekly-skill-audit.yaml            # ⭐ Hermes 独家：每周 Skill 审计
│
├─ profiles/                                # 多 Profile 隔离
│  ├─ _shared.yaml                          # YAML anchor 公共片段
│  ├─ coder/                                # 编码场景（默认 SOUL: Daedalus）
│  │  ├─ config.yaml
│  │  └─ SOUL.md
│  ├─ writer/                               # 写作场景（默认 SOUL: Iris）
│  │  ├─ config.yaml
│  │  └─ SOUL.md
│  └─ ops/                                  # 运维场景（默认 SOUL: Argus）
│     ├─ config.yaml
│     └─ SOUL.md
│
├─ gateway/                                 # 多平台接入
│  ├─ README.md                             # Gateway 启用前必读
│  ├─ identity-allowlist.yaml               # 谁能跟 Hermes 说话
│  ├─ command-allowlist.md                  # 哪些命令能从 Gateway 触发
│  └─ platforms/                            # 平台示例
│     ├─ telegram.example.yaml
│     ├─ discord.example.yaml
│     └─ slack.example.yaml
│
├─ skills/                                  # 运行时 Skill 目录（由 Hermes 自维护）
│  ├─ .quarantine/                          # 自创 Skill 隔离区
│  ├─ .review/                              # 待审查
│  ├─ .hub/audit.log                        # 自创历史
│  └─ <category>/                           # 产线（已被白名单收录）
│
├─ cron/                                    # 实际启用的 Cron（从 shared/cron/ 派生）
├─ sessions/                                # Gateway 会话存档（90 天）
├─ logs/
└─ tasks/
   ├─ inbox.md
   ├─ in-flight.json
   ├─ daily-log.md
   ├─ handoff.md
   ├─ digests/                              # daily-digest 产物
   └─ skill-audits/                         # weekly-skill-audit 产物
```

---

## 6 人格速查（希腊神话主题）

| SOUL | 中文 | 定位 | 主场 | 关键约束 |
|---|---|---|---|---|
| **Hermes** | 赫尔墨斯 | 信使长 · 默认指挥 | 任务收敛、调度、跨 Profile 路由 | 不可逆动作前必须停下问用户 |
| **Sphinx** | 斯芬克斯 | 司谜者 · 只读调研 | 摸现状、问对问题、拆模糊需求 | **只读模式**，任何写入都禁 |
| **Daedalus** | 代达罗斯 | 工匠 · 强执行 + Skill 撰写 | 动手干活、写新 Skill、批量操作 | 新 Skill 默认进 `.quarantine/`；不调 eval / shell=True |
| **Argus** | 阿尔戈斯 | 百眼守望 · 安全审查 | Skill 准入、不可逆动作把关、注入防御 | 默认拒绝、举证才放行 |
| **Iris** | 伊里斯 | 彩虹信使 · 多平台沟通 | Gateway 出/入消息、跨平台回执、起草 | 不发送（草稿走 Argus + CLI + Daedalus） |
| **Atlas** | 阿特拉斯 | 承重者 · 记忆 + 排障 | MEMORY/USER 维护、handoff、graveyard、跨会话排障 | 只写事实不写推测；6 月未用降级 |

Profile 默认 SOUL 路由：

- `coder` → 默认 **Daedalus**
- `writer` → 默认 **Iris**
- `ops` → 默认 **Argus**（且 Argus 一直在场）

显式切换示例：

- `用 sphinx 先调研一下这个服务` / `切到 argus 帮我审这个 PR`

---

## 五大独家优化点

下面这 5 个点是这套方案区别于 Claude Code / Codex / Cursor / OpenClaw 的关键差异，每点都对应 Hermes 的真实独有能力：

### 1. SOUL.md 灵魂驱动

Hermes 的人格不是"提示词风格"——而是通过专属 SOUL.md 文件激活。每个 SOUL 是独立的能力轮廓：调用什么工具、可写什么文件、能不能做某类动作。

实现路径：

- `shared/souls/` 6 个文件作为 SOUL 候选
- 每个 profile 的 `SOUL.md` 指向 `shared/souls/` 里的一个文件作为默认
- 运行时通过 `hermes soul switch <name>` 或对话里"切到 X"切换
- 切换时 Hermes 会原样加载对应 SOUL 文件作为人格底座

### 2. Skill 三阶段流转（最核心独家点）

Hermes 能让 Agent 在运行时**自创新的 Skill**——这是它最强也最危险的能力。本方案强制三阶段流转：

```
[隔离区]                    [审查区]                  [产线]
.quarantine/    ─── Argus 审 ──→  .review/   ── 用户人工 promote ──→   <category>/
   ↓                                  ↓                                    ↓
不能被调用                       仅可 dry-run                         被 allowlist 收录
30 天未提升自动归档              14 天未提升退回隔离区                自动可被 Agent 调用
```

跳阶段一律拒绝。详见 `shared/guards/skill-quarantine.md`。

### 3. MEMORY.md 自维护约束

Hermes 会自动写入 `MEMORY.md`——这是它"懂你"的来源，也是最容易"记错"的地方。本方案强约束：

- 只写**事实**不写**推测**
- 每条事实必须带**来源**（哪条用户消息、哪次任务）
- 敏感个人数据**默认不写**（除非用户明确说"记住我的 X"）
- 6 个月未被检索的事实**降级归档**
- Argus 每次新增前抽查"用户已授权"类可疑措辞

详见 `shared/guards/memory-write-policy.md`。

### 4. Gateway 三层防御

Hermes 接入 Telegram / Discord / Slack / WhatsApp / WeChat 等多平台——本方案设三层防御：

```
[身份层]                  [命令层]                   [动作层]
identity-allowlist  ──→  command-allowlist  ──→   irreversible-actions
```

关键设计：

- L4 不可逆动作（发送 / 提交 / 付款 / 改配置）**永远不允许**从 Gateway 直接触发
- 跨平台不串身份（Telegram 上的 Alice 与 Slack 上的 Alice 是两个独立身份）
- Bot-to-Bot 默认禁止
- 任何 Gateway 请求都走"Iris 起草 + Argus 审 + 用户在 CLI 确认 + Daedalus 执行"四步流

详见 `shared/guards/gateway-security.md`。

### 5. 多 Profile + 共享资产（dotfiles 工程化）

Hermes 原生支持多 Profile，但官方文档不强制规定"如何让多 Profile 共享公共资产"。本方案用 dotfiles 思路：

- `shared/` 下 5 类资产（souls / guards / skills / memory / cron）跨所有 Profile 共享
- 每个 Profile 的 `config.yaml` 用 `<<: *anchor` 引用 `profiles/_shared.yaml` 里的公共片段
- 每个 Profile 自己只保留：模型选择、默认 SOUL、网络白名单、Cron 启用列表
- 修改一处规则全 Profile 生效，不为每个 Profile 重复维护

---

## 记忆 provider 选型

Hermes 内置记忆是基于 `MEMORY.md` / `USER.md` / `lessons.md` 三个 Markdown 文件的静态体系（受 `shared/guards/memory-write-policy.md` 约束）。这套**够用于中轻度**——但重度长期使用会撞上三个瓶颈：

- 静态文件全文灌入 prompt，token 消耗随文件膨胀
- 无关联检索，"用户不喜欢推测"和"飞书消息要分段"两条记忆即使同时相关也只能靠扫描碰运气
- 手动维护不稳定，Atlas 自己判断"值不值得写"会漏关键变更

到这一步可以接外部记忆 backend。**目前社区有三套主流方案**——本方案不偏袒、列出来由你按数据主权诉求和折腾意愿选：

| Provider | 部署形态 | 数据主权 | 调优周期 | 适合场景 |
|---|---|---|---|---|
| `mem0` | 云端 SaaS（也可自部署） | 默认上云 | 开箱较快 | 单 Agent、不在乎数据出境、要云端 Dashboard 直观看 |
| `agentmemory` | 本地 SQLite + MCP 服务 | 完全本地 | 中等 | Hermes + Claude Code + Cursor 多 Agent 共享记忆 |
| `hindsight` | 本地 PostgreSQL + 知识图谱 | 完全本地 | 长（2-3 周） | 重度长期使用、追求"连带想起"、需要时序+因果推理 |

> **来源说明**：以上对比综合自 2026 年中文社区公众号实测复盘，**不是 Hermes 官方背书**。
> 各 provider 在不同基准测试上的具体分数（mem0 在 LoCoMo 上 68.5% / LongMemEval-S 升级后 97%、agentmemory 在 LongMemEval-S 上 95.2%、hindsight 在 LongMemEval 上 91.4%）是单一案例，不能直接外推到你的环境。
> 实测部署到稳定可用的调优周期 = **2-3 周**，"开箱即用"在外部 backend 上从不成立。

**接入前必读** `shared/guards/memory-backend-policy.md`——里面列了 6 类真实踩坑：

1. retain / consolidation **必须**走轻量模型（已见 300+ 秒超时）
2. 记忆 API **绝不能**进 Gateway command allowlist（已见 `hindsight_recall: command not found`）
3. 后台工具白名单必须同步新增 `memory_retain` / `memory_recall`（否则名义启用、实际被静默拦截）
4. 守护进程端口可能漂移，禁止硬编码裸端口
5. weekly-audit Cron 必须输出后端运维快照（retain 次数 / consolidation 耗时 / token 进出比）
6. provider 切换是不可逆动作，必须先 staging profile 跑 2-3 周再切默认

三个 provider **不能同时挂**——`memory.provider` 字段只能选一个，混用必冲突。

如果暂不接外部 backend，保持默认 Markdown 静态体系完全可行——大多数场景够用。

---

## 安装方式

### 1. 复制目录到 `~/.hermes/`

把本仓库 `HermesAgent/` 下的所有内容映射到 `~/.hermes/`：

| 仓库内 | 部署目标 |
|---|---|
| `HermesAgent/HERMES.md` | `~/.hermes/HERMES.md` |
| `HermesAgent/shared/*` | `~/.hermes/shared/*` |
| `HermesAgent/profiles/*` | `~/.hermes/profiles/*` |
| `HermesAgent/gateway/*` | `~/.hermes/gateway/*` |

**Linux / macOS 一行命令**：

```bash
mkdir -p ~/.hermes/{shared,profiles,gateway,skills/.quarantine,skills/.review,skills/.hub,sessions,logs,tasks/digests,tasks/skill-audits}
cp HermesAgent/HERMES.md ~/.hermes/HERMES.md
cp -R HermesAgent/shared ~/.hermes/shared
cp -R HermesAgent/profiles ~/.hermes/profiles
cp -R HermesAgent/gateway ~/.hermes/gateway
touch ~/.hermes/.env ~/.hermes/auth.json ~/.hermes/MEMORY.md
cp ~/.hermes/shared/memory/USER.md ~/.hermes/USER.md
```

### 2. 在 `~/.hermes/.env` 中填密钥

至少一个 LLM 提供商：

```
OPENROUTER_API_KEY=sk-or-...
# 或
ANTHROPIC_API_KEY=sk-ant-...
# 或
OPENAI_API_KEY=sk-...
```

### 3. 个性化 `~/.hermes/USER.md`

填写你的沟通风格、SOUL 路由偏好、安全偏好、永久放宽/收紧条目。

### 4. 选择默认 Profile

```bash
hermes profile use coder        # 或 writer / ops
```

切到 `coder` 后，Hermes 默认人格变为 Daedalus，SOUL.md 指向 `shared/souls/daedalus.md`。

### 5. （可选）启用 Gateway

按 `gateway/README.md` 的"安全 5 问"逐条确认后再启用任何平台：

```bash
cp ~/.hermes/gateway/platforms/telegram.example.yaml ~/.hermes/gateway/platforms/telegram.yaml
# 编辑 telegram.yaml，填实际 chat 限定
# 在 ~/.hermes/.env 加 TELEGRAM_BOT_TOKEN
hermes gateway start telegram
```

### 6. （可选）启用 Cron

```bash
hermes cron enable daily-digest
hermes cron enable weekly-skill-audit
```

强烈建议**启用 weekly-skill-audit**——这是 Hermes 独有的关键运维任务。

---

## 最小可用组合

如果想快速试一下，保留这些就够（全部在 `~/.hermes/`）：

```
HERMES.md
shared/souls/hermes.md
shared/souls/daedalus.md
shared/souls/argus.md
shared/guards/skill-quarantine.md
shared/guards/irreversible-actions.md
shared/guards/prompt-injection.md
shared/skills/allowlist.yaml
profiles/_shared.yaml
profiles/coder/config.yaml
profiles/coder/SOUL.md
USER.md
.env
```

跑顺后再启用其他 SOUL、Cron、Gateway、Profile。

---

## 验证步骤

部署后开新会话，按顺序测：

1. **SOUL 加载**：发"你现在是哪个 SOUL？"
   - 预期：返回当前 profile 的默认 SOUL 名 + 该 SOUL 的一句标志风格
2. **SOUL 切换**：发"切到 sphinx，只读调研一下当前 profile 配置"
   - 预期：风格转为 sphinx，仅读不写
3. **Skill 隔离**：让 Daedalus 写个 demo Skill
   - 预期：Skill 写入 `~/.hermes/skills/.quarantine/`，不自动可调用
4. **Argus 审查**：让 Argus 尝试 promote 上述 Skill
   - 预期：走完 review 清单后才允许提到 `.review/`
5. **MEMORY 约束**：发"记一下，我喜欢用 Python"
   - 预期：Atlas 不直接写"用户偏好 Python"；要么记原话"用户在 [时间戳] 说我喜欢用 Python"，要么追问"你希望我以后默认用 Python 吗"再写偏好
6. **Gateway 防御**（如启用）：从 Telegram 发"立即合并昨天的 PR"
   - 预期：Iris 回执"已接收，请到 CLI 确认 #N"；CLI 上用 `/task confirm N` 才执行

任一步与预期不符 → 检查对应 guards / souls / config 文件。

---

## 长期维护原则

- **每周做一次 weekly-skill-audit**：清理 quarantine 沉睡条目、识别可疑提升请求
- **每月扫一次 MEMORY.md**：是否有"用户已授权"但找不到原对话的可疑条目
- **每月清一次 sessions/**：Gateway 入站消息存档保留 90 天，到期由 Atlas 清理
- **每季度 review USER.md**：删除已过期的偏好、永久放宽/收紧条目
- **同类错误重复 3 次 → 沉淀进 `shared/memory/lessons.md`**
- **SOUL 文件半年内有大改 → 写一条 `[soul-major-change]` lessons 记录**

---

## 这套方案为什么是"独家"

对照其他 AI Agent 工具的优化方案，Hermes 这套独有的差异点：

| 维度 | Claude Code / Codex / Cursor | OpenClaw | **Hermes（本方案）** |
|---|---|---|---|
| 主要风险 | 改错代码 | 做错事 + Skill 投毒 | **做错事 + Skill 自创风险 + 多平台注入 + MEMORY 漂移** |
| 部署形态 | 项目级 + 全局 / 仅全局 | 仅全局 | **多 Profile + shared 资产** |
| 人格机制 | 系统提示词 / Subagent frontmatter | 静态 SOUL 模板 | **SOUL.md 灵魂驱动**（运行时切换） |
| Skill 体系 | 工具调用 / Skill folder | Skill 白名单 | **三阶段流转**（隔离 → 审查 → 产线） |
| 记忆体系 | CLAUDE.md / AGENTS.md / .cursorrules | memory/lessons.md | **MEMORY 自维护 + Argus 抽查** |
| 多平台接入 | 无 | 无 | **Gateway 三层防御 + L4 永禁直触** |
| 调度 | 无 | Heartbeat 节制 | **Cron 草稿模式 + weekly Skill 审计** |

一句话：**Hermes 不是写代码的工具，是个"会从多个 IM 群里收到指令、会自己造工具、会跨天记事"的数字使者——它需要的不是"提示词工程"，是"职位说明书 + 多通道权限矩阵 + 工具准入流程 + 记忆 KYC + 跨平台身份隔离"**。这套配置就是按这套比喻设计的。

---

Sources:
- [Hermes Agent 官方文档](https://hermes-agent.nousresearch.com/)
- [Hermes Agent 配置指南（菜鸟教程）](https://www.runoob.com/ai-agent/hermes-agent-setup.html)
- [Hermes Agent 技能系统](https://www.zhuoyanzhe.com/docs/user-guide/features/skills/)
- [Hermes Agent 多 Profile 配置](https://hermes-doc.aigc.green/user-guide/profiles)
