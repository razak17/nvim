if vim.fn.executable("typescript-language-server") then
  require'lspconfig'.tsserver.setup {
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      require'modules.lsp.servers'.enhance_attach(client, bufnr)
    end,
    root_dir = require'lspconfig.util'.root_pattern('tsconfig.json',
                                                    'package.json', '.git',
                                                    vim.fn.getcwd())
  }
end
