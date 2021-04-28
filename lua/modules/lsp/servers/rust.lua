if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = require'modules.lsp.servers'.enhance_attach
  }
end

