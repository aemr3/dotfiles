local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- lsp on attach
autocmd("LspAttach", {
  group = augroup("UserLspConfig", {}),
  callback = function(ev)
    local bufnr = ev.buf
    local map = function(mode, lhs, rhs, opts)
      local _opts = { noremap = true, silent = true, buffer = bufnr }
      for k, v in pairs(_opts) do
        opts[k] = v
      end
      opts["desc"] = "LSP: " .. opts["desc"]
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    local fzf_builtin = require("fzf-lua")
    map("n", "gd", fzf_builtin.lsp_definitions, { desc = "[G]oto [D]efinition" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
    map("n", "gr", fzf_builtin.lsp_references, { desc = "[G]oto [R]eferences" })
    map("n", "gI", fzf_builtin.lsp_implementations, { desc = "[G]oto [I]mplementation" })
    map("n", "<leader>D", fzf_builtin.lsp_typedefs, { desc = "Type [D]efinition" })
    map("n", "<leader>ds", fzf_builtin.lsp_document_symbols, { desc = "[D]ocument [S]ymbols" })
    map("n", "<leader>ws", fzf_builtin.lsp_live_workspace_symbols, { desc = "[W]orkspace [S]ymbols" })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame Symbol" })
    map("n", "K", vim.lsp.buf.hover, { desc = "Show Documentation" })
    map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
    map("n", "<leader>cf", function()
      require("conform").format({ lsp_fallback = true })
    end, { desc = "[C]ode [F]ormat" })
  end,
})

-- highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYankGroup", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- format prisma files
autocmd("BufWritePost", {
  pattern = "*.prisma",
  command = "!npx prisma format",
})


