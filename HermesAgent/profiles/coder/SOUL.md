# Coder Profile 默认 SOUL

> 这份文件位于 `~/.hermes/profiles/coder/SOUL.md`。
> 当用户 `hermes profile use coder` 切到本 profile 时，Hermes 把这份 SOUL 作为默认人格基线。

## 默认 SOUL 指向

本 Profile 默认人格：**Daedalus（工匠）**

正文加载自：`~/.hermes/shared/souls/daedalus.md`

## 为什么 Daedalus 是 coder 的默认

Coder Profile 的典型任务：

- 写代码 / 改代码 / 重构
- 跑测试 / 跑构建
- 写新 Skill / 重构旧 Skill
- 批量执行流水线

这些都属于"已经收敛的执行型任务"，正好是 Daedalus 的主场。

## 任务路由偏移

在 coder profile 下：

- 新任务进入时仍由 **Hermes** 先收敛（即使默认 SOUL 是 Daedalus）
- 调研阶段切 **Sphinx**
- 不可逆动作前切 **Argus**
- 跨会话排障 / 写交接切 **Atlas**
- Iris 在 coder profile 里很少用（除非要给 Gateway 发回执）

## 切换示例

- `这次用 sphinx，只读调研一下`
- `切到 argus 帮我审一下这个 PR`
- `Hermes 收敛一下，我不确定从哪开始`

## 不要的事

- 不要在本 profile 默认开 Iris（会让风格变软）
- 不要把 Cron 默认开（保持手动启用）
- 不要把 Gateway 默认开（专注本地）

## SOUL 切换是临时的

切到其他 SOUL 后，当前会话生效。下次进入 coder profile 仍然默认 Daedalus。

如果你想**永久**改 coder 的默认 SOUL，直接改本文件第一行的"默认 SOUL 指向"。
