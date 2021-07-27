local M = {}

M.init = function()
  if rvim.check_lsp_client_active "cmake" then
    return
  end
  require("lspconfig").cmake.setup {
    cmd = {rvim.lsp.binary.cmake},
    filetypes = {"cmake"},
    capabilities = rvim.lsp.capabilities,
    on_attach = rvim.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.format = function()
  -- TODO: implement formatters (if applicable)
  return "No formatters configured!"
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M
