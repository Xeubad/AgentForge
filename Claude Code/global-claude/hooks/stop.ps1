# ~/.claude/hooks/stop.ps1（全局部署，所有项目共用，PowerShell 版本）
# 用途：会话结束前触发反思，提醒 Claude 把经验/进度落盘
# 分层：
#   跨项目经验 → 写入 ~/.claude/memory/lessons.md（全局）
#   项目专属经验 → 写入 ./tasks/lessons.md（项目本地）
#   任务状态  → 写入 ./tasks/*（项目本地）
#   工作日志  → 写入 ./tasks/work-log.md（项目本地）
# 适用：原生 Windows PowerShell（不使用 Git Bash 时）
# 部署：复制到 ~/.claude/hooks/stop.ps1
#       hook 注册见 settings.local.powershell.json，command 写单字符串：
#       powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude\hooks\stop.ps1"
# 机制说明：Stop hook 退出码 0 的 stdout 不会注入给模型，只有 exit 2 + stderr
#           （或 JSON decision:block）才能让模型看到内容。本脚本用 exit 2 输出
#           反思清单并阻止本次收尾一次；模型完成清单后再次收尾时，输入里
#           stop_hook_active 为 true，脚本直接放行，不会死循环。

$ErrorActionPreference = "Continue"

# 强制 UTF-8 输出（PowerShell 5.1 默认按系统 OEM 代码页输出，中文会乱码）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 读取 hook 输入；若已经在 stop-hook 触发的延续轮里，直接放行
$hookInput = [Console]::In.ReadToEnd()
if ($hookInput -match '"stop_hook_active"\s*:\s*true') {
    exit 0
}

$checklist = @'
--- [STOP HOOK: 收尾反思清单] ---

会话即将结束 / 任务即将完成。在最终回复用户前，请**逐项检查**并完成以下事项（如适用）：

## 0. 用户纠正检查（最高优先级）

本轮对话中用户是否说过以下任何一种表达？
- "不对" / "不是这样" / "错了" / "不要" / "别这样" / "别这么做"
- "你应该..." / "你应该先..." / "别忘了..." / "我不是这个意思"
- "上次就说过" / "怎么又..." / "还是不对"
- 任何明确否定你的方案、做法、风格或工具选择的表达

**如果任一为是 → 必须写经验**（写入位置见下方分层规则），不能只口头说"已注意"。

写入格式：
```
### [YYYY-MM-DD] 短标题
- **触发场景**：什么情况下会撞到这件事
- **原本做法**：之前怎么做（或想怎么做）
- **正确做法**：现在应该怎么做
- **为什么**：背后的原因 / 用户的原话
```

## 1. 工作日志更新（写入 tasks/work-log.md）

**每次对话必须更新**，哪怕只是"今天没改动，只是确认了一下状态"。

写入格式：
```
## [YYYY-MM-DD HH:MM] 一句话标题

**做了什么**：
- 动作 1
- 动作 2

**改了哪些文件**：
- `path/to/file` — 改了什么

**学到什么**：
- 本次发现的规律 / 踩坑 / 纠正

**下次注意**：
- 下次应该怎么做 / 避免什么
```

## 2. 长期经验沉淀

本轮是否出现以下情况？任一为是 → 必须追加一条新经验：

- [ ] 用户明确纠正过我的方案、风格、术语或工具选择
- [ ] 出现过反复出错的问题，最终找到根因
- [ ] 学到了某个环境/依赖/接口的非显然行为
- [ ] 用户表达了"以后都这样 / 以后别这样"
- [ ] 同一个错误在不同会话中出现了两次以上

**写入位置分层**（判断标准：这条经验脱离当前仓库后还成立吗？）：
- 成立 → 写 **~/.claude/memory/lessons.md**（全局，所有项目受益）
- 不成立 → 写 **./tasks/lessons.md**（项目本地，下轮会话由 start hook 注入）

## 3. 项目级任务状态更新（写入 ./tasks/）

- [ ] `tasks/feature-list.json`：本轮推进过的功能状态是否需要更新？(not_started → in_progress → passing)
- [ ] `tasks/progress.md`：是否需要追加一条本轮里程碑？
- [ ] `tasks/session-handoff.md`：任务未完成时是否需要更新交接？

## 4. 验证证据收尾

- [ ] 标注的 `passing` 状态都有运行过的命令和结果作为证据吗？
- [ ] 没运行过验证的，是否在文档中明确说明"未验证"和"风险"？

---

[硬规则] 任一项需要更新但未做 → 必须在结束前完成，不允许只在对话里口头说"已注意"。
[硬规则] 短任务（一次性问答 / 无文件改动）可以跳过本清单，但要在最终回复里明示"本轮无需落盘"。
[硬规则] 跨项目经验写全局 lessons，项目专属经验写 tasks/lessons.md，任务状态写项目 tasks，工作日志写项目 work-log，不要混。
[硬规则] 用户纠正 → 必须写经验。这是最高优先级，不能省略。

完成以上检查后即可正常结束本轮回复。

--- [STOP HOOK END] ---
'@

[Console]::Error.WriteLine($checklist)
exit 2
