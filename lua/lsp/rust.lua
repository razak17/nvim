local M = {}
function M.setup(capabilities)
  if vim.fn.executable("rust-analyzer") then
    require'lspconfig'.rust_analyzer.setup {
      checkOnSave = {command = "clippy"},
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
    }
  end
end

return M
