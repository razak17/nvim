local lsp_servers = require 'modules.lang.lsp.servers'

if vim.fn.executable(r17.__elixirls_binary) then
  require'lspconfig'.elixirls.setup {
    cmd = {r17.__elixirls_root_path .. ".bin/language_server.sh"},
    elixirls = {dialyzerEnabled = false},
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach,
  }
end
