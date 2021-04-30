local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end

