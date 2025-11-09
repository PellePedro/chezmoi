# Lima

# Homebrew (recommended)
brew install lima
# optional completion
limactl completion bash  # or zsh/fish


limactl start ubuntu-arm64-noble


```
# List instances
limactl list

# Start/Stop
limactl start ubuntu-lts
limactl stop ubuntu-lts

# Delete (destroy)
limactl delete ubuntu-lts

```

```
limactl shell ubuntu-lts   # drops you into a shell as the default user
# (You can also: ssh $(limactl list --format '{{.SSHLocalPort}}' ubuntu-lts) ... but shell is simpler.)
```




