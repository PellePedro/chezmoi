# Clone Bare Repository for Worktree Workflow

Clone a remote repository as a bare repo and set it up for a worktree-based development workflow where all worktrees live as subdirectories of the root repo.

## Arguments

- `$ARGUMENTS` - The remote repository URL (e.g., `git@github.com:org/repo.git` or `https://github.com/org/repo.git`)

## Instructions

Perform the following steps:

### 1. Parse the repo name from the URL

Extract the repository name from `$ARGUMENTS` (strip `.git` suffix and path components). For example:
- `git@github.com:org/my-repo.git` → `my-repo`
- `https://github.com/org/my-repo.git` → `my-repo`
- `https://github.com/org/my-repo` → `my-repo`

### 2. Create the directory and clone as bare

```bash
mkdir <repo-name>
cd <repo-name>
git clone --bare $ARGUMENTS .git
```

### 3. Configure the bare repo

```bash
cd <repo-name>
git config core.bare true
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch origin
```

The `remote.origin.fetch` config is needed because bare clones don't set up tracking by default.

### 4. Detect the default branch

Determine the default branch (usually `main` or `master`):

```bash
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

If that fails, check if `main` or `master` exists:

```bash
git show-ref --verify --quiet refs/heads/main && echo main || echo master
```

### 5. Create the main worktree

Create a worktree for the default branch as a subdirectory:

```bash
git worktree add <default-branch> <default-branch>
```

For example, if the default branch is `main`:
```bash
git worktree add main main
```

### 6. Create CLAUDE.md

Create a `CLAUDE.md` file in the **root** of the bare repo directory (next to `.git/` and the worktree directories) with the following content. Replace `<repo-name>`, `<remote-url>`, and `<default-branch>` with the actual values:

```markdown
# <repo-name>

## Git Structure: Bare Repository with Worktrees

This repository uses a **bare repository with worktrees** structure. The `.git` directory is a bare repo, and each branch is checked out as a worktree in a subdirectory.

### Directory Layout

```
<repo-name>/
├── .git/                        # Bare repository (shared git database)
├── CLAUDE.md                    # This file
├── <default-branch>/            # Worktree for the default branch
│   ├── .git                     # File (not dir) linking to ../.git/worktrees/<default-branch>
│   └── [working files]
└── <feature-branch>/            # Additional worktrees (created as needed)
    ├── .git                     # File linking to ../.git/worktrees/<feature-branch>
    └── [working files]
```

### Remote

- **Origin**: `<remote-url>`
- **Default branch**: `<default-branch>`

### How It Works

- **Bare repo (`.git/`)**: Contains the entire git database (objects, refs, config). No working directory.
- **Worktrees**: Each branch gets its own subdirectory with a full working copy. All worktrees share the same git object database.
- **Linking**: Each worktree's `.git` file points back to `.git/worktrees/<name>/`, which contains per-worktree state (HEAD, index, etc.).

### Key Benefits

1. **Multiple branches simultaneously** - No need to stash/switch; each branch has its own directory
2. **Shared object database** - All worktrees share `.git/objects`, saving disk space
3. **Independent staging** - Each worktree has its own index/staging area
4. **Clean organization** - Branches as directories make navigation intuitive

### Common Commands

**List all worktrees:**
```bash
git worktree list
```

**Create a new worktree for an existing remote branch:**
```bash
git fetch origin
git worktree add <branch-name> <branch-name>
```

**Create a new worktree with a new branch:**
```bash
git worktree add <directory-name> -b <new-branch-name>
```

**Remove a worktree:**
```bash
git worktree remove <directory-name>
```

**Switch between worktrees:**
```bash
cd <branch-directory>    # Just cd into the worktree directory
```

### Important Rules

1. **Never delete `.git/`** - It contains the entire repository database shared by all worktrees
2. **Each worktree must be on a different branch** - Git prevents checking out the same branch in multiple worktrees
3. **Never work directly in the root directory** - Always `cd` into a worktree subdirectory before making changes
4. **All git operations work normally** inside any worktree (commit, push, pull, etc.)

### Development Workflow

1. **Always confirm which worktree/branch** you are in before making changes
2. **Never commit directly to `<default-branch>`** - Use feature branches with dedicated worktrees
3. **Create worktrees for feature branches** as subdirectories of this root
```

### 7. Verify the setup

Run the following to verify everything is correct:

```bash
cd <repo-name>
git worktree list
```

Expected output should show the bare repo and the default branch worktree.

### 8. Report to the user

Print a summary:
- Repository cloned as bare repo at `./<repo-name>/.git`
- Default branch worktree created at `./<repo-name>/<default-branch>/`
- `CLAUDE.md` created at `./<repo-name>/CLAUDE.md`
- Remind the user to `cd <repo-name>/<default-branch>` to start working
