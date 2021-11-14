local M = {}

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
end

return M
