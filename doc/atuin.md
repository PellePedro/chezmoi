# 🐢 atuin Usage Guide

> Magical shell history — search, sync, and never lose a command again.

## 📖 What is atuin?

atuin replaces your shell history with a SQLite database, providing powerful search, context-aware filtering, and optional encrypted sync across machines. It records extra context like exit code, duration, working directory, and hostname.

## ⚡ Shell Integration

### zsh

```bash
eval "$(atuin init zsh)"
```

### bash

```bash
eval "$(atuin init bash)"
```

> 💡 This is already configured in the dotfiles managed by chezmoi.

## 🚀 Quick Start

```bash
# Open interactive search (replaces Ctrl+R)
# Press Ctrl+R, then start typing

# Search from the command line
atuin search "docker run"

# Check stats about your shell usage
atuin stats
```

## 🔍 Interactive Search (Ctrl+R)

Press `Ctrl+R` to open the interactive search UI:

| Key | Action |
|---|---|
| `Ctrl+R` | 🔎 Open search / cycle filter mode |
| `↑` / `↓` | Navigate results |
| `Enter` | ✅ Execute selected command |
| `Tab` | 📋 Copy to command line (edit before running) |
| `Ctrl+D` | 🗑️ Delete selected entry |
| `Esc` | ❌ Cancel |

### 🎯 Filter Modes

Cycle through these with `Ctrl+R` while search is open:

- **Global** 🌍 — search all history from all machines
- **Host** 🖥️ — search only commands from this machine
- **Session** 📂 — search only commands from this terminal session
- **Directory** 📁 — search only commands run in the current directory

## 🔧 Common Commands

| Command | Description |
|---|---|
| `atuin search <query>` | 🔎 Search history for a pattern |
| `atuin history list` | 📜 List recent history |
| `atuin stats` | 📊 Show usage statistics |
| `atuin import auto` | 📥 Import existing shell history |
| `atuin register` | 👤 Create a sync account |
| `atuin login` | 🔑 Log in for sync |
| `atuin sync` | ☁️ Sync history across machines |
| `atuin doctor` | 🩺 Check atuin health |

## ☁️ Sync Across Machines

```bash
# On your first machine — register
atuin register -u <username> -e <email>

# Sync
atuin sync

# On another machine — login
atuin login -u <username>
atuin sync
```

> 🔒 History is end-to-end encrypted. The server never sees your commands.

## ⚙️ Configuration

Config lives at `~/.config/atuin/config.toml`:

```toml
# Search mode: prefix, fulltext, fuzzy, skim
search_mode = "fuzzy"

# Filter mode for Ctrl+R
filter_mode = "global"

# UI style: compact, full
style = "compact"

# Show preview of full command
show_preview = true

# Sync frequency (if logged in)
sync_frequency = "1h"
```

## 📊 Stats Example

```bash
$ atuin stats
╭────────────────────────────╮
│ Total commands:     12,847 │
│ Unique commands:     4,231 │
│ Most used: git status (342)│
╰────────────────────────────╯
```

## 💡 Tips

- 🎯 Use directory filter mode when you can't remember a project-specific command
- 🧹 Delete sensitive entries with `Ctrl+D` in the search UI
- 📥 Run `atuin import auto` right after installing to bring in your existing history
- 🔄 Sync is optional — atuin works great as a local-only tool too
- ⏱️ atuin tracks command duration, so you can find slow commands with `atuin search --exit 0 --duration 10s`
