return {
  -- Better highlighting and parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        highlight = { enabled = true },
        additional_vim_regex_highlighting = false,
        indent = { enabled = true },
        ensure_installed = {
          "go",
          "gomod",
          "gowork",
          "typescript",
          "tsx",
          "javascript",
          "json",
          "lua",
          "vimdoc",
          "markdown",
          "yaml",
          "bash",
          "c_sharp",
        },
      })
    end,
  },
}
