# Gateway 命令白名单

> 路径：`~/.hermes/gateway/command-allowlist.md`
> 作用：定义哪些命令可以从 Gateway 触发
> 强约束：未在此处登记的命令一律返回 "请通过 CLI 执行"

---

## 命令分级（再次强调）

| 等级 | 描述 | 触发方式 | Gateway 允许？ |
|---|---|---|---|
| L0 只读 | 查询状态、获取信息 | Iris 单步直接回执 | ✓ 允许 |
| L1 草稿 | 生成草稿但不发送 | Iris 起草 + 回执草稿 | ✓ 允许 |
| L2 任务请求 | 请 Hermes 收敛新任务 | 转 Hermes 收敛 + 等 CLI 确认 | ✓ 允许（需双重确认） |
| L3 受控执行 | 触发特定 Skill | 仅限白名单 Skill；走 Argus + CLI 双重确认 | ⚠️ 谨慎，仅明确登记的允许 |
| L4 不可逆 | 发送 / 提交 / 付款 / 改配置 | **从 Gateway 直接触发禁止** | ❌ 一律拒绝 |

---

## L0 只读命令（推荐全开）

下面这些命令默认对所有 allowlist 内的身份开放。

| 命令 | 用途 | 所需角色 | 备注 |
|---|---|---|---|
| `/status` | 查询当前 profile / SOUL / in-flight 任务 | readonly+ | |
| `/inbox` | 查询本身份在 inbox 里的未处理消息 | readonly+ | 跨平台不串 |
| `/help` | 查询帮助 + 当前白名单命令 | readonly+ | |
| `/profile current` | 查询当前激活的 profile | readonly+ | |
| `/profile list` | 列出可用 profile（仅返回身份有权访问的） | readonly+ | |
| `/skills list` | 列出产线 Skill（不显示 quarantine/review） | collaborator+ | |
| `/memory search <kw>` | 搜索 MEMORY（仅显示与本身份相关或公共部分） | collaborator+ | 涉及隐私信息脱敏 |

---

## L1 草稿命令（推荐选择性开启）

下面这些命令生成草稿，不发送。

| 命令 | 用途 | 所需角色 | 备注 |
|---|---|---|---|
| `/draft <内容>` | Iris 起草，回执草稿 | collaborator+ | 草稿写入 `tasks/drafts/` |
| `/summarize <时间窗>` | Atlas 整理某时间窗内的 daily-log | collaborator+ | |
| `/translate <文本> <目标语言>` | 翻译 | collaborator+ | |
| `/explain <概念>` | 知识问答型（不动外部） | readonly+ | |

---

## L2 任务请求命令（默认启用，但必须双重确认）

下面这些命令向 Hermes 提交"任务请求"，Hermes 收敛后等 CLI 确认。

| 命令 | 用途 | 所需角色 | 备注 |
|---|---|---|---|
| `/task <description>` | 提交新任务到 Hermes 收敛队列 | collaborator+ | 入队后回执 #N；CLI 上用 `/task confirm N` 启动 |
| `/abort <任务 ID>` | 请求中止任务 | collaborator+（只能中止自己提交的）；admin+（可中止任意） | 仅作请求，最终中止由 CLI 确认 |

**绝对不允许**：

- `/task confirm` 这种"在 Gateway 上直接确认任务"的命令 — 确认动作只能在 CLI 主控对话
- 任何允许从 Gateway 直接触发 `/promote-skill`、`/install-skill`、`/cron register` 的命令

---

## L3 受控执行（默认全关，仅在明确需要时按 Skill 登记）

如果你的 ops 场景需要从 Gateway 直接触发某个特定 Skill（例如"健康检查"），可以在此登记，但要满足：

1. 该 Skill 必须在 `shared/skills/allowlist.yaml` 里且 `permissions` 不含 `filesystem.write` 或 `network.outbound`（除 allowed_domains 内）
2. 该 Skill 必须 `irreversible: false`
3. 必须有详细 audit log
4. 调用前 Argus 检查
5. 调用后 Iris 回执 + 写 daily-log

格式示例（默认全部注释掉）：

```yaml
# - command: /healthcheck <service>
#   skill: ops_healthcheck
#   required_role: collaborator
#   require_argus_audit: true
#   require_cli_dual_confirm: false      # 仅本类只读检查可省略 CLI 二次确认
#   notes: "查询服务健康状态；只读，不改任何状态"
```

---

## L4 不可逆动作（永远禁止从 Gateway 触发）

下面这些动作**无论身份角色多高、无论已经通过多少层验证**，都**不允许**从 Gateway 直接触发：

- 发送任何 IM / 邮件 / 推送（包括 Gateway 的回执也走"草稿 + CLI 确认 + Daedalus 发送"四步流）
- 提交代码 / push 远程 / 合并 PR / 关闭 issue
- 修改 `auth.json` / `.env` / `config.yaml` / `guards/*` / 本文件 / `identity-allowlist.yaml`
- 安装新 Skill / MCP / 插件
- 提升 Skill 阶段（quarantine → review → production）
- 注册 / 修改 / 删除 Cron 任务
- 切换默认 Profile / 创建新 Profile
- 删除 MEMORY 条目 / 清空 MEMORY / 修改 USER.md
- 任何涉及付款、订阅、注销、绑定的操作
- 修改 Gateway 身份白名单 / 命令白名单

**这条红线无任何例外**。如果用户在 Gateway 上要求做以上动作，Iris 必须回执 "请到 CLI 执行"。

---

## 维护说明

- 添加新命令必须由 owner 在 CLI 主控对话执行
- 命令命名建议 `/<动词>-<对象>` 或 `/<动词> <参数>`
- 每条命令必须写"所需角色 / 用途 / 备注"
- 每月 Atlas 在周复盘时检查"30 天未使用"的命令，建议清理
- 拉黑 / 删除某命令 → 同步通知所有 collaborator+

---

## 反模式（禁止）

- 用 `*` 通配命令（不允许）
- 给同一命令同时打 L0 和 L3 双标签（要么只读要么有副作用，不能模糊）
- "这个命令我每次都用，先放 L4 后续观察"——L4 永远不允许 Gateway 直触
- "我自己是 owner，加个命令就直接生效"——任何命令变更要重启 Gateway 才应用
