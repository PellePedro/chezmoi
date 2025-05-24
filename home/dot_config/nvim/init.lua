-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.python3_host_prog = vim.fn.expand("~/.local/share/venv")
vim.opt_local.conceallevel = 0
require("config.lazy")
