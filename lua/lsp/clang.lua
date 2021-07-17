local M = {}
function M.setup(capabilities)
  if vim.fn.executable("clangd") then
    require'lspconfig'.clangd.setup {
      cmd = {
        'clangd',
        "--background-index",
        '--clang-tidy',
        '--completion-style=bundled',
        '--header-insertion=iwyu',
        '--suggest-missing-includes',
        '--cross-file-rename',
      },
      init_options = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticHighlighting = true,
      },
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
    }
  end
end

return M
