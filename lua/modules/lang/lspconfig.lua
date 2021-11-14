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
  }

  linters.setup {
    {
      exe = "luacheck",
      filetypes = { "lua" },
    },
  }
end
