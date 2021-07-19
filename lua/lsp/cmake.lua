local M = {}

M.format = function()
  -- TODO: implement formatters (if applicable)
  return "No formatters configured!"
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

M.init = function()
  require("lspconfig").cmake.setup {
    cmd = {core.lsp.binary.cmake},
    filetypes = {"cmake"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.dap = function()
  -- TODO: implement dap
  return "No DAP configured!"
end

return M
