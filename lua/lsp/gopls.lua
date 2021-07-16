local lsp = require 'lsp'

if vim.fn.executable('gopls') then
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true},
    root_dir = require'lspconfig.util'.root_pattern('main.go', '.gitignore',
                                                    '.git', vim.fn.getcwd())
  }
end

