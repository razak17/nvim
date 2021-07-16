local lsp = require 'lsp'

if vim.fn.executable(core.__elixirls_binary) then
  require'lspconfig'.elixirls.setup {
    cmd = {core.__elixirls_root_path .. ".bin/language_server.sh"},
    elixirls = {dialyzerEnabled = false},
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
  }
end
