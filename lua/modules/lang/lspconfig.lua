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
      args = {},
      stdin = true,
      filetypes = { "lua" },
    },
    {
      exe = "yapf",
      args = {},
      stdin = true,
      filetypes = { "python" },
    },
    {
      exe = "isort",
      filetypes = { "python" },
    },
  }

  linters.setup {
    {
      exe = "luacheck",
      filetypes = { "lua" },
    },
    { exe = "flake8", filetypes = { "python" } },
  }
end
