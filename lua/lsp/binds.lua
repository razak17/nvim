local vim = vim
local M = {}
local mapk = vim.api.nvim_buf_set_keymap;

function M.setup(bufnr, opts)
  mapk(bufnr, 'n', "<leader>vpd", '<cmd>lua vim.lsp.buf.peek_definition()<CR>', opts)
  mapk(bufnr, 'n', "<leader>vsd", '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  mapk(bufnr, 'n', "<leader>vsw", '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
  mapk(bufnr, 'n', 'glD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  mapk(bufnr, 'n', 'glt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  mapk(bufnr, 'n', 'glw', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  mapk(bufnr, 'n', 'gsh', '<cmd>lua vim.lsp.buf.signature_help <CR>', opts)
  mapk(bufnr, 'n', 'grr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  mapk(bufnr, 'n', 'gca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  mapk(bufnr, 'n', 'gsd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  mapk(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  mapk(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  mapk(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  mapk(bufnr, 'n', 'grR', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- completion
  mapk(bufnr, "i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
  mapk(bufnr, "i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
  mapk(bufnr, "i", "<c-space>", [[ "\<Plug>(completion_trigger)" ]], {expr = true})
  mapk(bufnr, "i", "<c-h>", [[ "\<Plug>(completion_next_source)" ]], {expr = true})
  mapk(bufnr, "i", "<c-k>", [[ "\<Plug>(completion_prev_source)" ]], {expr = true})
end

return M
