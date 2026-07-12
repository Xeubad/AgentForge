# Gateway 多平台接入

> 位置：`~/.hermes/gateway/`
> 作用：管理 Telegram / Discord / Slack / WhatsApp / WeChat / 邮件 等多平台接入
> 强约束：必须先读懂 `shared/guards/gateway-security.md` 再启用任何平台

Hermes 区别于 Claude Code / Codex / Cursor / OpenClaw 的最大独家点之一就是 **多平台 Gateway**——能让 Hermes 在 IM 软件、邮件客户端、群组里被多人触发。

这种能力既强大也危险。本目录的所有文件都是为了把"风险"压在"能用"之内。

---

## 目录结构

```
~/.hermes/gateway/
├── README.md                      # 本文件
├── identity-allowlist.yaml        # 谁能跟 Hermes 说话（身份白名单）
├── command-allowlist.md           # 哪些命令能从 Gateway 触发（命令白名单）
└── platforms/                     # 各平台的示例配置
    ├── telegram.example.yaml
    ├── discord.example.yaml
    └── slack.example.yaml
```

---

## 三层防御回顾

```
[身份层]                  [命令层]                   [动作层]
identity-allowlist  ──→  command-allowlist  ──→   irreversible-actions
谁能说话                   能说什么                    能让做什么
```

任何 Gateway 入站消息必须**全部**通过三层才被处理。详见 `shared/guards/gateway-security.md`。

---

## 启用顺序

1. **先读 guards**：通读 `shared/guards/gateway-security.md` 和 `prompt-injection.md`，理解风险面
2. **填 identity-allowlist.yaml**：列出每个被允许跟 Hermes 沟通的身份
3. **审 command-allowlist.md**：决定哪些命令开放给 Gateway 触发（默认就是 L0/L1，**不要轻易加 L2 以上**）
4. **复制 platforms/X.example.yaml** 为 `X.yaml` 并填实际凭据（API Token / Webhook URL）
5. **在 `~/.hermes/.env` 中填密钥**（绝不写在 yaml 里）
6. **运行 `hermes gateway start <platform>` 启动**
7. **从被允许的身份发一条只读测试消息**确认连通

---

## 第一次启用前的"安全 5 问"

启用任何 Gateway 平台前，逐条回答：

1. 这个平台的账号是否启用了双因素认证？
2. 如果该平台账号被劫持，攻击者能在 Hermes 这里做什么？（最坏情况）
3. identity-allowlist 是否最小化（只允许真正需要的人）？
4. command-allowlist 是否最小化（只允许真正必要的命令）？
5. 我是否能在 1 分钟内 `hermes gateway pause <platform>` 紧急停服？

**任一题答不出来 → 不要启用该平台。**

---

## 紧急停服

```bash
# 暂停某平台所有响应
hermes gateway pause <platform>

# 撤销某身份
hermes gateway revoke <platform> <user_id>

# 列出当前所有连接
hermes gateway list

# 列出最近 24 小时的所有入站消息
hermes gateway log --since 24h
```

---

## 跨平台不串身份

**重要原则**：Telegram 上的"Alice"和 Slack 上的"Alice"在 Hermes 这里是**两个独立身份**，权限独立计算，MEMORY 独立记录。

即使是同一个真人，跨平台的授权也不互通：

- 在 Telegram 上授权过的事，在 Slack 上仍要重新授权
- 在 Slack 上的 MEMORY 不会自动同步到 Telegram 用户的 MEMORY

这是为了防御"跨平台身份冒充"。

---

## Bot-to-Bot 默认禁止

发送方是其他 Bot 的消息，Hermes 默认**完全忽略**。

要开启必须显式 `allow_bot: true` 且 `allowed_bot_ids: [...]` 列出具体 Bot ID。

为什么默认禁：

- 防止 Bot 互链被劫持（A Bot 转发 B Bot 的消息，B Bot 触发 Hermes 执行）
- 防止告警 Bot 的批量推送被注入
- Bot 消息往往不带个人身份验证

---

## 与 Profile 的关系

Gateway 配置是**全局**的（跨所有 profile 共享 identity 和 command 白名单）。

但每个 profile 可以决定：

- 自己是否启用 Gateway（`gateway.enabled: true/false`）
- 默认回执到哪个平台（`gateway.default_response_platform`）
- 是否允许 Bot-to-Bot（`gateway.allow_bot_to_bot`）

详见各 profile 的 `config.yaml`。

---

## 反模式（禁止）

- 把 API Token / Webhook URL 写进 yaml — **必须**走 `.env`
- 添加 identity 不写 role / notes — 不可追溯
- command-allowlist 设成 `*` 通配 — 等于无白名单
- 允许 L3/L4 命令从 Gateway 直接触发 — 永远要双重确认
- 启用 `allow_bot: true` 后不限定 `allowed_bot_ids` — 等于裸奔
- 让 Hermes 转发 Gateway 平台的消息到另一个 Gateway 平台（除非走 Iris+Argus+Daedalus 四步流）
