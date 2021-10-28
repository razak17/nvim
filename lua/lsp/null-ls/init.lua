local M = {}

local formatters = require "lsp.null-ls.formatters"
local linters = require "lsp.null-ls.linters"

function M:setup()
  local status_ok, null_ls = rvim.safe_require "null-ls"
  if not status_ok then
    return
  end

  null_ls.config()
  local default_opts = require("lsp").get_global_opts()

  if vim.tbl_isempty(rvim.lsp.null_ls.setup or {}) then
    rvim.lsp.null_ls.setup = default_opts
  end

  require("lspconfig")["null-ls"].setup(rvim.lsp.null_ls.setup)
  for filetype, config in pairs(rvim.lang) do
    if not vim.tbl_isempty(config.formatters) then
      vim.tbl_map(function(c)
        c.filetypes = { filetype }
      end, config.formatters)
      formatters.setup(config.formatters)
    end
    if not vim.tbl_isempty(config.linters) then
      vim.tbl_map(function(c)
        c.filetypes = { filetype }
      end, config.formatters)
      linters.setup(config.linters)
    end
  end
end

return M
