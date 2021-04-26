local G = require 'core.global'

if vim.fn.executable(G.elixirls_binary) then
  require'lspconfig'.elixirls.setup {
    cmd = {G.elixirls_root_path .. ".bin/language_server.sh"},
    elixirls = {dialyzerEnabled = false},
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    on_attach = require'modules.lsp.servers'.enhance_attach
  }
end
