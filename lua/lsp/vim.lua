local M = {}

M.init = function()
  require'lspconfig'.vimls.setup {
    cmd = {core.lsp.binary.vim, "--stdio"},
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
  require("lint").linters_by_ft = {vim = {"vint"}}
end

return M

