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
      ensure_installed = { "gopls", "ts_ls", "lua_ls", "clangd", "rust_analyzer", "omnisharp", "jdtls", "julials", "pyright", "ruff", "zls", "asm_lsp" },

      -- optional: automatically call vim.lsp.enable() for installed servers
      automatic_enable = true,
    },
  },

  -- Provides server defaults (configs, root markers, etc.)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim" },
    config = function()
      -- Disable hover for ruff (Pyright provides better documentation)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

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
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
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
        cmd = {
          "clangd",
          "--background-index",
          "--query-driver=/usr/bin/g++,/usr/bin/gcc",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
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

      vim.lsp.config("julials", {
        capabilities = capabilities,
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        capabilities = capabilities,
        init_options = {
          settings = {
            lint = {
              ignore = { "E701", "E702", "E703" },
            },
          },
        },
      })

      vim.lsp.config("zls", {
        capabilities = capabilities,
        settings = {
          zls = {
            enable_snippets = true,
            enable_semantic_tokens = true,
            enable_inlay_hints = true,
          },
        },
      })

      vim.lsp.config("asm_lsp", {
        capabilities = capabilities,
      })
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

  -- Java LSP (requires special handling)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local config_dir = jdtls_path .. "/config_linux"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

          local config = {
            cmd = {
              "java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Xmx1g",
              "--add-modules=ALL-SYSTEM",
              "--add-opens", "java.base/java.util=ALL-UNNAMED",
              "--add-opens", "java.base/java.lang=ALL-UNNAMED",
              "-jar", launcher,
              "-configuration", config_dir,
              "-data", workspace_dir,
            },
            root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
            settings = {
              java = {
                signatureHelp = { enabled = true },
                completion = {
                  favoriteStaticMembers = {},
                  filteredTypes = { "com.sun.*", "io.micrometer.shaded.*" },
                },
                sources = {
                  organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
                },
              },
            },
            init_options = {
              bundles = {},
            },
          }

          require("jdtls").start_or_attach(config)
        end,
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
          cs = { "csharpier" },
          java = { "google-java-format" },
          python = { "ruff_fix" },
          zig = { "zigfmt" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format" })
    end,
  },

}
