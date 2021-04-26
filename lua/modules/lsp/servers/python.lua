if vim.fn.executable("pyright") then
  require'lspconfig'.pyright.setup {
    on_attach = require'modules.lsp.servers'.enhance_attach,
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    root_dir = require'lspconfig.util'.root_pattern('.git', vim.fn.getcwd())
  }
end

