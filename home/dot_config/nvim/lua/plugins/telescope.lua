return {
  "nvim-telescope/telescope.nvim",
  enabled = true,
  keys = {
    { "<leader>/", false },
    { "\\r", [[<cmd>lua vim.lsp.buf.rename()<cr>]], desc = "LSP Rename" },
    { "\\2", [[<cmd>:Telescope buffers<CR>]], desc = "Buffers" },
    { "\\q", [[<cmd>:Telescope aerial<CR>]], desc = "LSP Symbols" },
    {
      "\\s",
      function()
        require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ") })
      end,
      desc = "Search for",
    },
    {
      "\\w",
      function()
        require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
      end,
      desc = "Find word under cursor",
    },
  },
}
