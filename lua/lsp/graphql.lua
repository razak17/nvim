local M = {}

M.init = function()
  if rvim.check_lsp_client_active "graphql" then
    return
  end
  require'lspconfig'.graphql.setup {
    cmd = {rvim.lang.lsp.binary.graphql, "server", "-m", "stream"},
    capabilities = rvim.lang.lsp.capabilities,
    on_attach = rvim.lang.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.graphqlrc', '.gitignore', '.git',
      vim.fn.getcwd()),
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

