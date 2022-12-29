local M = { 'folke/which-key.nvim', lazy = false }

function M.config()
  local icons = rvim.style.icons
  local which_key = require('which-key')

  which_key.setup({
    plugins = {
      spelling = { enabled = true },
    },
    icons = { breadcrumb = icons.misc.double_chevron_right },
    window = { border = rvim.style.border.current },
    layout = { align = 'center' },
    hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
    show_help = true,
  })

  which_key.register({
    [']'] = {
      name = '+next',
      ['<space>'] = 'add space below',
    },
    ['['] = {
      name = '+prev',
      ['<space>'] = 'add space above',
    },
    ['<leader>'] = {
      a = { name = 'Actions' },
      b = { name = 'Buffer' },
      f = { name = 'Telescope', v = { name = 'Vim' } },
      g = { name = 'Git' },
      i = { name = 'Toggler' },
      l = { name = 'Lsp' },
      L = { name = 'rVim' },
      m = { name = 'Marks' },
      n = { name = 'Notify' },
      o = { name = 'Toggle' },
      s = { name = 'Session' },
      t = { name = 'Term' },
    },
    ['<localleader>'] = {
      d = { name = 'Dap' },
      g = { name = 'Git' },
      l = { name = 'Neogen' },
      t = { name = 'Neotest' },
      w = { name = 'Window' },
    },
  })

  rvim.augroup('WhichKeyMode', {
    {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    },
  })
end

return M
