local lsp = require 'lsp'

if vim.fn.executable("typescript-language-server") then
  require'lspconfig'.tsserver.setup {
    capabilities = lsp.capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      lsp.enhance_attach(client, bufnr)
    end,
    root_dir = require'lspconfig.util'.root_pattern('tsconfig.json',
      'package.json', '.git', vim.fn.getcwd()),
  }
end
