local M = {}
function M.setup(capabilities)
  if vim.fn.executable("pyright-langserver") then
    require'lspconfig'.pyright.setup {
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
      settings = {python = {analysis = {typeCheckingMode = "off"}}},
    }
  end
end

return M

