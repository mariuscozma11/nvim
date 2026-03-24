return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("moonfly")
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
  {
    "echasnovski/mini.tabline",
    version = false,
    config = function()
      require("mini.tabline").setup()
    end,

  },
}
