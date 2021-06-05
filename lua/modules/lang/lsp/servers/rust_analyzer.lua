local lsp_servers = require 'modules.lang.lsp.servers'

if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end

