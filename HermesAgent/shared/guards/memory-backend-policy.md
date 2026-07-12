# MEMORY 后端策略（memory-backend-policy）

> 与 `memory-write-policy.md` 互补：
> - `memory-write-policy.md` 管 **写什么**（事实 vs 推测、敏感信息脱敏、条目格式）
> - 本文件管 **后端怎么跑**（provider 选型、LLM 模型分工、调用路径、运维边界）

本文件的所有规则来自真实部署踩坑，**违反任一条 → Argus 拒绝启用对应 provider**。

---

## 1. 适用范围

只要 `config.yaml` 里 `memory.provider` 不是默认的内置 Markdown 文件（即 MEMORY.md / USER.md / lessons.md 这套静态文件），就属于"接入了外部记忆 backend"，本文件全部生效。

涵盖但不限于：

- `mem0`（云端记忆 API）
- `agentmemory`（本地 SQLite 引擎 + MCP）
- `hindsight`（本地 PostgreSQL + 知识图谱）
- 其他自建 RAG / 向量库 / 图谱方案

---

## 2. LLM 后端分工（最容易踩坑）

记忆 backend 内部会调 LLM 做 **retain**（写入时拆解事实）和 **consolidation**（定期整合记忆）。这两个动作**必须**用轻量模型。

### 2.1 强制规则

- **retain / consolidation 一律走轻量模型**（如 Flash / Haiku / 8B-class 本地模型）
- **禁止**把主对话用的 Opus / Sonnet / 70B+ 模型作为记忆后端
- 重模型会导致 **retain 超时**（已见 300+ 秒的案例），单条消息处理后台卡死
- 触发 API 限速（如 `RequestBurstTooFast`）时**不要重试堆积**——立刻降级到更轻的模型

### 2.2 验证步骤

启用任何新 provider 后 **24 小时内** 必须人工查日志：

```bash
grep -E "retain.*returned error|consolidation.*timeout|RequestBurstTooFast" ~/.hermes/logs/
```

任一命中 → 立即换轻量模型。

---

## 3. 工具路由与白名单（防"API 被当 shell 调"）

### 3.1 强制规则

- 记忆 backend 的 retain / recall 等操作**只能**通过 `mcp_servers` 或原生 provider 接口调用
- **绝不允许**把 `hindsight_recall` / `agentmemory_add` / `mem0_search` 这类名字以**命令**形式进 `command-allowlist.md` 或 `bash` shell——否则 Agent 会真的 `bash` 去找它，导致 `command not found`
- 记忆 API 调用方法应该出现在 SOUL 文件的"可用工具"段，**不在** Gateway command allowlist 里

### 3.2 后台工具白名单同步

Hermes 安全机制会拦截后台进程调用未白名单工具。新接 provider 后必须同步：

- 在 `shared/skills/allowlist.yaml` 加入 `memory_retain` / `memory_recall` / `memory_consolidate` 三项（或对应 provider 的等价名）
- 否则 **provider 名义启用、实际所有后台 retain/recall 静默被拦截**——查日志可见：
  ```
  Background review denied non-whitelisted tool: <skill_name>
  Memory is not available
  ```

---

## 4. 连接配置稳定性

### 4.1 端口与地址

- 守护进程重启后**端口可能漂移**（已见 hindsight-api 在不同实例间换端口）
- `config.yaml` 里**禁止**硬编码 `localhost:3111` 这类裸端口
- 推荐做法：
  - provider 守护进程提供 `--port-file ~/.hermes/run/<provider>.port` 写入实际端口
  - Hermes 启动时读该文件而非配置常量
  - 端口文件不存在时**降级到只读 MEMORY.md**，不静默失败

### 4.2 健康检查

每个 provider 必须有可用的健康检查 endpoint，Atlas 在以下时机触发：

- Hermes 启动时
- weekly-audit Cron 触发时
- 用户运行 `hermes memory status` 时

健康检查失败 → 进入只读降级，不写入新事实直到恢复。

---

## 5. 整合成本观察

retain / consolidation 长期累积会产生不可忽视的 LLM 调用成本（已见单次整合 79 秒 / 输出 token 1.22× 输入的案例）。

### 5.1 weekly-audit 必查项

每周由 Atlas 执行的 `weekly-skill-audit` Cron 必须**同时**输出记忆后端运维快照：

```
- 本周 retain 次数 / 平均耗时 / 失败率
- 本周 consolidation 次数 / 累计耗时 / token 进/出比
- 累计存储规模（节点数 / 边数 / 字节数）
- 本周热召回 Top 10 条目
- 6 个月未召回的"沉睡"条目数量（按 memory-write-policy 第 6 节归档）
```

### 5.2 异常阈值

任一触发 → 写一条 lessons 并告警用户：

- 单次 retain > 30 秒
- 单次 consolidation > 120 秒
- 单次 token 进/出比 > 2.0
- 周失败率 > 5%

---

## 6. Provider 切换流程

切换 `memory.provider`（如 mem0 → agentmemory）属于**不可逆动作**——历史记忆不一定能完整迁移。强制流程：

1. **导出现有记忆** 到 `~/.hermes/memories/exports/<date>-<old_provider>.json`（保留至少 3 个月）
2. **新 provider 在 staging profile 试跑 2-3 周**，不直接切默认 profile
3. **导入策略**：能批量导入则导，不能则保留旧 provider 只读访问（用 `hermes memory archive-mount`）
4. **切默认前** 由 Argus 跑一次 memory-write-policy 全文校验
5. **切完不删旧数据** 至少 90 天，确认无回退需求再清理

> 警告：所谓"开箱即用"对外部记忆 backend **从不成立**。
> 实测部署到可用的调优周期 = **2-3 周**，期间会涉及多次 LLM 后端切换、白名单调整、超时参数微调。
> 不要在生产 profile 上做这个调优。

---

## 7. 三大 provider 速查（来源：第三方公众号实测，非官方）

> 数据来源是 2026 年中文社区的实测复盘文章，**不是 Hermes 官方背书**。
> 看到的具体百分比、节点数、token 数都是单一案例，不能直接外推到你的环境。
> 详细比较见根 `README.md` 的「记忆 provider 选型」段。

| Provider | 部署 | 数据主权 | 调优周期 | 适合 |
|---|---|---|---|---|
| `mem0` | 云端 SaaS（也可自部署） | 默认上云 | 开箱较快 | 单 Agent、不在乎数据出境 |
| `agentmemory` | 本地 SQLite + MCP | 本地 | 中等 | 多 Agent 共享、Hermes + Claude Code + Cursor 联用 |
| `hindsight` | 本地 PostgreSQL + 知识图谱 | 本地 | 长（2-3 周） | 重度长期使用、追求"连带想起" |

三者**不可同时挂**（`memory.provider` 只能选一个），混用会冲突。

---

## 8. 反模式（禁止）

- ❌ "我先把 provider 切到 Hindsight 看看效果" → 必须在 staging profile 跑足 2 周
- ❌ "retain 失败就重试呗" → 重试会堆积 + 触发限速；先换轻量模型
- ❌ "把 hindsight_recall 加到 bash command 里方便调试" → 永远不允许
- ❌ "provider 启动了，应该没问题" → 必须查日志确认 retain 走通才能算"启用"
- ❌ "端口写死 localhost:3111 应该没事" → 守护进程一重启就坏
- ❌ "weekly-audit 跑就行了，不看输出" → 记忆后端运维快照必须 Atlas 在 daily-log 里写一段摘要
