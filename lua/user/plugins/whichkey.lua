return {
  'folke/which-key.nvim',
  init = function()
    local which_key = require('which-key')

    which_key.setup({
      plugins = {
        spelling = { enabled = true },
      },
      icons = { breadcrumb = rvim.ui.icons.misc.double_chevron_right },
      window = { border = rvim.ui.current.border },
      layout = { align = 'center' },
      hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
      show_help = true,
    })

    which_key.register({
      [']'] = {
        name = 'next',
        ['<space>'] = 'add space below',
      },
      ['['] = {
        name = 'prev',
        ['<space>'] = 'add space above',
      },
      ['<leader>'] = {
        a = { name = 'A.I.' },
        d = { name = 'Debugprint' },
        f = { name = 'Telescope' },
        fg = { name = 'Git' },
        fv = { name = 'Vim' },
        g = { name = 'Git' },
        h = { name = 'Gitsigns' },
        i = { name = 'Toggler' },
        l = { name = 'Lsp' },
        lt = { name = 'Toggle' },
        m = { name = 'Marks' },
        n = { name = 'Notify' },
        o = { name = 'Toggle' },
        r = { name = 'Run' },
        s = { name = 'Session' },
        t = { name = 'Test' },
        w = { name = 'Winbar' },
      },
      ['<localleader>'] = {
        c = { name = 'Conceal' },
        d = { name = 'Dap' },
        db = { name = 'Breakpoint' },
        g = { name = 'Git' },
        h = { name = 'Harpoon' },
        l = { name = 'Lsp' },
        n = { name = 'Neorg' },
        o = { name = 'Obsidian' },
        r = { name = 'Rest' },
        z = { name = 'Zen' },
      },
    })

    which_key.register({
      l = 'lsp',
    }, { mode = 'x', prefix = '<leader>' })

    which_key.register({
      g = 'git',
    }, { mode = 'x', prefix = '<localleader>' })

    rvim.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
