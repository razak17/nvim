local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable('gopls') then
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true},
    root_dir = require'lspconfig.util'.root_pattern('main.go', '.gitignore',
                                                    '.git', vim.fn.getcwd())
  }
end

