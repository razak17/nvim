local M = {}

M.init = function()
  if rvim.check_lsp_client_active "vimls" then
    return
  end
  require'lspconfig'.vimls.setup {
    cmd = {rvim.lsp.binary.vim, "--stdio"},
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
  require("lint").linters_by_ft = {vim = {"vint"}}
end

return M

