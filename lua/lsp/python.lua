local lsp = require 'lsp'

if vim.fn.executable("pyright-langserver") then
  require'lspconfig'.pyright.setup {
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
    settings = {python = {analysis = {typeCheckingMode = "off"}}},
  }
end

