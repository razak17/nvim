if vim.fn.executable("rust-analyzer") then
  require'lspconfig'.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    on_attach = require'modules.lsp.servers'.enhance_attach
  }
end

