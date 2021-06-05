local lsp_servers = require 'modules.lang.lsp.servers'

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
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end

