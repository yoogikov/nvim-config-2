return {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.10.0",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "python",
        "cpp",
        "c",
        "proto",
        "dockerfile",
        "starlark",
        "bash",
        "javascript",
        "lua",
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = false },
      modules = {},
      ignore_install = {},
      auto_install = false
    })
  end
}
