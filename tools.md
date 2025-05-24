# Tools

## Homebrew

```
mkdir -p ~/.local/share/Homebrew &&
curl -L https://github.com/Homebrew/brew/tarball/master |
tar xz --strip 1 -C ~/.local/share/Homebrew

mkdir -p ~/.local/bin &&
ln -s ~/.local/Homebrew/bin/brew ~/.local/bin


```
```

```
cat << 'EOF' >> ~/.zshrc
[ -d "$HOME/.local/bin" ] &&
export PATH="$PATH:$HOME/.local/bin"
EOF
```
```


```
```

## Age

# On your laptop
age-keygen -o ~/.age/key.txt    # one time
grep 'age1' ~/.age/key.txt      # get public key

~/.local/share/chezmoi/home     # chezmoi source dir
├── .chezmoi.yaml               # chezmoi config
├── private_dot_ssh/
│   ├── id_rsa.tmpl           # Template: decrypts id_rsa.age during apply
│   └── id_rsa.age            # The encrypted SSH key (safe in Git)
└── key.txt



## Chezmoi
