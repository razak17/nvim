local lsp = require 'lsp'

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
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
  }
end

