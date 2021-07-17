local M = {}
function M.setup(capabilities)
  if vim.fn.executable(core.__elixirls_binary) then
    require'lspconfig'.elixirls.setup {
      cmd = {core.__elixirls_root_path .. ".bin/language_server.sh"},
      elixirls = {dialyzerEnabled = false},
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
    }
  end
end

return M
