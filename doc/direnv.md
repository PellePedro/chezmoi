# 🌍 direnv Usage Guide

> Automatically load and unload environment variables when you `cd` into a directory.

## 📖 What is direnv?

direnv is an environment switcher for the shell. It loads and unloads environment variables depending on the current directory. Instead of cluttering your `~/.zshrc` with project-specific exports, you define them per-project in `.envrc` files.

## ⚡ Shell Integration

### zsh

```bash
eval "$(direnv hook zsh)"
```

### bash

```bash
eval "$(direnv hook bash)"
```

> 💡 This is already configured in the dotfiles managed by chezmoi.

## 🚀 Quick Start

```bash
# 1. Create a .envrc in your project
cd ~/my-project
echo 'export API_KEY="secret123"' > .envrc

# 2. Allow the file (required for security)
direnv allow

# 3. That's it! Variables load automatically when you enter the directory
echo $API_KEY   # secret123

# 4. Leave the directory — variables are unloaded
cd ~
echo $API_KEY   # (empty)
```

## 🔧 Common Commands

| Command | Description |
|---|---|
| `direnv allow` | ✅ Trust and load the current `.envrc` |
| `direnv deny` | 🚫 Block the current `.envrc` from loading |
| `direnv reload` | 🔄 Reload the environment |
| `direnv edit` | ✏️ Open `.envrc` in your editor |
| `direnv status` | 📊 Show current direnv state |

## 📝 Helper Functions

direnv provides stdlib functions you can use in `.envrc` files:

```bash
# Add a directory to PATH (cleaner than manual export)
PATH_add bin
PATH_add scripts

# Load a .env file
dotenv

# Load .env only if it exists
dotenv_if_exists

# Use a specific layout (e.g., Python venv)
layout python3

# Source another envrc
source_env ../.envrc

# Set and export in one step
export_function() { ... }
```

## 📂 Example `.envrc` Files

### 🐍 Python Project

```bash
layout python3
export DATABASE_URL="postgres://localhost/mydb"
export FLASK_ENV=development
dotenv_if_exists
```

### 🟢 Node.js Project

```bash
PATH_add node_modules/.bin
export NODE_ENV=development
dotenv_if_exists
```

### 🦀 Go Project

```bash
PATH_add bin
export GOBIN=$(pwd)/bin
export CGO_ENABLED=0
```

### 🔧 General Project

```bash
# Add local bin to PATH
PATH_add bin

# Set project root
export PROJECT_ROOT=$(pwd)

# Load secrets from .env (gitignored)
dotenv_if_exists

# Set tool versions
export TERRAFORM_VERSION=1.5.0
```

## 🔒 Security

- direnv will **never** load an `.envrc` without explicit `direnv allow`
- If the file changes, you must re-allow it
- Always add `.env` to `.gitignore` — use `dotenv_if_exists` to load secrets

## 💡 Tips

- 🔇 Add `.envrc` to your global `.gitignore` if you use project-specific configs
- 📦 Use `direnv allow` after cloning a repo with a `.envrc`
- 🧹 Run `direnv deny` to quickly unload an environment
- 🔗 Chain environments with `source_env` for shared configs across projects
