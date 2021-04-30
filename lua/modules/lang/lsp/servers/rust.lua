if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    handlers = require'modules.lang.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lang.lsp.servers'.capabilities,
    on_attach = require'modules.lang.lsp.servers'.enhance_attach
  }
end

