return function()
  for _, server in ipairs(rvim.lsp.servers) do
    require("lsp.manager").setup(server)
  end

  require("lsp").setup()

  local formatters = require "lsp.null-ls.formatters"
  local linters = require "lsp.null-ls.linters"

  formatters.setup {
    {
      exe = "stylua",
      stdin = true,
      filetypes = { "lua" },
    },
    {
      exe = "yapf",
      stdin = true,
      filetypes = { "python" },
    },
    {
      exe = "isort",
      filetypes = { "python" },
    },
    -- { exe = "prettier", filetypes = { "typescript", "typescriptreact" } },
  }

  linters.setup {
    {
      exe = "luacheck",
      filetypes = { "lua" },
    },
    { exe = "flake8", filetypes = { "python" } },
    -- { exe = "eslint", filetypes = { "typescript", "typescriptreact" } },
  }
end
