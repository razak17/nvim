if vim.fn.executable('gopls') then
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    handlers = require'modules.lang.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lang.lsp.servers'.capabilities,
    on_attach = require'modules.lang.lsp.servers'.enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true}
  }
end

