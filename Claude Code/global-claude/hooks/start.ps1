# ~/.claude/hooks/start.ps1（全局部署，所有项目共用，PowerShell 版本）
# 用途：会话开始时自动注入 tasks/（项目级） + memory/（全局）上下文
# 分层：
#   tasks/      → 项目本地，每个项目独立（功能进度、handoff、work-log、lessons）
#   memory/     → 全局 ~/.claude/memory/，跨项目共享（lessons、长期偏好）
# 适用：原生 Windows PowerShell（不使用 Git Bash 时）
# 部署：复制到 ~/.claude/hooks/start.ps1
#       hook 注册见 settings.local.powershell.json，command 写单字符串：
#       powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude\hooks\start.ps1"

$ErrorActionPreference = "Continue"

# 强制 UTF-8 输出（PowerShell 5.1 默认按系统 OEM 代码页输出，中文会乱码）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "--- [SESSION START CONTEXT INJECTION] ---"
Write-Output ""

# ============================================================
# 项目级任务运行态（tasks/ 在项目根）
# ============================================================
if (Test-Path "tasks") {
    Write-Output "## [项目级] 当前项目运行态 (./tasks/)"
    Write-Output ""

    # 1. handoff
    if (Test-Path "tasks/session-handoff.md") {
        Write-Output "### 1. 上次任务交接 (tasks/session-handoff.md)"
        Get-Content -Encoding UTF8 -Path "tasks/session-handoff.md" -TotalCount 30
        Write-Output ""
        Write-Output "..."
        Write-Output ""
    }

    # 2. 工作日志 —— 上次做了什么、学到什么
    if (Test-Path "tasks/work-log.md") {
        Write-Output "### 2. 上次工作日志 (tasks/work-log.md) - 最新 30 行"
        Get-Content -Encoding UTF8 -Path "tasks/work-log.md" -Tail 30
        Write-Output ""
    }

    # 3. progress
    if (Test-Path "tasks/progress.md") {
        Write-Output "### 3. 项目进度 (tasks/progress.md)"
        Get-Content -Encoding UTF8 -Path "tasks/progress.md" -TotalCount 20
        Write-Output ""
        Write-Output "..."
        Write-Output ""
    }

    # 4. feature-list - 提取 in_progress / blocked
    if (Test-Path "tasks/feature-list.json") {
        Write-Output "### 4. 功能清单 (tasks/feature-list.json) - 提取 in_progress/blocked 项"
        $content = Get-Content -Encoding UTF8 -Path "tasks/feature-list.json" -Raw
        try {
            $json = $content | ConvertFrom-Json
            $features = if ($json.features) { $json.features } else { $json }
            $filtered = $features | Where-Object { $_.status -in @("in_progress", "blocked") }
            if ($filtered.Count -gt 0) {
                $filtered | ConvertTo-Json -Depth 10
            } else {
                Write-Output "(没有 in_progress 或 blocked 项)"
            }
        } catch {
            $content -split "`n" | Select-String -Pattern '"status"\s*:\s*"(in_progress|blocked)"' -Context 2,2
        }
        Write-Output ""
    }

    # 5. 项目级 lessons（如有）
    if (Test-Path "tasks/lessons.md") {
        Write-Output "### 5. 项目内经验 (tasks/lessons.md)"
        Get-Content -Encoding UTF8 -Path "tasks/lessons.md" -Raw
        Write-Output ""
    }
} else {
    Write-Output "## [项目级] 本项目还没有 tasks/ 目录"
    Write-Output "如果是新项目第一次开工，建议先建：mkdir tasks; ni tasks\session-handoff.md, tasks\progress.md"
    Write-Output ""
}

# ============================================================
# 全局跨项目记忆（~/.claude/memory/）
# ============================================================
$GlobalMemory = Join-Path $HOME ".claude/memory"

if (Test-Path $GlobalMemory) {
    Write-Output "## [全局] 跨项目长期经验 (~/.claude/memory/)"
    Write-Output ""

    # 6. 全局 lessons.md（全量注入，不截断；超过 150 行时提示合并，控制注入成本）
    $lessonsPath = Join-Path $GlobalMemory "lessons.md"
    if (Test-Path $lessonsPath) {
        Write-Output "### 6. 全局避坑经验 (~/.claude/memory/lessons.md) - 全量"
        Get-Content -Encoding UTF8 -Path $lessonsPath -Raw
        $lessonLines = (Get-Content -Encoding UTF8 -Path $lessonsPath | Measure-Object -Line).Lines
        if ($lessonLines -gt 150) {
            Write-Output ""
            Write-Output "[维护提醒] 全局 lessons.md 已达 $lessonLines 行，每次会话全量注入成本偏高——收尾时建议按'5 弱合 2 强'规则合并同主题条目。"
        }
        Write-Output ""
    }

    # 7. 全局 user-preferences
    $prefsPath = Join-Path $GlobalMemory "user-preferences.md"
    if (Test-Path $prefsPath) {
        Write-Output "### 7. 用户长期偏好 (~/.claude/memory/user-preferences.md)"
        Get-Content -Encoding UTF8 -Path $prefsPath -Raw
        Write-Output ""
    }
} else {
    Write-Output "## [全局] 还没有全局 memory 目录"
    Write-Output "建议先建：mkdir ~/.claude/memory; ni ~/.claude/memory/lessons.md"
    Write-Output ""
}

Write-Output "--- [INJECTION END] ---"
Write-Output ""
Write-Output "[硬规则提醒]"
Write-Output "1. 优先基于以上上下文继续工作；不要从零开始猜测"
Write-Output "2. tasks/ 是项目级状态，只为当前项目维护"
Write-Output "3. memory/ 是跨项目长期经验，写入 ~/.claude/memory/lessons.md 让所有项目都受益"
Write-Output "4. 同类错误重复出现 → 必须写进 ~/.claude/memory/lessons.md（由 Stop hook 提醒）"
Write-Output "5. 如果 tasks/ 不存在且是新项目，先和用户确认本轮目标再动手"
Write-Output "6. 执行任务前，先检查上面的经验列表有没有相关条目——有就遵守，不要重蹈覆辙"
Write-Output "7. 用户纠正过你（'不对/不要/别这样/错了'）→ 必须写经验，不能只口头确认"
