-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Installs LSP servers (and other tools) easily
  {
    "williamboman/mason.nvim",
    config = true,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- installs these via Mason (so you don't have to)
      ensure_installed = { "gopls", "ts_ls", "lua_ls", "clangd", "rust_analyzer" },

      -- optional: automatically call vim.lsp.enable() for installed servers
      automatic_enable = true,
    },
  },

  -- Provides server defaults (configs, root markers, etc.)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim" },
    config = function()
      -- LSP keymaps when a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })

      -- If you use nvim-cmp, advertise completion capabilities to LSP servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Register/override configs using the NEW API (Neovim 0.11+)
      -- nvim-lspconfig supplies the baseline config; this adds your custom bits.
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,
            analyses = { unusedparams = true },
            staticcheck = true,
            semanticTokens = true,
          },
        },
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = { "clangd", "--background-index" },
        -- nice-to-haves:
        -- "--clang-tidy", -- enable clang-tidy diagnostics (can be noisy)
        -- "--completion-style=detailed",
      })
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })
      -- If you did NOT set mason-lspconfig automatic_enable=true,
      -- enable explicitly:
      -- vim.lsp.enable({ "gopls", "ts_ls", "lua_ls" })
    end,
  },

  -- Completion (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- Formatting (format-on-save)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        format_on_save = function()
          return { timeout_ms = 2000, lsp_fallback = true }
        end,
        formatters_by_ft = {
          go = { "goimports", "gofmt" },
          typescript = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          javascript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          lua = { "stylua" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          rust = { "rustfmt" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format" })
    end,
  },
}
