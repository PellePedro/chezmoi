# 🏠 chezmoi Usage Guide

> Manage your dotfiles across multiple machines, securely and declaratively.

## 📖 What is chezmoi?

chezmoi is a dotfile manager that helps you manage your personal configuration files (dotfiles) across multiple machines. It uses a source-state model — you edit files in a source directory and chezmoi applies them to your home directory, supporting templates, encryption, and OS-specific configs.

## 🗂️ How This Repo is Structured

```
~/.local/share/chezmoi/          # Source directory (this repo)
├── home/                        # 🏠 Root for managed files (.chezmoiroot = home)
│   ├── .chezmoi.yaml.tmpl      # ⚙️ Chezmoi config template
│   ├── dot_bashrc              # → ~/.bashrc
│   ├── symlink_dot_zshrc       # → ~/.zshrc (symlink)
│   ├── dot_config/             # → ~/.config/
│   │   ├── nvim/               #   → ~/.config/nvim/
│   │   ├── ghostty/            #   → ~/.config/ghostty/
│   │   ├── ripgrep/            #   → ~/.config/ripgrep/
│   │   ├── zsh/                #   → ~/.config/zsh/
│   │   └── ...
│   ├── dot_lima/               # → ~/.lima/
│   └── dot_opencode/           # → ~/.opencode/
├── scripts/                     # 📜 Installation scripts
├── doc/                         # 📚 Documentation
└── .chezmoiignore              # 🚫 Files to ignore during apply
```

### 📛 Naming Conventions

| Prefix | Meaning | Example |
|---|---|---|
| `dot_` | Becomes a `.` | `dot_bashrc` → `.bashrc` |
| `private_` | Sets permissions to `0600` | `private_dot_ssh/` |
| `symlink_` | Creates a symlink | `symlink_dot_zshrc` |
| `encrypted_` | Decrypted on apply | `encrypted_private_key` |
| `exact_` | Removes extra files in dir | `exact_dot_config/` |
| `.tmpl` suffix | Processed as a template | `.chezmoi.yaml.tmpl` |

## 🚀 Quick Start

### 🆕 First Machine (Init)

```bash
# Initialize from your repo
chezmoi init git@github.com:pellepedro/chezmoi.git

# Preview what would change
chezmoi diff

# Apply dotfiles to your home directory
chezmoi apply
```

### 💻 New Machine (Clone & Apply)

```bash
# One-liner: init + apply
chezmoi init --apply git@github.com:pellepedro/chezmoi.git
```

## 🔧 Common Commands

| Command | Description |
|---|---|
| `chezmoi apply` | ✅ Apply source state to home directory |
| `chezmoi diff` | 🔍 Preview changes before applying |
| `chezmoi add <file>` | ➕ Add a file to be managed |
| `chezmoi edit <file>` | ✏️ Edit a managed file in source |
| `chezmoi cd` | 📂 Open a shell in the source directory |
| `chezmoi update` | 🔄 Pull latest changes and apply |
| `chezmoi status` | 📊 Show what would change |
| `chezmoi managed` | 📋 List all managed files |
| `chezmoi data` | 📦 Show template data |
| `chezmoi doctor` | 🩺 Check chezmoi health |
| `chezmoi git -- <args>` | 🔀 Run git in the source directory |

## 📝 Daily Workflow

### ✏️ Editing a Managed File

```bash
# Option 1: Edit the source directly
chezmoi edit ~/.bashrc
# Then apply
chezmoi apply

# Option 2: Edit the actual file, then re-add
vim ~/.bashrc
chezmoi re-add
```

### ➕ Adding a New File

```bash
# Add an existing file to chezmoi
chezmoi add ~/.config/ghostty/config

# Add with encryption
chezmoi add --encrypt ~/.ssh/id_rsa

# Add as a template
chezmoi add --template ~/.gitconfig
```

### 🔄 Syncing Across Machines

```bash
# On machine A — after making changes
chezmoi cd
git add -A && git commit -m "update configs" && git push

# On machine B — pull and apply
chezmoi update
```

## 🔐 Encryption with age

This repo uses [age](https://age-encryption.org/) for encrypting sensitive files.

### ⚙️ Config (`.chezmoi.yaml.tmpl`)

```yaml
encryption: age
age:
  identity: ~/.age/key.txt
  recipient: age17879nz...
```

### 🔑 Setup

```bash
# Generate an age key (one time)
age-keygen -o ~/.age/key.txt

# Get your public key
grep 'age1' ~/.age/key.txt
```

### 🔒 Encrypt a File

```bash
# Add a file with encryption
chezmoi add --encrypt ~/.ssh/id_rsa

# The source file will be encrypted (safe to commit)
```

## 🧩 Templates

Templates use Go's `text/template` syntax and are useful for OS-specific or machine-specific configs.

### 🖥️ OS-Specific Config

```
{{- if eq .chezmoi.os "darwin" }}
export HOMEBREW_PREFIX="/opt/homebrew"
{{- else if eq .chezmoi.os "linux" }}
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{- end }}
```

### 📊 Available Template Data

```bash
# See all available data
chezmoi data

# Common variables:
# .chezmoi.os          → "darwin", "linux"
# .chezmoi.arch        → "amd64", "arm64"
# .chezmoi.hostname    → machine name
# .chezmoi.username    → current user
# .chezmoi.homeDir     → home directory path
```

## 🚫 Ignoring Files

`.chezmoiignore` controls which files in the source are **not** applied:

```
LICENSE
*.md
bootstrap.sh
```

> 💡 This is why the `doc/` and markdown files in this repo don't end up in your home directory.

## 🛠️ Useful Recipes

### 🔍 See What chezmoi Manages

```bash
chezmoi managed
chezmoi managed --include=files
chezmoi managed --include=dirs
```

### 🧪 Dry Run

```bash
# See what would change without applying
chezmoi diff
chezmoi apply --dry-run --verbose
```

### 🗑️ Remove a Managed File

```bash
# Stop managing a file (keeps the actual file)
chezmoi forget ~/.config/old-tool/config
```

### 🔧 Re-add Changed Files

```bash
# If you edited the target file directly
chezmoi re-add

# Or re-add a specific file
chezmoi re-add ~/.bashrc
```

## 💡 Tips

- 🔍 Always run `chezmoi diff` before `chezmoi apply` to preview changes
- 🔄 Use `chezmoi update` on secondary machines — it pulls and applies in one step
- 📂 Use `chezmoi cd` to quickly jump to the source directory
- 🧩 Use templates sparingly — plain files are easier to debug
- 🔐 Never commit `~/.age/key.txt` — it's your decryption key
- 📋 Run `chezmoi doctor` if something seems broken
- ⚡ `chezmoi apply` is idempotent — safe to run multiple times
