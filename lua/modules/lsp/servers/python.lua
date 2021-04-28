if vim.fn.executable("pyright") then
  require'lspconfig'.pyright.setup {
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    on_attach = require'modules.lsp.servers'.enhance_attach,
    capabilities = require'modules.lsp.servers'.capabilities,
    root_dir = require'lspconfig.util'.root_pattern('.git', vim.fn.getcwd())
  }
end

