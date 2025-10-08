# direnv Usage Guide

## Overview

direnv is an environment switcher for the shell. It loads and unloads environment variables depending on the current directory.

## Basic Usage

Create a `.envrc` file in your project directory with environment variables and path modifications.

## Setting PATH

### Using DIRENV_DIR

```bash
# Using DIRENV_DIR
export PATH=$(PWD)/bin:$PATH
export SKYRAMPDIR=$(PWD)

```

### Using direnv's Helper Function (Recommended)

```bash
# Or using direnv's helper function (cleaner)
PATH_add bin
export SKYRAMPDIR=$(PWD)

```

The `PATH_add` function is cleaner and automatically expands relative paths based on the current directory.

## Common Commands

- `direnv allow` - Allow the `.envrc` file to be loaded
- `direnv deny` - Deny the `.envrc` file from being loaded
- `direnv reload` - Reload the environment
- `direnv edit` - Edit the `.envrc` file

## Example .envrc

```bash
# Add local bin to PATH
PATH_add bin

# Set environment variables
export SKYRAMPDIR=${DIRENV_DIR}
export NODE_ENV=development
export API_KEY=your_key_here

# Load .env file if it exists
dotenv_if_exists
```
