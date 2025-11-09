# Lima

# Homebrew (recommended)
brew install lima
# optional completion
limactl completion bash  # or zsh/fish


```
limactl start armus
```

```
# List instances
limactl list

# Start/Stop
limactl start armus
limactl stop armus

# Delete (destroy)
limactl delete armus

```

```
limactl shell armus   # drops you into a shell as the default user
# (You can also: ssh $(limactl list --format '{{.SSHLocalPort}}' armus) ... but shell is simpler.)
```




