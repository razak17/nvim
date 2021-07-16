local lsp = require 'lsp'

if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach
  }
end

