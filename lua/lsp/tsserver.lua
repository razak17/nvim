local M = {}
function M.setup(capabilities)
  if vim.fn.executable("typescript-language-server") then
    require'lspconfig'.tsserver.setup {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        on_attach = core.lsp.on_attach
      end,
      root_dir = require'lspconfig.util'.root_pattern('tsconfig.json', 'package.json', '.git',
        vim.fn.getcwd()),
    }
  end
end

return M
