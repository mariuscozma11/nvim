return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Theme: pick ONE. TokyoNight is a safe default.
  {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            semantic_tokens = true,
          },
        },
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto", globalstatus = true },
      })
    end,
  },
}
