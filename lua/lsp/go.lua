local M = {}
function M.setup(capabilities)
  if vim.fn.executable('gopls') then
    require'lspconfig'.gopls.setup {
      cmd = {"gopls", "--remote=auto"},
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
      init_options = {usePlaceholders = true, completeUnimported = true},
      root_dir = require'lspconfig.util'.root_pattern('main.go', '.gitignore', '.git',
        vim.fn.getcwd()),
    }
  end
end

return M

