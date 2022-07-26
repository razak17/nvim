return function()
  local icons = rvim.style.icons
  local which_key = require('which-key')

  which_key.setup({
    plugins = {
      spelling = { enabled = true },
    },
    icons = { breadcrumb = icons.misc.double_chevron_right },
    window = { border = rvim.style.border.current },
    layout = { align = 'center' },
    hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' }, -- hide mapping boilerplate
    show_help = true,
  })

  which_key.register({
    ['<leader>'] = {
      a = '+Actions',
      b = '+Bufferline',
      C = 'Change',
      F = '+Fold',
      l = '+Lsp',
      L = 'rVim',
      n = 'Notify',
      p = '+Packer',
      s = 'Snip',
      r = 'Remove',
      z = 'Fold',
    },
    ['<localleader>'] = {
      d = 'Dap',
      L = 'rVim',
      w = 'Window',
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
