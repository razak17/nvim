local M = {}

M.init = function()
  require'lspconfig'.html.setup {
    cmd = {core.lsp.binary.html, "--stdio"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
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

