if vim.fn.executable("pyright") then
  require'lspconfig'.pyright.setup {
    handlers = require'modules.lang.lsp.lspconfig.utils'.diagnostics,
    on_attach = require'modules.lang.lsp.servers'.enhance_attach,
    capabilities = require'modules.lang.lsp.servers'.capabilities,
    root_dir = require'lspconfig.util'.root_pattern('.git', vim.fn.getcwd())
  }
end

