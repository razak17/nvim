-- FIXME: UI is broken
local M = { 'razak17/cybu.nvim', event = { 'BufRead', 'BufNewFile' } }

function M.init()
  rvim.nnoremap('H', '<Plug>(CybuPrev)', 'cybu: prev')
  rvim.nnoremap('L', '<Plug>(CybuNext)', 'cybu: next')
end

function M.config()
  require('cybu').setup({
    position = {
      relative_to = 'win',
      anchor = 'topright',
    },
    style = { border = rvim.style.border.current, hide_buffer_id = true },
    exclude = {
      'neo-tree',
      'qf',
      'lspinfo',
      'alpha',
      'NvimTree',
      'DressingInput',
      'dashboard',
      'neo-tree',
      'neo-tree-popup',
      'lsp-installer',
      'TelescopePrompt',
      'harpoon',
      'packer',
      'mason.nvim',
      'help',
      'CommandTPrompt',
    },
  })
end

return M
