# ⚡ fnm Usage Guide

> Fast and simple Node.js version manager, built in Rust.

## 📖 What is fnm?

fnm (Fast Node Manager) is a blazingly fast Node.js version manager. It's a drop-in replacement for nvm that starts in milliseconds instead of seconds. It supports `.node-version` and `.nvmrc` files and can automatically switch versions when you change directories.

## ⚡ Shell Integration

### zsh

```bash
eval "$(fnm env --use-on-cd)"
```

### bash

```bash
eval "$(fnm env --use-on-cd)"
```

> 💡 This is already configured in the dotfiles managed by chezmoi. The `--use-on-cd` flag enables automatic version switching.

## 🚀 Quick Start

```bash
# Install the latest LTS version
fnm install --lts

# Set it as default
fnm default lts-latest

# Check current version
node --version
fnm current
```

## 🔧 Common Commands

| Command | Description |
|---|---|
| `fnm install <version>` | 📥 Install a Node.js version |
| `fnm install --lts` | 📥 Install latest LTS |
| `fnm use <version>` | 🔀 Switch to a version |
| `fnm default <version>` | 📌 Set default version |
| `fnm current` | 📍 Show active version |
| `fnm list` | 📋 List installed versions |
| `fnm list-remote` | 🌐 List all available versions |
| `fnm uninstall <version>` | 🗑️ Remove a version |
| `fnm env` | ⚙️ Print environment variables |

## 📁 Automatic Version Switching

Create a `.node-version` file in your project root:

```
20.11.0
```

Or use `.nvmrc` (nvm-compatible):

```
v20.11.0
```

When `--use-on-cd` is enabled, fnm will automatically switch to the specified version when you `cd` into the directory.

```bash
$ cd ~/project-a    # has .node-version with 20.11.0
Using Node v20.11.0

$ cd ~/project-b    # has .node-version with 18.19.0
Using Node v18.19.0
```

## 🛠️ Example Workflows

### 🆕 Setting Up a New Machine

```bash
# Install latest LTS
fnm install --lts
fnm default lts-latest

# Install additional versions you need
fnm install 18
fnm install 20
fnm install 22

# Verify
fnm list
```

### 📂 Setting Up a Project

```bash
cd my-project

# Use a specific version
fnm use 20

# Pin it for the project
echo "20.11.0" > .node-version

# Now anyone with fnm + --use-on-cd gets the right version
```

### 🔀 Switching Between Projects

```bash
# With --use-on-cd, it's automatic:
cd ~/project-old     # → Node 16
cd ~/project-current # → Node 20
cd ~/project-edge    # → Node 22

# Or switch manually:
fnm use 18
fnm use 20
fnm use --lts
```

## 🏷️ Version Aliases

```bash
# Use partial versions (resolves to latest matching)
fnm install 20        # installs latest 20.x.x
fnm use 18            # uses latest installed 18.x.x

# Use aliases
fnm install --lts     # latest LTS
fnm use lts-latest    # latest LTS
fnm default 20        # default to latest 20.x
```

## 🆚 Compared to nvm

| Feature | fnm | nvm |
|---|---|---|
| Speed | ⚡ ~1ms startup | 🐢 ~200ms startup |
| Language | Rust | Shell script |
| `.node-version` | ✅ | ❌ |
| `.nvmrc` | ✅ | ✅ |
| Auto-switch on cd | ✅ | ✅ (with plugin) |
| Cross-platform | ✅ | ❌ (no native Windows) |

## 💡 Tips

- 🏃 fnm is ~200x faster than nvm at shell startup — your terminal opens instantly
- 📌 Always commit `.node-version` to your repo so teammates use the same Node version
- 🔢 Use partial versions like `fnm install 20` to get the latest patch
- 🔄 Run `fnm install --lts` periodically to stay up to date
- 🧹 Clean up old versions with `fnm list` then `fnm uninstall <old-version>`
