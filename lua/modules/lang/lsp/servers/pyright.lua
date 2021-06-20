local lsp_servers = require 'modules.lang.lsp.servers'

if vim.fn.executable('pyright') then
  require'lspconfig'.pyright.setup {
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach,
    -- settings = {python = {analysis = {typeCheckingMode = "off"}}}
  }
end

