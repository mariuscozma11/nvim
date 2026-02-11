return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2", -- IMPORTANT: use maintained version
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()



      -- Add current file
      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })

      -- Toggle quick menu
      vim.keymap.set("n", "<leader>hm", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon menu" })

      -- Remove current file from harpoon
      vim.keymap.set("n", "<leader>hr", function()
        require("harpoon"):list():remove()
      end, { desc = "Harpoon: remove file" })

      -- Jump to files
      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end)

      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end)

      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end)

      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end)

      -- Optional: cycle
      vim.keymap.set("n", "<C-S-P>", function()
        harpoon:list():prev()
      end)

      vim.keymap.set("n", "<C-S-N>", function()
        harpoon:list():next()
      end)
    end,
  },
}
