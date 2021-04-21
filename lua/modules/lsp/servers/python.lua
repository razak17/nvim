if vim.fn.executable("pyright") then
  require'lspconfig'.pyright.setup {
    on_attach = require'modules.lsp.servers'.enhance_attach,
    root_dir = require'lspconfig.util'.root_pattern('.git', vim.fn.getcwd()),
    capabilities = require'modules.lsp.servers'.capabilities
  }
end

