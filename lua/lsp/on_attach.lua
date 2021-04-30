local vim = vim
local completion = require('lsp/completion')

local on_attach = function(client, bufnr)
  require('completion').on_attach(client, {
    sorting = 'alphabet',
    matching_strategy_list = {'exact', 'substring', 'fuzzy', 'all'},
    chain_complete_list = completion.chain_complete_list
    })

  local opts = { noremap=true, silent=true }

  -- Binds
  require('lsp/binds').setup(bufnr, opts)

  -- Diagnostics
  require('lsp/diagnostics').setup(bufnr, opts)

  if client.resolved_capabilities.document_formatting then
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>vf', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
      -- vim.api.nvim_command('au BufWritePost <buffer> lua vim.lsp.buf.formatting();')
  end

  if client.resolved_capabilities.document_highlight then
      vim.api.nvim_command('augroup lsp_aucmds')
      vim.api.nvim_command('au!')
      vim.api.nvim_command('au CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
      vim.api.nvim_command('au CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
      vim.api.nvim_command('augroup END')
  end
end

return on_attach
