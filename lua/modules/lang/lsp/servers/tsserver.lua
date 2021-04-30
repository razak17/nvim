local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable("typescript-language-server") then
  require'lspconfig'.tsserver.setup {
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      lsp_servers.enhance_attach(client, bufnr)
    end,
    root_dir = require'lspconfig.util'.root_pattern('tsconfig.json',
                                                    'package.json', '.git',
                                                    vim.fn.getcwd())
  }
end
