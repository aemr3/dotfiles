return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-dap-python",
    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  ft = "python",
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>" },
  },
  config = function()
    local original_notify = vim.notify
    require("venv-selector").setup({})
    vim.schedule(function()
      if type(vim.notify) ~= "function" and type(original_notify) == "function" then
        vim.notify = original_notify
      end
    end)
  end,
}
