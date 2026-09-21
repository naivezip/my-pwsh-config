# My PowerShell Configuration 🚀

一套基于 PowerShell 7 (`pwsh`) 的现代化、高性能终端生产力配置。

## ✨ 特性亮点

- **编码保障**：默认全局 UTF-8 编码，彻底杜绝 Nerd Font 图标、Git 提信息与多语言字符乱码。
- **现代化 CLI 工具链集成**（优先加载 Scoop shims）：
  - 🎨 **Starship**：极速、跨平台提示符美化引擎，展示 Git 状态与开发环境信息。
  - 📂 **Zoxide**：智能目录跳转（`z <dir>` / `zi` 交互选择）。
  - 🔍 **Carapace**：全能命令参数自动补全引擎，覆盖 1000+ CLI 工具。
  - ⚡ **Eza / Bat / Btop / Lazygit**：全套 Rust/Go 现代工具替换传统命令（`ls` $\to$ `eza`、`cat` $\to$ `bat`、`top` $\to$ `btop`、`lg` $\to$ `lazygit`）。
- **PSReadLine 智能交互体验**：
  - 类似 Fish 的行内幽灵历史预测（InlineView），按 `→` 快速采纳。
  - 按 `Tab` 弹出网格候选补全菜单（`MenuComplete`），支持方向键选择。
  - 按 `↑`/`↓` 基于已输入前缀精准回溯历史命令。
- **Git 极速缩写别名**：涵盖 `gst`, `ga`, `gaa`, `gc`, `gcm`, `gco`, `gcb`, `gb`, `gl`, `gp`, `gd` 等经典习惯键位。
- **常用生产力小工具**：
  - `which`：快速查看命令绝对路径。
  - `touch`：快速创建空文件。
  - 🌐 **`edge`**：在终端直接唤起本地 Edge 浏览器打开本地 PDF、HTML、图片或网址（支持相对路径自动解析、Tab 补全、通配符批量打开与多标签页）。

---

## 📦 依赖工具推荐

推荐使用 [Scoop](https://scoop.sh/) 安装相关依赖套件：

```powershell
# 核心美化与补全引擎
scoop install starship zoxide carapace

# 现代化 CLI 替代品
scoop install eza bat btop lazygit fzf fd
```

---

## 🚀 安装与使用

### 1. 克隆或同步配置文件

将本仓库内容同步至本地 PowerShell 7 配置目录：

```powershell
git clone https://github.com/naivezip/my-pwsh-config.git "$HOME\Documents\PowerShell"
```

或者将本仓库中的 `Microsoft.PowerShell_profile.ps1` 复制到：
- `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### 2. Starship 提示符配置

将 `starship.toml` 放置到用户配置目录：

```powershell
New-Item -ItemType Directory -Path "$HOME\.config" -Force | Out-Null
Copy-Item ".\starship.toml" "$HOME\.config\starship.toml"
```

### 3. 重载配置

在当前终端中执行：

```powershell
. $PROFILE
```

---

## 📄 开源许可

本项目采用 [MIT](LICENSE) 许可证。
