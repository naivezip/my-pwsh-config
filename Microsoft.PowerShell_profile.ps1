# ==============================================================================
# PowerShell 7 Profile (现代化 CLI & Oh-My-Zsh 交互体验增强)
# ==============================================================================

# ---- 0. 控制台编码设置 (解决图标/Unicode乱码问题) ---------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ---- 1. PSReadLine 配置 (智能补全、历史预测与按键) ---------------------------
if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
# 历史回溯：输入前缀后按上下键，只搜索以该前缀开头的历史记录 (极爽的 Zsh 经典体验)
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ---- 2. Starship 提示符初始化 ------------------------------------------------
$starshipCmd = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipCmd) {
    Invoke-Expression (& $starshipCmd.Source init powershell --print-full-init | Out-String)
} elseif (Test-Path "$env:ProgramFiles\starship\bin\starship.exe") {
    Invoke-Expression (& "$env:ProgramFiles\starship\bin\starship.exe" init powershell --print-full-init | Out-String)
}

# ---- 3. 现代 CLI 工具别名与集成 ----------------------------------------------
# eza: 替代 ls / dir (彩色、图标、按文件夹排序、Git 状态)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons --group-directories-first $args }
    function ll { eza -la --icons --octal-permissions --group-directories-first --git $args }
    function l { eza -l --icons --group-directories-first $args }
    function la { eza -a --icons --group-directories-first $args }
    function tree { eza --tree --icons --level=3 $args }
}

# bat: 替代 cat (语法高亮与行号)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat --paging=never $args }
    function preview { bat $args }
}

# zoxide: 智能快速跳转 (z 关键字 / zi 交互跳转)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}

# fzf & fd: 模糊搜索与高效查找
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --inline-info"
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
    }
}

# btop: 性能监控快捷键
if (Get-Command btop -ErrorAction SilentlyContinue) {
    function top { btop $args }
}

# lazygit: Git 终端图形界面
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    function lg { lazygit $args }
}

# ---- 4. Oh-My-Zsh 风格的常用 Git 极速缩写 ------------------------------------
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

# ---- 5. Linux 常用习惯函数 ---------------------------------------------------
function which { Get-Command $args }
function touch {
    foreach ($file in $args) {
        if (-not (Test-Path $file)) {
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
    }
}
