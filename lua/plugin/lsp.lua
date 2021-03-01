vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    update_in_insert = true,
    virtual_text = {
      spacing = 4,
      -- prefix = '',
    },
    signs = true,
  }
)
require('lsp.conf').setup()

