return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "go",
      "gomod",
      "gowork",
      "gosum",
    },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },
  },
  opts_extend = {}, -- Disable extending, use only your list
}
