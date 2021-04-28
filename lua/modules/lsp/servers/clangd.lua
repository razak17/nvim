if vim.fn.executable("clangd") then
  require'lspconfig'.clangd.setup {
    cmd = {
      'clangd',
      "--background-index",
      '--clang-tidy',
      '--completion-style=bundled',
      '--header-insertion=iwyu',
      '--suggest-missing-includes',
      '--cross-file-rename'
    },
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true
    },
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = require'modules.lsp.servers'.enhance_attach
  }
end

