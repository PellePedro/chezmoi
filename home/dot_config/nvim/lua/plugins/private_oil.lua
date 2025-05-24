return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    -- keys = { "<leader>o" },
    keys = { "-" },
    config = function()
      require("oil").setup({
        columns = {
          "icon",
        },
        skip_confirm_for_simple_edits = true,
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
        },
        default_file_explorer = false,
      })
      vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Oil" })
    end,
  },
}
