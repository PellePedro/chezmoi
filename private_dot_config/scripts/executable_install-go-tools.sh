#!/bin/bash

set -e

export GOBIN=${HOME}/bin
go install github.com/jesseduffield/lazygit@latest
go install github.com/jesseduffield/lazydocker@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/josharian/impl@latest
go install github.com/koron/iferr@latest


go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/gopls@latest
go install github.com/derailed/k9s@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
