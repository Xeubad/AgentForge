# Finish Session

用于结束一次会话前的收尾检查。

## 步骤

1. 确认当前任务状态（not_started / in_progress / blocked / passing）。
2. 如果存在未完成的 `in_progress`，记录 blocker 和下一步。
3. 更新 `tasks/work-log.md`。
4. 检查是否需要写 `tasks/session-handoff.md`（长会话 / 多文件 / 多模块时）。
5. 清理临时调试代码、无主 TODO、注释掉的废代码。
6. 确认构建/验证状态清楚。
7. 确认下一步动作明确。

## 输出

- 会话总结
- 已完成项
- 待完成项
- blocker
- 下一步动作
- 交接文件位置（如需要）
