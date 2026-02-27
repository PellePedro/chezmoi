# Clone Bare Repository for Worktree Workflow

Clone a remote repository as a bare repo and set it up for a worktree-based development workflow where all worktrees live as subdirectories of the root repo.

## Arguments

- `$ARGUMENTS` - The remote repository URL (e.g., `git@github.com:org/repo.git` or `https://github.com/org/repo.git`)

## Instructions

**IMPORTANT**: The Bash tool may reset the shell working directory between calls. To prevent operations from running in the wrong directory, you MUST:
1. Determine the **absolute path** of the current working directory at the start (referred to as `<base-dir>` below).
2. Use **absolute paths** for ALL subsequent Bash commands — never rely on relative `cd` between separate Bash tool calls.
3. All paths below use `<base-dir>/<repo-name>` as the root of the new bare repo.

Perform the following steps:

### 1. Parse the repo name from the URL

Extract the repository name from `$ARGUMENTS` (strip `.git` suffix and path components). For example:
- `git@github.com:org/my-repo.git` → `my-repo`
- `https://github.com/org/my-repo.git` → `my-repo`
- `https://github.com/org/my-repo` → `my-repo`

### 2. Create the directory and clone as bare

```bash
mkdir <base-dir>/<repo-name>
git clone --bare $ARGUMENTS <base-dir>/<repo-name>/.git
```

### 3. Configure the bare repo

```bash
cd <base-dir>/<repo-name> && git config core.bare true && git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" && git fetch origin
```

The `remote.origin.fetch` config is needed because bare clones don't set up tracking by default.

### 4. Detect the default branch and clean up local branches

`git clone --bare` copies all remote branches as local `refs/heads/*`. After fetching the remote tracking refs, delete all local branches except the default branch so that only worktree-created branches exist locally.

Determine the default branch (usually `main` or `master`):

```bash
cd <base-dir>/<repo-name> && git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

If that fails, check if `main` or `master` exists:

```bash
cd <base-dir>/<repo-name> && git show-ref --verify --quiet refs/heads/main && echo main || echo master
```

Then delete all local branches except the default branch:

```bash
cd <base-dir>/<repo-name> && git for-each-ref --format='%(refname:short)' refs/heads/ | grep -v "^<default-branch>$" | xargs -r git branch -D
```

This ensures only the default branch exists locally. Additional local branches will be created on-demand by `git worktree add`.

### 5. Create the main worktree and set up tracking

Create a worktree for the default branch as a subdirectory and configure it to track the upstream remote branch:

```bash
cd <base-dir>/<repo-name> && git worktree add <default-branch> <default-branch>
cd <base-dir>/<repo-name> && git config branch.<default-branch>.remote origin && git config branch.<default-branch>.merge refs/heads/<default-branch>
```

For example, if the default branch is `main`:
```bash
cd <base-dir>/<repo-name> && git worktree add main main
cd <base-dir>/<repo-name> && git config branch.main.remote origin && git config branch.main.merge refs/heads/main
```

This ensures `git pull`, `git push`, and `git status` (ahead/behind) work correctly inside the worktree.

### 6. Create CLAUDE.md

Create a `CLAUDE.md` file at `<base-dir>/<repo-name>/CLAUDE.md` (next to `.git/` and the worktree directories) with the following content. Replace `<repo-name>`, `<remote-url>`, and `<default-branch>` with the actual values:

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

### 7. Create envrc and symlink it into the worktree

Create a file called `envrc` (no leading dot) at `<base-dir>/<repo-name>/envrc` (next to `.git/` and `CLAUDE.md`) with the following content:

```bash
export SKYRAMPDIR=$PWD
export PATH=$PWD/bin:$PATH
export GOFLAGS="-buildvcs=false"
export PIPDIR=$SKYRAMPDIR/libs/pip/dist
export NPM_BUILD_ARTIFACT="$SKYRAMPDIR/libs/npm/skyramp-skyramp-1.0.0.tgz"
export PIP_BUILD_ARTIFACT="$SKYRAMPDIR/libs/pip/dist/skyramp-1.0.tar.gz"
export JAVA_BUILD_ARTIFACT="$SKYRAMPDIR/libs/java/target/skyramp-library-0.0.1.jar"
```

Then create a symlink inside the default branch worktree pointing back to this file:

```bash
ln -s ../envrc <base-dir>/<repo-name>/<default-branch>/.envrc
```

This `envrc` file is intended to be used with [direnv](https://direnv.net/). Each worktree will symlink to it as `.envrc` so that environment variables are set correctly when entering any worktree directory. When creating additional worktrees in the future, the same symlink pattern should be used: `ln -s ../envrc <base-dir>/<repo-name>/<worktree-dir>/.envrc`.

### 8. Verify the setup

Run the following to verify everything is correct:

```bash
cd <base-dir>/<repo-name> && git worktree list
```

Expected output should show the bare repo and the default branch worktree.

### 9. Report to the user

Print a summary:
- Repository cloned as bare repo at `./<repo-name>/.git`
- Default branch worktree created at `./<repo-name>/<default-branch>/`
- `CLAUDE.md` created at `./<repo-name>/CLAUDE.md`
- `envrc` created at `./<repo-name>/envrc` and symlinked as `./<repo-name>/<default-branch>/.envrc`
- Remind the user to `cd <repo-name>/<default-branch>` to start working
- Remind the user to run `direnv allow` inside the worktree if direnv doesn't auto-allow
