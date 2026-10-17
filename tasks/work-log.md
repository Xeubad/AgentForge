# 工作日志

> 记录每次会话的工作内容、文件改动和学习心得。
> 最新一条在最上面（时间倒序）。

## 2026-07-21

**做了什么**:
- 拉取了仓库最新信息（从 origin/main）
- 根据仓库模板在本地进行 Claude Code 配置优化

**改了哪些文件**:
- `~/.claude/settings.json` — 添加 agent 字段，设置默认人格为 mio
- `~/.claude/settings.local.json` — 新建，存放 hooks 和插件配置
- `~/.claude/CLAUDE.md` — 新建，全局规则文件
- `~/.claude/agents/*.md` — 复制 7 个人格文件
- `~/.claude/memory/lessons.md` — 新建，全局记忆文件
- `~/.claude/hooks/start.sh` — 新建，会话启动 hook
- `~/.claude/hooks/stop.sh` — 新建，会话结束 hook
- `.claude/persona-control.md` — 新建，人格路由表
- `.claude/frontend-rules.md` — 新建，前端约束
- `.claude/commands/start-session.md` — 新建，启动会话命令
- `.claude/commands/finish-session.md` — 新建，结束会话命令
- `tasks/project-context.md` — 新建，项目上下文
- `tasks/progress.md` — 新建，进度追踪

**学到什么**:
- Claude Code 的配置分为全局（~/.claude/）和项目级（项目根目录）
- settings.json 和 settings.local.json 的分离设计：前者由 cc-switch 管理，后者防覆盖
- 7 个人格通过 frontmatter 的 description 字段实现自动路由
- Hooks 脚本在会话启动和结束时自动注入上下文

**下次注意**:
- 项目级配置完成后需要验证 hooks 是否生效
- 需要测试人格切换是否正常工作
- 考虑安装 claude-hud 插件增强状态栏显示
