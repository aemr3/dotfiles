local helpers = require("config.helpers")
local icons = require("config.icons")

return {
  {
    "christoomey/vim-tmux-navigator",
    event = "BufReadPre",
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
      keys = {
        {
          "<S-Enter>",
          function()
            require("noice").redirect(vim.fn.getcmdline())
          end,
          mode = "c",
          desc = "Redirect Cmdline",
        },
        {
          "<leader>snl",
          function()
            require("noice").cmd("last")
          end,
          desc = "Noice Last Message",
        },
        {
          "<leader>snh",
          function()
            require("noice").cmd("history")
          end,
          desc = "Noice History",
        },
        {
          "<leader>sna",
          function()
            require("noice").cmd("all")
          end,
          desc = "Noice All",
        },
        {
          "<leader>snd",
          function()
            require("noice").cmd("dismiss")
          end,
          desc = "Dismiss All",
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    config = function()
      require("notify").setup({
        background_colour = "#000000",
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      animation = true,
      auto_hide = 1,
      clickable = true,
      focus_on_close = "left",
      highlight_visible = true,
      maximum_padding = 3,
      minimum_padding = 2,
      maximum_length = 30,
      icons = {
        buffer_index = false,
        buffer_number = false,
        button = " ",
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
          [vim.diagnostic.severity.WARN] = { enabled = true, icon = " " },
          [vim.diagnostic.severity.INFO] = { enabled = false },
          [vim.diagnostic.severity.HINT] = { enabled = false },
        },
        gitsigns = {
          added = { enabled = true, icon = " " },
          changed = { enabled = true, icon = " " },
          deleted = { enabled = true, icon = " " },
        },
        filetype = { enabled = true, custom_colors = false },
        separator = { left = " ▎", right = "" },
        separator_at_end = false,
        modified = { button = "●" },
        pinned = { button = "", filename = true },
        preset = "default",
      },
      sidebar_filetypes = {
        ["neo-tree"] = { event = "BufWipeout" },
      },
    },
    keys = {
      { "<leader>bp", "<Cmd>BufferPin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferCloseAllButPinned<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferCloseBuffersRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferCloseBuffersLeft<CR>", desc = "Delete buffers to the left" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      vim.o.laststatus = vim.g.lualine_laststatus

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_c = {
            {
              "filename",
              file_status = true,
              newfile_status = false,
              path = 4,
              shorting_target = 40,
            },
            {
              "diagnostics",
              sources = { "nvim_diagnostic", "nvim_lsp" },
              sections = { "error", "warn", "info", "hint" },
              diagnostics_color = {
                error = "DiagnosticError",
                warn = "DiagnosticWarn",
                info = "DiagnosticInfo",
                hint = "DiagnosticHint",
              },
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
              colored = true,
              update_in_insert = false,
              always_visible = false,
            },
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
              function()
                return " "
              end,
              color = function()
                local status = require("sidekick.status").get()
                if status then
                  return status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "Special"
                end
              end,
              cond = function()
                local status = require("sidekick.status")
                return status.get() ~= nil
              end,
            },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = helpers.ui.fg("Statement"),
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = helpers.ui.fg("Constant"),
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = helpers.ui.fg("Debug"),
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = helpers.ui.fg("Special"),
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            {
              "searchcount",
              maxcount = 999,
              timeout = 500,
            },
            { "progress" },
            { "location" },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },
  {
    "coffebar/neovim-project",
    opts = {
      projects = {
        "~/Projects/*/*",
        "~/.config/*",
        "~/app/*",
        "~/.dotfiles",
        "~/.private",
      },
      last_session_on_startup = false,
      picker = {
        type = "telescope",
        preview = {
          enabled = false,
          git_status = true,
          git_fetch = false,
          show_hidden = true,
        },
      },
    },
    init = function()
      vim.opt.sessionoptions:append("globals")
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
      { "Shatur/neovim-session-manager" },
      { "ibhagwan/fzf-lua" },
    },
    lazy = false,
    priority = 100,
    keys = {
      { "<leader>fp", "<Cmd>NeovimProjectDiscover history<CR>", desc = "Projects" },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = [[
█████╗  ███████╗███╗   ███╗██████╗ ██████╗
██╔══██╗██╔════╝████╗ ████║██╔══██╗╚════██╗
███████║█████╗  ██╔████╔██║██████╔╝ █████╔╝
██╔══██║██╔══╝  ██║╚██╔╝██║██╔══██╗ ╚═══██╗
██║  ██║███████╗██║ ╚═╝ ██║██║  ██║██████╔╝
╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            {
              action = "Telescope find_files",
              desc = " Find file",
              icon = " ",
              key = "f",
            },
            {
              action = "ene | startinsert",
              desc = " New file",
              icon = " ",
              key = "n",
            },
            {
              action = "Telescope oldfiles",
              desc = " Recent files",
              icon = " ",
              key = "r",
            },
            {
              action = "Telescope live_grep",
              desc = " Find text",
              icon = " ",
              key = "g",
            },
            {
              action = "NeovimProjectDiscover history",
              desc = " Projects",
              icon = " ",
              key = "p",
              key_format = "  %s",
            },
            {
              action = [[ lua require("telescope.builtin")["find_files"]({ cwd = vim.fn.stdpath("config") }) ]],
              desc = " Config",
              icon = " ",
              key = "c",
            },
            {
              action = 'lua require("persistence").load()',
              desc = " Restore Session",
              icon = " ",
              key = "s",
            },
            {
              action = "Lazy",
              desc = " Lazy",
              icon = "󰒲 ",
              key = "l",
            },
            {
              action = "qa",
              desc = " Quit",
              icon = " ",
              key = "q",
            },
          },
          footer = function()
            return { "  Neovim" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
    end,
  },
}
