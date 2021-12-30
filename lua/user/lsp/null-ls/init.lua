local M = {}

local Log = require "user.core.log"

function M:setup()
  local status_ok, null_ls = rvim.safe_require "null-ls"
  if not status_ok then
    Log:error "Missing null-ls dependency"
    return
  end

  local default_opts = require("user.lsp").get_global_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, rvim.lsp.null_ls.setup))
end

return M
