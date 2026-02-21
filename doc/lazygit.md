# 🦥 lazygit Usage Guide

> A terminal UI for git that makes complex operations simple.

## 📖 What is lazygit?

lazygit is a terminal-based UI for git written in Go. It gives you a visual, interactive way to stage files, commit, branch, rebase, resolve conflicts, and more — all without memorizing git commands.

## 🚀 Launch

```bash
# Open lazygit in the current repo
lazygit

# Or use the alias
lg
```

## 🗂️ Panel Layout

lazygit has 5 main panels. Press the number or `Tab` to switch between them:

```
┌──────────────┬─────────────────────────────────┐
│ 1 Status     │                                 │
├──────────────┤         Main View               │
│ 2 Files      │     (diff, log, staged, etc.)   │
├──────────────┤                                 │
│ 3 Branches   │                                 │
├──────────────┤                                 │
│ 4 Commits    │                                 │
├──────────────┤                                 │
│ 5 Stash      │                                 │
└──────────────┴─────────────────────────────────┘
```

| Panel | What it shows |
|---|---|
| **Status** | 📊 Current branch, repo name, upstream |
| **Files** | 📂 Unstaged/staged changes (like `git status`) |
| **Branches** | 🌿 Local & remote branches |
| **Commits** | 📜 Commit log for the current branch |
| **Stash** | 📦 Stashed changes |

## ⌨️ Global Navigation

| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | ➡️ Switch between panels |
| `1`-`5` | 🔢 Jump to panel directly |
| `j` / `k` | ⬆️⬇️ Move up/down in a list |
| `h` / `l` | ◀️▶️ Scroll left/right in main view |
| `Enter` | 🔎 Expand / focus selected item |
| `Esc` | ⬅️ Go back / close popup |
| `?` | ❓ Show keybindings for current panel |
| `x` | 📋 Open context menu with all actions |
| `/` | 🔍 Filter the current list |
| `q` | 🚪 Quit lazygit |
| `@` | 📋 Open command log (see what git commands lazygit runs) |
| `+` / `-` | 🔧 Cycle diff context size (more/fewer surrounding lines) |
| `W` | 📐 Toggle diff options menu (ignore whitespace, etc.) |
| `Ctrl+r` | 🔀 Switch to a different repo |

## 📂 Files Panel

### 📄 Staging & Unstaging

| Key | Action |
|---|---|
| `Space` | ✅ Stage / unstage selected file |
| `a` | ✅ Stage / unstage **all** files |
| `Enter` | 🔎 Open file to stage individual hunks/lines |
| `d` | 🗑️ Discard changes in file (checkout) |
| `D` | 🗑️ Discard options menu (unstaged only, all, etc.) |
| `e` | ✏️ Edit file in your `$EDITOR` |
| `o` | 📂 Open file in default application |
| `i` | 🙈 Add to `.gitignore` |
| `r` | 🔄 Refresh files |
| `S` | 📦 Stash options (stash all, staged only, keep index) |
| `c` | 💾 Commit (opens commit message editor) |
| `w` | 💾 Commit with pre-commit hook skipped |
| `A` | 📝 Amend last commit with staged changes |
| `C` | 💾 Commit using git editor for message |

### 🔍 Staging Individual Lines

Press `Enter` on a file to enter the **staging view**:

| Key | Action |
|---|---|
| `Space` | ✅ Stage / unstage selected hunk |
| `v` | 📏 Toggle line select / hunk select mode |
| `a` | ✅ Stage / unstage entire file |
| `Esc` | ⬅️ Go back to files list |

> 💡 Use `v` to switch to line mode, then select specific lines with `j`/`k` and `Space`.

## 💾 Committing

| Key | Panel | Action |
|---|---|---|
| `c` | Files | 💾 Open commit message prompt |
| `C` | Files | 💾 Open full editor for commit message |
| `A` | Files | 📝 Amend last commit (add staged changes) |
| `w` | Files | 💾 Commit skipping pre-commit hooks |

### ✍️ Writing a Commit Message

When you press `c`, a prompt appears:

- Type your message and press `Enter` to commit
- Press `Esc` to cancel

For multi-line messages, press `C` to open your `$EDITOR`.

## 📜 Commits Panel

### 🔧 Rewriting History

| Key | Action |
|---|---|
| `r` | ✏️ **Reword** commit message |
| `R` | ✏️ Reword commit in editor (multi-line) |
| `d` | 🗑️ **Delete** commit (drop) |
| `s` | 🫸 **Squash** commit into the one below it |
| `f` | 🫸 **Fixup** — squash and discard this commit's message |
| `e` | ⏸️ Mark commit for **edit** during rebase |
| `p` | 📌 Mark commit for **pick** during rebase |
| `t` | ⏭️ **Revert** commit (creates a new undo commit) |
| `T` | 🏷️ Create a **tag** on the selected commit |
| `Ctrl+j` / `Ctrl+k` | ↕️ **Move** commit up or down (reorder) |
| `g` | 🔄 **Reset** options menu (see below) |
| `c` | 📋 **Copy** commit hash to clipboard |
| `y` | 📋 Copy commit hash |
| `o` | 🌐 Open commit in browser (GitHub/GitLab) |

### 🔄 Reset to a Commit

Press `g` on a commit to open the reset menu:

| Option | Description |
|---|---|
| **Soft** | 🟢 Keep changes staged (`--soft`) |
| **Mixed** | 🟡 Keep changes unstaged (`--mixed`) |
| **Hard** | 🔴 Discard all changes (`--hard`) |

### 🍒 Cherry-Pick

| Key | Action |
|---|---|
| `Shift+C` | 📋 Copy (cherry-pick) selected commit |
| `Shift+V` | 📋 Paste (apply) cherry-picked commits |

### 🩹 Creating a Patch

| Key | Action |
|---|---|
| `Enter` | 🔎 Open commit diff, then select files/hunks |
| `Space` | ✅ Add file/hunk to custom patch |
| `Ctrl+p` | 🩹 Open **custom patch options** menu |

Custom patch options include:
- Apply patch to index
- Apply patch in reverse
- Move patch to new commit
- Move patch out of commit
- Copy patch to clipboard

## 🌿 Branches Panel

### 🔀 Branch Operations

| Key | Action |
|---|---|
| `n` | 🆕 **Create** new branch |
| `Space` | 🔀 **Checkout** selected branch |
| `d` | 🗑️ **Delete** branch |
| `r` | ♻️ **Rebase** current branch onto selected |
| `M` | 🔗 **Merge** selected branch into current |
| `R` | 🏷️ **Rename** branch |
| `u` | ⬆️ Set **upstream** (tracking branch) |
| `f` | 🔄 **Fast-forward** current branch to match selected |
| `w` | 🔎 View branch **worktree** options |

### 📡 Remotes (inside Branches panel)

Press `Tab` within the Branches panel to switch between:
- **Local Branches**
- **Remotes**
- **Tags**

#### 🌐 Remotes Sub-Tab

| Key | Action |
|---|---|
| `n` | ➕ **Add** a new remote |
| `d` | 🗑️ **Delete** a remote |
| `e` | ✏️ **Edit** remote URL |
| `f` | 🔄 **Fetch** remote |
| `Enter` | 📂 Expand remote to show its branches |

## ⬆️ Push & Pull

| Key | Panel | Action |
|---|---|---|
| `p` | Files / Branches | ⬇️ **Pull** from remote |
| `P` | Files / Branches | ⬆️ **Push** to remote |
| `P` (on unpushed) | Commits | ⬆️ **Push** commits |
| `f` | Files | 🔄 **Fetch** all remotes |

### ⬆️ Push Options

When pushing, lazygit may prompt:

- **Normal push** — `git push`
- **Force push** — `git push --force-with-lease`
- **Push to specific remote** — choose remote and branch

> 💡 If the branch has no upstream, lazygit prompts you to set one.

## 📦 Stash Panel

| Key | Action |
|---|---|
| `Space` | 📂 Apply stash entry |
| `g` | 📂 Pop stash entry (apply + drop) |
| `d` | 🗑️ Drop stash entry |
| `n` | 📦 New stash from current changes |
| `r` | 🏷️ Rename stash entry |

## 🔀 Interactive Rebase

Start an interactive rebase from the **Commits** panel:

1. Navigate to the commit **before** where you want to start
2. Press `e` to edit, or just use these keys directly on commits:

| Key | Action |
|---|---|
| `s` | 🫸 Squash into previous commit |
| `f` | 🫸 Fixup (squash, discard message) |
| `d` | 🗑️ Drop commit |
| `e` | ⏸️ Edit commit (pause rebase here) |
| `p` | ✅ Pick (keep as-is) |
| `Ctrl+j` / `Ctrl+k` | ↕️ Reorder commits |

> 💡 During a rebase, a banner appears at the top. Resolve conflicts in the Files panel, stage them, then press `m` to continue.

## ⚔️ Merge Conflict Resolution

When conflicts arise:

1. Go to the **Files** panel
2. Select the conflicted file and press `Enter`
3. Use these keys in the conflict view:

| Key | Action |
|---|---|
| `↑` / `↓` | Navigate between conflicts |
| `←` / `→` | Choose left (ours) / right (theirs) |
| `b` | Choose both |
| `Space` | Pick current selection |
| `Esc` | Done — go back |

After resolving all conflicts:

| Key | Action |
|---|---|
| `Space` | ✅ Stage the resolved file |
| `m` | ▶️ Continue merge / rebase |

## 🔎 Searching & Filtering

| Key | Panel | Action |
|---|---|---|
| `/` | Any | 🔍 Filter current list |
| `Ctrl+s` | Commits | 🔎 Search commits by message |

## ⚙️ Configuration

Config lives at `~/.config/lazygit/config.yml`:

```yaml
gui:
  theme:
    activeBorderColor:
      - green
      - bold
  showFileTree: true       # Show files as tree vs flat list
  showRandomTip: false
  mouseEvents: true

git:
  paging:
    colorArg: always
    pager: delta            # Use delta for pretty diffs

os:
  editPreset: nvim          # Editor for commits/edits
```

## 📋 Cheat Sheet — Most Used Operations

| Operation | Keys |
|---|---|
| 📂 Stage file | `Space` (Files panel) |
| 📂 Stage all | `a` (Files panel) |
| 💾 Commit | `c` (Files panel) |
| 📝 Amend commit | `A` (Files panel) |
| ✏️ Reword commit | `r` (Commits panel) |
| 🗑️ Delete commit | `d` (Commits panel) |
| 🫸 Squash commit | `s` (Commits panel) |
| ↕️ Reorder commits | `Ctrl+j` / `Ctrl+k` (Commits panel) |
| 🔄 Reset to commit | `g` (Commits panel) |
| 🩹 Build custom patch | `Enter` → `Space` → `Ctrl+p` (Commits) |
| 🆕 Create branch | `n` (Branches panel) |
| 🔀 Checkout branch | `Space` (Branches panel) |
| 🗑️ Delete branch | `d` (Branches panel) |
| 🔗 Merge branch | `M` (Branches panel) |
| ♻️ Rebase onto branch | `r` (Branches panel) |
| ⬇️ Pull | `p` |
| ⬆️ Push | `P` |
| 🔄 Fetch | `f` (Files panel) |
| ➕ Add remote | `n` (Remotes sub-tab) |
| 📂 Show remotes | `Tab` in Branches → Remotes |
| 🍒 Cherry-pick | `Shift+C` copy, `Shift+V` paste |
| 📦 Stash changes | `S` (Files panel) |
| 📂 Pop stash | `g` (Stash panel) |

## 💡 Tips

- ❓ Press `?` in any panel to see all keybindings for that panel
- 📋 Press `x` to open the context menu with all available actions
- 📜 Press `@` to see the actual git commands lazygit runs behind the scenes
- 🔍 Press `Enter` on almost anything to drill deeper (files, commits, branches)
- ⚡ Use `[` and `]` to switch tabs within a panel (branches → remotes → tags)
- 🖱️ Mouse support is enabled by default — click panels and items
- 🔧 Lazygit is fully configurable — override any keybinding in `config.yml`
