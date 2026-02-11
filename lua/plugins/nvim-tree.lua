-- ~/.config/nvim/lua/plugins/nvim-tree.lua
return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*", -- use latest stable tag
    dependencies = {
      -- optional, but recommended for file icons
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeOpen" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>",   desc = "Explorer (toggle)" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Explorer (reveal file)" },
    },
    init = function()
      -- recommended: disable netrw to avoid conflicts
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- you already set this elsewhere, but it's fine to keep it here too
      vim.opt.termguicolors = true
    end,
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 32 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },

      -- Quality-of-life
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      git = { enable = true },
      diagnostics = { enable = true },

      -- Close tree when opening a file (optional: set to false if you prefer it pinned)
      actions = {
        open_file = { quit_on_open = false },
      },
    },
  },
}
