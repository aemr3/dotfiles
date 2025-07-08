return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "lua-language-server",
        "luacheck",
        "shfmt",
        "mypy",
        "pyright",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "typescript-language-server",
        "eslint-lsp",
        "phpactor",
        "phpcs",
        "php-cs-fixer",
        "hadolint",
        "markdownlint",
        "prettier",
        "prisma-language-server",
        "rubocop",
        "ruff",
        "taplo",
        "yq",
        "codelldb",
        "goimports",
        "actionlint",
        "tailwindcss-language-server",
        "json-lsp",
        "omnisharp",
        "ruby-lsp",
        "terraform-ls",
        "gopls",
        "rust-analyzer",
      },
    },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      {
        "mrcjkb/rustaceanvim",
        version = "^4",
        ft = { "rust" },
        keys = {
          {
            "<leader>rr",
            "<cmd>RustLsp runnables<CR>",
            desc = "LSP: [R]ust [R]unnables",
          },
          {
            "<leader>rd",
            "<cmd>RustLsp debuggables<CR>",
            desc = "LSP: [R]ust [D]ebuggables",
          },
        },
      },
    },
    init = function()
      local icons = require("config.icons")
      local x = vim.diagnostic.severity
      local i = icons.diagnostics
      vim.diagnostic.config({
        virtual_text = { prefix = i.VirtualText },
        signs = {
          text = {
            [x.ERROR] = i.Error,
            [x.WARN] = i.Warn,
            [x.INFO] = i.Info,
            [x.HINT] = i.Hint,
          },
        },
        underline = true,
        float = { border = "single" },
      })

      vim.lsp.enable("eslint")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("tailwindcss")
      vim.lsp.enable("pyright")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("omnisharp")
      vim.lsp.enable("ruby_lsp")
      vim.lsp.enable("ruff")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("rust_analyzer")

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "jit" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })

      vim.lsp.config("pyright", {
        capabilities = (function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
          return capabilities
        end)(),
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "off",
            },
          },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        vue = { "prettier" },
        svelte = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        docker = { "prettier" },
        sh = { "shfmt" },
        go = { "goimports", "gofmt" },
        ruby = { "rubocop" },
        rust = { "rustfmt" },
        yaml = { "yq" },
        toml = { "taplo" },
        tf = { "terraform_fmt" },
        python = function(bufnr)
          if require("conform").get_formatter_info("ruff_format", bufnr).available then
            return { "ruff_fix", "ruff_format", "ruff_organize_imports" }
          else
            return { "isort", "black" }
          end
        end,
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        lua = { "luacheck" },
        docker = { "hadolint" },
      }
    end,
  },
}
