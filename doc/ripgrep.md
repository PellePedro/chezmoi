# 🔎 ripgrep (rg) Usage Guide

> Blazingly fast recursive search — like grep, but better in every way.

## 📖 What is ripgrep?

ripgrep (`rg`) is a line-oriented search tool that recursively searches directories for a regex pattern. It's built in Rust and is significantly faster than grep, ag, or ack. It respects `.gitignore` rules by default.

## ⚙️ Configuration

This dotfiles repo includes a ripgrep config at `~/.config/ripgrep/config`:

```
--glob=!vendor
--hidden
--line-number
--no-heading
--sort=path
```

> 💡 Set `RIPGREP_CONFIG_PATH=~/.config/ripgrep/config` in your shell to load it automatically.

## 🚀 Quick Start

```bash
# Search for a pattern in the current directory
rg "TODO"

# Search in a specific directory
rg "function" src/

# Search for an exact string (no regex)
rg -F "console.log("

# Case-insensitive search
rg -i "error"
```

## 🔧 Common Usage Patterns

### 🎯 Filtering Files

```bash
# Search only in specific file types
rg "import" -t py           # Python files
rg "import" -t js           # JavaScript files
rg "struct" -t rust          # Rust files
rg "func" -t go              # Go files

# Search with glob patterns
rg "TODO" -g "*.ts"          # Only .ts files
rg "TODO" -g "!*.test.ts"   # Exclude test files
rg "TODO" -g "src/**"        # Only in src/

# Exclude directories
rg "TODO" -g "!node_modules" -g "!vendor"
```

### 📄 Output Control

```bash
# Show context lines
rg "error" -C 3              # 3 lines before and after
rg "error" -B 2              # 2 lines before
rg "error" -A 2              # 2 lines after

# Show only filenames
rg "TODO" -l                 # Files with matches
rg "TODO" --files-without-match  # Files without matches

# Count matches
rg "TODO" -c                 # Count per file
rg "TODO" --count-matches    # Count all matches

# Show only the match (not the whole line)
rg "TODO.*" -o
```

### 🧠 Advanced Patterns

```bash
# Multiline search
rg -U "struct.*\{[^}]*\}"

# Search and replace (preview)
rg "old_name" -r "new_name"

# Word boundary matching
rg -w "log"                  # Matches "log" but not "logging"

# Search hidden files (already on in our config)
rg --hidden "secret"

# Search files ignored by .gitignore
rg --no-ignore "TODO"

# Include binary files
rg -a "pattern" --binary
```

## 📋 Quick Reference

| Flag | Description |
|---|---|
| `-i` | 🔤 Case-insensitive |
| `-w` | 🎯 Match whole words only |
| `-F` | 📌 Fixed string (no regex) |
| `-l` | 📂 List filenames only |
| `-c` | 🔢 Count matches per file |
| `-C N` | 📑 Show N context lines |
| `-t TYPE` | 📎 Filter by file type |
| `-g GLOB` | 🎭 Filter by glob pattern |
| `-o` | ✂️ Show only matching text |
| `-U` | 📜 Multiline mode |
| `-r TEXT` | 🔄 Replace matches (stdout only) |
| `--hidden` | 👁️ Include hidden files |
| `--no-ignore` | 🚫 Don't respect .gitignore |
| `-z` | 📦 Search compressed files |

## 🆚 Compared to grep

```bash
# grep (slow, no .gitignore awareness)
grep -rn "pattern" .

# ripgrep (fast, respects .gitignore, colored output)
rg "pattern"
```

## 🔗 Integration with Other Tools

```bash
# Pipe to fzf for interactive filtering
rg "TODO" | fzf

# Use with vim/neovim (as :grep backend)
# In init.lua:
# vim.o.grepprg = "rg --vimgrep"

# Feed results to xargs
rg -l "old_api" | xargs sed -i 's/old_api/new_api/g'
```

## 💡 Tips

- 🚀 ripgrep is the default search backend in VS Code, Neovim (Telescope), and many other tools
- 📁 Use `rg --files` to list all files ripgrep would search (great for debugging ignore rules)
- 🏷️ Run `rg --type-list` to see all built-in file type aliases
- ⚡ For huge repos, use `-t` type filters instead of globs — it's faster
- 🔇 Use `rg -q "pattern"` for silent checks in scripts (exit code only)
