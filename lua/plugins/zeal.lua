-- ~/.config/nvim/lua/plugins/zeal.lua
return {
  {
    "KabbAmine/zeavim.vim",
    cmd = { "Zeavim", "ZeavimV", "Zeal" },
    keys = {
      { "<leader>z", "<cmd>Zeavim<cr>", desc = "Zeal (word under cursor)" },
      { "<leader>z", "<cmd>ZeavimV<cr>", mode = "v", desc = "Zeal (selection)" },
      { "<leader>Z", "<cmd>Zeal<cr>", desc = "Zeal (input)" },
    },
    config = function()
      vim.g.zv_file_types = {
        c = "c",
        cpp = "cpp",
        rust = "rust",
        go = "go",
        lua = "lua",
        python = "python",
        javascript = "javascript",
        typescript = "typescript",
        java = "java",
        cs = "csharp",
      }
    end,
  },
}
