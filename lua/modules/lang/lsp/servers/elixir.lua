local G = require 'core.globals'
local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable(G.elixirls_binary) then
  require'lspconfig'.elixirls.setup {
    cmd = {G.elixirls_root_path .. ".bin/language_server.sh"},
    elixirls = {dialyzerEnabled = false},
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end
