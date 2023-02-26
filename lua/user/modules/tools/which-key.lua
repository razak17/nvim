local icons = rvim.ui.icons

return {
  'folke/which-key.nvim',
  init = function()
    local which_key = require('which-key')

    which_key.setup({
      plugins = {
        spelling = { enabled = true },
      },
      icons = { breadcrumb = icons.misc.double_chevron_right },
      window = { border = rvim.ui.current.border },
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
        d = { name = 'Debugprint' },
        f = { name = 'Telescope' },
        fv = { name = 'Vim' },
        g = { name = 'Git' },
        h = { name = 'Gitsigns' },
        i = { name = 'Toggler' },
        l = { name = 'Lsp' },
        lt = { name = 'Toggle' },
        m = { name = 'Marks' },
        n = { name = 'Notify' },
        o = { name = 'Toggle' },
        r = { name = 'Rest' },
        s = { name = 'Session' },
        t = { name = 'Term' },
      },
      ['<localleader>'] = {
        c = { name = 'Conceal' },
        d = { name = 'Dap' },
        l = { name = 'Neogen' },
        s = { name = 'Sniprun' },
        t = { name = 'Neotest' },
        w = { name = 'Window' },
      },
    })

    which_key.register({
      l = 'lsp',
    }, { mode = 'v', prefix = '<leader>' })

    rvim.augroup('WhichKeyMode', {
      {
        event = { 'FileType' },
        pattern = { 'which_key' },
        command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
      },
    })
  end,
}
