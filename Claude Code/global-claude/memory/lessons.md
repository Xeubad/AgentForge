# 跨项目长期经验

> 这个文件在 `~/.claude/memory/lessons.md`，由 SessionStart hook 自动注入。
> 所有项目共享，不要在某个具体项目下复制本文件。
>
> 写入触发：用户纠正过的事 / 重复出错 / 跨项目都成立的非显然经验。
> 写入触发人：Stop hook 强制反思清单 / 用户主动要求记。

---

## 经验条目（按时间倒序追加在此处）

### [2026-06-01] claude-hud 走插件机制，不是手动改 hook

- **触发场景**：想给状态栏加可视化 HUD（context 进度 / 工具 / agent 状态）
- **错误做法**：手动改 `settings.json` 加 `statusLine` 字段，或者把 hook 脚本改成同时输出 statusline 数据
- **正确做法**：跑三条命令让插件自己装：
  ```
  /plugin marketplace add jarrodwatts/claude-hud
  /plugin install claude-hud
  /claude-hud:setup
  ```
- **为什么**：claude-hud 的 setup 命令会做运行时检测（平台/Node-or-Bun/终端列数/插件版本路径），硬编码的 statusLine command 容易在插件升级后失效
- **共存说明**：`statusLine` 字段和我们的 `agent` / `hooks` 是顶层并列，互不覆盖。setup 会 merge 不会全量改写

### [2026-05-28] hooks 必须用 `$HOME/.claude/hooks/xxx` 绝对路径才能全局生效

- **触发场景**：想让 hooks 在所有项目里自动触发，而不是每个新项目重新部署
- **错误做法**：`settings.json` 里 hook command 写 `.claude/hooks/start.sh` 相对路径
- **正确做法**：写 `$HOME/.claude/hooks/start.sh`（bash）或 `$env:USERPROFILE\.claude\hooks\start.ps1`（PowerShell）
- **为什么**：相对路径会相对**当前工作目录**（项目根），项目里没这个文件就找不到。绝对路径才能让全局 hook 在任何 cwd 下生效

### [2026-05-27] tasks 是项目级，memory 是全局，不要混

- **触发场景**：会话结束想沉淀经验时纠结写哪里
- **判断标准**：**"这条经验脱离当前项目后还成立吗？"**
  - 成立 → `~/.claude/memory/lessons.md`（全局）
  - 不成立 → `<project>/tasks/lessons.md`（项目）
- **写入位置铁律**：Stop hook 反思清单会强制提醒区分

### [2026-05-19] Claude Code 的 settings.json 支持 `agent` 顶层字段

- **触发场景**：想设置默认主线程人格
- **常见误诊**："subagent_type 不是合法字段" / "agent 字段不存在"——都是错的
- **事实**：`agent` 是 Claude Code settings.json 的官方合法字段，值为已注册 subagent 的 name
- **配合 frontmatter**：被引用的 subagent 必须有合法 YAML frontmatter（name / description / tools / model），否则 Claude Code 找不到

---

## 写入纪律

- 写之前问：**"这条经验脱离当前项目后还成立吗？"** 不成立 → 写到目标项目的 `tasks/lessons.md`
- 每条必须能回答"下次撞到时怎么办"
- 用户同类纠正 ≥ 2 次必须沉淀
- 过期 / 被替代时划掉但保留历史
