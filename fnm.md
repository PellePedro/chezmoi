# fnm Usage Guide

## Overview

fnm (Fast Node Manager) is a fast and simple Node.js version manager built in Rust.

## Shell Integration

### zsh (.zshrc)

Add the following to your `.zshrc`:

```bash
# fnm
eval "$(fnm env --use-on-cd)"
```

### bash (.bashrc)

Add the following to your `.bashrc`:

```bash
# fnm
eval "$(fnm env --use-on-cd)"
```

### fish (.config/fish/config.fish)

```bash
# fnm
fnm env --use-on-cd | source
```

The `--use-on-cd` flag automatically switches to the Node.js version specified in `.node-version` or `.nvmrc` when you change directories.

## Common Commands

- `fnm install <version>` - Install a specific Node.js version
- `fnm install --lts` - Install the latest LTS version
- `fnm use <version>` - Use a specific Node.js version
- `fnm default <version>` - Set default Node.js version
- `fnm list` - List installed Node.js versions
- `fnm list-remote` - List available Node.js versions
- `fnm current` - Show current Node.js version
- `fnm uninstall <version>` - Uninstall a Node.js version

## Project-Specific Versions

Create a `.node-version` file in your project root:

```
20.11.0
```

Or use `.nvmrc`:

```
v20.11.0
```

When you `cd` into the directory, fnm will automatically switch to that version (if `--use-on-cd` is enabled).

## Example Workflow

```bash
# Install latest LTS
fnm install --lts

# Set it as default
fnm default lts-latest

# Install specific version for a project
fnm install 18.19.0
fnm use 18.19.0

# Create .node-version file
echo "18.19.0" > .node-version
```
