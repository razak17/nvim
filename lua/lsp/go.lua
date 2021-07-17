local M = {}
M.setup = function(capabilities)
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    capabilities = capabilities,
    on_attach = core.lsp.on_attach,
    init_options = {usePlaceholders = true, completeUnimported = true},
    root_dir = require'lspconfig.util'.root_pattern('main.go', '.gitignore', '.git', vim.fn.getcwd()),
  }
end

return M

