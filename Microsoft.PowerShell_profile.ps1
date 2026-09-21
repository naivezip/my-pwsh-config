# ==============================================================================
# PowerShell 7 Profile (现代化 CLI、极速秒开与智能补全优化)
# ==============================================================================

# 1. 编码保障 (解决 Nerd Font 图标 / Git / Unicode 字符乱码)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Scoop Shims 优先确保在 PATH 最前
$scoopShims = "$env:USERPROFILE\scoop\shims"
if ($env:PATH -notlike "*$scoopShims*") {
    $env:PATH = "$scoopShims;$env:PATH"
}

# 3. PSReadLine 交互与智能补全增强
if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView     # 优雅的行内幽灵文字 (按 F2 可临时在行内/列表间切换)
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete      # Tab 弹出网格式候选菜单，支持方向键游走
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar # 右箭头采纳幽灵预测
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward   # 前缀历史精准向上回溯
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward # 前缀历史精准向下回溯

# 4. Starship 提示符 (极速初始化)
Invoke-Expression (& starship init powershell --print-full-init | Out-String)

# 5. Zoxide 智能目录跳转 (提供 z 与 zi)
Invoke-Expression (& zoxide init powershell | Out-String)

# 6. Carapace 现代多命令自动补全引擎 (支持 1000+ 命令参数和说明)
if (Test-Path "$scoopShims\carapace.exe") {
    $env:CARAPACE_BRIDGES = 'zsh,bash'
    carapace _carapace powershell | Out-String | Invoke-Expression
}

# 7. 现代命令别名绑定 (直连 Scoop，去除反复全盘扫描)
Remove-Item Alias:ls, Alias:cat -Force -ErrorAction SilentlyContinue
function ls { eza --icons --group-directories-first $args }
function ll { eza -la --icons --octal-permissions --group-directories-first --git $args }
function l  { eza -l --icons --group-directories-first $args }
function la { eza -a --icons --group-directories-first $args }
function tree { eza --tree --icons --level=3 $args }
function cat { bat --paging=never $args }
function preview { bat $args }
function top { btop $args }
function lg  { lazygit $args }

# FZF 模糊搜索环境变量
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --inline-info"
$env:FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"

# 8. Git 极速缩写别名 (Oh-My-Zsh 经典键位)
function gst { git status $args }
function ga  { git add $args }
function gaa { git add --all $args }
function gc  { git commit -v $args }
function gcm { git commit -m $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gb  { git branch $args }
function gba { git branch -a $args }
function gl  { git log --oneline --graph --decorate $args }
function gp  { git push $args }
function gpl { git pull $args }
function gd  { git diff $args }

# 9. 常用小工具函数
function which { Get-Command $args }
function touch {
    foreach ($file in $args) {
        if (-not (Test-Path $file)) {
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
    }
}

# 10. 浏览器快速调用 (唤起 Edge 浏览本地 PDF、HTML 等文件或网址)
function edge {
    <#
    .SYNOPSIS
        使用 Microsoft Edge 打开本地文件 (PDF、HTML、图片等) 或网页链接。
    .DESCRIPTION
        将传入的相对路径自动解析为规范的 file:/// 格式 URL，彻底解决包含空格、中文、中括号 [ ] 等特殊符号时传参被拆碎的问题。
        支持 Tab 键自动补全文件名、批量打开多个文件以及通配符 (如 edge *.pdf)。
    .EXAMPLE
        edge document.pdf
        edge ./preview.html
        edge *.pdf
        edge https://www.bing.com
    #>
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )

    $edgeExe = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    if (-not (Test-Path $edgeExe)) {
        $edgeExe = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
    }
    if (-not (Test-Path $edgeExe)) {
        $edgeExe = 'msedge'
    }

    if (-not $Path -or $Path.Count -eq 0) {
        Start-Process $edgeExe
        return
    }

    $targetList = [System.Collections.Generic.List[string]]::new()

    foreach ($item in $Path) {
        # 1. 命令行选项参数 (如 --inprivate)
        if ($item -match '^--?') {
            $targetList.Add($item)
            continue
        }

        # 2. 网络 URL 或本地服务地址
        if ($item -match '^(https?://|file://|edge://|about:)' -or $item -match '^localhost(:\d+)?(/.*)?$' -or $item -match '^www\.') {
            $targetList.Add($item)
            continue
        }

        # 3. 本地精准匹配 (字面路径，兼容文件名中含空格、中文、[ ] 等特殊字符)
        if (Test-Path -LiteralPath $item -ErrorAction SilentlyContinue) {
            $fullPath = Convert-Path -LiteralPath $item
            $uri = [System.Uri]::new($fullPath).AbsoluteUri
            $targetList.Add($uri)
            continue
        }

        # 4. 通配符匹配 (如 *.pdf 或 .\*.pdf)
        $matched = $false
        if ($item -match '[\*\?]') {
            $parent = Split-Path -Path $item -Parent
            $leaf = Split-Path -Path $item -Leaf
            if (-not $parent) { $parent = "." }

            $found = @()
            if (Test-Path -LiteralPath $parent -ErrorAction SilentlyContinue) {
                $found = @(Get-ChildItem -LiteralPath $parent -Filter $leaf -File -ErrorAction SilentlyContinue)
            }
            if ($found.Count -eq 0) {
                $found = @(Get-ChildItem -Path $item -File -ErrorAction SilentlyContinue)
            }

            if ($found.Count -gt 0) {
                $matched = $true
                foreach ($f in $found) {
                    $uri = [System.Uri]::new($f.FullName).AbsoluteUri
                    $targetList.Add($uri)
                }
            }
        }

        # 5. 未找到匹配项
        if (-not $matched) {
            Write-Warning "未找到文件或路径: $item"
        }
    }

    if ($targetList.Count -gt 0) {
        Start-Process $edgeExe -ArgumentList $targetList
    }
}

