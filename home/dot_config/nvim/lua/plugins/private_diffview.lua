return {
  "NeogitOrg/neogit",
  cmd = { "Neogit" },
  dependencies = {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
      })
    end,
  },
  config = function()
    require("neogit").setup({
      integrations = { diffview = true },
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
    })
  end,
}
