local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable("pyright") then
  require'lspconfig'.pyright.setup {
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach,
    root_dir = require'lspconfig.util'.root_pattern('.git', vim.fn.getcwd())
  }
end

