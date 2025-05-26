# My Dotfiles

## Prereq (MacOS)
```
homebrew
```

## Install core apps
- chezmoi 
- age
- gopass
- uv

```bash
URL=https://raw.githubusercontent.com/PellePedro/chezmoi/refs/heads/main/scripts/install.sh
curl --proto '=https' --tlsv1.2 -LsSf "${URL}" | sh 
```

## Clone Repo
```bash
chezmoi init --apply git@github.com:PellePedro/chezmoi.git
```

