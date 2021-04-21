if vim.fn.executable('gopls') then
  require'lspconfig'.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = require'modules.lsp.servers'.enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true}
  }
end

