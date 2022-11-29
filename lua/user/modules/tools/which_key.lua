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
      F = { name = 'Fold' },
      g = { name = 'Git' },
      i = { name = 'Toggler' },
      l = { name = 'Lsp' },
      L = { name = 'rVim' },
      m = { name = 'Marks' },
      n = { name = 'Notify' },
      o = { name = 'Toggle' },
      p = { name = 'Packer' },
      s = { name = 'Snip' },
      t = { name = 'Term' },
    },
    ['<localleader>'] = {
      c = { name = 'Crates' },
      d = { name = 'Dap' },
      g = { name = 'Git' },
      l = { name = 'Neogen' },
      r = { name = 'Rust Tools' },
      t = { name = 'Neotest' },
      p = { name = 'Package Info' },
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
