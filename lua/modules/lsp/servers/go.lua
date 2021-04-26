if vim.fn.executable('gopls') then
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    on_attach = require'modules.lsp.servers'.enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true}
  }
end

