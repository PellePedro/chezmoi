# 🚀 zoxide Usage Guide

> A smarter `cd` that learns your habits — jump anywhere in one command.

## 📖 What is zoxide?

zoxide is a blazingly fast replacement for `cd` that remembers which directories you visit. Instead of typing long paths, just type a fragment of the directory name and zoxide takes you there. It ranks directories by frequency and recency (a "frecency" algorithm).

## ⚡ Shell Integration

### zsh

```bash
eval "$(zoxide init zsh)"
```

### bash

```bash
eval "$(zoxide init bash)"
```

> 💡 This is already configured in the dotfiles managed by chezmoi. It adds the `z` and `zi` commands.

## 🚀 Quick Start

```bash
# First, use cd normally for a while so zoxide learns your paths
cd ~/projects/my-app
cd /etc/nginx
cd ~/documents/notes

# Then jump with just a keyword!
z my-app        # → ~/projects/my-app
z nginx         # → /etc/nginx
z notes         # → ~/documents/notes
```

## 🔧 Commands

| Command | Description |
|---|---|
| `z <query>` | 🚀 Jump to the best matching directory |
| `z <query1> <query2>` | 🎯 Jump using multiple keywords |
| `zi <query>` | 🔍 Interactive selection with fzf |
| `z -` | ⏪ Go to previous directory |
| `z ..` | ⬆️ Go up one directory |
| `z ../..` | ⬆️⬆️ Go up two directories |

## 🎯 How Matching Works

zoxide uses "frecency" — a combination of **frequency** (how often) and **recency** (how recently) you visited a directory.

```bash
# Single keyword — matches any part of the path
z proj          # → ~/projects
z api           # → ~/projects/my-api

# Multiple keywords — all must match (in order)
z proj api      # → ~/projects/my-api
z doc work      # → ~/documents/work

# Exact subdirectory match with /
z proj/         # → ~/projects (if you're already in ~)
```

### 🏆 Ranking Example

If you visit these directories:
- `~/projects/frontend` — 50 times
- `~/projects/backend` — 10 times
- `~/old/frontend` — 2 times (months ago)

Then `z front` → `~/projects/frontend` (highest frecency)

## 🔍 Interactive Mode (`zi`)

When multiple directories match, use `zi` to pick interactively:

```bash
$ zi proj
❯ ~/projects/my-api          (score: 120.5)
  ~/projects/my-app          (score: 98.2)
  ~/projects/old-thing       (score: 12.1)
```

> 💡 Requires `fzf` to be installed (already in the brew packages).

## 🛠️ Database Management

```bash
# List all tracked directories with scores
zoxide query -ls

# Add a directory manually
zoxide add ~/some/path

# Remove a directory
zoxide remove ~/old/path

# Remove entries for directories that no longer exist
zoxide remove --stale
```

## 📋 Practical Examples

```bash
# Jump to your project (from anywhere)
z myapp

# Jump to a nested path with multiple keywords
z my app src         # → ~/projects/my-app/src

# Open interactive picker when unsure
zi conf              # Pick between ~/.config, /etc/conf.d, etc.

# Quick back-and-forth
z api                # jump to API project
z front              # jump to frontend project
z -                  # back to API project
```

## ⚙️ Configuration

Environment variables (set before `zoxide init`):

```bash
# Change the main command name (default: z)
export _ZO_CMD_PREFIX=j       # Use j/ji instead of z/zi

# Exclude directories from tracking
export _ZO_EXCLUDE_DIRS="$HOME:$HOME/private/*"

# Change database location
export _ZO_DATA_DIR="$HOME/.local/share/zoxide"

# Maximum number of entries in the database
export _ZO_MAXAGE=10000
```

## 🆚 Compared to `cd`

```bash
# Without zoxide 😩
cd ~/projects/company/services/auth-api/src/handlers

# With zoxide 😎
z auth hand
```

## 💡 Tips

- 🧠 Just use `cd` normally at first — zoxide learns in the background
- 🎯 Use the minimum keywords needed — `z ap` is better than `z my-app` if it's unique
- 🔍 When in doubt, use `zi` for the interactive picker
- 🧹 Run `zoxide remove --stale` occasionally to clean up deleted directories
- 📊 Check your top directories with `zoxide query -ls | head -20`
- 🔗 zoxide works alongside `cd` — you can always fall back to full paths
