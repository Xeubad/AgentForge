# 每日运行日志

> 用途：记录每一天 OpenClaw 发生的事——任务、调度、失败、决策、用户纠正（跨工作目录统一写在这里）。
> 位置：`~/.openclaw/tasks/daily-log.md`（全局唯一）。
> 写入：每个任务结束时（由 scribe）/ 每次 Heartbeat 异常 / 每次主动汇报 / 每次安全事件。
> 不写入：成功的常规操作不需要逐条记录（避免噪音），只记里程碑和异常。
>
> 每条记录建议带 `workdir:` 字段，标记动作发生在哪个工作目录（或写 `global`），便于按目录回查。

---

## 当日条目格式

```
## YYYY-MM-DD

### [HH:MM] 标签 — 一行结论
- 触发：用户对话 / Heartbeat / Cron / Skill 失败
- 人格：执行的人格
- 内容：发生了什么
- 证据：命令输出 / 文件路径 / commit / 链接
- 后续：是否需要 follow-up
```

常用标签：

- `task-done`：任务完成
- `task-blocked`：任务被阻塞
- `user-correction`：用户纠正了 Agent
- `heartbeat-failure`：Heartbeat 周期里出错
- `cron-fired`：Cron 任务触发
- `skill-failure`：Skill 调用失败
- `security`：安全事件 / 注入拦截
- `decision`：用户做了一个重要决策

---

## 示例（保留作模板）

## 2026-05-19

### [10:12] task-done — 完成 OpenClaw 配置初稿
- 触发：用户对话
- 人格：captain → scribe
- workdir：global
- 内容：建立 ~/.openclaw/ 全局目录、6 人格、安全护栏、Skill 白名单、调度模板、记忆与任务系统
- 证据：见 `~/.openclaw/` 目录全部新增文件
- 后续：等待用户审阅并提出修订意见

### [10:30] decision — 默认关闭 Cron
- 触发：用户对话（"针对独家结构"）
- 人格：captain
- workdir：global
- 内容：决定 `~/.openclaw/config.yaml` 中 cron.enabled 默认 false，避免用户在不知情时被自动调度
- 证据：`~/.openclaw/config.yaml: schedule.cron.enabled = false`
- 后续：用户在对话里说"启用 ……"才打开对应 Cron 配置

---

## 维护原则

- 日志按天分块，最新的在上面。
- 单日条目 > 30 条时，scribe 周复盘时压缩成"高密度摘要"+ 保留异常完整内容。
- 不重写历史。事实写错了就在下面追加 `correction:` 条目。
- 安全事件单独高亮，复盘时优先看 `security` 标签。
- 跨会话开工，第一件事就是看昨天最后几条日志。
